import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'storage/platform_secure_storage.dart';


class SecureStorageService {
  final PlatformSecureStorage _storage = createPlatformSecureStorage();

  SharedPreferences? _prefs;

  Future<SharedPreferences> get _instance async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  /* =====================================================
   🔐 SECURE STORAGE
  ===================================================== */

  Future<void> writeData(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  Future<String?> readData(String key) async {
    return await _storage.read(key: key);
  }

  Future<void> deleteData(String key) async {
    await _storage.delete(key: key);
  }

  Future<void> clearSecureStorage() async {
    await _storage.deleteAll();
  }

  /* =====================================================
   💾 SHARED PREFERENCES
  ===================================================== */

  Future<void> setBool(String key, bool value) async {
    final prefs = await _instance;
    await prefs.setBool(key, value);
  }

  Future<bool?> getBool(String key) async {
    final prefs = await _instance;
    return prefs.getBool(key);
  }

  Future<void> setString(String key, String value) async {
    final prefs = await _instance;
    await prefs.setString(key, value);
  }

  Future<String?> getString(String key) async {
    final prefs = await _instance;
    return prefs.getString(key);
  }

  Future<void> removePref(String key) async {
    final prefs = await _instance;
    await prefs.remove(key);
  }

  Future<void> clearAllPrefs() async {
    final prefs = await _instance;
    await prefs.clear();
  }

  /* =====================================================
   🧹 SELECTIVE LOGOUT CLEAR (YOUR STYLE)
  ===================================================== */

  Future<void> clearAllData() async {
    const secureKeys = [
      'userData',
      'isAuthenticated',
      'isBiometricEnable',
      'userProfileData',
      'selected_plan',
      'updatePopUpDismiss',
      'isContactAlreadySync',
      // NOTE: 'readingPaneEnabled' is intentionally NOT cleared on logout —
      // it is a device-level user preference that should persist across sessions.
      // NOTE: 'deviceToken' (FCM push token) is intentionally NOT cleared on
      // logout — it is device-specific and written once during initState().
      // Since MyApp stays mounted across logout/login (GoRouter handles page
      // transitions), initState() never re-runs, so the token would be lost
      // until a full app restart. The next login re-uses the existing token.
      'loginId',
      // sessionJwt and refreshJwt are no longer written by the app — the
      // Descope SDK manages them via its own storage. These entries are kept
      // here only to clean up any stale values written by older app versions.
      'sessionJwt',
      'refreshJwt',
      // AppCache subscription data — cleared on logout.
      'payment_data',
      // Passkey enrollment flag — cleared on logout so a new user on the same
      // device doesn't inherit a previous user's passkey status.
      'hasPasskeyEnrolled',
      // N-6: Clear signup flag so a stale value from a previous mid-signup
      // logout doesn't affect the next user's router behavior.
      'signupInProgress',
      // Checkout / subscription routing flags — cleared on logout so stale
      // state from an abandoned checkout doesn't affect the next session.
      'isCheckout',
      'subscriptionPage',
    ];

    for (final key in secureKeys) {
      await _storage.delete(key: key);
    }

    await clearAllPrefs();
  }

  /* =====================================================
   💥 FULL APP WIPE (fresh install state)
  ===================================================== */

  Future<void> clearAllAppStorage() async {
    await _storage.deleteAll();

    final prefs = await _instance;
    await prefs.clear();
  }

  /* =====================================================
   📦 OBJECT STORAGE
  ===================================================== */

  Future<void> writeObjectData(String key, Map<String, dynamic> value) async {
    await _storage.write(key: key, value: json.encode(value));
  }

  Future<Map<String, dynamic>?> readObjectData(String key) async {
    final jsonString = await _storage.read(key: key);
    if (jsonString == null) return null;
    return json.decode(jsonString);
  }

  Future<void> updateObjectData(String key, String objectKey, dynamic newValue) async {
    final jsonData = await readObjectData(key);
    if (jsonData != null) {
      jsonData[objectKey] = newValue;
      await writeObjectData(key, jsonData);
    }
  }
}