import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:optmsg/common/responsive/responsive.dart';
import '../../../router/app_routes.dart';
import '../../../main.dart' show appRouter;
import '../../../widgets/load_container/delayed_loading_overlay.dart';
import 'layouts/layouts.dart';
import 'settings_notifier.dart';
import 'package:flutter/foundation.dart';

class Settingriverpod extends ConsumerStatefulWidget {
  final bool? isSideMenuCollapsed;
  final VoidCallback? onToggleSideMenu;

  const Settingriverpod({
    super.key,
    this.isSideMenuCollapsed,
    this.onToggleSideMenu,
  });

  @override
  ConsumerState<Settingriverpod> createState() => _SettingriverpodState();

  static void navigateToLogin() {
    appRouter.go(AppRoutes.login);
  }
}

class _SettingriverpodState extends ConsumerState<Settingriverpod> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(settingsProvider.notifier).getUserData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(settingsProvider.select((s) => s.isLoading));

    return ColoredBox(
      color: Theme.of(context).colorScheme.surface,
      child: SafeArea(
        top: false,
        bottom: false,
        child: DelayedLoadingOverlay(
          isLoading: isLoading,
          child: _buildBody(),
        ),
      ),
    );
  }

  Widget _buildBody() {
    final isMobile = AppBreakpoints.isMobileLayout(context);
    final isDesktop = AppBreakpoints.isDesktopLayout(context);

    if (!kIsWeb || isMobile) {
      return const SettingsMobileLayout();
    }

    if (isDesktop) {
      return const SettingsDesktopLayout();
    }

    return const SettingsTabletLayout();
  }
}
