import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../constant/img_path.dart';
import '../../../../constant/styles.dart';
import '../../../../widgets/drawer_item.dart';
import '../inbox_notifier.dart';

Widget readingPaneMenuOverlayWidget(WidgetRef ref, BuildContext context) {
  final (:selectedEmailIdForReadingPane, :selectedEmailIndex) = ref.watch(
    inboxProvider.select((s) => (
      selectedEmailIdForReadingPane: s.selectedEmailIdForReadingPane,
      selectedEmailIndex: s.selectedEmailIndex,
    )),
  );
  final notifier = ref.read(inboxProvider.notifier);

  void closeMenu() {
    notifier.closeReadingPaneMenu();
  }

  // ---- TAG ACTION ----
  void handleTag() {
    closeMenu();

    final id = selectedEmailIdForReadingPane;
    final index = selectedEmailIndex;

    if (id != null && index != null) {
      notifier.handleTagAction();
    }
  }

  // ---- MOVE ACTION ----
  void handleMove() {
    closeMenu();

    final id = selectedEmailIdForReadingPane;
    if (id != null) {
      notifier.handleMoveToFolderAction();
    }
  }

  // ---- ARCHIVE ----
  Future<void> archive() async {
    final id = selectedEmailIdForReadingPane;
    if (id == null) return;

    closeMenu();

    // Close reading pane
    notifier.clearReadingPaneSelection();

    await notifier.changeStatusWithUndo("isArchive", [id]);
  }

  // ---- TRASH ----
  Future<void> trash() async {
    final id = selectedEmailIdForReadingPane;
    if (id == null) return;

    closeMenu();

    notifier.clearReadingPaneSelection();

    await notifier.changeStatusWithUndo("isTrash", [id]);
  }

  // ---- MARK UNREAD ----
  Future<void> markUnread() async {
    final id = selectedEmailIdForReadingPane;
    if (id == null) return;

    closeMenu();

    // Close reading pane when marking as unread
    notifier.clearReadingPaneSelection();

    await notifier.updateEmailStatus(
      "isRead",
      [id],
      0,
    );
  }

  // ---------------- UI ----------------

  return Semantics(
    label: 'Close menu',
    button: true,
    child: InkWell(
    onTap: closeMenu,
    child: Container(
      decoration: const BoxDecoration(color: AppStyles.backDrop),
      child: Column(
        children: [
          Container(
            color: Theme.of(context).colorScheme.surface,
            child: Column(
              children: [
                MyDrawerItem(
                  title: 'Tag',
                  svgIcon: svgTags,
                  onTap: handleTag,
                  showRightIcon: false,
                ),

                /// MOVE
                MyDrawerItem(
                  title: 'Move',
                  svgIcon: svgFolderInput,
                  onTap: handleMove,
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

                /// MARK UNREAD
                MyDrawerItem(
                  title: 'Mark as Unread',
                  svgIcon: svgUnread,
                  onTap: markUnread,
                  showRightIcon: false,
                ),
              ],
            ),
          ),

          // Bottom corner curve filler
          Container(
            decoration: const BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(16.0),
              ),
            ),
          ),
        ],
      ),
    ),
  ),
  );
}
