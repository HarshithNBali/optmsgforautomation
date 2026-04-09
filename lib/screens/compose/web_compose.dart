import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'package:descope/descope.dart';
import 'package:optmsg/common/utilites/logger.dart';
import 'package:optmsg/services/action_biometric_guard.dart';
import 'package:optmsg/common/responsive/responsive.dart';
import 'package:optmsg/services/socket_service.dart';
import 'package:optmsg/constant/app_config.dart';
import 'package:optmsg/constant/img_path.dart';
import 'package:optmsg/constant/string_constant.dart';
import 'package:optmsg/constant/styles.dart';
import 'package:optmsg/constant/app_typography.dart';
import 'package:optmsg/model/signed_url_model.dart';

import 'package:optmsg/main.dart';
import 'package:optmsg/services/api_service.dart';
import 'package:optmsg/services/common_service.dart';
import 'package:optmsg/services/file_picker_service.dart';
import 'package:optmsg/services/storage_service.dart';
import 'package:optmsg/services/count_notifier.dart';
import 'package:optmsg/services/web_file_picker_service.dart';
import 'package:optmsg/widgets/add_email_modal.dart';
import 'package:optmsg/widgets/load_container/load_indicator.dart';
import 'package:optmsg/services/app_bar_config_state.dart';
import 'package:optmsg/widgets/shell_layout.dart';
import 'package:optmsg/widgets/common_web_button.dart';
import 'package:optmsg/router/app_routes.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:optmsg/screens/auth/auth_riverpod/auth_notifier.dart';
import 'package:optmsg/model/auth/auth_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WebCompose extends ConsumerStatefulWidget {
  final String type;
  final String? email;
  final int? emailId;
  final String? url;
  final String? token;
  final int? pageId;
  final String? sourcePage;
  const WebCompose({
    super.key,
    required this.type,
    this.emailId,
    this.url,
    this.token,
    this.pageId,
    this.email,
    this.sourcePage,
  });

  @override
  ConsumerState<WebCompose> createState() => _WebComposeState();
}

class _WebComposeState extends ConsumerState<WebCompose> {
  List<String> selectedFilePaths = [];
  int totalFileSizeInBytes = 0;
  final int maxTotalFileSizeInMB = 25;
  late List<Map<String, dynamic>> attachments;
  bool _isLoading =
      !kIsWeb; // On web, cross-origin iframe prevents onLoadStop from firing
  bool _hideInjected = false;
  double uploadProgress = 0.0;

  String token = "";
  final SecureStorageService secureStorageService = SecureStorageService();
  late Map<String, dynamic> userData;
  InAppWebViewController? _webViewController;
  bool socketInitialized = false;
  bool inProgress = false;
  int lastMessageTimestamp = 0;
  int globalCount = 0;
  StreamSubscription? _msgOptSub;
  bool _canPopNow = false;
  int _activeUploadCount =
      0; // guards against msgOptInApp firing during uploads
  Timer? _navTimer;
  bool _isDirty = false; // tracks whether user modified the draft

  /// Resolves auth headers from widget.token, Descope session, or stored token.
  Map<String, String>? get _authHeaders {
    final t =
        widget.token ??
        Descope.sessionManager.session?.sessionJwt ??
        (token.isNotEmpty ? token : null);
    if (t == null) return null;
    return {
      'authorization': t,
      'tokentype': 'descope',
      'x-opt-platform': CommonService().getPlatform(),
    };
  }

  void _pushAppBarConfig() {
    if (!mounted) return;
    final isMobileView =
        (!kIsWeb || AppBreakpoints.isMobileLayout(context)) &&
        !(!kIsWeb &&
            AppBreakpoints.isTabletLayout(context) &&
            MediaQuery.of(context).orientation == Orientation.landscape);

    ShellLayout.of(context)?.setAppBarConfig(
      AppBarConfig(
        title: isMobileView ? newMessage : '',
        onBackPressed: onCancel,
        customActions: isMobileView
            ? [
                IconButton(
                  tooltip: 'Attach file',
                  icon: const Icon(Icons.attachment_rounded),
                  onPressed: () async {
                    await closeKeyboard();
                    await fileOption();
                  },
                ),
                IconButton(
                  tooltip: 'Send',
                  icon: SvgPicture.asset(
                    svgSent,
                    colorFilter: ColorFilter.mode(
                      Theme.of(context).appBarTheme.foregroundColor ??
                          Theme.of(context).colorScheme.onSurface,
                      BlendMode.srcIn,
                    ),
                  ),
                  onPressed: inProgress || _isLoading
                      ? () {}
                      : () async {
                          await closeKeyboard();
                          if (!mounted) return;
                          setState(() {
                            _isLoading = true;
                            if (!AppBreakpoints.isDesktopLayout(context)) {
                              inProgress = true;
                            }
                          });

                          SocketService().emitEventWithAck(
                            'canSend',
                            {
                              "pageId": widget.pageId,
                              "userId": userData['user']['id'],
                            },
                            ackCallback: (data) async {
                              if (!mounted) return;
                              setState(() {
                                _isLoading = false;
                              });
                            },
                          );
                        },
                ),
              ]
            : [],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    attachments = [];
    manageComposeFlagTrue();
    _setupListeners();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _pushAppBarConfig();
    });
  }

