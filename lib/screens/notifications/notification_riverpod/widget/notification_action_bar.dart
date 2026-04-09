import 'package:optmsg/common/responsive/responsive.dart';
import 'package:optmsg/constant/app_typography.dart';
import 'package:optmsg/constant/img_path.dart';
import 'package:optmsg/constant/string_constant.dart';
import 'package:optmsg/screens/notifications/notification_riverpod/notification_provider.dart';
import 'package:optmsg/screens/notifications/notification_riverpod/notification_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class NotificationActionBar extends StatelessWidget {
  final NotificationState state;
  final NotificationNotifier notifier;
  final bool hasAnySelection;

  const NotificationActionBar({
    super.key,
    required this.state,
    required this.notifier,
    required this.hasAnySelection,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
        children: [
          // Selection counter on mobile
          if (state.selectedNotificationIds.isNotEmpty &&
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
              onPressed: () => notifier.bulkDelete(),
              tooltip: 'Delete',
            ),
            // Mark as Read/Unread buttons
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
                onPressed: () => notifier.bulkMarkAsUnread(),
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
                onPressed: () => notifier.bulkMarkAsRead(),
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
                onPressed: () => notifier.handleBulkMarkAction(),
                tooltip: _computeMarkActionTitle(),
              ),
            ],
          ],
        ],
      ),
    );
  }

  String _getMarkActionIcon() {
    final selectionState = notifier.getSelectionState();
    if (selectionState == 'singleRead' || selectionState == 'allRead') {
      return svgUnread;
    }
    return svgRead;
  }

  String _computeMarkActionTitle() {
    final selectionState = notifier.getSelectionState();
    if (selectionState == 'singleRead' || selectionState == 'allRead') {
      return markUnread;
    }
    return markRead;
  }
}
