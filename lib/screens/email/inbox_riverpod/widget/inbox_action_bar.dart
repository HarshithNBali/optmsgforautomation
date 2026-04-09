import 'package:optmsg/common/responsive/responsive.dart';
import 'package:optmsg/constant/app_typography.dart';
import 'package:optmsg/constant/img_path.dart';
import 'package:optmsg/constant/string_constant.dart';
import 'package:optmsg/screens/email/inbox_riverpod/inbox_notifier.dart';
import 'package:optmsg/screens/email/inbox_riverpod/inbox_state.dart';
import 'package:optmsg/widgets/common_web_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class InboxActionBar extends StatelessWidget {
  final InboxState state;
  final InboxNotifier notifier;
  final bool hasAnySelection;
  final bool hasReadingPaneSelection;
  final VoidCallback onCompose;
  final Function(int, String) onReply;
  final String Function() getMarkActionIcon;
  final String Function() computeMarkActionTitle;
  final String Function() getSelectionState;
  final VoidCallback onMarkAsRead;
  final VoidCallback onMarkAsUnread;

  const InboxActionBar({
    super.key,
    required this.state,
    required this.notifier,
    required this.hasAnySelection,
    required this.hasReadingPaneSelection,
    required this.onCompose,
    required this.onReply,
    required this.getMarkActionIcon,
    required this.computeMarkActionTitle,
    required this.getSelectionState,
    required this.onMarkAsRead,
    required this.onMarkAsUnread,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(width: 1, color: context.colors.outlineVariant),
        ),
      ),
      child: Row(
        children: [
          _ComposeButton(
            notifier: notifier,
            onCompose: onCompose,
          ),
          const SizedBox(width: 16),
          // Show "# selected" counter only on small screens;
          // medium/large screens show it in the list header instead.
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
          if (hasAnySelection && state.hasEmails) ...[
            if (state.longPressFlag &&
                state.readingPaneEnabledWeb &&
                state.hasEmails)
              if (hasReadingPaneSelection) ...[
                IconButton(
                  icon: SvgPicture.asset(svgReplyBtn, height: 20, width: 20,
                    colorFilter: ColorFilter.mode(context.colors.onSurfaceVariant, BlendMode.srcIn),
                  ),
                  onPressed: () {
                    if (state.selectedEmailIdForReadingPane != null) {
                      onReply(state.selectedEmailIdForReadingPane!, 'reply');
                    }
                  },
                  tooltip: 'Reply',
                ),
                IconButton(
                  icon: SvgPicture.asset(svgReplyAllBtn, height: 20, width: 20,
                    colorFilter: ColorFilter.mode(context.colors.onSurfaceVariant, BlendMode.srcIn),
                  ),
                  onPressed: () {
                    if (state.selectedEmailIdForReadingPane != null) {
                      onReply(state.selectedEmailIdForReadingPane!, 'replyAll');
                    }
                  },
                  tooltip: 'Reply All',
                ),
                IconButton(
                  icon: SvgPicture.asset(svgForwardBtn, height: 20, width: 20,
                    colorFilter: ColorFilter.mode(context.colors.onSurfaceVariant, BlendMode.srcIn),
                  ),
                  onPressed: () {
                    if (state.selectedEmailIdForReadingPane != null) {
                      onReply(state.selectedEmailIdForReadingPane!, 'forward');
                    }
                  },
                  tooltip: 'Forward',
                ),
              ],
            IconButton(
              icon: SvgPicture.asset(
                svgArchive,
                height: 20,
                width: 20,
                colorFilter:
                    ColorFilter.mode(context.colors.onSurfaceVariant, BlendMode.srcIn),
              ),
              onPressed: notifier.handleArchive,
              tooltip: 'Archive',
            ),
            IconButton(
              icon: SvgPicture.asset(
                svgDelete,
                height: 20,
                width: 20,
                colorFilter:
                    ColorFilter.mode(context.colors.onSurfaceVariant, BlendMode.srcIn),
              ),
              onPressed: notifier.handleDelete,
              tooltip: 'Trash',
            ),
            IconButton(
              icon: SvgPicture.asset(
                svgFolderInput,
                height: 20,
                width: 20,
                colorFilter:
                    ColorFilter.mode(context.colors.onSurfaceVariant, BlendMode.srcIn),
              ),
              onPressed: notifier.handleMoveToFolderAction,
              tooltip: 'Move',
            ),
            if (getSelectionState() == 'mixed') ...[
              IconButton(
                icon: SvgPicture.asset(
                  svgUnread,
                  height: 20,
                  width: 20,
                  colorFilter:
                      ColorFilter.mode(context.colors.onSurfaceVariant, BlendMode.srcIn),
                ),
                onPressed: onMarkAsUnread,
                tooltip: markUnread,
              ),
              IconButton(
                icon: SvgPicture.asset(
                  svgRead,
                  height: 20,
                  width: 20,
                  colorFilter:
                      ColorFilter.mode(context.colors.onSurfaceVariant, BlendMode.srcIn),
                ),
                onPressed: onMarkAsRead,
                tooltip: markRead,
              ),
            ] else ...[
              IconButton(
                icon: SvgPicture.asset(
                  getMarkActionIcon(),
                  height: 20,
                  width: 20,
                  colorFilter:
                      ColorFilter.mode(context.colors.onSurfaceVariant, BlendMode.srcIn),
                ),
                onPressed: notifier.handleMarkUnread,
                tooltip: computeMarkActionTitle(),
              ),
            ],
            if (state.longPressFlag && state.readingPaneEnabledWeb)
              IconButton(
                icon: SvgPicture.asset(
                  svgPrint,
                  height: 20,
                  width: 20,
                  colorFilter:
                      ColorFilter.mode(context.colors.onSurfaceVariant, BlendMode.srcIn),
                ),
                onPressed: () {
                  hasReadingPaneSelection
                      ? notifier.handlePrint()
                      : null;
                },
                tooltip: 'Print',
              ),
            IconButton(
              icon: SvgPicture.asset(
                svgTags,
                height: 20,
                width: 20,
                colorFilter:
                    ColorFilter.mode(context.colors.onSurfaceVariant, BlendMode.srcIn),
              ),
              onPressed: () => notifier.handleTagAction(),
              tooltip: 'Tag',
            ),
            IconButton(
              icon: SvgPicture.asset(svgOptin, height: 20, width: 20),
              onPressed: () => notifier.handleBulkOptInAction(),
              tooltip: 'Opt-In',
            ),
          ],
        ],
      ),
    );
  }
}

class _ComposeButton extends StatelessWidget {
  final InboxNotifier notifier;
  final VoidCallback onCompose;

  const _ComposeButton({
    required this.notifier,
    required this.onCompose,
  });

  @override
  Widget build(BuildContext context) {
    return CommonWebButton(
      iconAsset: svgCompose,
      label: 'Compose',
      onPressed: onCompose,
      onHoverStart: () => notifier.setComposeHovered(true),
      onHoverEnd: () => notifier.setComposeHovered(false),
    );
  }
}
