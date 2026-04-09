import 'package:optmsg/repositories/setting/setting_api.dart';
import 'package:optmsg/screens/contacts/contacts_riverpod/contact_list_notifier.dart';
import 'package:optmsg/screens/email/archive_riverpod/archive_list_notifier.dart';
import 'package:optmsg/screens/email/draft_riverpod/draft_notifier.dart';
import 'package:optmsg/screens/email/inbox_riverpod/inbox_notifier.dart';
import 'package:optmsg/screens/settings/setting_riverpod/setting_state.dart';
import 'package:optmsg/services/tags_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import 'package:optmsg/screens/auth/auth_riverpod/auth_notifier.dart';

import '../../../constant/string_constant.dart';
import '../../../services/biometric_service.dart';
import '../../../services/common_service.dart';
import '../../../services/storage_service.dart';
import '../../../common/responsive/breakpoints.dart';
import '../../../common/utilites/logger.dart';
import 'package:optmsg/main.dart' show MyApp;
import '../../../common/app_manger/app_cache.dart';

final settingsProvider = NotifierProvider<SettingsNotifier, SettingsState>(
  SettingsNotifier.new,
);

class SettingsNotifier extends Notifier<SettingsState> {
  late final SecureStorageService secureStorageService;
  late final BiometricService biometricService;
  late final SettingApi _settingApi;

  bool _disposed = false;

  @override
  SettingsState build() {
    secureStorageService = ref.read(storageServiceProvider);
    biometricService = ref.read(biometricServiceProvider);
    _settingApi = ref.read(settingApiProvider);
    _disposed = false;
    ref.onDispose(() {
      _disposed = true;
    });
    Future.microtask(_init);
    final cachedTheme = AppCache().themeModePref;
    printLog('[THEME] build()', 'cached=$cachedTheme');
    return SettingsState(isLoading: true, themeModePref: cachedTheme);
  }

  final LocalAuthentication localAuth = LocalAuthentication();

  String deviceToken = "";

  Future<void> _init() async {
    await getUserData();
    await _initializeBiometric();
    if (!_disposed) state = state.copyWith(isLoading: false);
  }

  // ---------------- USER DATA ----------------

  Future<void> getUserData() async {
    final data = ref.read(authProvider).userData;

    deviceToken = (await secureStorageService.readData('deviceToken')) ?? '';
    if (_disposed) return;

    final readingPaneValue = await secureStorageService.readData(
      'readingPaneEnabled',
    );
    if (_disposed) return;

    final themeModePrefValue = await secureStorageService.getString('themeModePref');
    if (_disposed) return;
    printLog('[THEME] getUserData()', 'storageValue=$themeModePrefValue, currentState=${state.themeModePref}');

    // Device-level preferences — load regardless of whether user/auth data
    // is ready so they survive page refresh.
    final bool readingPaneEnabled = readingPaneValue == null
        ? state.readingPaneEnabled
        : readingPaneValue == 'true';
    final String themeModePref = themeModePrefValue ?? state.themeModePref;

    if (data != null) {
      state = state.copyWith(
        userData: data,
        lastNameSorted: data['user']?['sortLastName'] ?? false,
        isNotificationSelected: data['user']?['isNotification'] ?? true,
        syncContact: data['user']?['contactSynch'] ?? true,
        readingPaneEnabled: readingPaneEnabled,
        themeModePref: themeModePref,
      );
    } else {
      // Auth data not yet available (e.g. page refresh) — still apply the
      // persisted device preferences so the UI doesn't reset to default.
      state = state.copyWith(
        readingPaneEnabled: readingPaneEnabled,
        themeModePref: themeModePref,
      );
    }
  }

  // ---------------- NOTIFICATIONS ----------------

