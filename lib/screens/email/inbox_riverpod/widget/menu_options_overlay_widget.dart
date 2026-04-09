import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:optmsg/common/responsive/responsive.dart';

import '../../../../constant/img_path.dart';
import '../../../../constant/string_constant.dart';
import '../../../../constant/styles.dart';
import '../../../../widgets/drawer_item.dart';
import '../inbox_notifier.dart';

Widget menuOptionsOverlayWidget(WidgetRef ref, BuildContext context) {
  final (:items, :selectedEmailIds) = ref.watch(
    inboxProvider.select((s) => (
      items: s.items,
      selectedEmailIds: s.selectedEmailIds,
    )),
  );
  final notifier = ref.read(inboxProvider.notifier);

  // Determine selection state
  String selectionState() {
    final selected = items
        .where((e) => selectedEmailIds.contains(e.emailId))
        .toList();

    if (selected.isEmpty) return 'none';

    final allUnread = selected.every((e) => !e.isRead);
    final allRead = selected.every((e) => e.isRead);

    if (selected.length == 1 && selected.first.isRead) {
      return 'singleRead';
    }

    if (selected.length == 1 && !selected.first.isRead) {
      return 'singleUnread';
    }

    if (allUnread) return 'allUnread';
    if (allRead) return 'allRead';

    return 'mixed';
  }

  final selState = selectionState();

  // Close overlay
  void closeMenu() {
    notifier.setShowMenuOptions(false);
  }

  // Tag action
  void handleTagTap() {
    closeMenu();
    notifier.handleTagAction();
  }

  // Archive
  void archive() {
    closeMenu();
    notifier.handleArchive();
  }

  // Move
  void move() {
    closeMenu();
    notifier.handleMoveToFolderAction();
  }

  // Trash
  void trash() {
    closeMenu();
    notifier.handleDelete();
  }

  // Mark read or unread
  Future<void> toggleReadState() async {
    closeMenu();

    if (selState == 'allUnread' || selState == 'singleUnread') {
      await notifier.handleMarkUnread();
    } else {
      await notifier.updateEmailStatus('isRead', selectedEmailIds, 0);
    }

    notifier.clearSelection();
  }

  // Opt-in
  void optIn() {
    closeMenu();
    notifier.handleBulkOptInAction();
  }

  // ------------------------ UI ------------------------
  return InkWell(
    onTap: closeMenu,
    child: Container(
      decoration: const BoxDecoration(
        color: AppStyles.backDrop,
      ),
      child: Column(
        children: [
          Container(
            color: Theme.of(context).colorScheme.surface,
            child: Column(
              children: [
                MyDrawerItem(
                  title: 'Tag',
                  svgIcon: svgTags,
                  onTap: handleTagTap,
                  showRightIcon: false,
                ),

                /// MOVE
                MyDrawerItem(
                  title: 'Move',
                  svgIcon: svgFolderInput,
                  onTap: move,
                  showRightIcon: false,
                ),

                /// ARCHIVE
                MyDrawerItem(
                  title: 'Archive',
                  svgIcon: svgArchive,
                  onTap: archive,
                  showRightIcon: false,
                ),

                /// TRASH
                MyDrawerItem(
                  title: 'Trash',
                  svgIcon: svgTrash1,
                  onTap: trash,
                  showRightIcon: false,
                ),

                // ---------- MARK READ / UNREAD ----------
                if (selState == 'mixed')
                  Column(
                    children: [
                      MyDrawerItem(
                        title: markRead,
                        svgIcon: svgRead,
                        onTap: () async {
                          closeMenu();
                          await notifier.markSelectedAsRead();
                          notifier.clearSelection();
                        },
                        showRightIcon: false,
                      ),
                      MyDrawerItem(
                        title: markUnread,
                        svgIcon: svgUnread,
                        onTap: () async {
                          closeMenu();
                          await notifier.updateEmailStatus(
                              'isRead', selectedEmailIds, 0);
                          notifier.clearSelection();
                        },
                        showRightIcon: false,
                      ),
                    ],
                  )
                else if (selState == 'allRead' || selState == 'singleRead')
                  MyDrawerItem(
                    title: markUnread,
                    svgIcon: svgUnread,
                    onTap: toggleReadState,
                    showRightIcon: false,
                  )
                else if (selState == 'allUnread' || selState == 'singleUnread')
                  MyDrawerItem(
                    title: markRead,
                    svgIcon: svgRead,
                    onTap: toggleReadState,
                    showRightIcon: false,
                  ),

                /// OPT-IN
                MyDrawerItem(
                  title: 'Opt-In',
                  svgIcon: svgOptin,
                  svgColor: context.appColors.svgIconAccent,
                  onTap: optIn,
                  showRightIcon: false,
                ),
              ],
            ),
          ),

          /// Bottom decoration
          Container(
            decoration: const BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
