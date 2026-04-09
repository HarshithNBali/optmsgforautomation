import 'dart:async';
import 'package:optmsg/common/responsive/responsive.dart';
import 'package:optmsg/constant/app_config.dart';
import 'package:optmsg/constant/app_typography.dart';
import 'package:optmsg/constant/img_path.dart';
import 'package:optmsg/constant/string_constant.dart';
import 'package:optmsg/screens/email/draft_riverpod/draft_notifier.dart';
import 'package:optmsg/screens/compose/compose_screen.dart';
import 'package:optmsg/screens/compose/compose_riverpod/compose_state.dart';
import 'package:optmsg/services/socket_service.dart';
import 'package:optmsg/widgets/common_web_button.dart';
import 'package:optmsg/widgets/load_container/delayed_loading_overlay.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DraftReadingPaneWidget extends ConsumerStatefulWidget {
  const DraftReadingPaneWidget({super.key});

  @override
  ConsumerState<DraftReadingPaneWidget> createState() =>
      _DraftReadingPaneWidgetState();
}

class _DraftReadingPaneWidgetState
    extends ConsumerState<DraftReadingPaneWidget> {
  bool _isLoading = true;
  Timer? _loadingTimeout;
  int? _currentPageId;
  bool _isSending = false;
  String? _cachedUrl;
  int? _cachedDraftId;

  @override
  void dispose() {
    _loadingTimeout?.cancel();
    super.dispose();
  }

  void _startLoadingTimeout() {
    _loadingTimeout?.cancel();
    _loadingTimeout = Timer(const Duration(seconds: 30), () {
      if (mounted && _isLoading) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  String _buildUrl(int draftId, int pageId, String token) {
    final DateTime now = DateTime.now();
    final int offsetInMinutes = now.timeZoneOffset.inMinutes;

    return '${defaultBaseUrl}email/compose?emailId=$draftId'
        '&type=draft'
        '&pageId=$pageId'
        '&timeZone=$offsetInMinutes';
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(draftProvider);

    if (state.selectedEmailIdForReadingPane == null) {
      _loadingTimeout?.cancel();
      _currentPageId = null;
      _cachedUrl = null;
      _cachedDraftId = null;
      // Schedule state reset for next frame to avoid setState during build
      if (_isLoading) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
          }
        });
      }
      final surface = Theme.of(context).colorScheme.surface;
      return state.items.isEmpty
          ? ColoredBox(color: surface, child: const SizedBox.expand())
          : const SizedBox.shrink();
    }

    final int draftId = state.selectedEmailIdForReadingPane!;

    // Feature flag: native Flutter compose in reading pane
    if (useNativeCompose) {
      return ComposeScreen(
        key: ValueKey('native-draft-pane-$draftId'),
        params: ComposeParams(
          mode: ComposeMode.updateDraft,
          emailId: draftId,
          sourcePage: 'drafts',
        ),
        hideAppBar: true,
      );
    }

    // Generate new pageId and URL only when draft changes
    if (_cachedDraftId != draftId) {
      _currentPageId = DateTime.now().microsecondsSinceEpoch;
      _cachedDraftId = draftId;
      _cachedUrl = _buildUrl(draftId, _currentPageId!, state.token);
      // On web, cross-origin iframes prevent onLoadStop from firing,
      // so skip the loading overlay entirely (matches web_compose.dart).
      if (!kIsWeb) {
        _isLoading = true;
        _startLoadingTimeout();
      }
    }

    // Use cached URL to avoid regenerating on every build
    final String url =
        _cachedUrl ?? _buildUrl(draftId, _currentPageId!, state.token);

    return Stack(
      children: [
        Container(
          color: Theme.of(context).colorScheme.surface,
          child: InAppWebView(
            key: ValueKey('draft_reading_pane_$draftId'),
            initialUrlRequest: URLRequest(
              url: WebUri(url),
              // On web, cross-origin iframes handle auth via cookies/session;
              // sending headers breaks the iframe (matches web_compose.dart).
              headers: kIsWeb
                  ? null
                  : (state.token.isNotEmpty
                        ? {'authorization': state.token, 'tokentype': 'descope'}
                        : null),
            ),
            initialSettings: InAppWebViewSettings(
              javaScriptEnabled: true,
              domStorageEnabled: true,
              useHybridComposition: true,
              allowsInlineMediaPlayback: true,
              mediaPlaybackRequiresUserGesture: false,
              supportZoom: false,
              cacheEnabled: true,
              clearCache: false,
              cacheMode: CacheMode.LOAD_DEFAULT,
            ),
            onWebViewCreated: (controller) {
              // Controller available for future use if needed
            },
            // On web, cross-origin iframes prevent these callbacks from firing,
            // so disable them to avoid stale loading state (matches web_compose.dart).
            onLoadStart: kIsWeb
                ? null
                : (controller, url) {
                    if (mounted) {
                      setState(() {
                        _isLoading = true;
                      });
                      _startLoadingTimeout();
                    }
                  },
            onLoadStop: kIsWeb
                ? null
                : (controller, url) async {
                    _loadingTimeout?.cancel();
                    if (mounted) {
                      setState(() {
                        _isLoading = false;
                      });
                    }
                    // Blur any focused input elements to prevent keyboard from auto-opening
                    await controller.evaluateJavascript(
                      source: '''
                        if (document.activeElement) {
                          document.activeElement.blur();
                        }
                      ''',
                    );
                  },
            onReceivedError: kIsWeb
                ? null
                : (controller, request, error) {
                    _loadingTimeout?.cancel();
                    if (mounted) {
                      setState(() {
                        _isLoading = false;
                      });
                    }
                  },
            onReceivedHttpError: kIsWeb
                ? null
                : (controller, request, response) {
                    _loadingTimeout?.cancel();
                    if (mounted) {
                      setState(() {
                        _isLoading = false;
                      });
                    }
                  },
          ),
        ),
        if (!kIsWeb && _isLoading)
          DelayedLoadingOverlay(
            isLoading: true,
            child: ColoredBox(
              color: Theme.of(context).colorScheme.surface,
              child: const SizedBox.expand(),
            ),
          ),
        // Send button overlay at the top
        if (!_isLoading && _currentPageId != null && state.userData != null)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                border: Border(
                  bottom: BorderSide(
                    width: 1,
                    color: context.colors.outlineVariant,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CommonWebButton(
                    onPressed: () {
                      if (_isSending ||
                          _currentPageId == null ||
                          state.userData == null) {
                        return;
                      }

                      setState(() {
                        _isSending = true;
                      });

                      SocketService().emitEventWithAck(
                        'canSend',
                        {
                          "pageId": _currentPageId,
                          "userId": state.userData!['user']['id'],
                        },
                        ackCallback: (data) {
                          if (mounted) {
                            setState(() {
                              _isSending = false;
                            });
                            // Refresh drafts list after sending
                            final notifier = ref.read(draftProvider.notifier);
                            notifier.getAllEmails(
                              state.searchKey,
                              isRefresh: true,
                            );
                            // Clear reading pane selection so it returns to placeholder
                            notifier.setSelectedEmailIdForReadingPane(null);
                          }
                        },
                      );
                    },
                    iconAsset: svgSent,
                    iconSize: 20,
                    spacing: 8,
                    label: send,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 12.0,
                    ),
                    textStyle: AppTypography.titleMedium(context).copyWith(
                      fontWeight: FontWeight.w500,
                      color: context.colors.onPrimary,
                    ),
                    backgroundColor: _isSending
                        ? Theme.of(context).colorScheme.onSurfaceVariant
                        : context.appColors.accent,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
