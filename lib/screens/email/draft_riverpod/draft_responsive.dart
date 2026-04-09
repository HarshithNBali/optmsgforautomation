import 'package:optmsg/main.dart' show MyApp;
import 'package:optmsg/common/responsive/responsive.dart';
import 'package:optmsg/constant/img_path.dart';
import 'package:optmsg/constant/string_constant.dart';
import 'package:optmsg/constant/app_typography.dart';
import 'package:optmsg/screens/email/draft_riverpod/draft_notifier.dart';
import 'package:optmsg/screens/email/draft_riverpod/draft_state.dart';
import 'package:optmsg/screens/email/draft_riverpod/layouts/draft_mobile_layout.dart';
import 'package:optmsg/screens/email/draft_riverpod/layouts/draft_tablet_layout.dart';
import 'package:optmsg/screens/email/draft_riverpod/layouts/draft_desktop_layout.dart';
import 'package:optmsg/services/common_service.dart';
import 'package:optmsg/widgets/load_container/delayed_loading_overlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:optmsg/widgets/standard_fab.dart';

import 'package:optmsg/services/app_bar_config_state.dart';
import 'package:optmsg/widgets/shell_layout.dart';

class DraftResponsive extends ConsumerStatefulWidget {
  final VoidCallback? onLongPress;
  final bool? isSideMenuCollapsed;
  final VoidCallback? onToggleSideMenu;

  final int? selectedEmailId;

  const DraftResponsive({
    super.key,
    this.onLongPress,
    this.isSideMenuCollapsed,
    this.onToggleSideMenu,
    this.selectedEmailId,
  });

  @override
  ConsumerState<DraftResponsive> createState() => DraftResponsiveState();
}

