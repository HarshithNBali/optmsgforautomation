import 'package:optmsg/common/responsive/responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../widgets/load_container/delayed_loading_overlay.dart';
import 'account_notifier.dart';
import 'layouts/layouts.dart';

class Accountriverpod extends ConsumerWidget {
  final bool? isSideMenuCollapsed;
  final VoidCallback? onToggleSideMenu;

  const Accountriverpod({
    super.key,
    this.isSideMenuCollapsed,
    this.onToggleSideMenu,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(accountProvider);

    return Scaffold(
      body: SafeArea(
        top: false,
        bottom: false,
        child: DelayedLoadingOverlay(
          isLoading: state.isLoading,
          child: _buildBody(context),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    final isMobile = AppBreakpoints.isMobileLayout(context);

    if (isMobile) {
      return const AccountMobileLayout();
    } else if (AppBreakpoints.isTabletLayout(context)) {
      return const AccountTabletLayout();
    } else {
      return const AccountDesktopLayout();
    }
  }
}
