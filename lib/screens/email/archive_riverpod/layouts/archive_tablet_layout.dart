import 'package:optmsg/common/responsive/responsive.dart';
import 'package:optmsg/constant/app_typography.dart';
import 'package:optmsg/constant/img_path.dart';
import 'package:optmsg/widgets/reading_pane_placeholder.dart';
import 'package:optmsg/constant/string_constant.dart';
import 'package:optmsg/constant/styles.dart';
import 'package:optmsg/router/app_routes.dart';
import 'package:optmsg/screens/email/archive_riverpod/archive_list_notifier.dart';
import 'package:optmsg/screens/email/archive_riverpod/archive_state.dart';
import 'package:optmsg/screens/email/archive_riverpod/widget/archive_action_bar.dart';
import 'package:optmsg/screens/email/archive_riverpod/widget/archive_filter_overlay.dart';
import 'package:optmsg/screens/email/archive_riverpod/widget/archive_menu_options_overlay.dart';
import 'package:optmsg/screens/email/archive_riverpod/widget/archive_reading_pane_menu_overlay.dart';
import 'package:optmsg/screens/email/archive_riverpod/widget/archive_tag_list_overlay.dart';
import 'package:optmsg/screens/inbox/view_email.dart';
import 'package:optmsg/services/tags_provider.dart';
import 'package:optmsg/widgets/custom_dismissible.dart';
import 'package:optmsg/widgets/move_picker_overlay.dart';
import 'package:optmsg/widgets/draggable_divider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ArchiveTabletLayout extends ConsumerWidget {
  final ArchiveState state;
  final ArchiveNotifier notifier;
  final bool showReadingPane;
  final Function(int, dynamic, int) onViewDetail;
  final VoidCallback? onLongPress;

  const ArchiveTabletLayout({
    super.key,
    required this.state,
    required this.notifier,
    required this.showReadingPane,
    required this.onViewDetail,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tagProvider = ref.read(tagsProvider);
    final tagsList = tagProvider.tagsList?.data.tags ?? [];
    // Only show reading pane selection in action bar when reading pane is active
    // This ensures action ribbon doesn't show when returning from full-screen detail view
    final bool hasReadingPaneSelection =
        showReadingPane && state.selectedEmailIdForReadingPane != null;
    final bool hasListSelection = state.selectedEmailIds.isNotEmpty;
    final bool hasAnySelection = hasReadingPaneSelection || hasListSelection;
    bool isListingEmails = (state.inboxList?.data.emails.isNotEmpty ?? false);
    // Use the showReadingPane parameter passed from archive_responsive (already includes screen width check)
    return Column(
      children: [
        // Full-width action bar
        ArchiveActionBar(
          state: state,
          notifier: notifier,
          hasAnySelection: hasAnySelection,
          hasReadingPaneSelection: hasReadingPaneSelection,
          showReadingPaneActions: showReadingPane,
        ),
        // Main content area
        // Only show reading pane if enabled (user preference AND screen width check)
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

              // Only show reading pane if enabled - don't show just because an email is selected
              final shouldShowReadingPane = showReadingPane;

              if (isLandscape) {
                return _buildLandscapeLayout(
                  context,
                  ref,
                  tagsList,
                  hasAnySelection,
                  shouldShowReadingPane,
                );
              } else {
                // Portrait mode: always use Column layout (reading pane below)
                return _buildPortraitLayout(
                  context,
                  tagsList,
                  hasAnySelection,
                  shouldShowReadingPane,
                  isListingEmails,
                );
              }
            },
          ),
        ),
      ],
    );
  }

  /// Build landscape layout with email list and reading pane side-by-side
  Widget _buildLandscapeLayout(
    BuildContext context,
    WidgetRef ref,
    List tagsList,
    bool hasAnySelection,
    bool shouldShowReadingPane,
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

        if (shouldShowReadingPane) {
          return ResizableSplitPane(
            isHorizontal: true,
            initialFirstPaneSize: listPaneWidth,
            minFirstPaneSize: minListWidth,
            maxFirstPaneSize: maxListWidth,
            onSizeChanged: (size) {
              notifier.setEmailListPaneWidth(size);
            },
            firstChild: _buildEmailListPane(context, tagsList),
            secondChild: _buildReadingPane(context),
          );
        } else {
          // No reading pane - full screen list
          return _buildEmailListPane(context, tagsList);
        }
      },
    );
  }

  /// Build portrait layout with email list and reading pane stacked
  Widget _buildPortraitLayout(
    BuildContext context,
    List tagsList,
    bool hasAnySelection,
    bool shouldShowReadingPane,
    bool isListingEmails,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final totalHeight = constraints.maxHeight;
        const minPaneHeight = 200.0;
        final maxPaneHeight = totalHeight * 0.6;
        final defaultHeight = totalHeight * 0.35;

        // Reuse emailListPaneWidth to store reading pane height in portrait mode
        final paneHeight = (state.emailListPaneWidth ?? defaultHeight).clamp(
          minPaneHeight,
          maxPaneHeight,
        );

        if (shouldShowReadingPane) {
          return ResizableSplitPane(
            isHorizontal: false,
            initialFirstPaneSize: paneHeight,
            minFirstPaneSize: minPaneHeight,
            maxFirstPaneSize: maxPaneHeight,
            onSizeChanged: (size) {
              notifier.setEmailListPaneWidth(size);
            },
            firstChild: _buildEmailListPane(context, tagsList),
            secondChild: _buildReadingPane(context),
          );
        } else {
          // No reading pane - full screen list
          return _buildEmailListPane(context, tagsList);
        }
      },
    );
  }

  /// Build the email list pane
  Widget _buildEmailListPane(BuildContext context, List tagsList) {
    final String currentMenuLabel = _getCurrentMenuLabel();
    final bool showCheckbox =
        kIsWeb && (state.showCheckboxes || state.selectedEmailIds.isNotEmpty);

    return Column(
      children: [
        // List header
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
                currentMenuLabel,
                style: AppTypography.titleMedium(
                  context,
                ).copyWith(color: context.colors.onSurface),
              ),
              const Spacer(),
              // Checkbox toggle button
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
                      notifier.setShowCheckboxes(false);
                      notifier.setSelectedEmails([], []);
                    } else {
                      // Currently hidden - show checkboxes
                      notifier.setShowCheckboxes(true);
                    }
                  },
                  tooltip: showCheckbox ? 'Hide Checkboxes' : 'Show Checkboxes',
                ),
              _buildFilterIcon(context),
            ],
          ),
        ),
        // Divider
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Container(height: 1, color: context.colors.outlineVariant),
        ),
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
                          style: AppTypography.timeStamp(
                            context,
                          ).copyWith(color: context.colors.onSurfaceVariant),
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
        // Email list
        Expanded(
          child: Stack(
            children: [
              CustomDismissible(
                onLongPress: (int id, String email) {
                  notifier.onLongPress(id, email);
                },
                longPress: kIsWeb ? state.showCheckboxes : !state.longPressFlag,
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
                selectedEmailId: state.selectedEmailIdForReadingPane,
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
                  onViewDetail(emailId, tag, index);
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
                archiveFilterOverlay(state, notifier, context),
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

  /// Build the reading pane
  Widget _buildReadingPane(BuildContext context) {
    return Stack(
      children: [
        state.selectedEmailIdForReadingPane != null
            ? ViewEmail(
                key: ValueKey(
                  '${state.selectedEmailIdForReadingPane}_${state.readingPaneRefreshKey}',
                ),
                emailId: state.selectedEmailIdForReadingPane!,
                emailType: _getEmailTypeForView(),
                allTagsList: state.selectedEmailTags,
                itemIndex: state.selectedEmailIndex,
                hideAppBar: true,
                onAction: (actionData) {
                  // Handle action from ViewEmail when in reading pane mode
                  // The API call is already done by ViewEmail, just update the list
                  final emailId = actionData['emailId'] as int?;
                  final actionType = actionData['type'] as String?;

                  if (emailId != null) {
                    // For actions that move the email out of archive (trash, inbox, delete)
                    // remove it from the list
                    if (actionType == 'isArchive' ||
                        actionType == 'isTrash' ||
                        actionType == 'isDeleted' ||
                        actionType == 'isInbox' ||
                        actionType == 'isSent') {
                      notifier.removeEmailFromListById(emailId);
                    } else if (actionType == 'tagsUpdated') {
                      final tags = actionData['updatedTags'];
                      if (tags is List) {
                        notifier.updateEmailTagsInList(emailId, tags.cast());
                      }
                    }
                  }
                },
              )
            : const ReadingPanePlaceholder.inbox(),
        if (state.showReadingPaneMenuOptions &&
            state.selectedEmailIdForReadingPane != null)
          ArchiveReadingPaneMenuOverlay(state: state, notifier: notifier),
      ],
    );
  }

  String _getCurrentMenuLabel() {
    if (state.currentPath == AppRoutes.sent) return 'Sent';
    if (state.currentPath == AppRoutes.archive) return 'Archive';
    if (state.currentPath == AppRoutes.trash) return 'Trash';
    return 'Inbox';
  }

  String _getEmailTypeForView() {
    if (state.currentPath == AppRoutes.trash) return 'Trash';
    if (state.currentPath == AppRoutes.archive) return 'Archive';
    if (state.currentPath == AppRoutes.sent) return 'Sent';
    return 'Inbox';
  }

  void _handleSelectAllEmails() {
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
  }

  Widget _buildFilterIcon(BuildContext context) {
    if (state.emailType == 'unread') {
      return IconButton(
        icon: SvgPicture.asset(
          svgUnread,
          height: 20,
          width: 20,
          colorFilter: ColorFilter.mode(
            context.colors.onSurface,
            BlendMode.srcIn,
          ),
        ),
        onPressed: () => notifier.clearUnreadFilter(),
        tooltip: 'Clear Unread Filter',
      );
    } else if (state.tagFilter) {
      return IconButton(
        icon: SvgPicture.asset(
          svgTags,
          height: 20,
          width: 20,
          colorFilter: ColorFilter.mode(
            context.colors.onSurface,
            BlendMode.srcIn,
          ),
        ),
        onPressed: () => notifier.clearTagFilter(),
        tooltip: 'Clear Tag Filter',
      );
    } else {
      return IconButton(
        icon: SvgPicture.asset(
          svgFilter,
          height: 20,
          width: 20,
          colorFilter: ColorFilter.mode(
            context.colors.onSurface,
            BlendMode.srcIn,
          ),
        ),
        onPressed: () => notifier.toggleFilter(),
        tooltip: 'Filter',
      );
    }
  }
}
