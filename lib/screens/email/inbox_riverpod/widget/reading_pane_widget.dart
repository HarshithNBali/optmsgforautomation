import 'package:optmsg/common/responsive/responsive.dart';
import 'package:optmsg/constant/app_typography.dart';
import 'package:optmsg/screens/email/inbox_riverpod/widget/reading_pane_menu_overlay_widget.dart';
import 'package:optmsg/services/tags_provider.dart';
import 'package:optmsg/widgets/load_container/delayed_loading_overlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../compose/compose_screen.dart';
import '../../../compose/compose_riverpod/compose_state.dart';
import '../../../inbox/view_email.dart';
import '../../../../constant/app_config.dart';
import '../inbox_notifier.dart';

/// PC-01: Converted from ConsumerWidget to ConsumerStatefulWidget so we can
/// hold a local `_detailError` string reported by ViewEmail via callback,
/// eliminating the emailDetailProvider watch that caused a duplicate
/// email/detail API call on every email open.
class ReadingPaneWidget extends ConsumerStatefulWidget {
  const ReadingPaneWidget({super.key});

  @override
  ConsumerState<ReadingPaneWidget> createState() => _ReadingPaneWidgetState();
}

class _ReadingPaneWidgetState extends ConsumerState<ReadingPaneWidget> {
  String? _detailError;
  int _retryKey = 0;
  int? _lastEmailId;

  @override
  Widget build(BuildContext context) {
    final (
      :isLoading,
      :items,
      :selectedEmailIdForReadingPane,
      :composeInReadingPane,
      :showReadingPaneMenuOptions,
      :selectedEmailIndex,
      :readingPaneRefreshKey,
    ) = ref.watch(
      inboxProvider.select(
        (s) => (
          isLoading: s.isLoading,
          items: s.items,
          selectedEmailIdForReadingPane: s.selectedEmailIdForReadingPane,
          composeInReadingPane: s.composeInReadingPane,
          showReadingPaneMenuOptions: s.showReadingPaneMenuOptions,
          selectedEmailIndex: s.selectedEmailIndex,
          readingPaneRefreshKey: s.readingPaneRefreshKey,
        ),
      ),
    );
    final tagsListModel = ref.watch(tagsProvider.select((s) => s.tagsList));

    // Clear stale error when user selects a different email
    if (selectedEmailIdForReadingPane != _lastEmailId) {
      _lastEmailId = selectedEmailIdForReadingPane;
      _detailError = null;
      _retryKey = 0;
    }

    // Show loading indicator while data is being fetched
    if (isLoading && items.isEmpty) {
      return DelayedLoadingOverlay(
        isLoading: true,
        child: ColoredBox(
          color: Theme.of(context).colorScheme.surface,
          child: const SizedBox.expand(),
        ),
      );
    }

    // PC-01: Error state is now reported by ViewEmail via onError callback
    // instead of watching emailDetailProvider (which caused a duplicate fetch).
    if (_detailError != null && selectedEmailIdForReadingPane != null) {
      return Container(
        color: Theme.of(context).colorScheme.surface,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: context.colors.error),
              const SizedBox(height: 16),
              Text(
                _detailError!,
                textAlign: TextAlign.center,
                style: AppTypography.bodySmall(
                  context,
                ).copyWith(color: context.colors.onSurfaceVariant),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  // Clear error and bump local retry key to force ViewEmail re-create
                  setState(() {
                    _detailError = null;
                    _retryKey++;
                  });
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    // Show compose in reading pane when requested
    if (useNativeCompose && composeInReadingPane != null) {
      final params = ComposeParams(
        mode: ComposeMode.fromString(composeInReadingPane['mode'] as String?),
        emailId: composeInReadingPane['emailId'] as int?,
        toEmail: composeInReadingPane['toEmail'] as String?,
        sourcePage: 'inbox',
      );
      return ComposeScreen(
        key: ValueKey('compose-pane-${params.mode.name}-${params.emailId}'),
        params: params,
        hideAppBar: true,
      );
    }

    return RepaintBoundary(
      child: Stack(
        children: [
          selectedEmailIdForReadingPane != null
              ? ViewEmail(
                  key: ValueKey(
                    '${selectedEmailIdForReadingPane}_${readingPaneRefreshKey}_$_retryKey',
                  ),
                  emailId: selectedEmailIdForReadingPane,
                  emailType: "Inbox",
                  allTagsList: tagsListModel,
                  itemIndex: selectedEmailIndex,
                  hideAppBar: true,
                  // PC-01: ViewEmail reports errors via callback instead of provider
                  onError: (error) {
                    if (mounted) setState(() => _detailError = error);
                  },
                  onErrorCleared: () {
                    if (mounted && _detailError != null) {
                      setState(() => _detailError = null);
                    }
                  },
                  onAction: (actionData) {
                    // Handle action from ViewEmail when in reading pane mode
                    // The API call is already done by ViewEmail, just update the list
                    final emailId = actionData['emailId'] as int?;
                    final actionType = actionData['type'] as String?;

                    if (emailId != null) {
                      // For actions that move the email out of inbox (archive, trash, delete)
                      // remove it from the list
                      if (actionType == 'isArchive' ||
                          actionType == 'isTrash' ||
                          actionType == 'isDeleted') {
                        ref
                            .read(inboxProvider.notifier)
                            .removeEmailFromListById(emailId);
                      } else if (actionType == 'tagsUpdated') {
                        final tags = actionData['updatedTags'];
                        if (tags is List) {
                          ref
                              .read(inboxProvider.notifier)
                              .updateEmailTagsInList(emailId, tags.cast());
                        }
                      }
                    }
                  },
                )
              : items.isEmpty
              ? ColoredBox(
                  color: Theme.of(context).colorScheme.surface,
                  child: const SizedBox.expand(),
                )
              : const ColoredBox(color: Colors.transparent),

          // -------------------- OVERLAY ---------------------
          if (showReadingPaneMenuOptions &&
              selectedEmailIdForReadingPane != null)
            readingPaneMenuOverlayWidget(ref, context),
        ],
      ),
    );
  }
}
