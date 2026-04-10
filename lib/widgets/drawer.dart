import 'package:optmsg/common/app_manger/app_cache.dart';
import 'package:optmsg/services/count_notifier.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:optmsg/common/responsive/responsive.dart';
import 'package:optmsg/constant/img_path.dart';
import 'package:optmsg/widgets/drawer_item.dart';
import 'package:optmsg/constant/string_constant.dart';
import 'package:optmsg/constant/styles.dart';
import 'package:optmsg/constant/app_typography.dart';
import 'package:optmsg/router/app_routes.dart';
import 'package:optmsg/widgets/drawer_tags_section.dart';

class MyDrawer extends ConsumerStatefulWidget {
  const MyDrawer({super.key});

  @override
  ConsumerState<MyDrawer> createState() => _DrawerState();
}

class _DrawerState extends ConsumerState<MyDrawer> {
  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    // Watch the provider for live count updates
    final countState = ref.watch(countProvider);
    final inboxCount = countState.inboxCount;
    final draftCount = countState.draftCount;
    final trashCount = countState.trashCount;
    final archiveCount = countState.archiveCount;

    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: _buildMenu(
                  isLandscape, inboxCount, draftCount, trashCount, archiveCount),
            ),
            if (!isLandscape) ...[
              Text(slogan,
                  style: AppTypography.slogan(context)
                      .copyWith(color: Theme.of(context).colorScheme.primary)),
              SizedBox(
                height: AppBreakpoints.screenHeight(context) * 0.035,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: AppStyles.space8),
      alignment: Alignment.centerLeft,
      child: Text(menu, style: AppTypography.appBarTitle(context)),
    );
  }

  Widget _buildMenu(bool isLandscape, int inboxCount, int draftCount,
      int trashCount, int archiveCount) {
    final currentLocation = GoRouterState.of(context).matchedLocation;
    final currentUri = GoRouterState.of(context).uri.toString();
    bool isRoute(String route) => currentLocation.startsWith(route);

    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: Padding(
        padding: EdgeInsets.only(top: 8, bottom: isLandscape ? 8 : 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MyDrawerItem(
              testId: 'drawer_inbox_tile',
              title: inbox,
              svgIcon: svgInbox,
              isActive: isRoute(AppRoutes.inbox),
              labelText: inboxCount > 0 ? inboxCount.toString() : null,
              onTap: () => _navigate('Inbox2'),
            ),
            MyDrawerItem(
              testId: 'drawer_drafts_tile',
              title: draft,
              svgIcon: svgDraft,
              draft: true,
              isActive: isRoute(AppRoutes.drafts),
              labelText: draftCount > 0 ? draftCount.toString() : null,
              onTap: () => _navigate('Draft'),
            ),
            MyDrawerItem(
              testId: 'drawer_archive_tile',
              title: archive,
              svgIcon: svgArchive,
              isActive: isRoute(AppRoutes.archive),
              labelText: archiveCount > 0 ? archiveCount.toString() : null,
              onTap: () => _navigate('Archive'),
            ),
            MyDrawerItem(
              testId: 'drawer_sent_tile',
              title: sent,
              svgIcon: svgSent,
              isActive: isRoute(AppRoutes.sent),
              onTap: () => _navigate('Sent'),
            ),
            MyDrawerItem(
              testId: 'drawer_trash_tile',
              title: trash,
              svgIcon: svgTrash1,
              isActive: isRoute(AppRoutes.trash),
              labelText: trashCount > 0 ? trashCount.toString() : null,
              onTap: () => _navigate('Trash'),
            ),
            MyDrawerItem(
              testId: 'drawer_contacts_tile',
              title: contacts,
              svgIcon: svgRoundUser,
              isActive: isRoute(AppRoutes.contacts),
              onTap: () => _navigate('ContactList'),
            ),
            MyDrawerItem(
              testId: 'drawer_help_tile',
              title: helpCenter,
              svgIcon: svgHelp,
              isActive: isRoute(AppRoutes.helpCenter),
              onTap: () => _navigate('HelpCenter'),
            ),
            MyDrawerItem(
              testId: 'drawer_settings_tile',
              title: settings,
              svgIcon: svgSettings,
              isActive: isRoute(AppRoutes.settings),
              onTap: () => _navigate('Settings'),
            ),
            const SizedBox(height: 8),
            Divider(
              height: 1,
              color: Theme.of(context).colorScheme.outlineVariant,
              indent: 16,
              endIndent: 16,
            ),
            const SizedBox(height: 4),
            DrawerTagsSection(
              currentLocation: currentUri,
            ),
          ],
        ),
      ),
    );
  }

  // -------------------- Navigation --------------------

  void _navigate(String name) {
    AppCache().setTabName(name);
    Navigator.of(context).pop(); // close the drawer
    final route = _getMobileRoute(name);
    // No pre-config needed — ShellLayout.didUpdateWidget handles go() routes.
    if (route != null) context.go(route);
  }

  String? _getMobileRoute(String name) {
    switch (name) {
      case 'Inbox':
      case 'Inbox2':
        return AppRoutes.inbox;
      case 'Draft':
        return AppRoutes.drafts;
      case 'Archive':
        return AppRoutes.archive;
      case 'Sent':
        return AppRoutes.sent;
      case 'Trash':
        return AppRoutes.trash;
      case 'ContactList':
        return AppRoutes.contacts;
      case 'Settings':
        return AppRoutes.settings;
      case 'HelpCenter':
        return AppRoutes.helpCenter;
      case 'Compose':
        return AppRoutes.compose;
      default:
        return null;
    }
  }
}