  Future<void> manageComposeFlagTrue() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('inCompose', true);
  }

  Future<void> manageComposeFlagFalse() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('inCompose', false);
  }

  /// Check if compose form has any content (TO, subject, body, or attachments)
  /// Returns a map with hasContent flag and individual field states
  Future<Map<String, dynamic>> _checkComposeHasContent() async {
    try {
      // Check if there are attachments in the Flutter state
      bool hasAttachments =
          attachments.isNotEmpty || selectedFilePaths.isNotEmpty;

      // Query WebView for form field values
      String? toFieldValue;
      String? subjectValue;
      String? bodyValue;

      if (!kIsWeb) {
        // For native apps, query WebView directly
        final toResult = await _webViewController?.evaluateJavascript(
          source: '''
            (function() {
              var toField = document.getElementById('recipient');
              return toField ? toField.value.trim() : '';
            })();
          ''',
        );
        toFieldValue = toResult?.toString() ?? '';

        final subjectResult = await _webViewController?.evaluateJavascript(
          source: '''
            (function() {
              var subjectField = document.getElementById('subject');
              return subjectField ? subjectField.value.trim() : '';
            })();
          ''',
        );
        subjectValue = subjectResult?.toString() ?? '';

        final bodyResult = await _webViewController?.evaluateJavascript(
          source: '''
            (function() {
              var summernote = \$('#summernote11');
              if (summernote.length > 0) {
                var content = summernote.summernote('code');
                // Strip HTML tags and check for actual text content
                var temp = document.createElement('div');
                temp.innerHTML = content;
                return temp.textContent.trim() || temp.innerText.trim() || '';
              }
              return '';
            })();
          ''',
        );
        bodyValue = bodyResult?.toString() ?? '';
      } else {
        // For web, we can still try to query the iframe content
        // But due to cross-origin restrictions, this might not work
        // In that case, always allow save (server will handle validation)
        return {
          'hasContent': true,
          'hasTo': true,
          'hasSubject': true,
          'hasBody': true,
          'hasAttachments': hasAttachments,
        };
      }

      // Check if any field has content
      bool hasTo = toFieldValue.isNotEmpty;
      bool hasSubject = subjectValue.isNotEmpty;
      bool hasBody = bodyValue.isNotEmpty;

      bool hasContent = hasTo || hasSubject || hasBody || hasAttachments;

      return {
        'hasContent': hasContent,
        'hasTo': hasTo,
        'hasSubject': hasSubject,
        'hasBody': hasBody,
        'hasAttachments': hasAttachments,
      };
    } catch (e) {
      // If we can't check, allow the save (server will handle validation)
      return {
        'hasContent': true,
        'hasTo': true,
        'hasSubject': true,
        'hasBody': true,
        'hasAttachments':
            attachments.isNotEmpty || selectedFilePaths.isNotEmpty,
      };
    }
  }

  static final _webViewSettings = InAppWebViewSettings(
    javaScriptEnabled: true,
    domStorageEnabled: true,
    useHybridComposition: true,
    allowsInlineMediaPlayback: true,
    mediaPlaybackRequiresUserGesture: false,
    supportZoom: false,
    cacheEnabled: true,
    clearCache: false,
    cacheMode: CacheMode.LOAD_DEFAULT,
  );

  /// Script injected at document-start to hide the entire page (including any
  /// server-side loading spinner) until [_onComposePageLoaded] reveals it.
  /// Targets `<html>` directly since `<head>`/`<body>` may not exist yet.
  static final _hideBodyScripts = UnmodifiableListView<UserScript>([
    UserScript(
      source: "document.documentElement.style.opacity='0';",
      injectionTime: UserScriptInjectionTime.AT_DOCUMENT_START,
    ),
  ]);

  Future<void> _onComposePageLoaded(InAppWebViewController ctrl) async {
    if (mounted) setState(() => _isLoading = false);

    // Reveal the page and hide any server-side loading spinners.
    await ctrl.evaluateJavascript(
      source: '''
      (function() {
        document.documentElement.style.opacity = '1';
        document.querySelectorAll(
          '.spinner,.loader,.loading,#spinner,#loading,#loader,' +
          '[class*="spinner"],[class*="loader"],[class*="loading"],' +
          '.preloader,#preloader,.sk-spinner'
        ).forEach(function(el) { el.style.display = 'none'; });
      })();
    ''',
    );

    // Constrain quoted-email tables/images to viewport width.
    // NOTE: Do NOT override overflow or box-sizing globally — it clips
    // the autocomplete dropdown in TO/CC/BCC fields on iOS.
    await ctrl.evaluateJavascript(
      source: '''
      (function() {
        var style = document.createElement('style');
        style.textContent = [
          'table, td, th { max-width: 100% !important; width: auto !important; }',
          'img { max-width: 100% !important; height: auto !important; }',
        ].join('\\n');
        document.head.appendChild(style);
        document.querySelectorAll('table,td,th').forEach(function(el) {
          el.removeAttribute('width');
        });
        document.querySelectorAll('img').forEach(function(el) {
          el.removeAttribute('width');
          el.removeAttribute('height');
        });
      })();
    ''',
    );

    // Place cursor — poll until the target element is ready (summernote initialises async).
    if (widget.type == 'compose' || widget.type == 'forward') {
      await ctrl.evaluateJavascript(
        source: '''
        (function tryFocus(n) {
          var el = document.getElementById('recipient');
          if (el) { el.focus(); }
          else if (n > 0) { setTimeout(function(){ tryFocus(n-1); }, 150); }
        })(15);
      ''',
      );
    } else if (widget.type == 'reply' || widget.type == 'replyAll') {
      await ctrl.evaluateJavascript(
        source: '''
        (function tryFocus(n) {
          if (typeof \$ !== 'undefined' && \$('#summernote11').data('summernote')) {
            \$('#summernote11').summernote('focus');
          } else if (n > 0) {
            setTimeout(function(){ tryFocus(n-1); }, 150);
          }
        })(15);
      ''',
      );
    }

    // Listen for any user edits to mark the draft as dirty.
    await ctrl.evaluateJavascript(
      source: '''
      (function listenForChanges(n) {
        function notify() {
          if (window.flutter_inappwebview) {
            window.flutter_inappwebview.callHandler('onComposeDirty');
          }
        }
        var recipient = document.getElementById('recipient');
        var subject = document.getElementById('subject');
        if (recipient) { recipient.addEventListener('input', notify); }
        if (subject) { subject.addEventListener('input', notify); }
        if (typeof \$ !== 'undefined' && \$('#summernote11').length) {
          \$('#summernote11').on('summernote.change', notify);
        } else if (n > 0) {
          setTimeout(function(){ listenForChanges(n-1); }, 200);
        }
      })(20);
    ''',
    );
  }

  @override
  Widget build(BuildContext context) {
    // Guard: if url is null compose cannot render — redirect to inbox.
    if (widget.url == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.go(AppRoutes.inbox);
      });
      return const SizedBox.shrink();
    }

    // Check if this is a mobile view (native mobile OR web mobile view)

    final isDesktop = AppBreakpoints.isDesktopLayout(context);
    final isTablet = AppBreakpoints.isTabletLayout(context);
    final isNativeTabletLandscape =
        !kIsWeb &&
        isTablet &&
        MediaQuery.of(context).orientation == Orientation.landscape;
    final hasSidebar =
        (kIsWeb && (isDesktop || isTablet)) || isNativeTabletLandscape;
    final dividerColor = context.colors.outlineVariant;

    // Re-push AppBarConfig after build so actions stay in sync with state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _pushAppBarConfig();
    });

    // React to session expiry: release pop-lock and cancel socket subscription
    // so GoRouter can redirect to /login without interference from stale state.
    ref.listen<AuthState>(authProvider, (previous, next) {
      if (previous?.isAuthenticated == true && !next.isAuthenticated) {
        _msgOptSub?.cancel();
        _msgOptSub = null;
        _navTimer?.cancel();
        if (mounted) setState(() => _canPopNow = true);
      }
    });

    return PopScope(
      canPop: _canPopNow,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await closeKeyboard();
        await onCancel();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          top: false,
          bottom: false,
          // Unified layout: sidebar widgets are conditionally shown above,
          // but the InAppWebView always occupies the same tree position.
          // This prevents WebView destruction when hasSidebar toggles
          // (e.g., keyboard dismiss changing layout on Android).
          child: Column(
            children: [
              if (hasSidebar) ...[
                // Action bar with sent button (web tablet/desktop only)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 12.0,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    border: Border(
                      bottom: BorderSide(width: 1, color: dividerColor),
                    ),
                  ),
                  child: Row(
                    children: [
                      // Sent button
                      CommonWebButton(
                        onPressed: () async {
                          if (inProgress || _isLoading) return;
                          await closeKeyboard();
                          setState(() {
                            _isLoading = true;
                            if (!mounted) return;
                            if (!AppBreakpoints.isDesktopLayout(context)) {
                              inProgress = true;
                            }
                          });

                          SocketService().emitEventWithAck(
                            'canSend',
                            {
                              "pageId": widget.pageId,
                              "userId": userData['user']['id'],
                            },
                            ackCallback: (data) async {
                              if (!mounted) return;
                              setState(() {
                                _isLoading = false;
                              });
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
                        textStyle: AppTypography.labelLarge(
                          context,
                        ).copyWith(color: context.colors.onPrimary),
                        backgroundColor: inProgress || _isLoading
                            ? Theme.of(context).colorScheme.onSurfaceVariant
                            : context.appColors.accentButton,
                        borderRadius: const BorderRadius.all(
                          Radius.circular(8.0),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Attachment icon
                      IconButton(
                        icon: const Icon(Icons.attachment_rounded),
                        onPressed: () async {
                          await closeKeyboard();
                          await fileOption();
                        },
                        tooltip: 'Attach',
                      ),
                    ],
                  ),
                ),
                // New message header with Delete and Save buttons
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 19.0,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    border: Border(
                      bottom: BorderSide(width: 1, color: dividerColor),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        newMessage,
                        style: AppTypography.titleLarge(context).copyWith(
                          fontWeight: FontWeight.bold,
                          color: context.colors.onSurface,
                        ),
                      ),
                      Row(
                        children: [
                          // Delete button
                          InkWell(
                            onTap: () async {
                              await closeKeyboard();
                              _showDeleteConfirmationDialog();
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 4.0,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surface,
                                border: Border.all(
                                  color: dividerColor,
                                  width: 1,
                                ),
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(8.0),
                                ),
                              ),
                              child: Text(
                                'Delete',
                                style: AppTypography.labelLarge(
                                  context,
                                ).copyWith(color: context.colors.onSurface),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Save button
                          CommonWebButton(
                            onPressed: () async {
                              await closeKeyboard();
                              _showSaveConfirmationDialog();
                            },
                            iconData: Icons.save,
                            label: 'Save',
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 8.0,
                            ),
                            backgroundColor: context.appColors.accent,
                            borderRadius: const BorderRadius.all(
                              Radius.circular(8.0),
                            ),
                            textStyle: AppTypography.labelLarge(
                              context,
                            ).copyWith(color: context.colors.onPrimary),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
              // WebView content — single instance, always at same tree position
              Expanded(
                child: Stack(
                  children: [
                    InAppWebView(
                      initialSettings: _webViewSettings,
                      initialUserScripts: kIsWeb ? null : _hideBodyScripts,
                      initialUrlRequest: URLRequest(
                        url: WebUri(validateUrl(widget.url as String)),
                        headers: kIsWeb ? null : _authHeaders,
                      ),
                      onWebViewCreated: (controller) {
                        _webViewController = controller;
                        if (!kIsWeb) {
                          controller.addJavaScriptHandler(
                            handlerName: 'onComposeDirty',
                            callback: (args) {
                              if (!_isDirty && mounted) {
                                setState(() => _isDirty = true);
                              }
                            },
                          );
                        }
                      },
                      onProgressChanged: kIsWeb
                          ? null
                          : (controller, progress) {
                              if (!_hideInjected) {
                                _hideInjected = true;
                                controller.evaluateJavascript(
                                  source:
                                      "document.documentElement.style.opacity='0';",
                                );
                              }
                            },
                      onLoadStop: kIsWeb
                          ? null
                          : (controller, url) async =>
                                _onComposePageLoaded(controller),
                      onWebContentProcessDidTerminate: kIsWeb
                          ? null
                          : (controller) async {
                              // iOS killed the WKWebView content process (backgrounded too long).
                              // Reload with fresh auth headers to restore the compose page.
                              final headers = _authHeaders;
                              if (headers != null && mounted) {
                                await controller.loadUrl(
                                  urlRequest: URLRequest(
                                    url: WebUri(
                                      validateUrl(widget.url as String),
                                    ),
                                    headers: headers,
                                  ),
                                );
                              }
                            },
                    ),
                    if (_isLoading && !hasSidebar)
                      ColoredBox(
                        color: Theme.of(context).colorScheme.surface,
                        child: const SizedBox.expand(),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Show save confirmation dialog
  Future<void> _showSaveConfirmationDialog() async {
    // Check if compose has any content before showing save dialog
    final contentCheck = await _checkComposeHasContent();

    if (!contentCheck['hasContent']) {
      // No content to save - show error message
      CommonService.animatedToast(
        'Please add at least one of: recipient, subject, body, or attachment to save as draft',
        'error',
      );
      return;
    }

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        final double screenWidth = AppBreakpoints.screenWidth(context);
        final double dialogWidth = AppBreakpoints.isMobile(screenWidth)
            ? screenWidth * 0.85
            : 500;

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppStyles.radiusM),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: PointerInterceptor(
            intercepting: kIsWeb || Platform.isAndroid ? true : false,
            child: Center(
              child: Container(
                width: dialogWidth,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(AppStyles.radiusM),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(
                        context,
                      ).colorScheme.shadow.withValues(alpha: 0.26),
                      offset: const Offset(0, 10),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Do you want to save it draft?',
                      style: AppTypography.headlineMedium(context).copyWith(
                        fontWeight: FontWeight.bold,
                        color: context.colors.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: PointerInterceptor(
                            intercepting: kIsWeb || Platform.isAndroid
                                ? true
                                : false,
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  if (!mounted) return;
                                  Navigator.of(dialogContext).pop();
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14.0,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.surface,
                                    border: Border.all(
                                      color: context.colors.outlineVariant,
                                      width: 1.5,
                                    ),
                                    borderRadius: const BorderRadius.all(
                                      Radius.circular(8.0),
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'No',
                                      style: AppTypography.labelLarge(context)
                                          .copyWith(
                                            color: context.colors.onSurface,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: PointerInterceptor(
                            intercepting: kIsWeb || Platform.isAndroid
                                ? true
                                : false,
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () async {
                                  if (dialogContext.mounted) {
                                    Navigator.of(dialogContext).pop();
                                  }
                                  if (widget.type == 'updateDraft') {
                                    await sendEmail('updateDraft');
                                  } else {
                                    await sendEmail('addDraft');
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14.0,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: context.appColors.accentGradient,
                                    borderRadius: const BorderRadius.all(
                                      Radius.circular(8.0),
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Yes',
                                      style: AppTypography.labelLarge(context)
                                          .copyWith(
                                            color: context.colors.onPrimary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // Show delete confirmation dialog
  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        final double screenWidth = AppBreakpoints.screenWidth(context);
        final double dialogWidth = AppBreakpoints.isMobile(screenWidth)
            ? screenWidth * 0.85
            : 500;

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppStyles.radiusM),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: PointerInterceptor(
            intercepting: kIsWeb || Platform.isAndroid ? true : false,
            child: Center(
              child: Container(
                width: dialogWidth,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(AppStyles.radiusM),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(
                        context,
                      ).colorScheme.shadow.withValues(alpha: 0.26),
                      offset: const Offset(0, 10),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Are you sure you want to delete this draft?',
                      style: AppTypography.headlineMedium(context).copyWith(
                        fontWeight: FontWeight.bold,
                        color: context.colors.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: PointerInterceptor(
                            intercepting: kIsWeb || Platform.isAndroid
                                ? true
                                : false,
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  if (dialogContext.mounted) {
                                    Navigator.of(dialogContext).pop();
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14.0,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.surface,
                                    border: Border.all(
                                      color: context.colors.outlineVariant,
                                      width: 1.5,
                                    ),
                                    borderRadius: const BorderRadius.all(
                                      Radius.circular(8.0),
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'No',
                                      style: AppTypography.labelLarge(context)
                                          .copyWith(
                                            color: context.colors.onSurface,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: PointerInterceptor(
                            intercepting: kIsWeb || Platform.isAndroid
                                ? true
                                : false,
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () async {
                                  if (dialogContext.mounted) {
                                    Navigator.of(dialogContext).pop();
                                  }
                                  await _handleDeleteDraft(context);
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14.0,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: context.appColors.accentGradient,
                                    borderRadius: const BorderRadius.all(
                                      Radius.circular(8.0),
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Yes',
                                      style: AppTypography.labelLarge(context)
                                          .copyWith(
                                            color: context.colors.onPrimary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> fileOption() async {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        actions: <Widget>[
          if (!kIsWeb)
            PointerInterceptor(
              intercepting: kIsWeb || Platform.isAndroid ? true : false,
              child: CupertinoActionSheetAction(
                child: Text(
                  'Gallery',
                  style: AppTypography.actionSheetItem(context),
                ),
                onPressed: () async {
                  // Pop the action sheet FIRST so context stays valid
                  // while the gallery picker runs (Android lifecycle issue).
                  if (!mounted) return;
                  context.pop();
                  // Allow the dismiss animation to finish before presenting
                  // the picker — iOS drops the presentation if the previous
                  // VC is still animating away.
                  await Future.delayed(const Duration(milliseconds: 350));
                  if (!mounted) return;
                  await requestGalleryPermissionAndPickImage(
                    context,
                    _getImage,
                  );
                },
              ),
            ),
          PointerInterceptor(
            intercepting: kIsWeb || Platform.isAndroid ? true : false,
            child: CupertinoActionSheetAction(
              child: Text(
                'File',
                style: AppTypography.actionSheetItem(context),
              ),
              onPressed: () async {
                if (!kIsWeb) {
                  // Pop the action sheet FIRST so context stays valid
                  // while the file picker runs (Android lifecycle issue).
                  if (context.mounted) context.pop();
                  // Allow the dismiss animation to finish before presenting
                  // the picker — iOS drops the presentation if the previous
                  // VC is still animating away.
                  await Future.delayed(const Duration(milliseconds: 350));
                  if (!mounted) return;
                  await requestCameraPermissionAndPickImage(context, _getImage);
                } else {
                  await selectFileWeb('file');
                  if (_isLoading) {
                    setState(() {
                      _isLoading = false;
                    });
                    if (context.mounted) {
                      context.pop();
                    }
                  }
                  if (context.mounted) {
                    context.pop();
                  }
                }
              },
            ),
          ),
        ],
        cancelButton: PointerInterceptor(
          intercepting: kIsWeb || Platform.isAndroid ? true : false,
          child: CupertinoActionSheetAction(
            isDefaultAction: true,
            onPressed: () {
              if (!mounted) return;
              context.pop();
            },
            child: Text(
              cancel,
              style: AppTypography.actionSheetCancel(context),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> selectFile(String source) async {
    if (source == 'file') {
      // File picker also triggers lifecycle events on Android (separate activity).
      ActionBiometricGuard.markDeparture();
      try {
        final filePaths = await FilePickerService.pickFiles();
        if (filePaths != null && filePaths.isNotEmpty) {
          await processSelectedFiles(filePaths);
        }
      } finally {
        ActionBiometricGuard.markReturn();
      }
    } else {
      // file_picker uses the system Storage Access Framework (SAF) on Android
      // and PHPickerViewController on iOS 14+ — neither requires READ_MEDIA_*
      // or photos permissions. Call the picker directly.
      ActionBiometricGuard.markDeparture();
      try {
        final filePaths = await FilePickerService.pickImageFiles();
        if (filePaths != null && filePaths.isNotEmpty) {
          await processSelectedFiles(filePaths);
        }
      } catch (e) {
        // Error picking image
      } finally {
        ActionBiometricGuard.markReturn();
      }
    }
  }

  Future<void> requestGalleryPermissionAndPickImage(
    BuildContext context,
    Function(ImageSource) onPermissionGranted,
  ) async {
    // file_picker uses the system Storage Access Framework (SAF) picker on
    // Android and PHPickerViewController on iOS 14+ — both are permission-less
    // system UIs. No READ_MEDIA_IMAGES / READ_MEDIA_VIDEO / photos permission
    // is required or requested. Invoke the picker callback directly.
    ActionBiometricGuard.markDeparture();
    try {
      onPermissionGranted(ImageSource.gallery);
    } finally {
      ActionBiometricGuard.markReturn();
    }
  }

  /// On mobile: strips token from URL (auth sent via HTTP headers).
  /// On web: keeps token in URL because browsers cannot set custom HTTP
  /// headers on iframe src — without it the InAppWebView plugin fetches the
  /// HTML server-side and loads it as a data: URI, breaking all relative
  /// CSS/JS paths.
  String validateUrl(String url) {
    if (kIsWeb) {
      // Ensure the token IS in the URL for web.
      final uri = Uri.parse(url);
      if (uri.queryParameters.containsKey('token')) return url;
      final t =
          widget.token ??
          Descope.sessionManager.session?.sessionJwt ??
          (token.isNotEmpty ? token : null);
      if (t == null) return url;
      final params = Map<String, String>.from(uri.queryParameters)
        ..['token'] = t
        ..['tokentype'] = 'descope';
      return uri.replace(queryParameters: params).toString();
    }
    // Mobile: keep the token in the URL so that client-side JavaScript
    // (e.g. autocomplete/lookup AJAX calls in TO/CC/BCC fields) can read it.
    // The original code always kept the token in the URL.
    final uri = Uri.parse(url);
    if (uri.queryParameters.containsKey('token')) return url;
    final t =
        widget.token ??
        Descope.sessionManager.session?.sessionJwt ??
        (token.isNotEmpty ? token : null);
    if (t == null) return url;
    final params = Map<String, String>.from(uri.queryParameters)
      ..['token'] = t
      ..['tokentype'] = 'descope';
    return uri.replace(queryParameters: params).toString();
  }

  Future<void> requestCameraPermissionAndPickImage(
    BuildContext context,
    Function(ImageSource) onPermissionGranted,
  ) async {
    // File picker opens a separate activity/VC, triggering lifecycle events.
    ActionBiometricGuard.markDeparture();
    try {
      final filePaths = await FilePickerService.pickFiles();
      if (filePaths != null && filePaths.isNotEmpty) {
        await processSelectedFiles(filePaths);
      }
    } finally {
      ActionBiometricGuard.markReturn();
    }
  }

  Future<void> _getImage(ImageSource source) async {
    // Use file_picker instead of ImagePicker to preserve original filenames.
    // ImagePicker renames files to image_picker_UUID on iOS/Android.
    final filePaths = await FilePickerService.pickImageFiles();
    if (filePaths != null && filePaths.isNotEmpty) {
      await processSelectedFiles(filePaths);
    }
  }

  Future<void> selectFileWeb(String source) async {
    if (source == 'file') {
      final results = await WebFilePickerService.pickFiles();
      if (results != null && results.isNotEmpty) {
        await processSelectedFilesWeb(results);
      }
    } else {
      final results = await WebFilePickerService.pickImageFiles();
      if (results != null && results.isNotEmpty) {
        await processSelectedFilesWeb(results);
      }
    }
  }

  Future<void> processSelectedFileWeb(
    String fileName,
    Uint8List fileBytes,
  ) async {
    int fileSizeInBytes = fileBytes.length;
    int fileSizeInMB = fileSizeInBytes ~/ (1024 * 1024);

    if (fileSizeInMB > maxTotalFileSizeInMB) {
      CommonService.animatedToast('File size cannot exceed 25 MB', 'error');
      return;
    }

    if (totalFileSizeInBytes + fileSizeInBytes >
        maxTotalFileSizeInMB * 1024 * 1024) {
      CommonService.animatedToast(
        'Total files size cannot exceed 25 MB',
        'error',
      );
      return;
    }

    setState(() {
      totalFileSizeInBytes += fileSizeInBytes;
      selectedFilePaths.add(fileName);
    });

    await getSignedUrl(fileName, fileBytes: fileBytes);
  }

  Future<void> processSelectedFile(String filePath) async {
    try {
      File file = File(filePath);
      if (!await file.exists()) {
        CommonService.animatedToast(
          'Unable to access selected file. Please try again.',
          'error',
        );
        return;
      }
      int fileSizeInBytes = await file.length();
      int fileSizeInMB = fileSizeInBytes ~/ (1024 * 1024);

      if (fileSizeInMB > maxTotalFileSizeInMB) {
        CommonService.animatedToast('File size cannot exceed 25 MB', 'error');
        return;
      }

      if (totalFileSizeInBytes + fileSizeInBytes >
          maxTotalFileSizeInMB * 1024 * 1024) {
        CommonService.animatedToast(
          'Total files size cannot exceed 25 MB',
          'error',
        );
        return;
      }

      if (!mounted) return;
      setState(() {
        totalFileSizeInBytes += fileSizeInBytes;
        selectedFilePaths.add(filePath);
      });

      await getSignedUrl(file.path.split('/').last, filePath: file.path);
    } on FileSystemException catch (e) {
      debugPrint('[Compose] File access error: $e');
      CommonService.animatedToast(
        'Unable to read the selected file. Please try a different file.',
        'error',
      );
    } catch (e) {
      debugPrint('[Compose] Unexpected error processing file: $e');
      CommonService.animatedToast('Error processing file attachment', 'error');
    }
  }

  /// Process multiple selected files sequentially.
  /// Each file is validated, added to the attachment list, and uploaded.
  Future<void> processSelectedFiles(List<String> filePaths) async {
    for (final filePath in filePaths) {
      if (!mounted) return;
      await processSelectedFile(filePath);
    }
  }

  /// Process multiple selected web files sequentially.
  /// Each file is validated, added to the attachment list, and uploaded.
  Future<void> processSelectedFilesWeb(List<Map<String, dynamic>> files) async {
    for (final file in files) {
      if (!mounted) return;
      if (file['bytes'] != null && file['name'] != null) {
        await processSelectedFileWeb(file['name'], file['bytes']);
      }
    }
  }

  Future<void> getSignedUrl(
    String fileNameWithExtension, {
    String? filePath,
    Uint8List? fileBytes,
  }) async {
    try {
      Map<String, dynamic> response = await ApiService().post(
        'user/create-singed-url',
        {"location": bucketFolder + fileNameWithExtension},
      );

      SignedUrlModel signedUrlModel = SignedUrlModel.fromJson(response);
      if (signedUrlModel.success) {
        if (kIsWeb && fileBytes != null) {
          await uploadFileToSignedUrlWeb(
            signedUrlModel.data.url,
            signedUrlModel.data.fileName,
            fileBytes,
            fileNameWithExtension,
          );
        } else if (filePath != null) {
          await uploadFileToSignedUrl(
            signedUrlModel.data.url,
            signedUrlModel.data.fileName,
            filePath,
          );
        } else {
          CommonService.animatedToast("No valid file data provided", 'error');
        }
      } else {
        CommonService.animatedToast(signedUrlModel.message, 'error');
      }
    } catch (e) {
      CommonService.animatedToast(
        "Error during signed URL request: $e",
        'error',
      );
    }
  }

  dynamic uploadFileToSignedUrlWeb(
    String signedUrl,
    String fileName,
    Uint8List fileBytes,
    String fileNameWithExtension,
  ) async {
    _activeUploadCount++;
    try {
      final navContext = NavigationService.navigatorKey.currentContext;
      if (navContext != null) {
        showDialog(
          context: navContext,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return const Center(child: LoaderIndicator());
          },
        );
      }
      final fileLength = fileBytes.length;

      final request = http.Request('PUT', Uri.parse(signedUrl));
      request.headers['Content-Length'] = '$fileLength';
      request.headers['Content-Type'] = 'application/octet-stream';
      request.bodyBytes = fileBytes;

      final response = await request.send();

      if (response.statusCode == 200) {
        String fileNameWithExtentaion = fileNameWithExtension;
        String fileType = fileName.split('.').last;

        // Track successfully uploaded attachment immediately
        if (mounted) {
          setState(() {
            _isDirty = true;
            attachments.add({
              'fileName': fileNameWithExtentaion,
              'type': fileType,
              'path': fileName,
              'size': fileLength,
            });
          });
        }

        SocketService().emitEventWithAck(
          'newUpload',
          {
            "pageId": widget.pageId,
            "userId": userData['user']['id'],
            "fileName": fileNameWithExtentaion,
            "type": fileType,
            "path": fileName,
            "size": fileLength,
          },
          ackCallback: (data) async {
            // Socket acknowledged - attachment already tracked
          },
        );
        if (!mounted) return;
        context.pop();

        setState(() {
          uploadProgress = 0.0;
        });
      } else {
        if (!mounted) return;
        context.pop();

        setState(() {
          _isLoading = false;
          uploadProgress = 0.0;
        });
      }
    } catch (e) {
      if (!mounted) return;
      context.pop();

      setState(() {
        _isLoading = false;
        uploadProgress = 0.0;
      });
    } finally {
      _activeUploadCount--;
    }
  }

  dynamic uploadFileToSignedUrl(
    String signedUrl,
    String fileName,
    String filePath,
  ) async {
    _activeUploadCount++;
    try {
      final dialogContext = mounted
          ? context
          : NavigationService.navigatorKey.currentState?.context;
      if (dialogContext != null) {
        showDialog(
          context: dialogContext,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return const Center(child: LoaderIndicator());
          },
        );
      }
      final file = File(filePath);
      final fileLength = await file.length();
      final fileStream = file.openRead();

      final request = http.Request('PUT', Uri.parse(signedUrl));
      request.headers['Content-Length'] = '$fileLength';
      request.headers['Content-Type'] = 'application/octet-stream';

      List<int> bytes = [];
      await for (var data in fileStream) {
        bytes.addAll(data);
      }
      request.bodyBytes = bytes;

      final response = await request.send();

      if (response.statusCode == 200) {
        if (mounted) context.pop();
        String fileNameWithExtentaion = filePath.split('/').last;
        String fileType = fileName.split('.').last;

        // Track successfully uploaded attachment immediately
        if (mounted) {
          setState(() {
            _isDirty = true;
            attachments.add({
              'fileName': fileNameWithExtentaion,
              'type': fileType,
              'path': fileName,
              'size': fileLength,
            });
          });
        }

        SocketService().emitEventWithAck(
          'newUpload',
          {
            "pageId": widget.pageId,
            "userId": userData['user']['id'],
            "fileName": fileNameWithExtentaion,
            "type": fileType,
            "path": fileName,
            "size": fileLength,
          },
          ackCallback: (data) async {
            // Socket acknowledged - attachment already tracked
          },
        );

        if (mounted) {
          setState(() {
            _isLoading = false;
            uploadProgress = 0.0;
          });
        }
      } else {
        if (mounted) context.pop();
        if (mounted) {
          setState(() {
            _isLoading = false;
            uploadProgress = 0.0;
          });
        }
      }
    } catch (e) {
      if (mounted) context.pop();
      if (mounted) {
        setState(() {
          _isLoading = false;
          uploadProgress = 0.0;
        });
      }
    } finally {
      _activeUploadCount--;
    }
  }

  void handleDeniedPermission(BuildContext context) async {
    await showDialog(
      context: NavigationService.navigatorKey.currentState!.context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text('Permission Required'),
          content: Column(
            children: <Widget>[
              const SizedBox(height: 10),
              Text(
                'Allow access to Photos to attach images from your library and to save attachments, please grant permission in the settings.',
                style: AppTypography.bodySmall(context),
              ),
            ],
          ),
          actions: <Widget>[
            CupertinoDialogAction(
              child: Text(
                'Cancel',
                style: TextStyle(color: context.colors.primary),
              ),
              onPressed: () {
                if (!mounted) return;
                context.pop();
              },
            ),
            CupertinoDialogAction(
              child: Text(
                'Settings',
                style: TextStyle(color: context.colors.primary),
              ),
              onPressed: () async {
                if (!mounted) return;
                context.pop();
                await openAppSettings();
              },
            ),
          ],
        );
      },
    );
  }

  List<String> toEmails = [];
  List<String> ccEmails = [];
  List<String> bccEmails = [];
  final Completer<String> navigationCompleter = Completer<String>();

  Future<void> _setupListeners() async {
    try {
      await getUserData();
      if (userData['user'] == null) return;
      if (userData['user']['isFreeUser']) {
        if (!mounted) return;
        setState(() => _canPopNow = true);
        context.pop();
        CommonService.animatedToast(freeUserWarning, 'warning', null, true);
        return;
      }
      // getProviderValue(); // Removed
      _msgOptSub = SocketService().onEvent('msgOptInApp').listen((
        newMessage,
      ) async {
        printLog("msgOptInApp", newMessage);

        // Skip this event while attachment uploads are in flight — the server
        // broadcasts msgOptInApp after each newUpload, and the WebView form
        // state may be stale/empty at that moment, which would blank the draft.
        if (_activeUploadCount > 0) {
          printLog("msgOptInApp", "skipped — attachment upload in progress");
          return;
        }

        final currentTimestamp = DateTime.now().millisecondsSinceEpoch;
        if (currentTimestamp - lastMessageTimestamp <= 1000) {
          if (mounted) {
            setState(() {
              inProgress = false;
            });
          }
          return;
        }
        lastMessageTimestamp = currentTimestamp;

        if (mounted) {
          setState(() {
            toEmails = List<String>.from(newMessage['to']);
            ccEmails = List<String>.from(newMessage['cc']);
            bccEmails = List<String>.from(newMessage['bcc']);
          });
        }
        if (toEmails.isEmpty && ccEmails.isEmpty && bccEmails.isEmpty) {
          CommonService.animatedToast(
            'Please enter recipient email id',
            'error',
            null,
            true,
          );
          if (mounted) {
            setState(() {
              inProgress = false;
            });
          }
          return;
        }

        final pageId = int.tryParse(newMessage['pageId'].toString());
        final allEmails = {...toEmails, ...ccEmails, ...bccEmails}.toList();
        if (pageId == widget.pageId) {
          if (!mounted) return;
          if (!AppBreakpoints.isDesktopLayout(context) || !kIsWeb) {
            await _displayAddEmailModal(allEmails, 0);
          } else {
            // For desktop, just call the local method too, it handles the context/navigatorKey internally if needed
            // or we can invoke it on the current context since showDialog uses webNavigatorKey in _displayAddEmailModal
            await _displayAddEmailModal(allEmails, 0);
            if (!kIsWeb) {
              if (!mounted) return;
              setState(() => _canPopNow = true);
              context.pop();
            }
          }
        }
      });
    } catch (e) {
      // Socket initialization error
    }
  }

  @override
  void dispose() {
    _navTimer?.cancel();
    manageComposeFlagFalse();
    _msgOptSub?.cancel();
    super.dispose();
  }

  dynamic triggerEmail() {
    if (userData['user'] == null || userData['user']['id'] == null) {
      return;
    }
    try {
      SocketService().emitEventWithAck(
        'sendMessage',
        {"pageId": widget.pageId, "userId": userData['user']['id']},
        ackCallback: (data) async {
          if (data != null && data == 'yes' && mounted) {
            if (widget.type == 'forward' ||
                widget.type == 'replyAll' ||
                widget.type == 'reply' ||
                widget.type == 'contact') {
              CommonService.animatedToast('Email sent', 'success');
              await secureStorageService.deleteData('composeEmailData');
            } else {
              CommonService.animatedToast('Email sent', 'success', null, true);
              await secureStorageService.deleteData('composeEmailData');
            }
            setState(() {
              inProgress = false;
              _canPopNow = true;
            });
            if (mounted) {
              context.pop();
            }
          } else if (mounted) {
            setState(() {
              inProgress = false;
              _canPopNow = true;
            });
            if (!mounted) return;
            context.pop();
            CommonService.animatedToast(catchError, 'error');
          }
        },
      );
    } catch (e) {
      setState(() {
        inProgress = false;
      });
    }
  }

  List<String> globalEmails = [];
  int globalIndex = 0;

  dynamic _displayAddEmailModal(List<String> emails, int index) async {
    if (index >= emails.length) {
      return;
    }
    String email = emails[index];
    globalEmails = emails;

    try {
      Map<String, dynamic> resp = await ApiService().post(
        'contact/check-email',
        {"email": email},
      );
      if (resp['success']) {
        if (resp['data']['status']) {
          _displayAddEmailModal(emails, index + 1);
          if (index >= emails.length - 1) {
            triggerEmail();
          }
          return;
        }
        if (!mounted) return;
        final result = await showDialog(
          useRootNavigator: true,
          context: context,
          builder: (BuildContext context) {
            return AddEmailModal(
              title: addEmail,
              type: emails.length > 1 ? "Multiple" : "Single",
              subtitleFirst: email,
              subtitle: addEmailcontact,
              contact: null,
              saveFlag: () async {},
              currentIndex: index,
              totalEmails: emails.length,
            );
          },
        );

        if (result == 'skip_all') {
          // User clicked Skip All & Send - send without adding remaining contacts
          triggerEmail();
          return;
        } else if (result == 'cancel-email') {
          // User clicked X close - don't send, stay on compose page
          setState(() {
            inProgress = false;
          });
          return;
        } else if (result == 'skip') {
          // User clicked Skip - skip this contact, continue to next or send
          if (index >= emails.length - 1) {
            triggerEmail();
            return;
          }
          _displayAddEmailModal(emails, index + 1);
          return;
        } else if (result == 'existing_contact') {
          // User clicked Add to Existing - navigate to picker and await
          if (!mounted) return;
          final pickerResult = await context.push(
            AppRoutes.addExistingContact,
            extra: {'prevEmail': email, 'type': 'optin'},
          );

          if (pickerResult == 'success') {
            // Success! Proceed to next email or trigger send
            if (index >= emails.length - 1) {
              triggerEmail();
              return;
            }
            _displayAddEmailModal(emails, index + 1);
          } else {
            // Picker cancelled or failed
            setState(() {
              inProgress = false;
            });
          }
          return;
        } else {
          // User saved contact - continue to next or send
          if (index >= emails.length - 1) {
            triggerEmail();
            return;
          }
          _displayAddEmailModal(emails, index + 1);
        }
      } else {
        CommonService.animatedToast(resp['message'], 'error');
        setState(() {
          inProgress = false;
        });
      }
    } catch (error) {
      setState(() {
        inProgress = false;
      });
      if (error is! NoInternetException) {
        CommonService.animatedToast(
          'Error checking email',
          'error',
          null,
          true,
        );
      }
    }
  }

  Future<void> getUserData() async {
    final storedData = ref.read(authProvider).userData;
    if (storedData == null ||
        storedData['user'] == null ||
        storedData['user']['id'] == null) {
      return;
    }

    if (!mounted) return;
    setState(() {
      userData = storedData;
      token = (storedData['user']['token'] ?? '').toString();
    });
    await secureStorageService.writeObjectData('composeEmailData', {
      'pageId': widget.pageId.toString(),
      'userId': userData['user']['id'],
      'type': widget.type,
    });
  }

  dynamic onCancel() async {
    final widgetContext = context;

    final contentCheck = await _checkComposeHasContent();
    if (contentCheck['hasContent'] == false) {
      if (!mounted) return;
      setState(() => _canPopNow = true);
      context.pop();
      return;
    }

    showCupertinoModalPopup(
      context: widgetContext,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (BuildContext popupContext) => CupertinoActionSheet(
        actions: <Widget>[
          PointerInterceptor(
            intercepting: kIsWeb || Platform.isAndroid ? true : false,
            child: CupertinoActionSheetAction(
              child: Text(
                deleteDraft,
                style: AppTypography.actionSheetDelete(context),
              ),
              onPressed: () async {
                Navigator.of(popupContext).pop();
                await _handleDeleteDraft(widgetContext);
              },
            ),
          ),
          PointerInterceptor(
            intercepting: kIsWeb || Platform.isAndroid ? true : false,
            child: CupertinoActionSheetAction(
              child: Text(
                saveDraft,
                style: AppTypography.actionSheetItem(context),
              ),
              onPressed: () async {
                Navigator.of(popupContext).pop();
                await _handleSaveDraft();
              },
            ),
          ),
        ],
        cancelButton: PointerInterceptor(
          intercepting: kIsWeb || Platform.isAndroid ? true : false,
          child: CupertinoActionSheetAction(
            isDefaultAction: true,
            onPressed: () {
              Navigator.of(popupContext).pop();
            },
            child: Text(
              cancel,
              style: AppTypography.actionSheetCancel(context),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleSaveDraft() async {
    // If this is an existing draft and the user made no changes, skip the
    // server round-trip and navigate back immediately.
    if (widget.type == 'updateDraft' && !_isDirty) {
      CommonService.animatedToast(draftSaved, 'success', null, true);
      if (!mounted) return;
      setState(() => _canPopNow = true);
      context.pop();
      return;
    }

    if (widget.type == 'updateDraft') {
      await sendEmail('updateDraft');
    } else {
      await sendEmail('addDraft');
    }
  }

  Future<void> _handleDeleteDraft(BuildContext widgetContext) async {
    if (!mounted) return;

    if (widget.type == 'updateDraft') {
      // Delete the existing draft
      List<dynamic> id = [];
      id.add(widget.emailId);

      final success = await deleteDrafts(id);

      if (!mounted) return;

      // Only navigate away on successful deletion
      if (success) {
        setState(() {
          _canPopNow = true;
        });
        context.pop('draftDeleted');
      }
    } else {
      // Not an existing draft, just show message and navigate back
      if (widget.type == 'forward' ||
          widget.type == 'replyAll' ||
          widget.type == 'reply') {
        CommonService.animatedToast('Message Deleted', 'success');
      } else {
        CommonService.animatedToast('Message Deleted', 'success', null, true);
      }

      if (!mounted) return;
      setState(() {
        _canPopNow = true;
      });
      context.pop('draftDeleted');
    }
  }

  dynamic closeKeyboard() async {
    if (!kIsWeb) {
      FocusScope.of(context).unfocus();
      await _webViewController?.evaluateJavascript(
        source: "document.activeElement.blur();",
      );
    }
  }

  Future<void> sendEmail(String action) async {
    final userId = userData['user'] != null ? userData['user']['id'] : null;

    if (userId == null) {
      CommonService.animatedToast(
        'Unable to save draft - user not found',
        'error',
      );
      return;
    }

    // Build the payload for socket event
    Map<String, dynamic> payload = {"pageId": widget.pageId, "userId": userId};

    // For updateDraft, include the emailId
    if (action == 'updateDraft' && widget.emailId != null) {
      payload["id"] = widget.emailId;
    }
    final targetRoute = widget.sourcePage ?? AppRoutes.inbox;
    printLog("targetRoute", targetRoute);
    // Emit the socket event to save/update draft
    SocketService().emitEventWithAck(
      'addUpdateDraft',
      payload,
      ackCallback: (data) async {
        _navTimer = Timer(const Duration(milliseconds: 500), () {
          safeNavigateBack();
        });
      },
    );

    SocketService().emitEventWithAck(
      'unReadCount',
      {"userId": userId},
      ackCallback: (data) {
        if (data != null && mounted) {
          ref
              .read(countProvider.notifier)
              .updateCounts(
                inbox: data['inboxCount'] ?? 0,
                draft: data['draftCount'] ?? 0,
                trash: data['trashCount'] ?? 0,
                archive: data['archiveCount'] ?? 0,
              );
        }
      },
    );
  }

  void navigateBack() {
    if (!mounted) return;

    // Show success toast
    if (widget.type == 'forward' ||
        widget.type == 'replyAll' ||
        widget.type == 'reply') {
      CommonService.animatedToast(draftSaved, 'success');
    } else {
      CommonService.animatedToast(draftSaved, 'success', null, true);
    }
    //printLog("sourcePage", widget.sourcePage);
    if (!mounted) return;
    //context.go(AppRoutes.drafts);
    setState(() {
      _canPopNow = true;
    });
    context.pop('draftSaved');
  }

  // Track if navigation has occurred to prevent double navigation
  bool hasNavigated = false;

  void safeNavigateBack() {
    if (!hasNavigated) {
      hasNavigated = true;
      navigateBack();
    }
  }

  Future<bool> deleteDrafts(List ids) async {
    bool success = false;
    try {
      Map<String, dynamic> resp = await ApiService().post(
        'email/delete-drafts',
        {"draftIds": ids},
      );
      if (resp['success']) {
        CommonService.animatedToast(resp['message'], 'success', null, true);
        success = true;
      } else {
        if (mounted) {
          CommonService.animatedToast(resp['message'], 'error');
        }
      }
    } catch (error) {
      if (mounted) {
        if (error is! NoInternetException) {
          CommonService.animatedToast('Failed to delete draft', 'error');
        }
      }
    }

    // Update counts after deletion
    if (success && kIsWeb && mounted) {
      SocketService().emitEventWithAck(
        'unReadCount',
        {"userId": userData['user']['id']},
        ackCallback: (data) {
          if (data != null && mounted) {
            ref
                .read(countProvider.notifier)
                .updateCounts(
                  inbox: data['inboxCount'] ?? 0,
                  draft: data['draftCount'] ?? 0,
                  trash: data['trashCount'] ?? 0,
                  archive: data['archiveCount'] ?? 0,
                );
          }
        },
      );
    }
    return success;
  }
}
