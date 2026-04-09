import 'package:optmsg/common/responsive/responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../constant/img_path.dart';
import '../../../../constant/string_constant.dart';
import '../../../../constant/styles.dart';
import 'package:optmsg/constant/app_typography.dart';
import '../../../../services/common_service.dart';
import '../../../../widgets/custom_switchlist.dart';
import '../../../../widgets/drawer_item.dart';
import '../../../../widgets/load_container/delayed_loading_overlay.dart';
import '../../../../widgets/pop_up_modal.dart';
import '../../profile_riverpod/profile_notifier.dart';
import '../settings_notifier.dart';
import 'package:go_router/go_router.dart';
import '../../../../router/app_routes.dart';

class SettingsDesktopLayout extends ConsumerWidget {
  const SettingsDesktopLayout({super.key});

  static const Divider _divider = Divider();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 24,
              ),
              child: _SettingsList(),
            ),
          ),
        ),
        _LogoutButton(),
        const SizedBox(height: AppStyles.space32),
        Text(
          slogan,
          textAlign: TextAlign.center,
          style: AppTypography.slogan(context),
        ),
        const SizedBox(height: AppStyles.space32),
      ],
    );
  }
}

//////////////////////////////////////////////////////////////////////////////
/// Settings List
//////////////////////////////////////////////////////////////////////////////

class _SettingsList extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final profileNotifier = ref.read(profileProvider.notifier);
    final isWeb = CommonService().getPlatform() == "web";

    return DelayedLoadingOverlay(
      isLoading: state.isLoading,
      child: Container(
      decoration: BoxDecoration(
        border: Border.all(color: context.colors.outlineVariant),
        borderRadius: BorderRadius.circular(AppStyles.radiusM),
      ),
      child: Column(
        children: [
          _DrawerAction(
            title: profile,
            icon: svgUser,
            onTap: () {
              profileNotifier.disableEdit();
              profileNotifier.fetchProfile();
              context.go(AppRoutes.profile);
            },
          ),
          SettingsDesktopLayout._divider,
          _DrawerAction(
            title: account,
            icon: svgUserSettings,
            onTap: () => context.go(AppRoutes.account),
          ),
          SettingsDesktopLayout._divider,
          _SwitchItem(
            title: manageNotification,
            value: state.isNotificationSelected,
            onChanged: notifier.toggleNotification,
            icon: SvgPicture.asset(
              svgNoNotifications,
              colorFilter:
                  ColorFilter.mode(context.colors.onSurface, BlendMode.srcIn),
            ),
          ),
          if (!isWeb) ...[
            SettingsDesktopLayout._divider,
            _SwitchItem(
              title: manageBiometric,
              value: state.isBiometricSelected,
              onChanged: notifier.toggleBiometric,
              icon: Icon(Icons.login, size: 24, color: context.colors.onSurface),
            ),
          ],
          SettingsDesktopLayout._divider,
          _SwitchItem(
            title: sortContact,
            value: !state.lastNameSorted,
            onChanged: notifier.toggleSort,
            icon: Icon(Icons.contacts, size: 24, color: context.colors.onSurface),
          ),
          SettingsDesktopLayout._divider,
          _SwitchItem(
            title: readingPaneText,
            value: state.readingPaneEnabled,
            onChanged: notifier.toggleReadingPane,
            icon: SvgPicture.asset(
              svgReadingPane,
              colorFilter:
                  ColorFilter.mode(context.colors.onSurface, BlendMode.srcIn),
            ),
          ),
          if (!isWeb) ...[
            SettingsDesktopLayout._divider,
            _SwitchItem(
              title: importContactDevice,
              value: state.syncContact,
              onChanged: notifier.toggleSyncContacts,
              icon: Icon(Icons.contacts, size: 24, color: context.colors.onSurface),
            ),
          ],
          SettingsDesktopLayout._divider,
          _ThemeModeSelector(
            value: state.themeModePref,
            onChanged: notifier.setThemeMode,
          ),
        ],
      ),
    ),
    );
  }
}

//////////////////////////////////////////////////////////////////////////////
/// Drawer Action
//////////////////////////////////////////////////////////////////////////////

class _DrawerAction extends StatelessWidget {
  final String title;
  final String icon;
  final VoidCallback onTap;

  const _DrawerAction({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return MyDrawerItem(
      title: title,
      svgIcon: icon,
      showIndicator: false,
      showChevron: true,
      onTap: onTap,
    );
  }
}

//////////////////////////////////////////////////////////////////////////////
/// Switch Item
//////////////////////////////////////////////////////////////////////////////

class _SwitchItem extends StatelessWidget {
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;
  final Widget icon;

  const _SwitchItem({
    required this.title,
    required this.value,
    required this.onChanged,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return CustomSwitchListTile(
      title: title,
      value: value,
      onChanged: onChanged,
      secondary: icon,
    );
  }
}

//////////////////////////////////////////////////////////////////////////////
/// Theme Mode Selector (Light / System / Dark)
//////////////////////////////////////////////////////////////////////////////

class _ThemeModeSelector extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;

  const _ThemeModeSelector({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 5.0),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.dark_mode, size: 24, color: context.colors.onSurface),
              const SizedBox(width: 14.5),
              Text(darkModeText, style: AppTypography.drawerTitle(context)),
              const Spacer(),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'light', icon: Icon(Icons.light_mode, size: 18)),
                  ButtonSegment(value: 'system', icon: Icon(Icons.settings_brightness, size: 18)),
                  ButtonSegment(value: 'dark', icon: Icon(Icons.dark_mode, size: 18)),
                ],
                selected: {value},
                onSelectionChanged: (selected) => onChanged(selected.first),
                showSelectedIcon: false,
                style: ButtonStyle(
                  visualDensity: VisualDensity.compact,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  padding: const WidgetStatePropertyAll(
                    EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  ),
                  textStyle: WidgetStatePropertyAll(
                    AppTypography.labelSmall(context),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppStyles.space8),
        ],
      ),
    );
  }
}

//////////////////////////////////////////////////////////////////////////////
/// Logout Button
//////////////////////////////////////////////////////////////////////////////

class _LogoutButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(settingsProvider.notifier);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () {
            showDialog(
              context: context,
              useRootNavigator: true,
              builder: (dialogContext) => CustomPopupModal(
                icon: svgLogOut,
                title: logOut,
                subtitle: logOutText,
                textButton1: 'No',
                textButton2: 'Yes',
                onPressedButton1: () =>
                    Navigator.of(dialogContext, rootNavigator: true).pop(),
                onPressedButton2: () {
                  // Close the confirmation dialog
                  Navigator.of(dialogContext, rootNavigator: true).pop();

                  // Perform logout via Riverpod notifier
                  notifier.performLogout();
                },
              ),
            );
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                svgLogOutSettings,
                width: 24,
                height: 24,
                colorFilter: ColorFilter.mode(
                  Theme.of(context).colorScheme.error,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: AppStyles.space16),
              Text(logOut, style: AppTypography.logOut(context)),
            ],
          ),
        ),
      ),
    );
  }
}
