import 'package:optmsg/common/responsive/responsive.dart';
import 'package:optmsg/constant/app_typography.dart';
import 'package:optmsg/widgets/reading_pane_placeholder.dart';
import 'package:optmsg/constant/img_path.dart';
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
import 'package:optmsg/widgets/custom_dismissible.dart';
import 'package:optmsg/widgets/move_picker_overlay.dart';
import 'package:optmsg/widgets/draggable_divider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:optmsg/services/tags_provider.dart';

class ArchiveDesktopLayout extends ConsumerWidget {
  final ArchiveState state;
  final ArchiveNotifier notifier;
  final bool showReadingPane;
  final Function(int, dynamic, int) onViewDetail;
  final VoidCallback? onLongPress;

  const ArchiveDesktopLayout({
    super.key,
    required this.state,
    required this.notifier,
    required this.showReadingPane,
    required this.onViewDetail,
    this.onLongPress,
  });

  static final _pathLabelMap = {
    AppRoutes.sent: 'Sent',
    AppRoutes.archive: 'Archive',
    AppRoutes.trash: 'Trash',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tagsNotifier = ref.read(tagsProvider);
    final tagsList = tagsNotifier.tagsList?.data.tags ?? [];

    final hasReadingPaneSelection =
        showReadingPane && state.selectedEmailIdForReadingPane != null;
    final hasAnySelection =
        hasReadingPaneSelection || state.selectedEmailIds.isNotEmpty;

    return Column(
      children: [
        ArchiveActionBar(
          state: state,
          notifier: notifier,
          hasAnySelection: hasAnySelection,
          hasReadingPaneSelection: hasReadingPaneSelection,
          showReadingPaneActions: showReadingPane,
        ),
        Expanded(
          child: showReadingPane
              ? _buildSplitView(context, tagsList)
              : _buildEmailListPane(context, tagsList),
        ),
      ],
    );
  }

  // ========================= SPLIT VIEW =========================

  Widget _buildSplitView(BuildContext context, List tagsList) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        final widths = _getPaneWidths(totalWidth);

        final listPaneWidth = (state.emailListPaneWidth ?? widths.defaultWidth)
            .clamp(widths.minWidth, widths.maxWidth);