  Future<void> toggleNotification(bool value) async {
    if (state.userData == null) return;
    final previousValue = state.isNotificationSelected;
    state = state.copyWith(isNotificationSelected: value);

    try {
      final response = await _settingApi.toggleNotification({
        'isNotification': value,
      });
      if (_disposed) return;
      final resp = response.data ?? {};

      if (resp['success']) {
        await ref.read(authProvider.notifier).updateUserField('isNotification', value);
        if (_disposed) return;
        state = state.copyWith(userData: ref.read(authProvider).userData);
        CommonService.animatedToast(resp['message'], 'success');
      } else {
        state = state.copyWith(isNotificationSelected: previousValue);
        CommonService.animatedToast(resp['message'], 'error');
      }
    } catch (e) {
      if (_disposed) return;
      state = state.copyWith(isNotificationSelected: previousValue);
      printLog('[SETTINGS] toggleNotification error', e.toString());
      CommonService.animatedToast(catchError, 'error');
    }
  }

  // ---------------- BIOMETRICS ----------------

  Future<void> _initializeBiometric() async {
    final isEnabled = await secureStorageService.readData('isBiometricEnable');
    if (_disposed) return;

    state = state.copyWith(isBiometricSelected: isEnabled == 'true');
  }

  Future<void> toggleBiometric(bool value) async {
    final previousValue = state.isBiometricSelected;

    // When enabling, authenticate FIRST before any state change
    if (value) {
      if (await localAuth.canCheckBiometrics) {
        final authenticated = await biometricService.authenticate();
        if (_disposed) return;
        if (!authenticated) return; // User cancelled — no change
      }
    }

    state = state.copyWith(isBiometricSelected: value);

    final success = await _updateBiometricsApi(value);
    if (_disposed) return;

    if (success) {
      await secureStorageService.writeData('isBiometricEnable', value.toString());
      if (_disposed) return;
      MyApp.notifyBiometricSettingChanged();
      CommonService.animatedToast(
        value ? 'Biometrics Enabled' : 'Biometrics Disabled',
        'success',
      );
    } else {
      state = state.copyWith(isBiometricSelected: previousValue);
      CommonService.animatedToast('Failed to update biometric setting', 'error');
    }
  }

  // ---------------- SORT CONTACTS ----------------

  Future<void> toggleSort(bool value) async {
    if (state.userData == null) return;
    final previousValue = state.lastNameSorted;
    state = state.copyWith(lastNameSorted: !value);

    try {
      final response = await _settingApi.contactSortToggle({
        'sortLastName': state.lastNameSorted,
      });
      if (_disposed) return;
      final resp = response.data ?? {};

      if (resp['success']) {
        await ref.read(authProvider.notifier).updateUserField('sortLastName', state.lastNameSorted);
        if (_disposed) return;
        state = state.copyWith(userData: ref.read(authProvider).userData);
        // Re-sort the contact list immediately so the user sees the change
        ref
            .read(contactListProvider.notifier)
            .updateSortSetting(state.lastNameSorted);
        CommonService.animatedToast('Settings updated', 'success');
      } else {
        state = state.copyWith(lastNameSorted: previousValue);
        CommonService.animatedToast(resp['message'] ?? 'Failed to update setting', 'error');
      }
    } catch (e) {
      if (_disposed) return;
      state = state.copyWith(lastNameSorted: previousValue);
      printLog('[SETTINGS] toggleSort error', e.toString());
      CommonService.animatedToast(catchError, 'error');
    }
  }

  // ---------------- READING PANE ----------------
  // TODO: Add a backend API endpoint (e.g. POST /user/toggle-reading-pane) to
  // persist the reading pane preference globally instead of device-local secure
  // storage, which can randomly reset (e.g. iOS Keychain cleared on
  // uninstall/restore). Follow the same pattern as toggleNotification with
  // optimistic update + rollback on failure.

  Future<void> toggleReadingPane(bool value) async {
    state = state.copyWith(readingPaneEnabled: value);

    // Persist to storage FIRST so any subsequent bootstrap reads the correct value
    await secureStorageService.writeData(
      'readingPaneEnabled',
      value.toString(),
    );
    if (_disposed) return;

    // Then update providers for immediate UI feedback on platforms that show reading pane
    if (kIsWeb || AppBreakpoints.isPhysicalTablet) {
      ref.read(inboxProvider.notifier).updateReadingPaneSettings(value);
      ref.read(archiveProvider.notifier).updateReadingPaneSettings(value);
      ref.read(draftProvider.notifier).updateReadingPaneSettings(value);
      ref.read(contactListProvider.notifier).updateReadingPaneSettings(value);
    }
  }

