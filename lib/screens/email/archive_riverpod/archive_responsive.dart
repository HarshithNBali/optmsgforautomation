import 'package:optmsg/common/responsive/responsive.dart';
import 'package:optmsg/constant/img_path.dart';
import 'package:optmsg/constant/string_constant.dart';
import 'package:optmsg/constant/app_typography.dart';
import 'package:optmsg/screens/email/archive_riverpod/archive_list_notifier.dart';
import 'package:optmsg/screens/email/archive_riverpod/archive_state.dart';
import 'package:optmsg/screens/email/archive_riverpod/layouts/archive_desktop_layout.dart';
import 'package:optmsg/screens/email/archive_riverpod/layouts/archive_mobile_layout.dart';
import 'package:optmsg/screens/email/archive_riverpod/layouts/archive_tablet_layout.dart';
import 'package:optmsg/widgets/load_container/delayed_loading_overlay.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:optmsg/widgets/standard_fab.dart';

import '../../../router/app_routes.dart';
import 'package:optmsg/services/app_bar_config_state.dart';
import 'package:optmsg/widgets/shell_layout.dart';

/// Main responsive archive widget that automatically adapts to screen size
class ArchiveResponsive extends ConsumerStatefulWidget {
  final VoidCallback? onLongPress;
  final String? parentRoute;
  final bool? isSideMenuCollapsed;
  final VoidCallback? onToggleSideMenu;

  final int? selectedEmailId;

  const ArchiveResponsive({
    super.key,
    this.onLongPress,
    this.parentRoute,
    this.isSideMenuCollapsed,
    this.onToggleSideMenu,
    this.selectedEmailId,
  });

  @override
  ConsumerState<ArchiveResponsive> createState() => ArchiveResponsiveState();
}

