import 'package:optmsg/common/responsive/responsive.dart';
import 'package:optmsg/constant/app_typography.dart';
import 'package:optmsg/screens/email/archive_riverpod/archive_list_notifier.dart';
import 'package:optmsg/screens/email/archive_riverpod/archive_state.dart';
import 'package:optmsg/screens/email/archive_riverpod/widget/archive_menu_options_overlay.dart';
import 'package:optmsg/screens/email/archive_riverpod/widget/archive_tag_list_overlay.dart';
import 'package:optmsg/services/tags_provider.dart';
import 'package:optmsg/services/common_service.dart';
import 'package:optmsg/widgets/custom_dismissible.dart';
import 'package:optmsg/constant/img_path.dart';
import 'package:optmsg/constant/string_constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:optmsg/widgets/move_picker_overlay.dart';
import 'package:go_router/go_router.dart';
import '../../../../router/app_routes.dart';

class ArchiveMobileLayout extends ConsumerWidget {
  final ArchiveState state;
  final ArchiveNotifier notifier;
  final Function(int, dynamic, int) onViewDetail;
  final VoidCallback? onLongPress;
  final TextEditingController searchController;
  final FocusNode focusNode;

  const ArchiveMobileLayout({
    super.key,
    required this.state,
    required this.notifier,
    required this.onViewDetail,
    this.onLongPress,
    required this.searchController,
    required this.focusNode,
  });

  Future<void> _navigateToViewEmail(
    BuildContext context,
    WidgetRef ref,
    int id,
    int index,
  ) async {
    final tagProvider = ref.read(tagsProvider);
    final emailTypeForView = _determineEmailTypeForView();

    // Set the reading pane selection before navigating
    // This ensures the selection is preserved when resizing from mobile to tablet/desktop
    String? senderEmail;
    if (index >= 0 && index < state.items.length) {
      senderEmail = state.items[index].senderEmail;
    }
    notifier.setReadingPaneSelection(id, index, senderEmail);

    final result = await context.push<Map?>(
      AppRoutes.viewEmailPath(id.toString(), emailTypeForView),
      extra: {
        'emailId': id,
        'emailType': emailTypeForView,
        'allTagsList': tagProvider.tagsList,
        'itemIndex': index,
      },
    );

    if (result == null) {
      // User returned without action - clear the reading pane selection
      notifier.clearReadingPaneSelection();
      return;
    }

    final emailId = result['emailId'] as int?;
    final markedAsUnread = result['markedAsUnread'] == true;

    // Handle tag updates
    final isTagsUpdated = result['isTagsUpdated'] == true;
    final tag = result['tag'];
    debugPrint('[ArchiveMobileLayout] isTagsUpdated: $isTagsUpdated');
    debugPrint('[ArchiveMobileLayout] tag: $tag');
    debugPrint('[ArchiveMobileLayout] tag type: ${tag?.runtimeType}');
    debugPrint(
      '[ArchiveMobileLayout] index: $index, items.length: ${state.items.length}',
    );

    // Refresh list when tags are updated to get accurate tag data from server
    if (isTagsUpdated) {
      debugPrint('[ArchiveMobileLayout] Tags were updated, refreshing list...');
      await notifier.refresh();
      return;
    }

    // Handle "Mark as Unread" flag
    if (markedAsUnread && emailId != null) {
      notifier.markEmailAsUnreadById(emailId);
      // Don't return here - continue to check for other actions
    }

    // Handle actions that remove items from list (undo == true)
    // Note: API call was already made in view_email.dart, so we just need to update the local list
    if (result['undo'] == true && emailId != null) {
      notifier.removeEmailFromListById(emailId);
    }

    // Refresh the list to get updated data from server
    await notifier.refresh();
  }

