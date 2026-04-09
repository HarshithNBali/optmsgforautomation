import 'package:optmsg/common/responsive/responsive.dart';
import 'package:optmsg/constant/app_typography.dart';
import 'package:optmsg/constant/img_path.dart';
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
import 'package:flutter_svg/flutter_svg.dart';

class DraftTabletLayout extends ConsumerWidget {
  final DraftState state;
  final DraftNotifier notifier;
  final Function(int) onViewDetail;

  const DraftTabletLayout({
    super.key,
    required this.state,
    required this.notifier,
    required this.onViewDetail,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool hasReadingPaneSelection =
        state.selectedEmailIdForReadingPane != null;
    final bool hasListSelection = state.selectedEmailIds.isNotEmpty;
    final bool hasAnySelection = hasReadingPaneSelection || hasListSelection;

    // Only show reading pane if enabled AND screen is wide enough (>= 600px - tablets and desktops)
    final bool showReadingPane = state.readingPaneEnabled &&
        (kIsWeb || AppBreakpoints.canShowReadingPaneForDevice(context));
    return Column(
      children: [
        DraftActionBar(
          state: state,
          notifier: notifier,
          hasAnySelection: hasAnySelection,
        ),
        Expanded(
          child: OrientationBuilder(
            builder: (context, orientation) {
              // Use MediaQuery to double-check orientation for tablets
              final mediaQuery = MediaQuery.of(context);
              final screenWidth = mediaQuery.size.width;
              final screenHeight = mediaQuery.size.height;
              // For tablets, check both OrientationBuilder and screen dimensions
              final isLandscape = orientation == Orientation.landscape &&
                  screenWidth > screenHeight;

              if (isLandscape) {
                return _buildLandscapeLayout(context, showReadingPane);
              } else {
                // Portrait mode: always use Column layout (reading pane below)
                return _buildPortraitLayout(context, showReadingPane);
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLandscapeLayout(BuildContext context, bool showReadingPane) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        const minListWidth = 300.0;
        final maxListWidth = totalWidth * 0.55;
        final defaultWidth = totalWidth * 0.4;

        // Use stored width or default
        final listPaneWidth = (state.emailListPaneWidth ?? defaultWidth)
            .clamp(minListWidth, maxListWidth);

        if (showReadingPane) {
          return ResizableSplitPane(
            isHorizontal: true,
            initialFirstPaneSize: listPaneWidth,
            minFirstPaneSize: minListWidth,
            maxFirstPaneSize: maxListWidth,
            onSizeChanged: (size) {
              notifier.setEmailListPaneWidth(size);
            },
            firstChild: _buildEmailListPane(context),
            secondChild: const DraftReadingPaneWidget(),
          );
        } else {
          // No reading pane - full screen list
          return _buildEmailListPane(context);
        }
      },
    );
  }

  Widget _buildPortraitLayout(BuildContext context, bool showReadingPane) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final totalHeight = constraints.maxHeight;
        const minPaneHeight = 200.0;
        final maxPaneHeight = totalHeight * 0.6;
        final defaultHeight = totalHeight * 0.35;

        // Reuse emailListPaneWidth to store reading pane height in portrait mode
        final paneHeight = (state.emailListPaneWidth ?? defaultHeight)
            .clamp(minPaneHeight, maxPaneHeight);

        if (showReadingPane) {
          return ResizableSplitPane(
            isHorizontal: false,
            initialFirstPaneSize: paneHeight,
            minFirstPaneSize: minPaneHeight,
            maxFirstPaneSize: maxPaneHeight,
            onSizeChanged: (size) {
              notifier.setEmailListPaneWidth(size);
            },
            firstChild: _buildEmailListPane(context),
            secondChild: const DraftReadingPaneWidget(),
          );
        } else {
          // No reading pane - full screen list
          return _buildEmailListPane(context);
        }
      },
    );
  }

  Widget _buildEmailListPane(BuildContext context) {
    final bool showCheckbox =
        kIsWeb && (state.showCheckboxes || state.selectedEmailIds.isNotEmpty);

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(showCheckbox ? 8 : 16, 12, 16, 4),
          child: Row(
            children: [
              if (showCheckbox)
                SizedBox(
                  width: AppStyles.checkboxSize(context),
                  height: AppStyles.checkboxSize(context),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(AppStyles.radiusXL),
                    onTap: () => _handleSelectAllEmails(),
                    child: Center(
                      child: Icon(
                        state.allEmailIdsFlag
                            ? Icons.check_box
                            : Icons.check_box_outline_blank,
                        color: context.colors.primary,
                        size: AppStyles.checkboxIconSize(context),
                      ),
                    ),
                  ),
                ),
              Text(
                'Drafts',
                style: AppTypography.titleMedium(context).copyWith(
                  color: context.colors.onSurface,
                ),
              ),
              const Spacer(),
              if (kIsWeb)
                IconButton(
                  icon: SvgPicture.asset(
                    // Use actual checkbox visibility state for icon
                    showCheckbox ? svgHideCheckboxs : svgShowCheckboxs,
                    height: 24,
                    width: 24,
                  ),
                  onPressed: () {
                    if (showCheckbox) {
                      // Currently showing checkboxes - hide them and clear selection
                      notifier.setCheckboxVisibility(false);
                      notifier.clearSelection();
                    } else {
                      // Currently hidden - show checkboxes
                      notifier.setCheckboxVisibility(true);
                    }
                  },
                  tooltip: showCheckbox ? 'Hide Checkboxes' : 'Show Checkboxes',
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Container(height: 1, color: context.colors.outlineVariant),
        ),
        Expanded(
          child: CustomDismissible(
            onLongPress: notifier.toggleSelectFromList,
            longPress: kIsWeb ? state.showCheckboxes : !state.longPressFlag,
            allEmailIdsFlag: state.allEmailIdsFlag,
            selectedEmailIds: state.selectedEmailIds,
            selectedEmails: state.selectedEmails,
            setSelectedEmailIds: notifier.setSelectedFromList,
            onRefresh: () =>
                notifier.getAllEmails(state.searchKey, isRefresh: true),
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
          ),
        ),
      ],
    );
  }

  void _handleViewDetail(BuildContext context, int id) {
    if (state.selectedEmailIds.isNotEmpty) {
      notifier.clearSelection();
    }
    final canShowReadingPane = state.readingPaneEnabled &&
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

  void _handleSelectAllEmails() {
    if (state.allEmailIdsFlag) {
      notifier.clearSelection();
    } else {
      notifier.selectAllFromList();
    }
  }
}