class ArchiveResponsiveState extends ConsumerState<ArchiveResponsive>
    with WidgetsBindingObserver {
  final _focusNode = FocusNode();
  final _searchController = TextEditingController();
  bool _wasNavigatedAway = false;
  DeviceType? _lastDeviceType;
  double? _lastScreenWidth;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Always clear overlay states when page is initialized
    Future.microtask(() {
      ref.read(archiveProvider.notifier).clearOverlayStates();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(archiveProvider.notifier)
          .resolveInitialRouteAndLoad(
            widget.parentRoute,
            emailIdToRestore: widget.selectedEmailId,
          );

      // Initialize device type tracking
      if (mounted) {
        _lastDeviceType = AppBreakpoints.deviceType(context);
        _lastScreenWidth = AppBreakpoints.screenWidth(context);
      }
    });
    // Push AppBar config once on mount
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final state = ref.read(archiveProvider);
        final notifier = ref.read(archiveProvider.notifier);
        _pushAppBarConfig(state, notifier);
      }
    });
    // Re-push AppBar config when selection mode changes
    ref.listenManual(
      archiveProvider.select(
        (s) => (s.longPressFlag, s.selectedEmailIds.length),
      ),
      (_, _) {
        if (mounted) {
          final state = ref.read(archiveProvider);
          final notifier = ref.read(archiveProvider.notifier);
          _pushAppBarConfig(state, notifier);
        }
      },
    );
    // Re-push AppBar config when filter/overlay state changes so the mobile
    // filter icon updates and onBackPressed stays in sync with overlay state.
    ref.listenManual(
      archiveProvider.select(
        (s) => (
          s.emailType,
          s.tagFilter,
          s.showFilter,
          s.showTagList,
          s.showMenuOptions,
          s.showMoveOverlay,
        ),
      ),
      (_, _) {
        if (mounted) {
          final state = ref.read(archiveProvider);
          final notifier = ref.read(archiveProvider.notifier);
          _pushAppBarConfig(state, notifier);
        }
      },
    );
  }

  /* void updateEmailList() {
    SocketService().onEvent('newMessage').listen((data) {
      _archiveNotifier.refresh();
    });
    SocketService().onEvent('trashMessage').listen((data) {
      printLog('trashMessage', data);
      _archiveNotifier.refresh();
    });
    SocketService().on('unReadCount', (response) {
      _archiveNotifier.refresh();
    });
    SocketService().onEvent('notificationExists').listen((data) {
      _archiveNotifier.updateNotificationFlag(data);
    });
  } */

  @override
  void dispose() {
    // Clear overlay states when leaving the page
    WidgetsBinding.instance.removeObserver(this);
    _focusNode.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(ArchiveResponsive oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If selectedEmailId changed (e.g. via URL navigation), update the selection in notifier
    // without doing a full resolveInitialRouteAndLoad of the entire list.
    if (widget.selectedEmailId != oldWidget.selectedEmailId &&
        widget.selectedEmailId != null) {
      final emailId = widget.selectedEmailId!;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ref
              .read(archiveProvider.notifier)
              .setReadingPaneSelection(emailId, null, null);
        }
      });
    }
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    // Detect screen size changes and handle layout updates
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        // Don't reload if a dialog is open
        final route = ModalRoute.of(context);
        if (route != null && !route.isCurrent) {
          return;
        }

        final currentDeviceType = AppBreakpoints.deviceType(context);
        final currentScreenWidth = AppBreakpoints.screenWidth(context);

        final deviceTypeChanged =
            _lastDeviceType != null && _lastDeviceType != currentDeviceType;

        // Handle device type changes (mobile <-> tablet <-> desktop)
        if (deviceTypeChanged) {
          final previousDeviceType = _lastDeviceType;
          _lastDeviceType = currentDeviceType;
          _lastScreenWidth = currentScreenWidth;

          // Preserve reading pane selection when changing device types
          final currentSelection = ref
              .read(archiveProvider)
              .selectedEmailIdForReadingPane;
          final currentIndex = ref.read(archiveProvider).selectedEmailIndex;
          final currentSender = ref.read(archiveProvider).selectedEmailSender;

          // Clear overlays but DON'T clear reading pane selection
          ref.read(archiveProvider.notifier).clearOverlayStates();

          // When going from mobile to tablet/desktop, restore reading pane selection
          if (previousDeviceType == DeviceType.mobile &&
              (currentDeviceType == DeviceType.tablet ||
                  currentDeviceType == DeviceType.desktop)) {
            if (currentSelection != null) {
              ref
                  .read(archiveProvider.notifier)
                  .setReadingPaneSelection(
                    currentSelection,
                    currentIndex,
                    currentSender,
                  );
            }
          }

          setState(() {});
        } else {
          // For window resize within same device type, just trigger a rebuild
          final screenSizeChanged =
              _lastScreenWidth != null &&
              (_lastScreenWidth! - currentScreenWidth).abs() > 50;

          if (screenSizeChanged) {
            _lastScreenWidth = currentScreenWidth;
            ref.read(archiveProvider.notifier).clearOverlayStates();
            setState(() {});
          } else {
            _lastDeviceType = currentDeviceType;
            _lastScreenWidth = currentScreenWidth;
          }
        }
      }
    });
  }

  /// Public method to refresh the archive
  Future<void> refresh() async {
    await ref.read(archiveProvider.notifier).refresh();
  }

  /// Push the correct AppBarConfig for the current state.
  void _pushAppBarConfig(ArchiveState state, ArchiveNotifier notifier) {
    if (!mounted) return;
    final isInSelectionMode =
        !state.longPressFlag || state.selectedEmailIds.isNotEmpty;
    final isMobile = AppBreakpoints.isMobileLayout(context);

    if (!isInSelectionMode || !isMobile) {
      // Normal mode or desktop/tablet — no selection AppBar
      ShellLayout.of(context)?.setAppBarConfig(
        AppBarConfig(
          showSearch: true,
          onSearch: (value) => notifier.onSearchChanged(value),
          filterWidget: _buildFilterWidget(state, notifier),
        ),
      );
    } else {
      // Selection mode — mobile only
      ShellLayout.of(context)?.setAppBarConfig(
        AppBarConfig(
          title: '',
          isSelectionMode: true,
          selectionLeading: _buildSelectionLeadingWidget(state, notifier),
          selectionActions: _buildSelectionActionsWidgets(state, notifier),
        ),
      );
    }
  }

  Widget? _buildFilterWidget(ArchiveState state, ArchiveNotifier notifier) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!state.tagFilter &&
            state.emailType != 'unread' &&
            state.emailType != 'community')
          IconButton(
            icon: SvgPicture.asset(svgFilter),
            onPressed: () => notifier.toggleFilter(),
          ),
        if (state.emailType == 'unread' || state.emailType == 'community')
          IconButton(
            icon: SvgPicture.asset(
              svgUnread,
              colorFilter: ColorFilter.mode(
                Theme.of(context).appBarTheme.foregroundColor ??
                    Theme.of(context).colorScheme.onSurface,
                BlendMode.srcIn,
              ),
            ),
            onPressed: () => notifier.clearUnreadFilter(),
            tooltip: 'Clear Unread Filter',
          ),
        if (state.tagFilter)
          IconButton(
            icon: SvgPicture.asset(
              svgTags,
              colorFilter: ColorFilter.mode(
                Theme.of(context).appBarTheme.foregroundColor ??
                    Theme.of(context).colorScheme.onSurface,
                BlendMode.srcIn,
              ),
            ),
            onPressed: () => notifier.clearTagFilter(),
            tooltip: 'Clear Tag Filter',
          ),
      ],
    );
  }

  Widget _buildSelectionLeadingWidget(
    ArchiveState state,
    ArchiveNotifier notifier,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(width: 5),
        IconButton(
          onPressed: state.isInProcess
              ? null
              : () => notifier.onLongPress(null, null),
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
          icon: state.allEmailIdsFlag
              ? const Icon(Icons.check_box)
              : state.selectedEmailIds.isNotEmpty
              ? const Icon(Icons.indeterminate_check_box)
              : const Icon(Icons.check_box_outline_blank),
          onPressed: () => _handleSelectAllEmails(state, notifier),
        ),
        Text(
          state.allEmailIdsFlag
              ? 'All Selected (${state.selectedCount})'
              : state.selectedEmailIds.isNotEmpty
              ? '${state.selectedCount} selected'
              : selectAll,
          style: AppTypography.labelMedium(context).copyWith(
            color: context.colors.primary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  List<Widget> _buildSelectionActionsWidgets(
    ArchiveState state,
    ArchiveNotifier notifier,
  ) {
    return [
      if (state.currentPath != AppRoutes.sent)
        IconButton(
          icon: SvgPicture.asset(svgOptin, height: 24, width: 24),
          onPressed: () {
            if (state.selectedEmails.isNotEmpty) {
              notifier.displayAddEmailModal(
                state.selectedEmails.toSet().toList(),
                0,
              );
            }
          },
        ),
      IconButton(
        icon: SvgPicture.asset(svgDelete, height: 24, width: 24),
        onPressed: () => notifier.handleBulkDeleteAction(),
      ),
      if (state.currentPath == AppRoutes.sent)
        IconButton(
          icon: SvgPicture.asset(
            svgArchive,
            height: 24,
            width: 24,
            colorFilter: ColorFilter.mode(
              Theme.of(context).appBarTheme.foregroundColor ??
                  Theme.of(context).colorScheme.onSurface,
              BlendMode.srcIn,
            ),
          ),
          onPressed: () => notifier.handleBulkArchiveAction(),
        ),
      IconButton(
        icon: SvgPicture.asset(
          svgMoreHori,
          height: 24,
          width: 24,
          colorFilter: ColorFilter.mode(
            Theme.of(context).appBarTheme.foregroundColor ??
                Theme.of(context).colorScheme.onSurface,
            BlendMode.srcIn,
          ),
        ),
        onPressed: () => notifier.toggleMenuOptions(),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(archiveProvider);
    final notifier = ref.read(archiveProvider.notifier);

    // Clear overlays when route becomes active again (after navigation)
    // This handles the case when user navigates to ViewEmail and comes back
    final route = ModalRoute.of(context);
    if (route != null && route.isCurrent && _wasNavigatedAway) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ref.read(archiveProvider.notifier).clearOverlayStates();
          _pushAppBarConfig(
            ref.read(archiveProvider),
            ref.read(archiveProvider.notifier),
          ); // Restore search/filter in AppBar after return
          setState(() {
            _wasNavigatedAway = false;
          });
        }
      });
    } else if (route != null && !route.isCurrent && !_wasNavigatedAway) {
      _wasNavigatedAway = true;
    }

    // Auto-show checkboxes when list selection happens on web
    // M-PERF-01: Use .select() to only fire when relevant fields change.
    ref.listen(
      archiveProvider.select(
        (s) => (s.selectedEmailIds.isNotEmpty, s.showCheckboxes),
      ),
      (_, next) {
        final (hasSelection, showCheckboxes) = next;
        if (kIsWeb && hasSelection && !showCheckboxes) {
          notifier.setShowCheckboxes(true);
        }
      },
    );

    // AppBar config pushed in initState + on selection mode changes only.

    return PopScope(
      canPop: false,
      child: Stack(
        key: Key('${_screenKeyPrefix()}_screen'),
        children: [
          _buildBody(state, notifier),
          StandardFab(
            testId: '${_screenKeyPrefix()}_compose_fab',
            iconAsset: svgComposeIcon,
            onPressed: () => notifier.gotoCompose(),
            heroTag: 'archiveResponsive',
            visible:
                state.longPressFlag && AppBreakpoints.isMobileLayout(context),
          ),
        ],
      ),
    );
  }

  String _screenKeyPrefix() {
    switch (widget.parentRoute) {
      case AppRoutes.trash:
        return 'trash';
      case AppRoutes.sent:
        return 'sent';
      case AppRoutes.archive:
      default:
        return 'archive';
    }
  }

  void _handleSelectAllEmails(ArchiveState state, ArchiveNotifier notifier) {
    List<int> idList = state.items
        .where((item) => item.receivers != null && item.receivers!.isNotEmpty)
        .map<int>((item) => item.receivers![0].emailId!)
        .toList();
    Set<String> emailSet = <String>{};

    for (var item in state.items) {
      String senderEmail = item.senderEmail ?? '';
      if (!emailSet.contains(senderEmail)) {
        emailSet.add(senderEmail);
      }
    }

    List<String> emailList = emailSet.toList();

    notifier.setSelectedEmails(
      state.allEmailIdsFlag ? [] : idList,
      state.allEmailIdsFlag ? [] : emailList,
    );

    if (!state.longPressFlag && state.currentPath != AppRoutes.sent) {
      if (widget.onLongPress != null) {
        widget.onLongPress!();
      }
    }
  }

  Widget _buildBody(ArchiveState state, ArchiveNotifier notifier) {
    // Show delayed spinner during initial load (no items yet).
    // DelayedLoadingOverlay handles the 600ms delay internally.
    if (state.isLoading && state.items.isEmpty) {
      return const DelayedLoadingOverlay(
        isLoading: true,
        child: SizedBox.shrink(),
      );
    }

    // Use device type detection that works for both web and native apps
    // This ensures tablets show tablet layout, not mobile layout
    final deviceType = AppBreakpoints.deviceType(context);
    final shouldShowReadingPane =
        AppBreakpoints.canShowReadingPaneForDevice(context) &&
        state.readingPaneEnabled &&
        state.items.isNotEmpty;

    switch (deviceType) {
      case DeviceType.mobile:
        return ArchiveMobileLayout(
          state: state,
          notifier: notifier,
          onViewDetail: _handleViewDetail,
          onLongPress: widget.onLongPress,
          searchController: _searchController,
          focusNode: _focusNode,
        );
      case DeviceType.tablet:
        return MediaQuery.of(context).orientation == Orientation.landscape
            ? ArchiveDesktopLayout(
                state: state,
                notifier: notifier,
                showReadingPane: shouldShowReadingPane,
                onViewDetail: _handleViewDetail,
                onLongPress: widget.onLongPress,
              )
            : ArchiveTabletLayout(
                state: state,
                notifier: notifier,
                showReadingPane: shouldShowReadingPane,
                onViewDetail: _handleViewDetail,
                onLongPress: widget.onLongPress,
              );
      case DeviceType.desktop:
        return ArchiveDesktopLayout(
          state: state,
          notifier: notifier,
          showReadingPane: shouldShowReadingPane,
          onViewDetail: _handleViewDetail,
          onLongPress: widget.onLongPress,
        );
    }
  }

  void _handleViewDetail(int id, dynamic tag, int index) {
    final notifier = ref.read(archiveProvider.notifier);
    notifier.gotoViewDetail(id, index);
    _searchController.clear();

    // Only clear search state when NOT using the reading pane (i.e. mobile full screen navigation)
    // If reading pane is shown (Desktop, Tablet Landscape, and Tablet Portrait), keep the list/search state.
    final state = ref.read(archiveProvider);
    final shouldShowReadingPane =
        AppBreakpoints.canShowReadingPaneForDevice(context) &&
        state.readingPaneEnabled;

    if (!shouldShowReadingPane) {
      notifier.onSearchChanged('');
    }
  }
}