  String _determineEmailTypeForView() {
    if (state.currentPath == AppRoutes.sent) return 'Sent';
    if (state.currentPath == AppRoutes.archive) return 'Archive';
    if (state.currentPath == AppRoutes.trash) return 'Trash';
    return 'Inbox';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tagProvider = ref.read(tagsProvider);
    final tagsList = tagProvider.tagsList?.data.tags ?? [];
    String sentPath = AppRoutes.sent;
    return Column(
      children: [
        // Search bar removed — now handled by ShellLayout AppBar.bottom
        if (state.currentPath == AppRoutes.trash)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: Row(
                    children: [
                      SvgPicture.asset(
                        svgTrash1,
                        height: 20,
                        width: 20,
                        colorFilter: ColorFilter.mode(
                          context.appColors.accentHover,
                          BlendMode.srcIn,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Flexible(
                        child: Text(
                          autoDeleteItem,
                          style: AppTypography.timeStamp(context).copyWith(
                            color: context.colors.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(),
              ],
            ),
          ),
        Expanded(
          child: Stack(
            children: [
              CustomDismissible(
                onLongPress: (int id, String email) {
                  notifier.onLongPress(id, email);
                },
                longPress: !state.longPressFlag,
                allEmailIdsFlag: state.allEmailIdsFlag,
                selectedEmailIds: state.selectedEmailIds,
                selectedEmails: state.selectedEmails,
                setSelectedEmailIds: (ids, mails) {
                  if (ids.isEmpty && onLongPress != null) {
                    onLongPress!();
                  }
                  notifier.setSelectedEmails(ids, mails);
                },
                onRefresh: () async {
                  await notifier.refresh();
                },
                onEndReached: () {
                  if (!state.isLoading &&
                      state.inboxList?.data.nextPage == true) {
                    notifier.getAllEmails(state.searchKey);
                  }
                },
                shouldShowStartPane: true,
                selectedIndex: state.currentPath == AppRoutes.trash
                    ? state.selectedIndex
                    : null,
                items: state.items,
                addEmailTags: notifier.addEmailTags,
                emailType: state.currentPath == null
                    ? 'trash'
                    : state.currentPath!.split('/')[1],
                updateEmailStatus: notifier.updateInboxEmailStatus,
                tagsList: tagsList,
                rightActions: state.currentPath == AppRoutes.archive
                    ? ['More', 'Sent', 'Trash']
                    : ['More', 'Archive', 'Trash'],
                userData: notifier.userData,
                viewDetail: (emailId, tag, index) {
                  // Clear any selections when viewing an email
                  if (state.selectedEmailIds.isNotEmpty) {
                    notifier.setSelectedEmails([], []);
                  }
                  // For mobile, always navigate directly (like inbox)
                  _navigateToViewEmail(context, ref, emailId, index);
                },
                onMoveToInboxEmail: (int emailId, int index) {
                  if (state.currentPath == AppRoutes.archive ||
                      state.currentPath == AppRoutes.trash) {
                    notifier.handleSingleEmailMoveToInbox(emailId, index);
                  }
                },
                onArchiveEmail: (int emailId, int index) {
                  if (state.currentPath == AppRoutes.sent ||
                      state.currentPath == AppRoutes.trash) {
                    notifier.handleSingleEmailArchive(emailId, index);
                  }
                },
                onDeleteEmail: (int emailId, int index) {
                  notifier.handleSingleEmailDelete(emailId, index);
                },
                onOptInEmail: (email, index) {
                  notifier.handleSingleEmailOptIn(email, index);
                },
              ),
              if (state.showFilter)
                Positioned.fill(
                  child: Container(color: Theme.of(context).colorScheme.scrim.withValues(alpha: 0.5)),
                ),
              // Filter options overlay for mobile
              if (state.showFilter)
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
                          if (state.currentPath != sentPath)
                            InkWell(
                              onTap: () {
                                notifier.applyUnreadFilter();
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
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
                          if (state.currentPath != sentPath)
                            Divider(
                              height: 1,
                              thickness: 1,
                              color: context.colors.outlineVariant,
                            ),
                          // Tags option
                          InkWell(
                            onTap: () {
                              final tags = tagProvider.tagsList?.data.tags;
                              if (tags != null && tags.isNotEmpty) {
                                notifier.tagsOnclick();
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
                                horizontal: 16,
                                vertical: 14,
                              ),
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
                          // Community Recommendations option (only for Trash)
                          if (state.currentPath == AppRoutes.trash) ...[
                            Divider(
                              height: 1,
                              thickness: 1,
                              color: context.colors.outlineVariant,
                            ),
                            InkWell(
                              onTap: () {
                                notifier.applyCommunityFilter();
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                                child: Row(
                                  children: [
                                    SvgPicture.asset(
                                      svgFillFlag,
                                      height: 20,
                                      width: 20,
                                      colorFilter: ColorFilter.mode(
                                        context.colors.onSurfaceVariant,
                                        BlendMode.srcIn,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        communityRecommendation,
                                        style: AppTypography.labelMedium(context).copyWith(
                                          color: context.colors.onSurfaceVariant,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              if (state.showTagList)
                archiveTagListOverlay(state, notifier, context),
              if (state.showMenuOptions)
                ArchiveMenuOptionsOverlay(state: state, notifier: notifier),
              if (state.showMoveOverlay)
                MovePickerOverlay(
                  currentFolder: _currentFolderName(state.currentPath),
                  selectionOrigin: notifier.getSelectionOrigin(),
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

  static String _currentFolderName(String? path) {
    if (path == AppRoutes.archive) return 'archive';
    if (path == AppRoutes.sent) return 'sent';
    if (path == AppRoutes.trash) return 'trash';
    return 'archive';
  }
}
