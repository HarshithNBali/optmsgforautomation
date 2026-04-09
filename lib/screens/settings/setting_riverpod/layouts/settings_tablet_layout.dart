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

class SettingsTabletLayout extends ConsumerWidget {
  const SettingsTabletLayout({super.key});

  static const Divider _divider = Divider();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        const Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: _SettingsList(),
            ),
          ),
        ),
        const _LogoutButton(),
        const SizedBox(height: AppStyles.space32),
        Text(slogan, style: AppTypography.slogan(context)),
        const SizedBox(height: AppStyles.space32),
      ],
    );
  }
}

class _SettingsList extends ConsumerWidget {
  const _SettingsList();

  bool get _isWeb => CommonService().getPlatform() == "web";

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final profileNotifier = ref.read(profileProvider.notifier);

    final switchItems = <_SettingsSwitchItem>[
      _SettingsSwitchItem(
        title: manageNotification,
        value: state.isNotificationSelected,
        onChanged: notifier.toggleNotification,
        icon: SvgPicture.asset(
          svgNoNotifications,
          colorFilter: ColorFilter.mode(context.colors.onSurface, BlendMode.srcIn),
        ),
      ),
      _SettingsSwitchItem(
        title: manageBiometric,
        value: state.isBiometricSelected,
        onChanged: notifier.toggleBiometric,
        icon: Icon(Icons.login, size: 24, color: context.colors.onSurface),
        visible: !_isWeb,
      ),
      _SettingsSwitchItem(
        title: sortContact,
        value: !state.lastNameSorted,
        onChanged: notifier.toggleSort,
        icon: Icon(Icons.contacts, size: 24, color: context.colors.onSurface),
      ),
      _SettingsSwitchItem(
        title: readingPaneText,
        value: state.readingPaneEnabled,
        onChanged: notifier.toggleReadingPane,
        icon: SvgPicture.asset(
          svgReadingPane,
          colorFilter:
              ColorFilter.mode(context.colors.onSurface, BlendMode.srcIn),
        ),
      ),
      _SettingsSwitchItem(
        title: importContactDevice,
        value: state.syncContact,
        onChanged: notifier.toggleSyncContacts,
        icon: Icon(Icons.contacts, size: 24, color: context.colors.onSurface),
        visible: !_isWeb,
      ),
    ];

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
            SettingsTabletLayout._divider,
            _DrawerAction(
              title: account,
              icon: svgUserSettings,
              onTap: () => context.go(AppRoutes.account),
            ),
            ...switchItems.where((item) => item.visible).map((item) => _buildDividerSwitch(context, item)),
            SettingsTabletLayout._divider,
            _ThemeModeSelector(
              value: state.themeModePref,
              onChanged: notifier.setThemeMode,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDividerSwitch(BuildContext context, _SettingsSwitchItem item) {
    return Column(
      children: [
        SettingsTabletLayout._divider,
        _SwitchItem(
          title: item.title,
          value: item.value,
          onChanged: item.onChanged,
          icon: item.icon,
        ),
      ],
    );
  }
}

class _SettingsSwitchItem {
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;
  final Widget icon;
  final bool visible;

  const _SettingsSwitchItem({
    required this.title,
    required this.value,
    required this.onChanged,
    required this.icon,
    this.visible = true,
  });
}

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
                  ButtonSegment(value: 'light', icon: Icon(Icons.light_mode, size: 18), label: Text('Light')),
                  ButtonSegment(value: 'system', icon: Icon(Icons.settings_brightness, size: 18), label: Text('Auto')),
                  ButtonSegment(value: 'dark', icon: Icon(Icons.dark_mode, size: 18), label: Text('Dark')),
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

class _LogoutButton extends ConsumerWidget {
  const _LogoutButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(settingsProvider.notifier);

    return MouseRegion(
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
            Text(
              logOut,
              style: AppTypography.logOut(context),
            ),
          ],
        ),
      ),
    );
  }
}