  // ---------------- THEME MODE ----------------

  /// Set theme mode preference: 'system', 'light', or 'dark'.
  Future<void> setThemeMode(String mode) async {
    printLog('[THEME] setThemeMode()', 'mode=$mode');
    state = state.copyWith(themeModePref: mode);
    AppCache().setThemeModePref(mode);
    // Write to SharedPreferences (plain localStorage on web) — no encryption
    // overhead and avoids WebCrypto/IndexedDB edge cases on browser refresh.
    await secureStorageService.setString('themeModePref', mode);
    if (_disposed) return;
  }

  // ---------------- SYNC CONTACTS ----------------

  Future<void> toggleSyncContacts(bool value) async {
    if (state.userData == null) return;
    printLog('[CONTACT_SYNC] Toggle called', 'value=$value');
    final previousValue = state.syncContact;
    state = state.copyWith(syncContact: value);

    try {
      printLog('[CONTACT_SYNC] Calling API', '/user/toggle-contact-synch');
      final response = await _settingApi.toggleContactSynch({
        'contactSynch': value,
      });
      if (_disposed) return;
      final resp = response.data ?? {};

      printLog('[CONTACT_SYNC] API response', 'success=${resp['success']}');

      if (resp['success']) {
        await ref.read(authProvider.notifier).updateUserField('contactSynch', value);
        if (_disposed) return;
        state = state.copyWith(userData: ref.read(authProvider).userData);
        printLog('[CONTACT_SYNC] Storage updated', 'contactSynch=$value');

        CommonService.animatedToast(resp['message'], 'success');

        // If enabling contact sync, trigger smart permission flow
        if (value == true) {
          printLog(
            '[CONTACT_SYNC] Triggering contact sync flow',
            'Calling triggerContactSyncFromSettings',
          );
          ref.read(inboxProvider.notifier).triggerContactSyncFromSettings();
        }
      } else {
        state = state.copyWith(syncContact: previousValue);
        printLog('[CONTACT_SYNC] API failed', 'message=${resp['message']}');
        CommonService.animatedToast(resp['message'] ?? 'Failed to update setting', 'error');
      }
    } catch (e) {
      if (_disposed) return;
      state = state.copyWith(syncContact: previousValue);
      printLog('[CONTACT_SYNC] Exception', e.toString());
      CommonService.animatedToast(catchError, 'error');
    }
  }

  Future<bool> _updateBiometricsApi(bool isBiometric) async {
    try {
      final resp = await _settingApi.deviceBiometric({
        "isDeviceBiometrics": isBiometric,
      });
      if (_disposed) return false;
      final response = resp.data;

      if (response!['success']) {
        await secureStorageService.writeObjectData(
          'userProfileData',
          response['data'],
        );
        if (_disposed) return false;
        await ref.read(authProvider.notifier).updateUserField('isDeviceBiometrics', isBiometric);
        if (_disposed) return false;
        return true;
      }
      return false;
    } catch (e) {
      if (_disposed) return false;
      printLog('[SETTINGS] updateBiometricsApi error', e.toString());
      return false;
    }
  }

  /// Centralized logout entry-point for the settings UI.
  ///
  /// Delegates all auth + cleanup work to [AuthNotifier.logout()] — the single
  /// canonical logout path — then resets settings-specific providers so no
  /// stale in-memory state persists on the next login.
  void performLogout() {
    // AuthNotifier.logout() flips auth state synchronously (GoRouter redirects
    // to /login) and runs all cleanup in a background Future (API call, Descope
    // revocation, storage wipe, socket disconnect, badge reset, prefs).
    ref.read(authProvider.notifier).logout();

    // Reset in-memory providers that AuthNotifier doesn't know about.
    ref.read(tagsProvider.notifier).reset();
    ref.read(inboxProvider.notifier).reset();
    ref.read(archiveProvider.notifier).reset();
    ref.read(draftProvider.notifier).reset();
  }

  /// Reset settings state to initial state (used during logout)
  void reset() {
    state = const SettingsState();
  }
}