        return ResizableSplitPane(
          isHorizontal: true,
          initialFirstPaneSize: listPaneWidth,
          minFirstPaneSize: widths.minWidth,
          maxFirstPaneSize: widths.maxWidth,
          onSizeChanged: notifier.setEmailListPaneWidth,
          firstChild: _buildEmailListPane(context, tagsList),
          secondChild: _buildReadingPane(context),
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

  // ========================= EMAIL LIST =========================

  Widget _buildEmailListPane(BuildContext context, List tagsList) {
    return Column(
      children: [
        _buildHeader(context),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Divider(),
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
        Expanded(
          child: Stack(
            children: [
              _buildEmailList(context, tagsList),
              ..._buildOverlays(context),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
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
          if (canShowToggle)
            SizedBox(
              width: cbSize,
              height: cbSize,
              child: InkWell(
                borderRadius: BorderRadius.circular(AppStyles.radiusXL),
                onTap: () {
                  if (!isMultiSelectActive) {
                    notifier.setShowCheckboxes(true);
                  } else if (state.allEmailIdsFlag) {
                    notifier.clearSelection();
                  } else {
                    notifier.selectAllFromList();
                  }
                },
                onLongPress: isMultiSelectActive
                    ? () {
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
            _getCurrentMenuLabel(),
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
          _buildFilterIcon(context),
        ],
      ),
    );
  }

  Widget _buildEmailList(BuildContext context, List tagsList) {
    return CustomDismissible(
      onLongPress: notifier.onLongPress,
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
      onRefresh: notifier.refresh,
      onEndReached: () {
        if (!state.isLoading && state.inboxList?.data.nextPage == true) {
          notifier.getAllEmails(state.searchKey);
        }
      },
      shouldShowStartPane: true,
      selectedIndex: state.currentPath == AppRoutes.trash
          ? state.selectedIndex
          : null,
      items: state.items,
      addEmailTags: notifier.addEmailTags,
      emailType: state.currentPath?.split('/').last ?? 'trash',
      updateEmailStatus: notifier.updateInboxEmailStatus,
      tagsList: tagsList,
      rightActions: state.currentPath == AppRoutes.archive
          ? ['More', 'Sent', 'Trash']
          : ['More', 'Archive', 'Trash'],
      userData: notifier.userData,
      viewDetail: (id, tag, index) {
        notifier.setSelectedEmails([], []);
        onViewDetail(id, tag, index);
      },
      onMoveToInboxEmail: notifier.handleSingleEmailMoveToInbox,
      onArchiveEmail: notifier.handleSingleEmailArchive,
      onDeleteEmail: (id, index) => notifier.handleSingleEmailDelete(id, index),
      onOptInEmail: (email, index) =>
          notifier.handleSingleEmailOptIn(email, index),
      selectedEmailId: state.selectedEmailIdForReadingPane,
      onShiftClick: (index) {
        int from;
        if (state.lastClickedIndex != -1) {
          from = state.lastClickedIndex;
        } else if (state.selectedEmailIdForReadingPane != null) {
          final viewedIdx = state.items.indexWhere(
            (e) =>
                e.receivers != null &&
                e.receivers!.isNotEmpty &&
                e.receivers![0].emailId == state.selectedEmailIdForReadingPane,
          );
          from = viewedIdx != -1 ? viewedIdx : index;
        } else {
          from = index;
        }
        notifier.selectRangeFromList(from, index);
      },
      onCtrlClick: (index) {
        if (state.selectedEmailIds.isEmpty &&
            state.selectedEmailIdForReadingPane != null) {
          final viewedIdx = state.items.indexWhere(
            (e) =>
                e.receivers != null &&
                e.receivers!.isNotEmpty &&
                e.receivers![0].emailId == state.selectedEmailIdForReadingPane,
          );
          if (viewedIdx != -1) {
            notifier.toggleSingleSelectByIndex(viewedIdx);
          }
        }
        notifier.toggleSingleSelectByIndex(index);
      },
    );
  }

  List<Widget> _buildOverlays(BuildContext context) {
    return [
      if (state.showFilter) archiveFilterOverlay(state, notifier, context),
      if (state.showTagList) archiveTagListOverlay(state, notifier, context),
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
    ];
  }

  static String _currentFolderName(String? path) {
    if (path == AppRoutes.archive) return 'archive';
    if (path == AppRoutes.sent) return 'sent';
    if (path == AppRoutes.trash) return 'trash';
    return 'archive';
  }

  // ========================= READING PANE =========================

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
                onAction: _handleReadingPaneAction,
              )
            : const ReadingPanePlaceholder.inbox(),
        if (state.showReadingPaneMenuOptions &&
            state.selectedEmailIdForReadingPane != null)
          ArchiveReadingPaneMenuOverlay(state: state, notifier: notifier),
      ],
    );
  }

  void _handleReadingPaneAction(Map<String, dynamic> data) {
    final emailId = data['emailId'] as int?;
    final type = data['type'] as String?;

    if (emailId != null) {
      if ({
        'isArchive',
        'isTrash',
        'isDeleted',
        'isInbox',
        'isSent',
      }.contains(type)) {
        notifier.removeEmailFromListById(emailId);
      } else if (type == 'tagsUpdated') {
        final tags = data['updatedTags'];
        if (tags is List) {
          notifier.updateEmailTagsInList(emailId, tags.cast());
        }
      }
    }
  }

  // ========================= HELPERS =========================

  String _getCurrentMenuLabel() => _pathLabelMap[state.currentPath] ?? 'Inbox';

  String _getEmailTypeForView() => _pathLabelMap[state.currentPath] ?? 'Inbox';

  Widget _buildFilterIcon(BuildContext context) {
    if (state.emailType == 'unread') {
      return _icon(
        svgUnread,
        notifier.clearUnreadFilter,
        'Clear Unread Filter',
        context: context,
      );
    }
    if (state.tagFilter) {
      return _icon(
        svgTags,
        notifier.clearTagFilter,
        'Clear Tag Filter',
        context: context,
      );
    }
    return _icon(svgFilter, notifier.toggleFilter, 'Filter', context: context);
  }

  Widget _icon(
    String asset,
    VoidCallback action,
    String tip, {
    required BuildContext context,
  }) {
    return IconButton(
      icon: SvgPicture.asset(
        asset,
        height: 20,
        width: 20,
        colorFilter: ColorFilter.mode(
          context.colors.onSurface,
          BlendMode.srcIn,
        ),
      ),
      onPressed: action,
      tooltip: tip,
    );
  }
}

// ========================= MODELS =========================

class _PaneWidths {
  final double minWidth;
  final double maxWidth;
  final double defaultWidth;

  _PaneWidths({
    required this.minWidth,
    required this.maxWidth,
    required this.defaultWidth,
  });
}
