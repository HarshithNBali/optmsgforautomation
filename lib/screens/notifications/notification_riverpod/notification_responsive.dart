import 'package:optmsg/common/responsive/responsive.dart';
import 'package:optmsg/constant/app_typography.dart';
import 'package:optmsg/constant/img_path.dart';
import 'package:optmsg/constant/string_constant.dart';
import 'package:optmsg/screens/notifications/notification_riverpod/layouts/notification_desktop_layout.dart';
import 'package:optmsg/screens/notifications/notification_riverpod/layouts/notification_mobile_layout.dart';
import 'package:optmsg/screens/notifications/notification_riverpod/layouts/notification_tablet_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:optmsg/services/app_bar_config_state.dart';
import 'package:optmsg/widgets/shell_layout.dart';
import 'notification_provider.dart';
import 'notification_state.dart';

class NotificationResponsive extends ConsumerStatefulWidget {
  const NotificationResponsive({super.key});

  @override
  ConsumerState<NotificationResponsive> createState() =>
      _NotificationResponsiveState();
}

class _NotificationResponsiveState
    extends ConsumerState<NotificationResponsive> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _pushAppBarConfig();
        ref
            .read(notificationProvider.notifier)
            .fetchNotifications(refresh: true);
      }
    });

    // Re-push AppBar config when selection mode changes
    ref.listenManual(
      notificationProvider.select(
          (s) => (s.longPressFlag, s.selectedNotificationIds.length)),
      (_, _) {
        if (mounted) _pushAppBarConfig();
      },
    );
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final state = ref.read(notificationProvider);
      if (state.hasMore) {
        ref.read(notificationProvider.notifier).fetchNotifications();
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  NotificationState get s => ref.read(notificationProvider);
  NotificationNotifier get n => ref.read(notificationProvider.notifier);

  void _pushAppBarConfig() {
    if (!mounted) return;
    final isInSelectionMode =
        !s.longPressFlag || s.selectedNotificationIds.isNotEmpty;
    final isMobile = AppBreakpoints.isMobileLayout(context);

    if (!isInSelectionMode || !isMobile) {
      ShellLayout.of(context)?.setAppBarConfig(AppBarConfig(
        // On mobile: show "Notifications" title in appbar
        // On medium/large: empty title (list header has its own title)
        // Use space char on non-mobile to take ownership and prevent
        // route-derived title from bleeding through
        title: isMobile ? notification : ' ',
      ));
    } else {
      ShellLayout.of(context)?.setAppBarConfig(AppBarConfig(
        title: '',
        isSelectionMode: true,
        selectionLeading: _buildSelectionLeadingWidget(),
        selectionActions: _buildSelectionActionsWidgets(),
      ));
    }
  }

  Widget _buildSelectionLeadingWidget() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(width: 5),
        IconButton(
          onPressed: () => n.clearSelection(),
          icon: SvgPicture.asset(
            svgLeftArrow,
            colorFilter: ColorFilter.mode(
              Theme.of(context).appBarTheme.foregroundColor ??
                  Theme.of(context).colorScheme.onSurface,
              BlendMode.srcIn,
            ),
          ),
        ),
        IconButton(
          icon: s.allNotificationIdsFlag
              ? const Icon(Icons.check_box)
              : s.selectedNotificationIds.isNotEmpty
                  ? const Icon(Icons.indeterminate_check_box)
                  : const Icon(Icons.check_box_outline_blank),
          onPressed: _handleSelectAll,
        ),
        Text(
          s.allNotificationIdsFlag
              ? 'All Selected (${s.selectedCount})'
              : s.selectedNotificationIds.isNotEmpty
                  ? '${s.selectedCount} selected'
                  : selectAll,
          style: AppTypography.labelMedium(context).copyWith(
            color: context.colors.primary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  List<Widget> _buildSelectionActionsWidgets() {
    return [
      // Delete
      IconButton(
        onPressed: () => n.bulkDelete(),
        icon: SvgPicture.asset(
          svgDelete,
          height: 24,
          width: 24,
          colorFilter: ColorFilter.mode(
            Theme.of(context).appBarTheme.foregroundColor ??
                Theme.of(context).colorScheme.onSurface,
            BlendMode.srcIn,
          ),
        ),
      ),
      // Mark read/unread
      IconButton(
        onPressed: () => n.handleBulkMarkAction(),
        icon: SvgPicture.asset(
          _getMarkActionIconForAppBar(),
          height: 24,
          width: 24,
          colorFilter: ColorFilter.mode(
            Theme.of(context).appBarTheme.foregroundColor ??
                Theme.of(context).colorScheme.onSurface,
            BlendMode.srcIn,
          ),
        ),
      ),
    ];
  }

  String _getMarkActionIconForAppBar() {
    final selectionState = n.getSelectionState();
    if (selectionState == 'singleRead' || selectionState == 'allRead') {
      return svgUnread;
    }
    return svgRead;
  }

  void _handleSelectAll() {
    if (s.allNotificationIdsFlag) {
      n.clearSelection();
    } else {
      n.selectAllFromList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(notificationProvider);
    final notifier = ref.read(notificationProvider.notifier);
    final deviceType = AppBreakpoints.deviceType(context);

    switch (deviceType) {
      case DeviceType.mobile:
        return NotificationMobileLayout(
          state: state,
          notifier: notifier,
          scrollController: _scrollController,
        );
      case DeviceType.tablet:
        return NotificationTabletLayout(
          state: state,
          notifier: notifier,
          scrollController: _scrollController,
        );
      case DeviceType.desktop:
        return NotificationDesktopLayout(
          state: state,
          notifier: notifier,
          scrollController: _scrollController,
        );
    }
  }
}
