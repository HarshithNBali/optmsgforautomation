import 'package:optmsg/common/responsive/responsive.dart';
import 'package:optmsg/constant/app_typography.dart';
import 'package:optmsg/constant/img_path.dart';
import 'package:optmsg/constant/string_constant.dart';
import 'package:optmsg/screens/email/archive_riverpod/archive_list_notifier.dart';
import 'package:optmsg/screens/email/archive_riverpod/archive_state.dart';
import 'package:optmsg/router/app_routes.dart';
import 'package:optmsg/widgets/common_web_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ArchiveActionBar extends StatelessWidget {
  final ArchiveState state;
  final ArchiveNotifier notifier;
  final bool hasAnySelection;
  final bool hasReadingPaneSelection;
  final bool showReadingPaneActions;

  const ArchiveActionBar({
    super.key,
    required this.state,
    required this.notifier,
    required this.hasAnySelection,
    required this.hasReadingPaneSelection,
    this.showReadingPaneActions = false,
  });

  String get archivePath => AppRoutes.archive;
  String get sentPath => AppRoutes.sent;
  String get trashPath => AppRoutes.trash;

  bool get _hasListSelectionActive => state.selectedEmailIds.isNotEmpty;
  bool get _isReadingPaneSelectionOnly =>
      hasReadingPaneSelection && !_hasListSelectionActive;

  @override
  Widget build(BuildContext context) {
    final origin = hasAnySelection ? notifier.getSelectionOrigin() : 'none';

    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(bottom: BorderSide(width: 1, color: context.colors.outlineVariant)),
      ),
      child: Row(
        children: [
          // Compose button with hover effect
          _ComposeButton(notifier: notifier),
          const SizedBox(width: 16),
          if (state.selectedEmailIds.isNotEmpty &&
              AppBreakpoints.isMobileLayout(context)) ...[
            Text(
              '${state.selectedCount} selected',
              style: AppTypography.bodyMedium(context).copyWith(
                color: context.colors.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 16),
          ],
          // Action buttons when selection exists
          if (hasAnySelection && state.items.isNotEmpty) ...[
            // Reply actions for reading pane
            if (state.longPressFlag &&
                showReadingPaneActions &&
                _isReadingPaneSelectionOnly) ...[
              IconButton(
                icon: SvgPicture.asset(
                  svgReplyBtn,
                  height: 20,
                  width: 20,
                  colorFilter: ColorFilter.mode(
                    context.colors.onSurfaceVariant,
                    BlendMode.srcIn,
                  ),
                ),
                onPressed: () => notifier.handleReplyAction('reply'),
                tooltip: 'Reply',
              ),
              IconButton(
                icon: SvgPicture.asset(
                  svgReplyAllBtn,
                  height: 20,
                  width: 20,
                  colorFilter: ColorFilter.mode(
                    context.colors.onSurfaceVariant,
                    BlendMode.srcIn,
                  ),
                ),
                onPressed: () => notifier.handleReplyAction('replyAll'),
                tooltip: 'Reply All',
              ),
              IconButton(
                icon: SvgPicture.asset(
                  svgForwardBtn,
                  height: 20,
                  width: 20,
                  colorFilter: ColorFilter.mode(
                    context.colors.onSurfaceVariant,
                    BlendMode.srcIn,
                  ),
                ),
                onPressed: () => notifier.handleReplyAction('forward'),
                tooltip: 'Forward',
              ),
              IconButton(
                icon: SvgPicture.asset(
                  svgPrint,
                  height: 20,
                  width: 20,
                  colorFilter: ColorFilter.mode(
                    context.colors.onSurfaceVariant,
                    BlendMode.srcIn,
                  ),
                ),
                onPressed: () => notifier.handlePrint(),
                tooltip: 'Print',
              ),
            ],
            // Delete button
            IconButton(
              icon: SvgPicture.asset(
                svgDelete,
                height: 20,
                width: 20,
                colorFilter: ColorFilter.mode(
                  context.colors.onSurfaceVariant,
                  BlendMode.srcIn,
                ),
              ),
              onPressed: () => notifier.handleBulkDeleteAction(),
              tooltip: 'Delete',
            ),
            // Move button — opens destination picker
            IconButton(
              icon: SvgPicture.asset(
                svgFolderInput,
                height: 20,
                width: 20,
                colorFilter: ColorFilter.mode(
                  context.colors.onSurfaceVariant,
                  BlendMode.srcIn,
                ),
              ),
              onPressed: () => notifier.handleMoveAction(),
              tooltip: 'Move',
            ),
            // Archive button (for sent and trash)
            if (state.currentPath == sentPath || state.currentPath == trashPath)
              IconButton(
                icon: SvgPicture.asset(
                  svgArchive,
                  height: 20,
                  width: 20,
                  colorFilter: ColorFilter.mode(
                    context.colors.onSurfaceVariant,
                    BlendMode.srcIn,
                  ),
                ),
                onPressed: () => notifier.handleBulkArchiveAction(),
                tooltip: 'Archive',
              ),
            // Move to Inbox button (for archive and trash, not for sent-origin or mixed)
            if (state.currentPath != sentPath &&
                origin != 'mixed' &&
                origin != 'allSent')
              IconButton(
                icon: SvgPicture.asset(
                  svgInbox,
                  height: 20,
                  width: 20,
                  colorFilter: ColorFilter.mode(
                    context.colors.onSurfaceVariant,
                    BlendMode.srcIn,
                  ),
                ),
                onPressed: () => notifier.handleBulkMoveToInboxAction(),
                tooltip: 'Inbox',
              ),
            // Move to Sent button (for archive and trash, not for received-origin or mixed)
            if (state.currentPath != sentPath &&
                origin != 'mixed' &&
                origin != 'allReceived')
              IconButton(
                icon: SvgPicture.asset(
                  svgSent,
                  height: 20,
                  width: 20,
                  colorFilter: ColorFilter.mode(
                    context.colors.onSurfaceVariant,
                    BlendMode.srcIn,
                  ),
                ),
                onPressed: () => notifier.handleBulkMoveToSentAction(),
                tooltip: 'Sent',
              ),
            // Mark as Read/Unread buttons (hidden for sent-origin emails)
            if (state.currentPath != sentPath && origin != 'allSent') ...[
              if (notifier.getSelectionState() == 'mixed') ...[
                IconButton(
                  icon: SvgPicture.asset(
                    svgUnread,
                    height: 24,
                    width: 24,
                    colorFilter: ColorFilter.mode(
                      context.colors.onSurfaceVariant,
                      BlendMode.srcIn,
                    ),
                  ),
                  onPressed: () => notifier.handleBulkMarkUnreadAction(),
                  tooltip: markUnread,
                ),
                IconButton(
                  icon: SvgPicture.asset(
                    svgRead,
                    height: 24,
                    width: 24,
                    colorFilter: ColorFilter.mode(
                      context.colors.onSurfaceVariant,
                      BlendMode.srcIn,
                    ),
                  ),
                  onPressed: () => notifier.handleBulkMarkAsReadAction(),
                  tooltip: markRead,
                ),
              ] else ...[
                IconButton(
                  icon: SvgPicture.asset(
                    _getMarkActionIcon(),
                    height: 24,
                    width: 24,
                    colorFilter: ColorFilter.mode(
                      context.colors.onSurfaceVariant,
                      BlendMode.srcIn,
                    ),
                  ),
                  onPressed: () => notifier.handleBulkMarkUnreadAction(),
                  tooltip: notifier.computeMarkActionTitle(),
                ),
              ],
            ],
            // Tags button
            IconButton(
              icon: SvgPicture.asset(
                svgTags,
                height: 20,
                width: 20,
                colorFilter: ColorFilter.mode(
                  context.colors.onSurfaceVariant,
                  BlendMode.srcIn,
                ),
              ),
              onPressed: () => notifier.handleBulkTagAction(),
              tooltip: 'Tag',
            ),
            // Opt-In button (not for sent)
            if (state.currentPath != sentPath)
              IconButton(
                icon: SvgPicture.asset(
                  svgOptin,
                  height: 20,
                  width: 20,
                ),
                onPressed: () => notifier.handleBulkOptInAction(),
                tooltip: 'Opt-In',
              ),
          ],
        ],
      ),
    );
  }

  String _getMarkActionIcon() {
    final selectionState = notifier.getSelectionState();
    if (_isReadingPaneSelectionOnly && !_hasListSelectionActive) {
      return svgUnread;
    }
    if (selectionState == 'singleRead' || selectionState == 'allRead') {
      return svgUnread;
    }
    return svgRead;
  }
}

/// Animated compose button with hover effect
class _ComposeButton extends StatelessWidget {
  final ArchiveNotifier notifier;

  const _ComposeButton({required this.notifier});

  @override
  Widget build(BuildContext context) {
    return CommonWebButton(
      iconAsset: svgCompose,
      label: 'Compose',
      onPressed: () => notifier.gotoCompose(),
    );
  }
}
