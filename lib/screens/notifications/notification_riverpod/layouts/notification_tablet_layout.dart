import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:optmsg/common/responsive/responsive.dart';
import 'package:optmsg/constant/app_typography.dart';
import 'package:optmsg/constant/img_path.dart';
import 'package:optmsg/constant/string_constant.dart';
import 'package:optmsg/constant/styles.dart';
import 'package:optmsg/widgets/empty_state.dart';
import 'package:optmsg/widgets/notification_item.dart';
import '../notification_provider.dart';
import '../notification_state.dart';
import '../widget/notification_action_bar.dart';

class NotificationTabletLayout extends StatelessWidget {
  final NotificationState state;
  final NotificationNotifier notifier;
  final ScrollController scrollController;

  const NotificationTabletLayout({
    super.key,
    required this.state,
    required this.notifier,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    final isLandscape = context.isLandscape;

    // Landscape: desktop-style with action bar + checkbox header
    // Portrait: mobile-style with long-press multi-select
    if (isLandscape) {
      return _buildLandscapeLayout(context);
    } else {
      return _buildPortraitLayout(context);
    }
  }

  // ────────────────── Landscape (desktop-like) ──────────────────

  bool get _canShowToggle => kIsWeb;

  bool get _isMultiSelectActive =>
      _canShowToggle &&
      (state.showCheckboxes || state.selectedNotificationIds.isNotEmpty);

  Widget _buildLandscapeLayout(BuildContext context) {
    final hasAnySelection = state.hasSelection;

    return Column(
      children: [
        if (hasAnySelection)
          NotificationActionBar(
            state: state,
            notifier: notifier,
            hasAnySelection: hasAnySelection,
          ),
        _buildListHeader(context),
        Divider(height: 1, color: context.colors.outlineVariant),
        Expanded(
          child: state.items.isEmpty
              ? state.isLoading
                  ? const SizedBox.shrink()
                  : const Center(
                      child:
                          EmptyState(variant: EmptyStateVariant.notifications),
                    )
              : RefreshIndicator(
                  color: const Color(0XFF1C5AD6),
                  onRefresh: () =>
                      notifier.fetchNotifications(refresh: true),
                  child: ListView.builder(
                    controller: scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: state.items.length,
                    itemBuilder: (context, index) =>
                        _buildDesktopStyleItem(context, index),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildListHeader(BuildContext context) {
    final cbSize = AppStyles.checkboxSize(context);
    final iconSize = AppStyles.checkboxIconSize(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(_canShowToggle ? 8 : 16, 4, 16, 4),
      child: Row(
        children: [
          if (_canShowToggle)
            SizedBox(
              width: cbSize,
              height: cbSize,
              child: InkWell(
                borderRadius: BorderRadius.circular(AppStyles.radiusXL),
                onTap: () {
                  if (!_isMultiSelectActive) {
                    notifier.setShowCheckboxes(true);
                  } else if (state.allNotificationIdsFlag) {
                    notifier.clearSelection();
                  } else {
                    notifier.selectAllFromList();
                  }
                },
                onLongPress: _isMultiSelectActive
                    ? () {
                        notifier.setShowCheckboxes(false);
                        notifier.clearSelection();
                      }
                    : null,
                child: Center(
                  child: Icon(
                    _isMultiSelectActive
                        ? (state.allNotificationIdsFlag
                            ? Icons.check_box
                            : (state.selectedNotificationIds.isNotEmpty
                                ? Icons.indeterminate_check_box
                                : Icons.check_box_outline_blank))
                        : Icons.check_box_outline_blank,
                    color: context.colors.primary,
                    size: iconSize,
                  ),
                ),
              ),
            ),
          Text(
            notification,
            style: AppTypography.headlineMedium(context).copyWith(
              color: context.colors.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (state.selectedNotificationIds.isNotEmpty) ...[
            const SizedBox(width: 12),
            Text(
              state.allNotificationIdsFlag
                  ? 'All Selected (${state.selectedCount})'
                  : '${state.selectedCount} selected',
              style: AppTypography.labelMedium(context).copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
          ],
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildDesktopStyleItem(BuildContext context, int index) {
    final item = state.items[index];
    final isSelected = state.selectedNotificationIds.contains(item.id);
    final showCheckbox = _canShowToggle &&
        (state.showCheckboxes || state.selectedNotificationIds.isNotEmpty);

    return Slidable(
      key: Key(item.id.toString()),
      enabled: !state.hasSelection,
      startActionPane: _buildStartPane(context, index),
      endActionPane: _buildEndPane(context, index),
      child: NotificationItem(
        item: item,
        index: index,
        showCheckbox: showCheckbox,
        isSelected: isSelected,
        onCheckboxChanged: () => notifier.toggleSingleSelectByIndex(index),
        onDelete: () => notifier.deleteNotification(item.id, index),
        onToggleRead: () => notifier.toggleRead(item.id, index),
        onTap: () {
          if (kIsWeb) {
            final keys = HardwareKeyboard.instance.logicalKeysPressed;
            final isShift = keys.contains(LogicalKeyboardKey.shiftLeft) ||
                keys.contains(LogicalKeyboardKey.shiftRight);
            final isCtrl = keys.contains(LogicalKeyboardKey.controlLeft) ||
                keys.contains(LogicalKeyboardKey.controlRight) ||
                keys.contains(LogicalKeyboardKey.metaLeft) ||
                keys.contains(LogicalKeyboardKey.metaRight);

            if (isShift) {
              final anchor =
                  state.lastClickedIndex >= 0 ? state.lastClickedIndex : 0;
              notifier.selectRangeFromList(anchor, index);
              return;
            }
            if (isCtrl) {
              notifier.toggleSingleSelectByIndex(index);
              return;
            }
          }

          if (state.hasSelection) {
            notifier.toggleSingleSelectByIndex(index);
          } else if (!(item.isRead ?? false)) {
            notifier.toggleRead(item.id, index);
          }
        },
        onLongPress: showCheckbox
            ? null
            : () => notifier.toggleSelectFromList(item.id),
      ),
    );
  }

  // ────────────────── Portrait (mobile-like) ──────────────────

  bool get _isInSelectionMode => !state.longPressFlag;

  Widget _buildPortraitLayout(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: RefreshIndicator(
          color: const Color(0XFF1C5AD6),
          onRefresh: () => notifier.fetchNotifications(refresh: true),
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
                      _buildMobileStyleItem(context, index),
                ),
        ),
      ),
    );
  }

  Widget _buildMobileStyleItem(BuildContext context, int index) {
    final item = state.items[index];
    final isSelected = state.selectedNotificationIds.contains(item.id);

    return Slidable(
      key: Key(item.id.toString()),
      enabled: !_isInSelectionMode,
      startActionPane: _buildStartPane(context, index),
      endActionPane: _buildEndPane(context, index),
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

  // ────────────────── Shared swipe panes ──────────────────

  ActionPane _buildStartPane(BuildContext context, int index) {
    final item = state.items[index];
    return ActionPane(
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
    );
  }

  ActionPane _buildEndPane(BuildContext context, int index) {
    final item = state.items[index];
    return ActionPane(
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
    );
  }
}
