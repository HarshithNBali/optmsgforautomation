import 'package:optmsg/constant/img_path.dart';
import 'package:optmsg/constant/styles.dart';
import 'package:optmsg/screens/email/archive_riverpod/archive_list_notifier.dart';
import 'package:optmsg/screens/email/archive_riverpod/archive_state.dart';
import 'package:optmsg/router/app_routes.dart';
import 'package:optmsg/widgets/drawer_item.dart';
import 'package:flutter/material.dart';

class ArchiveReadingPaneMenuOverlay extends StatelessWidget {
  final ArchiveState state;
  final ArchiveNotifier notifier;

  const ArchiveReadingPaneMenuOverlay({
    super.key,
    required this.state,
    required this.notifier,
  });

  static const String archivePath = AppRoutes.archive;
  static const String sentPath = AppRoutes.sent;
  static const String trashPath = AppRoutes.trash;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Close menu',
      button: true,
      child: InkWell(
      onTap: notifier.closeReadingPaneMenu,
      child: Container(
        decoration: const BoxDecoration(color: AppStyles.backDrop),
        child: Column(
          children: [
            Container(
              color: Theme.of(context).colorScheme.surface,
              child: Column(
                children: [
                  if (state.currentPath == trashPath) ..._trashOptions(context),
                  if (state.currentPath == archivePath)
                    ..._archiveOptions(context),
                  if (state.currentPath == sentPath) ..._sentOptions(context),
                ],
              ),
            ),
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
    ),
    );
  }

  /* -------------------- ORIGIN CHECK -------------------- */

  bool get _isSelectedEmailSentByMe {
    final id = state.selectedEmailIdForReadingPane;
    if (id == null) return false;
    final idx = state.items.indexWhere(
      (e) => (e.receivers != null && e.receivers!.isNotEmpty)
          ? e.receivers![0].emailId == id
          : e.id == id,
    );
    if (idx == -1) return false;
    return state.items[idx].senderId == notifier.userId;
  }

  /* -------------------- OPTION GROUPS -------------------- */

  List<Widget> _trashOptions(BuildContext context) => [
    _tagItem(),
    _movePickerItem(),
    _moveItem(title: 'Archive', icon: svgArchive, status: 'isArchive'),
    _deletePermanently(),
    if (_isSelectedEmailSentByMe)
      _moveItem(title: 'Sent', icon: svgSent, status: 'isSent')
    else
      _moveItem(title: 'Inbox', icon: svgInbox, status: 'isInbox'),
    if (!_isSelectedEmailSentByMe) _markUnreadItem(),
  ];

  List<Widget> _archiveOptions(BuildContext context) => [
    _tagItem(),
    _movePickerItem(),
    _moveItem(title: 'Trash', icon: svgTrash1, status: 'isTrash'),
    if (_isSelectedEmailSentByMe)
      _moveItem(title: 'Sent', icon: svgSent, status: 'isSent')
    else
      _moveItem(title: 'Inbox', icon: svgInbox, status: 'isInbox'),
    if (!_isSelectedEmailSentByMe) _markUnreadItem(),
  ];

  List<Widget> _sentOptions(BuildContext context) => [
    _tagItem(),
    _movePickerItem(),
    _moveItem(title: 'Trash', icon: svgTrash1, status: 'isTrash'),
    _moveItem(title: 'Archive', icon: svgArchive, status: 'isArchive'),
  ];

  /* -------------------- SHARED ITEMS -------------------- */

  MyDrawerItem _tagItem() {
    return MyDrawerItem(
      title: 'Tag',
      svgIcon: svgTags,
      showRightIcon: false,
      onTap: () => _withSelectedEmail((id, index) {
        notifier.closeReadingPaneMenu();
        notifier.showList(id, index);
      }),
    );
  }

  MyDrawerItem _movePickerItem() {
    return MyDrawerItem(
      title: 'Move',
      svgIcon: svgFolderInput,
      showRightIcon: false,
      onTap: () {
        notifier.closeReadingPaneMenu();
        notifier.handleMoveAction();
      },
    );
  }

  MyDrawerItem _moveItem({
    required String title,
    required String icon,
    required String status,
  }) {
    return MyDrawerItem(
      title: title,
      svgIcon: icon,
      showRightIcon: false,
      onTap: () => _withSelectedEmail((id, index) {
        _closeReadingPane();
        notifier.updateInboxEmailStatus(status, [id], index);
      }),
    );
  }

  MyDrawerItem _markUnreadItem() {
    return MyDrawerItem(
      title: 'Mark as Unread',
      svgIcon: svgUnread,
      showRightIcon: false,
      onTap: () => _withSelectedEmail((id, index) {
        _closeReadingPane();
        notifier.updateInboxEmailStatus('isRead', [id], index);
      }),
    );
  }

  MyDrawerItem _deletePermanently() {
    return MyDrawerItem(
      title: 'Permanently Delete',
      svgIcon: svgTrash1,
      showRightIcon: false,
      onTap: () {
        final id = state.selectedEmailIdForReadingPane;
        if (id != null) {
          notifier.deleteEmailModal([id]);
        }
      },
    );
  }

  /* -------------------- HELPERS -------------------- */

  void _withSelectedEmail(void Function(int id, int index) action) {
    final id = state.selectedEmailIdForReadingPane;
    final index = state.selectedEmailIndex;

    if (id != null && index != null) {
      action(id, index);
    }
  }

  void _closeReadingPane() {
    notifier.updateReadingPane(id: null, index: null, sender: null);
    notifier.closeReadingPaneMenu();
  }
}
