import 'package:optmsg/common/responsive/responsive.dart';
import 'package:optmsg/constant/app_typography.dart';
import 'package:optmsg/constant/styles.dart';
import 'package:optmsg/model/tags_list_model.dart';
import 'package:optmsg/screens/email/inbox_riverpod/widget/reading_pane_widget.dart';
import 'package:optmsg/screens/email/inbox_riverpod/widget/tag_list_overlay_widget.dart';
import 'package:optmsg/services/common_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../widgets/custom_dismissible.dart';
import '../../../../widgets/draggable_divider.dart';
import '../widget/filter_overlay_widget.dart';
import '../inbox_notifier.dart';
import '../inbox_state.dart';
import '../widget/filter_icon_widget.dart';
import '../widget/inbox_action_bar.dart';
import '../widget/menu_options_overlay_widget.dart';
import '../../../../widgets/move_picker_overlay.dart';
import 'package:go_router/go_router.dart';
import '../../../../router/app_routes.dart';

class InboxDesktopLayout extends ConsumerWidget {
  final InboxState state;
  final InboxNotifier notifier;
  final List tagsList;
  final TagsListModel? tagsListModel;
  final String currentMenuLabel;
  final bool hasAnySelection;
  final bool hasReadingPaneSelection;
  final VoidCallback onCompose;
  final Function(int, String) onReply;
  final String Function() getMarkActionIcon;
  final String Function() computeMarkActionTitle;
  final String Function() getSelectionState;
  final VoidCallback onMarkAsRead;
  final VoidCallback onMarkAsUnread;

