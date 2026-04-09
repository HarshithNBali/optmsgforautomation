import 'package:optmsg/common/responsive/responsive.dart';
import 'package:optmsg/constant/app_typography.dart';
import 'package:optmsg/model/tags_list_model.dart';
import 'package:optmsg/screens/email/inbox_riverpod/widget/tag_list_overlay_widget.dart';
import 'package:optmsg/services/common_service.dart';
import 'package:optmsg/services/tags_provider.dart';
import 'package:optmsg/constant/img_path.dart';
import 'package:optmsg/constant/string_constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../widgets/custom_dismissible.dart';
import '../inbox_notifier.dart';
import '../widget/menu_options_overlay_widget.dart';
import '../../../../widgets/move_picker_overlay.dart';
import 'package:go_router/go_router.dart';
import '../../../../router/app_routes.dart';

class InboxMobileLayout extends ConsumerWidget {
  final List tagsList;
  final TagsListModel? tagsListModel;
  final bool hideOverlays;
  final Function()? onBack;
  // PW-02: Passed from parent (InboxResponsive) — properly created once and
  // disposed. Replaces the inline TextEditingController(text:) that was
  // allocated on every rebuild and never disposed.
  final TextEditingController searchController;

  const InboxMobileLayout(
      {super.key,
      required this.tagsList,
      required this.searchController,
      this.tagsListModel,
      this.hideOverlays = false,
      this.onBack});

  Future<void> _navigateToViewEmail(BuildContext context, WidgetRef ref, int id,
      int index, TagsListModel? tagsListModel) async {
    // Set the currently viewed email ID in state before navigating
    // This ensures the reading pane selection is preserved when resizing from mobile to tablet/desktop
    final notifier = ref.read(inboxProvider.notifier);
    notifier.setCurrentlyViewedEmailId(id, null, index);
    // Optimistically mark as read immediately — viewing always triggers a
    // server-side mark-as-read via email_detail_notifier, so reflect it in
    // the list now for instant feedback (matches multi-select behaviour).
    notifier.markEmailAsReadInList(id);

    // PM-02: Await the push result directly — the previous `.then()` swallowed
    // the return value, making `result` always null and all mutation handling
    // dead code. Now we capture the result AND call onBack for search clearing.
    final result = await context.push<Map?>(
      AppRoutes.viewEmailPath(id.toString()),
      extra: {
        'emailId': id,
        'emailType': CommonService().capitalize('inbox'),
        'allTagsList': tagsListModel,
        'itemIndex': index,
      },
    );

    // Clear search state on return (previously in .then())
    onBack?.call();

    // No mutation occurred — just read the email. Skip refresh.
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

    // Handle actions that remove items from list (undo == true for Archive/Trash)
    // Note: API call was already made in view_email.dart, so we just need to update the local list
    if (result['undo'] == true && emailId != null) {
      notifier.removeEmailFromListById(emailId);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(inboxProvider);
    final notifier = ref.read(inboxProvider.notifier);
    final tagsState = ref.watch(tagsProvider);

    // Hide overlays until parent has cleared state (prevents flash of old state)
    final showFilter = hideOverlays ? false : state.showFilter;
    final showTagList = hideOverlays ? false : state.showTagList;

    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return Column(
      children: [
        // Search bar removed — now handled by ShellLayout AppBar.bottom
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: keyboardHeight),
            child: Stack(
            children: [
              CustomDismissible(
                onLongPress: notifier.toggleSelectFromList,
                // Show checkboxes on long press for both web and native mobile
                longPress: !state.longPressFlag,
                allEmailIdsFlag: state.allEmailIdsFlag,
                selectedEmailIds: state.selectedEmailIds,
                selectedEmails: state.selectedEmails,
                setSelectedEmailIds: notifier.setSelectedFromList,
                onRefresh: notifier.refresh,
                onEndReached: () {
                  if (!state.isLoading &&
                      state.inboxList?.data?.nextPage == true) {
                    notifier.getAllEmails(state.searchKey);
                  }
                },
                shouldShowStartPane: true,
                items: state.items,
                addEmailTags: notifier.addEmailTags,
                tagsList: tagsList,
                emailType: state.emailType ?? 'inbox',
                updateEmailStatus: notifier.updateEmailStatus,
                viewDetail: (id, selectedTag, index) {
                  _navigateToViewEmail(context, ref, id, index, tagsListModel);
                },
                rightActions: const ['More', 'Archive', 'Trash'],
                onArchiveEmail: (id, _) =>
                    notifier.changeStatusWithUndo("isArchive", [id]),
                onDeleteEmail: (id, _) =>
                    notifier.changeStatusWithUndo("isTrash", [id]),
                onOptInEmail: (email, index) =>
                    notifier.handleSingleEmailOptIn(email, index),
                selectedEmailId: state.currentlyViewedEmailId,
              ),
              // Dark overlay when filter is shown
              if (showFilter)
                Positioned.fill(
                  child: Container(
                    color: Theme.of(context).colorScheme.scrim.withValues(alpha: 0.5),
                  ),
                ),
              // Filter options overlay for mobile
              if (showFilter)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Material(
                    elevation: 4,
                    child: Container(
                      width: double.infinity,
                      color: Theme.of(context).colorScheme.surface,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Unread option
                          InkWell(
                            onTap: () {
                              notifier.applyUnreadFilter(state.searchKey);
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 14),
                              child: Row(
                                children: [
                                  SvgPicture.asset(
                                    svgUnread,
                                    height: 20,
                                    width: 20,
                                    colorFilter: ColorFilter.mode(
                                      context.colors.onSurfaceVariant,
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    unread,
                                    style: AppTypography.labelMedium(context).copyWith(
                                      color: context.colors.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Divider(
                              height: 1, thickness: 1, color: context.colors.outlineVariant),
                          // Tags option
                          InkWell(
                            onTap: () {
                              final tags = tagsState.tagsList?.data.tags;
                              if (tags != null && tags.isNotEmpty) {
                                notifier.showTagListFromFilter();
                              } else {
                                CommonService.animatedToast(
                                  "No Tags Found",
                                  "warning",
                                  null,
                                  true,
                                );
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 14),
                              child: Row(
                                children: [
                                  SvgPicture.asset(
                                    svgTags,
                                    height: 20,
                                    width: 20,
                                    colorFilter: ColorFilter.mode(
                                      context.colors.onSurfaceVariant,
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    tag,
                                    style: AppTypography.labelMedium(context).copyWith(
                                      color: context.colors.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              if (showTagList)
                TagListOverlayWidget(
                  isForAddingTags: state.selectedEmailIds.isNotEmpty ||
                      state.selectedEmailIdForReadingPane != null,
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
        ),
      ],
    );
  }
}
