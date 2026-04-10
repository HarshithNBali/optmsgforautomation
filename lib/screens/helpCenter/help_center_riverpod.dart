import 'package:optmsg/common/responsive/responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'help_center_provider.dart';
import 'layouts/layouts.dart';

class HelpCenterriverpod extends ConsumerWidget {
  final bool? isSideMenuCollapsed;
  final VoidCallback? onToggleSideMenu;

  const HelpCenterriverpod({
    super.key,
    this.isSideMenuCollapsed,
    this.onToggleSideMenu,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Run init logic once when widget builds
    ref.listen(helpCenterProvider, (_, _) {
      ref.read(helpCenterProvider.notifier).manageComposeFlag();
    });

    return ColoredBox(
      key: const Key('help_center_screen'),
      color: Theme.of(context).colorScheme.surface,
      child: SafeArea(
        top: false,
        bottom: false,
        child: _buildBody(context),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (AppBreakpoints.isTabletLayout(context)) {
      return const HelpCenterTabletLayout();
    } else if (AppBreakpoints.isDesktopLayout(context)) {
      return const HelpCenterDesktopLayout();
    } else {
      return const HelpCenterMobileLayout();
    }
  }
}