  const InboxDesktopLayout({
    super.key,
    required this.state,
    required this.notifier,
    required this.tagsList,
    this.tagsListModel,
    required this.currentMenuLabel,
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

  Future<void> _handleViewDetail(
    BuildContext context,
    int id,
    int index,
  ) async {
    // Clear any selections when viewing an email
    if (state.selectedEmailIds.isNotEmpty) {
      notifier.clearSelection();
    }

    final canShowReadingPane = kIsWeb
        ? state.readingPaneEnabledWeb
        : (state.readingPaneEnabledWeb &&
              AppBreakpoints.canShowReadingPaneForDevice(context));

    if (canShowReadingPane) {
      // Hide checkboxes when opening email in reading pane
      if (state.showCheckboxes) {
        notifier.setShowCheckboxes(false);
      }
      notifier.setSelectedEmailIdForReadingPane(id, index);
      notifier.setCurrentlyViewedEmailId(id);
    } else {
      notifier.setCurrentlyViewedEmailId(id);
      // Optimistically mark as read immediately — viewing always triggers a
      // server-side mark-as-read via email_detail_notifier, so reflect it in
      // the list now for instant feedback (matches multi-select behaviour).
      notifier.markEmailAsReadInList(id);
      final result = await context.push<Map?>(
        AppRoutes.viewEmailPath(id.toString()),
        extra: {
          'emailId': id,
          'emailType': CommonService().capitalize('inbox'),
          'allTagsList': tagsListModel,
          'itemIndex': index,
        },
      );

      // Keep currentlyViewedEmailId set to preserve highlighting when returning
      // Action ribbon won't show because selectedEmailIdForReadingPane is not set when reading pane is OFF

      if (result == null) {
        return;
      }

      final emailId = result['emailId'] as int?;
      final markedAsUnread = result['markedAsUnread'] == true;

      // Handle tag updates - refresh list to get accurate tag data from server
      final isTagsUpdated = result['isTagsUpdated'] == true;
      if (isTagsUpdated) {
        await notifier.refresh();
        return;
      }

      // Handle "Mark as Unread" flag
      if (markedAsUnread && emailId != null) {
        notifier.markEmailAsUnreadInList(emailId);
      }

      // Handle actions that remove items from list (undo == true for Archive/Trash/Inbox/Sent)
      // Note: API call was already made in view_email.dart, so we just need to update the local list
      if (result['undo'] == true && emailId != null) {
        notifier.removeEmailFromListById(emailId);
        notifier.clearSelection();
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        InboxActionBar(
          state: state,
          notifier: notifier,
          hasAnySelection: hasAnySelection,
          hasReadingPaneSelection: hasReadingPaneSelection,
          onCompose: onCompose,
          onReply: onReply,
          getMarkActionIcon: getMarkActionIcon,
          computeMarkActionTitle: computeMarkActionTitle,
          getSelectionState: getSelectionState,
          onMarkAsRead: onMarkAsRead,
          onMarkAsUnread: onMarkAsUnread,
        ),
        Expanded(
          child:
              state.readingPaneEnabledWeb &&
                  (kIsWeb ||
                      AppBreakpoints.canShowReadingPaneForDevice(context)) &&
                  state.items.isNotEmpty
              ? LayoutBuilder(
                  builder: (context, constraints) {
                    final totalWidth = constraints.maxWidth;
                    const minListWidth = 280.0;
                    final maxListWidth = totalWidth * 0.6;
                    final defaultWidth = totalWidth * 0.33;

                    // Guard: ensure min doesn't exceed max (narrow screens)
                    final effectiveMin = minListWidth.clamp(
                      0.0,
                      maxListWidth.clamp(0.0, totalWidth),
                    );
                    final listPaneWidth =
                        (state.emailListPaneWidth ?? defaultWidth).clamp(
                          effectiveMin,
                          maxListWidth.clamp(effectiveMin, totalWidth),
                        );

                    return ResizableSplitPane(
                      isHorizontal: true,
                      initialFirstPaneSize: listPaneWidth,
                      minFirstPaneSize: minListWidth,
                      maxFirstPaneSize: maxListWidth,
                      onSizeChanged: (size) {
                        notifier.setEmailListPaneWidth(size);
                      },
                      firstChild: _buildEmailListPane(context, ref),
                      secondChild: const ReadingPaneWidget(),
                    );
                  },
                )
              : _buildEmailListPane(context, ref),
        ),
      ],
    );
  }

  Widget _buildEmailListPane(BuildContext context, WidgetRef ref) {
    final isTablet = AppBreakpoints.isTabletLayout(context);
    final isNativeTabletLandscape =
        !kIsWeb &&
        isTablet &&
        MediaQuery.of(context).orientation == Orientation.landscape;
    return Column(
      children: [
        _buildListHeader(ref, context),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Container(height: 1, color: context.colors.outlineVariant),
        ),
        Expanded(
          child: Stack(
            children: [
              CustomDismissible(
                items: state.items,
                tagsList: tagsList,
                emailType: state.emailType ?? 'inbox',
                longPress: (kIsWeb || isNativeTabletLandscape)
                    ? state.showCheckboxes
                    : !state.longPressFlag,
                allEmailIdsFlag: state.allEmailIdsFlag,
                selectedEmailIds: state.selectedEmailIds,
                selectedEmails: state.selectedEmails,
                setSelectedEmailIds: (ids, mails) {
                  notifier.setSelectedFromList(ids, mails);
                },
                onLongPress: notifier.toggleSelectFromList,
                onRefresh: notifier.refresh,
                onEndReached: () {
                  if (!state.isLoading &&
                      state.inboxList?.data?.nextPage == true) {
                    notifier.getAllEmails(state.searchKey);
                  }
                },
                viewDetail: (id, selectedTag, index) {
                  _handleViewDetail(context, id, index);
                },
                onArchiveEmail: (int id, int index) {
                  notifier.changeStatusWithUndo("isArchive", [id]);
                },
                onDeleteEmail: (int id, int index) {
                  notifier.changeStatusWithUndo("isTrash", [id]);
                },
                onOptInEmail: (String email, int index) {
                  notifier.handleSingleEmailOptIn(email, index);
                },
                selectedEmailId: state.currentlyViewedEmailId,
                onShiftClick: (index) {
                  // Determine the anchor: last multi-select click, or the
                  // email currently being viewed in the reading pane.
                  int from;
                  if (state.lastClickedIndex != -1) {
                    from = state.lastClickedIndex;
                  } else if (state.currentlyViewedEmailId != null) {
                    final viewedIdx = state.items.indexWhere(
                      (e) => e.emailId == state.currentlyViewedEmailId,
                    );
                    from = viewedIdx != -1 ? viewedIdx : index;
                  } else {
                    from = index;
                  }
                  notifier.selectRangeFromList(from, index);
                },
                onCtrlClick: (index) {
                  // If first Ctrl/Cmd+Click while viewing a message in the
                  // reading pane, include that viewed message in the selection.
                  if (state.selectedEmailIds.isEmpty &&
                      state.currentlyViewedEmailId != null) {
                    final viewedIdx = state.items.indexWhere(
                      (e) => e.emailId == state.currentlyViewedEmailId,
                    );
                    if (viewedIdx != -1) {
                      notifier.toggleSingleSelectByIndex(viewedIdx);
                    }
                  }
                  notifier.toggleSingleSelectByIndex(index);
                },
                rightActions: const ['More', 'Archive', 'Trash'],
                shouldShowStartPane: true,
                updateEmailStatus: notifier.updateEmailStatus,
                addEmailTags: notifier.addEmailTags,
              ),
              if (state.showFilter) filterOverlayWidget(ref, context),
              if (state.showTagList)
                TagListOverlayWidget(
                  isForAddingTags:
                      !state.isTagListForFilter &&
                      (state.selectedEmailIds.isNotEmpty ||
                          state.selectedEmailIdForReadingPane != null),
                ),
              if (state.showMenuOptions) menuOptionsOverlayWidget(ref, context),
              if (state.showMoveOverlay)
                MovePickerOverlay(
                  currentFolder: 'inbox',
                  selectionOrigin: 'allReceived',
                  onSystemFolderSelected: notifier.handleMoveToSystemFolder,
                  onTagSelected: notifier.handleMoveToTag,
                  onDismiss: notifier.dismissMoveOverlay,
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildListHeader(WidgetRef ref, BuildContext context) {
    final isTablet = AppBreakpoints.isTabletLayout(context);
    final isNativeTabletLandscape =
        !kIsWeb &&
        isTablet &&
        MediaQuery.of(context).orientation == Orientation.landscape;
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
          // Single checkbox icon — toggles multi-select on/off, then select-all
          if (canShowToggle)
            SizedBox(
              width: cbSize,
              height: cbSize,
              child: InkWell(
                borderRadius: BorderRadius.circular(AppStyles.radiusXL),
                onTap: () {
                  if (!isMultiSelectActive) {
                    // Activate multi-select mode
                    notifier.setShowCheckboxes(true);
                  } else if (state.allEmailIdsFlag) {
                    // All selected — deselect all and exit multi-select
                    notifier.clearSelection();
                  } else {
                    // Some or none selected — select all
                    notifier.selectAllFromList();
                  }
                },
                onLongPress: isMultiSelectActive
                    ? () {
                        // Long-press to exit multi-select mode
                        notifier.setShowCheckboxes(false);
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
            currentMenuLabel,
            style: AppTypography.headlineMedium(context).copyWith(
              color: context.colors.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (state.selectedEmailIds.isNotEmpty) ...[
            const SizedBox(width: 12),
            Text(
              state.allEmailIdsFlag
                  ? 'All Selected (${state.selectedCount})'
                  : '${state.selectedCount} selected',
              style: AppTypography.labelMedium(
                context,
              ).copyWith(color: context.colors.onSurfaceVariant),
            ),
          ],
          const Spacer(),
          filterIconWidget(ref, context),
        ],
      ),
    );
  }
}
