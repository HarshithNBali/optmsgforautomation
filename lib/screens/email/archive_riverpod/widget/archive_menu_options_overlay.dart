import 'package:optmsg/common/responsive/responsive.dart';
import 'package:optmsg/constant/img_path.dart';
import 'package:optmsg/constant/string_constant.dart';
import 'package:optmsg/constant/styles.dart';
import 'package:optmsg/screens/email/archive_riverpod/archive_list_notifier.dart';
import 'package:optmsg/screens/email/archive_riverpod/archive_state.dart';
import 'package:optmsg/router/app_routes.dart';
import 'package:optmsg/widgets/drawer_item.dart';
import 'package:flutter/material.dart';

class ArchiveMenuOptionsOverlay extends StatelessWidget {
  final ArchiveState state;
  final ArchiveNotifier notifier;

  const ArchiveMenuOptionsOverlay({
    super.key,
    required this.state,
    required this.notifier,
  });

  static const String archivePath = AppRoutes.archive;
  static const String sentPath = AppRoutes.sent;
  static const String trashPath = AppRoutes.trash;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: notifier.closeMenuOptions,
      child: Container(
        decoration: const BoxDecoration(color: AppStyles.backDrop),
        child: Column(
          children: [
            _buildMenuByPath(context),
            const SizedBox(
              height: 1,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -------------------- MENU ROUTER --------------------

  Widget _buildMenuByPath(BuildContext context) {
    switch (state.currentPath) {
      case trashPath:
        return _menuContainer(context, _trashMenuItems(context));
      case archivePath:
        return _menuContainer(context, _archiveMenuItems(context));
      case sentPath:
        return _menuContainer(context, _sentMenuItems(context));
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _menuContainer(BuildContext context, List<Widget> items) {
    return Container(
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface),
      child: Column(children: items),
    );
  }

  // -------------------- MENU DEFINITIONS --------------------

  List<Widget> _trashMenuItems(BuildContext context) {
    final origin = notifier.getSelectionOrigin();
    return [
      _tagItem(context),
      _movePickerItem(context),
      _moveItem(context, 'Archive', svgArchive, 'isArchive'),
      _deletePermanentItem(context),
      if (origin != 'mixed' && origin != 'allSent')
        _moveItem(context, 'Inbox', svgInbox, 'isInbox'),
      if (origin != 'mixed' && origin != 'allReceived')
        _moveItem(context, 'Sent', svgSent, 'isSent'),
      if (origin != 'allSent') _buildMarkAsReadUnreadOptions(context),
      _optInItem(context),
    ];
  }

  List<Widget> _archiveMenuItems(BuildContext context) {
    final origin = notifier.getSelectionOrigin();
    return [
      _tagItem(context),
      _movePickerItem(context),
      _moveItem(context, 'Trash', svgTrash1, 'isTrash'),
      if (origin != 'mixed' && origin != 'allSent')
        _moveItem(context, 'Inbox', svgInbox, 'isInbox'),
      if (origin != 'mixed' && origin != 'allReceived')
        _moveItem(context, 'Sent', svgSent, 'isSent'),
      if (origin != 'allSent') _buildMarkAsReadUnreadOptions(context),
      _optInItem(context),
    ];
  }

  List<Widget> _sentMenuItems(BuildContext context) => [
    _tagItem(context),
    _movePickerItem(context),
    _moveItem(context, 'Trash', svgDelete, 'isTrash'),
    _moveItem(context, 'Archive', svgArchive, 'isArchive'),
  ];

  // -------------------- COMMON ITEMS --------------------

  Widget _tagItem(BuildContext context) {
    return MyDrawerItem(
      title: 'Tag',
      svgIcon: svgTags,
      onTap: () => notifier.showList(0, 1),
      showRightIcon: false,
    );
  }

  Widget _movePickerItem(BuildContext context) {
    return MyDrawerItem(
      title: 'Move',
      svgIcon: svgFolderInput,
      onTap: () => notifier.handleMoveAction(),
      showRightIcon: false,
    );
  }

  Widget _moveItem(
    BuildContext context,
    String title,
    String icon,
    String status,
  ) {
    return MyDrawerItem(
      title: title,
      svgIcon: icon,
      onTap: () => notifier.changeEmailStatus(status),
      showRightIcon: false,
    );
  }

  Widget _deletePermanentItem(BuildContext context) {
    return MyDrawerItem(
      title: 'Permanently Delete',
      svgIcon: svgTrash1,
      onTap: () => notifier.deleteEmailModal(state.selectedEmailIds),
      showRightIcon: false,
    );
  }

  Widget _optInItem(BuildContext context) {
    return MyDrawerItem(
      title: 'Opt-In',
      svgIcon: svgOptin,
      svgColor: context.appColors.svgIconAccent,
      onTap: () {
        if (state.selectedEmails.isNotEmpty) {
          notifier.displayAddEmailModal(state.selectedEmails, 0);
        }
      },
      showRightIcon: false,
    );
  }

  // -------------------- READ / UNREAD --------------------

  Widget _buildMarkAsReadUnreadOptions(BuildContext context) {
    final selectionState = notifier.getSelectionState();

    switch (selectionState) {
      case 'mixed':
        return Column(children: [_markReadItem(), _markUnreadItem()]);

      case 'allRead':
      case 'singleRead':
        return _markUnreadItem();

      case 'allUnread':
      case 'singleUnread':
        return _markReadItem();

      default:
        return const SizedBox.shrink();
    }
  }

  Widget _markReadItem() {
    return MyDrawerItem(
      title: markRead,
      svgIcon: svgRead,
      onTap: () {
        notifier.markSelectedAsReadWithUndo();
        notifier.onLongPress(null, null);
      },
      showRightIcon: false,
    );
  }

  Widget _markUnreadItem() {
    return MyDrawerItem(
      title: markUnread,
      svgIcon: svgUnread,
      onTap: () {
        notifier.updateInboxEmailStatus('isRead', state.selectedEmailIds, 0);
        notifier.onLongPress(null, null);
      },
      showRightIcon: false,
    );
  }
}
