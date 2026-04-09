import 'package:optmsg/common/responsive/responsive.dart';
import 'package:optmsg/constant/app_typography.dart';
import 'package:optmsg/constant/styles.dart';
import 'package:optmsg/screens/email/draft_riverpod/draft_notifier.dart';
import 'package:optmsg/screens/email/draft_riverpod/draft_state.dart';
import 'package:optmsg/screens/email/draft_riverpod/widget/draft_action_bar.dart';
import 'package:optmsg/screens/email/draft_riverpod/widget/draft_reading_pane_widget.dart';
import 'package:optmsg/widgets/custom_dismissible.dart';
import 'package:optmsg/widgets/draggable_divider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DraftDesktopLayout extends ConsumerWidget {
  final DraftState state;
  final DraftNotifier notifier;
  final Function(int) onViewDetail;

  const DraftDesktopLayout({
    super.key,
    required this.state,
    required this.notifier,
    required this.onViewDetail,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool hasAnySelection =
        state.selectedEmailIdForReadingPane != null ||
        state.selectedEmailIds.isNotEmpty;

    final bool showReadingPane =
        state.readingPaneEnabled &&
        (kIsWeb || AppBreakpoints.canShowReadingPaneForDevice(context)) &&
        state.items.isNotEmpty;

    return Column(
      children: [
        DraftActionBar(
          state: state,
          notifier: notifier,
          hasAnySelection: hasAnySelection,
        ),
        Expanded(
          child: showReadingPane
              ? _buildSplitView(context)
              : _buildEmailListPane(context),
        ),
      ],
    );
  }

  // ====================== SPLIT VIEW ======================

  Widget _buildSplitView(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final _PaneWidths widths = _getPaneWidths(constraints.maxWidth);

        final double listPaneWidth =
            (state.emailListPaneWidth ?? widths.defaultWidth).clamp(
              widths.minWidth,
              widths.maxWidth,
            );

        return ResizableSplitPane(
          isHorizontal: true,
          initialFirstPaneSize: listPaneWidth,
          minFirstPaneSize: widths.minWidth,
          maxFirstPaneSize: widths.maxWidth,
          onSizeChanged: notifier.setEmailListPaneWidth,
          firstChild: _buildEmailListPane(context),
          secondChild: const DraftReadingPaneWidget(),
        );
      },
    );
  }

  _PaneWidths _getPaneWidths(double totalWidth) {
    final maxWidth = totalWidth * 0.6;
    // Guard: ensure min doesn't exceed max on narrow screens
    final minWidth = AppBreakpoints.splitPaneMinWidth.clamp(
      0.0,
      maxWidth.clamp(0.0, totalWidth),
    );
    return _PaneWidths(
      minWidth: minWidth,
      maxWidth: maxWidth.clamp(minWidth, totalWidth),
      defaultWidth: totalWidth * 0.33,
    );
  }

  // ====================== EMAIL LIST ======================

  Widget _buildEmailListPane(BuildContext context) {
    final bool isTablet = AppBreakpoints.isTabletLayout(context);

    final bool isNativeTabletLandscape =
        !kIsWeb &&
        isTablet &&
        MediaQuery.of(context).orientation == Orientation.landscape;

    final bool showCheckbox =
        (kIsWeb || isNativeTabletLandscape) &&
        (state.showCheckboxes || state.selectedEmailIds.isNotEmpty);

    return Column(
      children: [
        _buildHeader(context, showCheckbox, isNativeTabletLandscape),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Divider(),
        ),
        Expanded(child: _buildEmailList(context, isNativeTabletLandscape)),
      ],
    );
  }

  // ====================== HEADER ======================

  Widget _buildHeader(
    BuildContext context,
    bool showCheckbox,
    bool isNativeTabletLandscape,
  ) {
    final bool canShowToggle = kIsWeb || isNativeTabletLandscape;
    final bool isMultiSelectActive =
        canShowToggle &&
        (state.showCheckboxes || state.selectedEmailIds.isNotEmpty);

    final cbSize = AppStyles.checkboxSize(context);
    final iconSize = AppStyles.checkboxIconSize(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 16, 4),
      child: Row(
        children: [
          if (canShowToggle)
            SizedBox(
              width: cbSize,
              height: cbSize,
              child: InkWell(
                borderRadius: BorderRadius.circular(AppStyles.radiusXL),
                onTap: () {
                  if (!isMultiSelectActive) {
                    notifier.setCheckboxVisibility(true);
                  } else if (state.allEmailIdsFlag) {
                    notifier.clearSelection();
                  } else {
                    notifier.selectAllFromList();
                  }
                },
                onLongPress: isMultiSelectActive
                    ? () {
                        notifier.setCheckboxVisibility(false);
                        notifier.clearSelection();
                      }
                    : null,
                child: Center(
                  child: Icon(
                    isMultiSelectActive
                        ? (state.allEmailIdsFlag
                              ? Icons.check_box
                              : (state.selectedEmailIds.isNotEmpty
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
            'Drafts',
            style: AppTypography.headlineMedium(context).copyWith(
              color: context.colors.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (state.selectedEmailIds.isNotEmpty) ...[
            const SizedBox(width: 12),
            Text(
              state.isAllSelected
                  ? 'All Selected (${state.selectedCount})'
                  : '${state.selectedCount} selected',
              style: AppTypography.labelMedium(
                context,
              ).copyWith(color: context.colors.onSurfaceVariant),
            ),
          ],
          const Spacer(),
        ],
      ),
    );
  }

  // ====================== EMAIL LIST ======================

  Widget _buildEmailList(BuildContext context, bool isNativeTabletLandscape) {
    return CustomDismissible(
      onLongPress: notifier.toggleSelectFromList,
      longPress: (kIsWeb || isNativeTabletLandscape)
          ? state.showCheckboxes
          : !state.longPressFlag,
      allEmailIdsFlag: state.allEmailIdsFlag,
      selectedEmailIds: state.selectedEmailIds,
      selectedEmails: state.selectedEmails,
      setSelectedEmailIds: notifier.setSelectedFromList,
      onRefresh: () => notifier.getAllEmails(state.searchKey, isRefresh: true),
      onEndReached: () => notifier.getAllEmails(state.searchKey),
      shouldShowStartPane: false,
      items: state.items,
      addEmailTags: (_, _, _, _) async {},
      emailType: 'draft',
      updateEmailStatus: (_, _, _) async {},
      tagsList: const [],
      rightActions: const ['', 'Trash', ''],
      viewDetail: (id) => _handleViewDetail(context, id),
      onDeleteEmail: (id, _) => notifier.deleteDrafts([id]),
      selectedEmailId: state.currentlyViewedEmailId,
      onShiftClick: (index) {
        int from;
        if (state.lastClickedIndex != -1) {
          from = state.lastClickedIndex;
        } else if (state.currentlyViewedEmailId != null) {
          final viewedIdx = state.items.indexWhere(
            (e) => e.id == state.currentlyViewedEmailId,
          );
          from = viewedIdx != -1 ? viewedIdx : index;
        } else {
          from = index;
        }
        notifier.selectRangeFromList(from, index);
      },
      onCtrlClick: (index) {
        if (state.selectedEmailIds.isEmpty &&
            state.currentlyViewedEmailId != null) {
          final viewedIdx = state.items.indexWhere(
            (e) => e.id == state.currentlyViewedEmailId,
          );
          if (viewedIdx != -1) {
            notifier.toggleSingleSelectByIndex(viewedIdx);
          }
        }
        notifier.toggleSingleSelectByIndex(index);
      },
    );
  }

  // ====================== ACTIONS ======================

  void _handleViewDetail(BuildContext context, int id) {
    if (state.selectedEmailIds.isNotEmpty) {
      notifier.clearSelection();
    }
    final canShowReadingPane =
        state.readingPaneEnabled &&
        (kIsWeb || AppBreakpoints.canShowReadingPaneForDevice(context));
    if (canShowReadingPane) {
      if (state.showCheckboxes) {
        notifier.setCheckboxVisibility(false);
      }
      notifier.setCurrentlyViewedEmailId(id);
      notifier.setSelectedEmailIdForReadingPane(id);
    } else {
      onViewDetail(id);
    }
  }
}

// ====================== MODELS ======================

class _PaneWidths {
  final double minWidth;
  final double maxWidth;
  final double defaultWidth;

  const _PaneWidths({
    required this.minWidth,
    required this.maxWidth,
    required this.defaultWidth,
  });

  _PaneWidths copyWith({
    double? minWidth,
    double? maxWidth,
    double? defaultWidth,
  }) {
    return _PaneWidths(
      minWidth: minWidth ?? this.minWidth,
      maxWidth: maxWidth ?? this.maxWidth,
      defaultWidth: defaultWidth ?? this.defaultWidth,
    );
  }
}
