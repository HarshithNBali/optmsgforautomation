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

class SettingsMobileLayout extends ConsumerWidget {
  const SettingsMobileLayout({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    return DelayedLoadingOverlay(
      isLoading: state.isLoading,
      child: Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: context.colors.outlineVariant),
                  borderRadius: BorderRadius.circular(AppStyles.radiusM),
                ),
                child: Column(
                  children: [
                    MyDrawerItem(
                      testId: 'settings_profile_item',
                      title: profile,
                      svgIcon: svgUser,
                      showIndicator: false,
                      showChevron: true,
                      onTap: () {
                        // Reset edit mode when navigating to profile
                        ref.read(profileProvider.notifier).disableEdit();
                        // Fetch latest profile data before navigating
                        ref.read(profileProvider.notifier).fetchProfile();
                        context.go(AppRoutes.profile);
                      },
                    ),
                    Divider(
                      color: context.colors.outlineVariant,
                      thickness: 1,
                      height: 1,
                    ),
                    MyDrawerItem(
                      testId: 'settings_account_item',
                      title: account,
                      svgIcon: svgUserSettings,
                      showIndicator: false,
                      showChevron: true,
                      onTap: () {
                        context.go(AppRoutes.account);
                      },
                    ),
                    Divider(
                      color: context.colors.outlineVariant,
                      thickness: 1,
                      height: 1,
                    ),
                    CustomSwitchListTile(
                      testId: 'settings_notification_switch',
                      title: manageNotification,
                      value: state.isNotificationSelected,
                      onChanged: notifier.toggleNotification,
                      secondary: SvgPicture.asset(
                        svgNoNotifications,
                        colorFilter: ColorFilter.mode(
                          context.colors.onSurface,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                    if (CommonService().getPlatform() != "web") ...[
                      Divider(
                        color: context.colors.outlineVariant,
                        thickness: 1,
                        height: 1,
                      ),
                      CustomSwitchListTile(
                        testId: 'settings_biometric_switch',
                        title: manageBiometric,
                        value: state.isBiometricSelected,
                        onChanged: notifier.toggleBiometric,
                        secondary: Icon(Icons.login, size: 24, color: context.colors.onSurface),
                      ),
                    ],
                    Divider(
                      color: context.colors.outlineVariant,
                      thickness: 1,
                      height: 1,
                    ),
                    CustomSwitchListTile(
                      testId: 'settings_sort_switch',
                      title: sortContact,
                      value: !state.lastNameSorted,
                      onChanged: notifier.toggleSort,
                      secondary: Icon(Icons.contacts, size: 24, color: context.colors.onSurface),
                    ),
                    Divider(
                      color: context.colors.outlineVariant,
                      thickness: 1,
                      height: 1,
                    ),
                    CustomSwitchListTile(
                      testId: 'settings_readingpane_switch',
                      title: readingPaneText,
                      value: state.readingPaneEnabled,
                      onChanged: notifier.toggleReadingPane,
                      secondary: SvgPicture.asset(
                        svgReadingPane,
                        colorFilter: ColorFilter.mode(
                            context.colors.onSurface, BlendMode.srcIn),
                      ),
                    ),
                    if (CommonService().getPlatform() != "web") ...[
                      Divider(
                        color: context.colors.outlineVariant,
                        thickness: 1,
                        height: 1,
                      ),
                      CustomSwitchListTile(
                        testId: 'settings_synccontact_switch',
                        title: importContactDevice,
                        value: state.syncContact,
                        onChanged: notifier.toggleSyncContacts,
                        secondary: Icon(Icons.contacts, size: 24, color: context.colors.onSurface),
                      ),
                    ],
                    Divider(
                      color: context.colors.outlineVariant,
                      thickness: 1,
                      height: 1,
                    ),
                    _ThemeModeSelector(
                      value: state.themeModePref,
                      onChanged: notifier.setThemeMode,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () async {
              showDialog(
                context: context,
                useRootNavigator: true,
                builder: (dialogContext) => CustomPopupModal(
                  testId: 'settings_logout',
                  icon: svgLogOut,
                  title: logOut,
                  subtitle: logOutText,
                  onPressedButton1: () {
                    Navigator.of(dialogContext, rootNavigator: true).pop();
                  },
                  onPressedButton2: () {
                    Navigator.of(dialogContext, rootNavigator: true).pop();
                    notifier.performLogout();
                  },
                  textButton1: 'No',
                  textButton2: 'Yes',
                ),
              );
            },
            child: Row(
              key: const Key('settings_logout_button'),
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  svgLogOutSettings,
                  width: 24.0,
                  height: 24.0,
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
        const SizedBox(height: AppStyles.space32),
        Text(slogan, style: AppTypography.slogan(context)),
        const SizedBox(height: AppStyles.space32),
      ],
    ),
    );
  }
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
                key: const Key('settings_theme_selector'),
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