class DraftResponsiveState extends ConsumerState<DraftResponsive>
    with WidgetsBindingObserver {
  final _focusNode = FocusNode();
  final _searchController = TextEditingController();
  bool _wasNavigatedAway = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Always clear overlay states when page is initialized
    Future.microtask(() {
      ref.read(draftProvider.notifier).clearOverlayStates();
    });

    Future.microtask(() {
      ref.read(draftProvider.notifier).bootstrap(
            emailIdToRestore: widget.selectedEmailId,
          );
    });
    // Push AppBar config once on mount
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final state = ref.read(draftProvider);
        final notifier = ref.read(draftProvider.notifier);
        _pushAppBarConfig(state, notifier);
      }
    });
    // Re-push AppBar config when selection mode changes
    ref.listenManual(
      draftProvider.select((s) => (s.longPressFlag, s.selectedEmailIds.length)),
      (_, _) {
        if (mounted) {
          final state = ref.read(draftProvider);
          final notifier = ref.read(draftProvider.notifier);
          _pushAppBarConfig(state, notifier);
        }
      },
    );
  }

  @override
  void didUpdateWidget(DraftResponsive oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If selectedEmailId changed (e.g. via URL navigation), update the selection in notifier
    // without doing a full bootstrap of the entire list.
    if (widget.selectedEmailId != oldWidget.selectedEmailId &&
        widget.selectedEmailId != null) {
      final emailId = widget.selectedEmailId!;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ref.read(draftProvider.notifier).setCurrentlyViewed(emailId, 0);
        }
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _focusNode.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && !MyApp.isActionDepartureActive) {
      // Refresh drafts when app comes back to foreground.
      // Skip when a permission dialog / file picker is active — the lifecycle
      // churn is not a real background event and refreshing can reset compose state.
      ref.read(draftProvider.notifier).refresh();
    }
  }

  Future<void> refresh() async {
    await ref.read(draftProvider.notifier).getAllEmails('', isRefresh: true);
  }

  /// Push the correct AppBarConfig for the current state.
  void _pushAppBarConfig(DraftState state, DraftNotifier notifier) {
    if (!mounted) return;
    final bool isInSelectionMode = !state.longPressFlag || state.selectedEmailIds.isNotEmpty;
    final bool hasReadingPaneSelection =
        state.selectedEmailIdForReadingPane != null;
    final bool hasListSelection = state.selectedEmailIds.isNotEmpty;
    final bool hasAnySelection = hasReadingPaneSelection || hasListSelection;
    final isMobile = AppBreakpoints.isMobileLayout(context);

    if (!isInSelectionMode || !isMobile) {
      // Normal mode or desktop/tablet — no selection AppBar
      ShellLayout.of(context)?.setAppBarConfig(
            AppBarConfig(
              showSearch: true,
              onSearch: notifier.onSearchChanged,
            ),
          );
    } else {
      // Selection mode — mobile only
      ShellLayout.of(context)?.setAppBarConfig(
            AppBarConfig(
              title: '',
              isSelectionMode: true,
              selectionLeading: _buildSelectionLeadingWidget(state, notifier),
              selectionActions:
                  _buildSelectionActionsWidgets(state, notifier, hasAnySelection),
            ),
          );
    }
  }

  Widget _buildSelectionLeadingWidget(
      DraftState state, DraftNotifier notifier) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(width: 5),
        IconButton(
          icon: SvgPicture.asset(
            svgLeftArrow,
            colorFilter: ColorFilter.mode(
              Theme.of(context).appBarTheme.foregroundColor ??
                  Theme.of(context).colorScheme.onSurface,
              BlendMode.srcIn,
            ),
          ),
          onPressed: () {
            notifier.clearSelection();
          },
        ),
        IconButton(
          icon: state.allEmailIdsFlag
              ? const Icon(Icons.check_box)
              : state.selectedEmailIds.isNotEmpty
                  ? const Icon(Icons.indeterminate_check_box)
                  : const Icon(Icons.check_box_outline_blank),
          onPressed: state.allEmailIdsFlag
              ? notifier.clearSelection
              : notifier.selectAllFromList,
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
      DraftState state, DraftNotifier notifier, bool hasAnySelection) {
    return [
      IconButton(
        onPressed: hasAnySelection
            ? () => notifier.deleteDrafts(state.selectedEmailIds)
            : null,
        icon: SvgPicture.asset(svgDelete, height: 24, width: 24),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(draftProvider);
    final notifier = ref.read(draftProvider.notifier);

    // Refresh drafts when route becomes active again (after returning from compose)
    final route = ModalRoute.of(context);
    if (route != null && route.isCurrent && _wasNavigatedAway) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          notifier.refresh();
          _pushAppBarConfig(state, notifier); // Restore search in AppBar after return
          setState(() {
            _wasNavigatedAway = false;
          });
        }
      });
    } else if (route != null && !route.isCurrent && !_wasNavigatedAway) {
      _wasNavigatedAway = true;
    }

    // AppBar config pushed in initState + on selection mode changes only.

    return PopScope(
      canPop: CommonService().getPlatform() == 'ios' ? false : true,
      child: Stack(
        children: [
          _buildBody(state, notifier),
          StandardFab(
            iconAsset: svgComposeIcon,
            onPressed: () {
              notifier.gotoCompose();
              _searchController.clear();
              notifier.onSearchChanged('');
            },
            heroTag: 'draftResponsive',
            visible: state.longPressFlag && AppBreakpoints.isMobileLayout(context),
          ),
        ],
      ),
    );
  }


  Widget _buildBody(DraftState state, DraftNotifier notifier) {
    // While loading with no items yet, show the delayed loading overlay
    // (spinner appears after 600ms) to prevent empty-state image from flashing.
    if (state.isLoading && state.items.isEmpty) {
      return const DelayedLoadingOverlay(
        isLoading: true,
        child: SizedBox.shrink(),
      );
    }

    final deviceType = AppBreakpoints.deviceType(context);

    switch (deviceType) {
      case DeviceType.mobile:
        return DraftMobileLayout(
          state: state,
          notifier: notifier,
          searchController: _searchController,
          focusNode: _focusNode,
          onViewDetail: (id) {
            notifier.gotoViewDetail(id);
            _searchController.clear();
            notifier.onSearchChanged('');
          },
        );
      case DeviceType.tablet:
        return MediaQuery.of(context).orientation == Orientation.landscape
            ? DraftDesktopLayout(
                state: state,
                notifier: notifier,
                onViewDetail: (id) => notifier.gotoViewDetail(id),
              )
            : DraftTabletLayout(
                state: state,
                notifier: notifier,
                onViewDetail: (id) => notifier.gotoViewDetail(id),
              );
      case DeviceType.desktop:
        return DraftDesktopLayout(
          state: state,
          notifier: notifier,
          onViewDetail: (id) => notifier.gotoViewDetail(id),
        );
    }
  }
}
