import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:optmsg/common/app_manger/app_cache.dart';
import 'package:optmsg/constant/img_path.dart';
import 'package:optmsg/router/app_routes.dart';

/// Bottom navigation bar for mobile quick-switching between Inbox, Trash, and Contacts.
///
/// Immediately resets the [AppBarConfig] before navigating so the AppBar
/// title and actions update without a one-frame lag.
class AppNavigationBar extends StatelessWidget {
  const AppNavigationBar({super.key});

  @override
  Widget build(BuildContext context) {
    final currentLocation = GoRouterState.of(context).matchedLocation;
    final selectedIndex = _indexForRoute(currentLocation);
    final cs = Theme.of(context).colorScheme;
    // M-UX-01: When no tab matches the current route (e.g. /settings),
    // use index 0 for NavigationBar (required) but mark none as selected
    // visually so no tab appears highlighted.
    final hasMatch = selectedIndex >= 0;

    return TooltipVisibility(
      visible: false,
      child: NavigationBar(
      selectedIndex: hasMatch ? selectedIndex : 0,
      onDestinationSelected: (index) => _navigate(context, index),
      destinations: [
        NavigationDestination(
          icon: _icon(svgInbox, isSelected: hasMatch && selectedIndex == 0, cs: cs),
          label: 'Inbox',
        ),
        NavigationDestination(
          icon: _icon(svgTrash1, isSelected: hasMatch && selectedIndex == 1, cs: cs),
          label: 'Trash',
        ),
        NavigationDestination(
          icon: _icon(svgRoundUser, isSelected: hasMatch && selectedIndex == 2, cs: cs),
          label: 'Contacts',
        ),
      ],
    ));
  }

  Widget _icon(String asset, {required bool isSelected, required ColorScheme cs}) {
    return SvgPicture.asset(
      asset,
      height: 22,
      colorFilter: ColorFilter.mode(
        isSelected ? cs.primary : cs.onSurfaceVariant,
        BlendMode.srcIn,
      ),
    );
  }

  int _indexForRoute(String path) {
    if (path.startsWith(AppRoutes.inbox)) return 0;
    if (path.startsWith(AppRoutes.trash)) return 1;
    if (path.startsWith(AppRoutes.contacts)) return 2;
    return -1;
  }

  void _navigate(BuildContext context, int index) {
    final route = switch (index) {
      0 => AppRoutes.inbox,
      1 => AppRoutes.trash,
      2 => AppRoutes.contacts,
      _ => AppRoutes.inbox,
    };

    // No pre-config needed — ShellLayout.didUpdateWidget handles go() routes.
    AppCache().setTabName(route);
    GoRouter.of(context).go(route);
  }
}
