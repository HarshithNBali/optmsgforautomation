import 'package:optmsg/common/responsive/responsive.dart';
import 'package:optmsg/constant/app_typography.dart';
import 'package:optmsg/constant/img_path.dart';
import 'package:optmsg/constant/styles.dart';
import 'package:optmsg/model/tags_list_model.dart';
import 'package:optmsg/screens/email/inbox_riverpod/widget/tag_list_overlay_widget.dart';
import 'package:optmsg/screens/email/inbox_riverpod/widget/reading_pane_widget.dart';
import 'package:optmsg/services/common_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

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

class InboxTabletLayout extends ConsumerWidget {
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

  const InboxTabletLayout({
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

  void _handleViewDetail(BuildContext context, int id, int index) async {
    // Clear any selections when viewing an email
    if (state.selectedEmailIds.isNotEmpty) {
      notifier.clearSelection();
    }

    // If reading pane is disabled, navigate to ViewEmail instead
    if (!state.readingPaneEnabledWeb) {
      notifier.setCurrentlyViewedEmailId(id, null, index);
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

      // Handle result from ViewEmail if needed
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
      }
      return;
    }

    // Reading pane is enabled - use reading pane
    // Hide checkboxes when opening email in reading pane
    if (state.showCheckboxes) {
      notifier.setShowCheckboxes(false);
    }
    notifier.setSelectedEmailIdForReadingPane(id, index);
    notifier.setCurrentlyViewedEmailId(id, null, index);
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
          child: OrientationBuilder(
            builder: (context, orientation) {
              // Use MediaQuery to double-check orientation for tablets
              final mediaQuery = MediaQuery.of(context);
              final screenWidth = mediaQuery.size.width;
              final screenHeight = mediaQuery.size.height;
              // For tablets, check both OrientationBuilder and screen dimensions
              final isLandscape =
                  orientation == Orientation.landscape &&
                  screenWidth > screenHeight;
              // Only show reading pane if it's enabled AND screen is wide enough (>= 600px - tablets and desktops)
              // When disabled, clicking an email navigates to ViewEmail instead
              final showReadingPane =
                  state.readingPaneEnabledWeb &&
                  (kIsWeb ||
                      AppBreakpoints.canShowReadingPaneForDevice(context)) &&
                  state.items.isNotEmpty;

              if (isLandscape) {
                return _buildLandscapeLayout(context, ref, showReadingPane);
              } else {
                // Portrait mode: always use Column layout (reading pane below)
                return _buildPortraitLayout(context, ref, showReadingPane);
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLandscapeLayout(
    BuildContext context,
    WidgetRef ref,
    bool showReadingPane,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        const minListWidth = 300.0;
        final maxListWidth = totalWidth * 0.55;
        final defaultWidth = totalWidth * 0.4;

        // Use stored width or default
        final listPaneWidth = (state.emailListPaneWidth ?? defaultWidth).clamp(
          minListWidth,
          maxListWidth,
        );

        if (showReadingPane) {
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
        } else {
          // No reading pane - full screen list
          return _buildEmailListPane(context, ref);
        }
      },
    );
  }

  Widget _buildPortraitLayout(
    BuildContext context,
    WidgetRef ref,
    bool showReadingPane,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final totalHeight = constraints.maxHeight;
        const minPaneHeight = 200.0;
        final maxPaneHeight = totalHeight * 0.6;
        final defaultHeight = totalHeight * 0.35;

        // Use stored height or default
        final paneHeight = (state.readingPaneHeight ?? defaultHeight).clamp(
          minPaneHeight,
          maxPaneHeight,
        );

        if (showReadingPane) {
          return ResizableSplitPane(
            isHorizontal: false,
            initialFirstPaneSize: paneHeight,
            minFirstPaneSize: minPaneHeight,
            maxFirstPaneSize: maxPaneHeight,
            onSizeChanged: (size) {
              notifier.setReadingPaneHeight(size);
            },
            firstChild: _buildEmailListPane(context, ref),
            secondChild: const ReadingPaneWidget(),
          );
        } else {
          // No reading pane - full screen list
          return _buildEmailListPane(context, ref);
        }
      },
    );
  }

  Widget _buildEmailListPane(BuildContext context, WidgetRef ref) {
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
                emailType: 'inbox',
                longPress: kIsWeb ? state.showCheckboxes : !state.longPressFlag,
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
    final bool showCheckbox =
        kIsWeb && (state.showCheckboxes || state.selectedEmailIds.isNotEmpty);
    final cbSize = AppStyles.checkboxSize(context);
    final iconSize = AppStyles.checkboxIconSize(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(showCheckbox ? 8 : 16, 4, 16, 4),
      child: Row(
        children: [
          if (showCheckbox)
            SizedBox(
              width: cbSize,
              height: cbSize,
              child: InkWell(
                borderRadius: BorderRadius.circular(AppStyles.radiusXL),
                onTap: () => _handleSelectAllEmails(),
                child: Center(
                  child: Icon(
                    state.allEmailIdsFlag
                        ? Icons.check_box
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
          const Spacer(),
          if (kIsWeb)
            IconButton(
              tooltip: showCheckbox ? 'Hide Checkboxes' : 'Show Checkboxes',
              icon: SvgPicture.asset(
                // Use actual checkbox visibility state for icon
                showCheckbox ? svgHideCheckboxs : svgShowCheckboxs,
                height: 24,
                width: 24,
              ),
              onPressed: () {
                if (showCheckbox) {
                  // Currently showing checkboxes - hide them and clear selection
                  notifier.setShowCheckboxes(false);
                  notifier.clearSelection();
                } else {
                  // Currently hidden - show checkboxes
                  notifier.setShowCheckboxes(true);
                }
              },
            ),
          filterIconWidget(ref, context),
        ],
      ),
    );
  }

  void _handleSelectAllEmails() {
    if (state.allEmailIdsFlag) {
      notifier.clearSelection();
    } else {
      notifier.selectAllFromList();
    }
  }
}
