import 'package:optmsg/common/responsive/responsive.dart';
import 'package:optmsg/screens/settings/profile_riverpod/profile_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../constant/string_constant.dart';
import '../../../widgets/load_container/delayed_loading_overlay.dart';
import '../../../services/app_bar_config_state.dart';
import '../../../widgets/shell_layout.dart';
import 'layouts/layouts.dart';

class Profileriverpod extends ConsumerWidget {
  const Profileriverpod({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(profileProvider);
    final notifier = ref.read(profileProvider.notifier);

    final isMobile = AppBreakpoints.isMobileLayout(context);

    // Update AppBar title for edit mode (route title is "Profile" by default)
    if (state.isEdit) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ShellLayout.of(context)?.setAppBarConfig(const AppBarConfig(
          title: editProfile,
        ));
      });
    }

    return PopScope(
      // Block pop when in edit mode — exit edit first, then pop navigates back
      canPop: !state.isEdit,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && state.isEdit) {
          notifier.disableEdit();
        }
      },
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
          body: SafeArea(
            top: false,
            bottom: false,
            child: DelayedLoadingOverlay(
              isLoading: state.isLoading,
              child: _buildBody(context, isMobile),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, bool isMobile) {
    if (isMobile) {
      return const ProfileMobileLayout();
    } else if (AppBreakpoints.isTabletLayout(context)) {
      return const ProfileTabletLayout();
    } else {
      return const ProfileDesktopLayout();
    }
  }
}
