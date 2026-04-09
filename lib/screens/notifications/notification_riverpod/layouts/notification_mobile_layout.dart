import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:optmsg/common/responsive/responsive.dart';
import 'package:optmsg/constant/app_typography.dart';
import 'package:optmsg/constant/img_path.dart';
import 'package:optmsg/constant/string_constant.dart';
import 'package:optmsg/widgets/empty_state.dart';
import 'package:optmsg/widgets/load_container/delayed_loading_overlay.dart';
import 'package:optmsg/widgets/notification_item.dart';
import '../notification_provider.dart';
import '../notification_state.dart';

class NotificationMobileLayout extends StatelessWidget {
  final NotificationState state;
  final NotificationNotifier notifier;
  final ScrollController scrollController;

  const NotificationMobileLayout({
    super.key,
    required this.state,
    required this.notifier,
    required this.scrollController,
  });

  bool get _isInSelectionMode => !state.longPressFlag;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DelayedLoadingOverlay(
        isLoading: state.isLoading && state.items.isEmpty,
        child: Padding(
          padding: const EdgeInsets.only(top: 10),
          child: RefreshIndicator(
            color: const Color(0XFF1C5AD6),
            onRefresh: () async {
              await notifier.fetchNotifications(refresh: true);
            },
            child: state.items.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      if (!state.isLoading)
                        const Center(
                          child: EmptyState(
                              variant: EmptyStateVariant.notifications),
                        ),
                    ],
                  )
                : ListView.builder(
                    controller: scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: state.items.length,
                    itemBuilder: (context, index) =>
                        _buildNotificationItem(context, index),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationItem(BuildContext context, int index) {
    final item = state.items[index];
    final isSelected = state.selectedNotificationIds.contains(item.id);

    return Slidable(
      key: Key(item.id.toString()),
      enabled: !_isInSelectionMode,
      startActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.25,
        children: [
          CustomSlidableAction(
            onPressed: (_) => notifier.toggleRead(item.id, index),
            backgroundColor: (item.isRead ?? false)
                ? context.appColors.statusInfoBg
                : context.appColors.statusSuccessBg,
            foregroundColor: (item.isRead ?? false)
                ? context.appColors.statusInfoText
                : context.appColors.statusSuccessText,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  (item.isRead ?? false) ? svgUnread : svgRead,
                  height: 24,
                  width: 24,
                  colorFilter: ColorFilter.mode(
                    (item.isRead ?? false)
                        ? context.appColors.statusInfoText
                        : context.appColors.statusSuccessText,
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  (item.isRead ?? false) ? 'Unread' : 'Read',
                  style: AppTypography.titleSmall(context).copyWith(
                    color: (item.isRead ?? false)
                        ? context.appColors.statusInfoText
                        : context.appColors.statusSuccessText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.25,
        children: [
          CustomSlidableAction(
            onPressed: (_) => notifier.deleteNotification(item.id, index),
            backgroundColor: context.appColors.statusErrorBg,
            foregroundColor: context.appColors.statusErrorText,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  svgTrash1,
                  height: 24,
                  width: 24,
                  colorFilter: ColorFilter.mode(
                    context.appColors.statusErrorText,
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  trash,
                  style: AppTypography.titleSmall(context).copyWith(
                    color: context.appColors.statusErrorText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      child: NotificationItem(
        item: item,
        index: index,
        showCheckbox: _isInSelectionMode,
        isSelected: isSelected,
        onCheckboxChanged: () => notifier.toggleSelectFromList(item.id),
        onDelete: () => notifier.deleteNotification(item.id, index),
        onToggleRead: () => notifier.toggleRead(item.id, index),
        onTap: () {
          if (_isInSelectionMode) {
            notifier.toggleSelectFromList(item.id);
          } else if (!(item.isRead ?? false)) {
            notifier.toggleRead(item.id, index);
          }
        },
        onLongPress: () {
          if (!_isInSelectionMode) {
            notifier.toggleSelectFromList(item.id);
          }
        },
      ),
    );
  }
}
