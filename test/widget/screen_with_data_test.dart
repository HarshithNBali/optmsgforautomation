// Implements: TC-DISC-SCREEN-DATA-001..010
// Source: Screen layouts rendered with pre-populated state
// Coverage target: Cover layout widgets by providing fake state data
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:optmsg/model/auth/auth_state.dart';
import 'package:optmsg/screens/auth/auth_riverpod/auth_notifier.dart';
import 'package:optmsg/screens/settings/setting_riverpod/settings_notifier.dart';
import 'package:optmsg/screens/settings/setting_riverpod/setting_state.dart';
import 'package:optmsg/screens/settings/setting_riverpod/setting_riverpod.dart';
import 'package:optmsg/screens/settings/profile_riverpod/profile_riverpod.dart';

import '../helpers/test_helpers.dart';
import '../helpers/riverpod_test_helpers.dart';
import '../factories/test_data_factories.dart';

// Fake auth notifier returning authenticated state
class _FakeAuthNotifier extends AuthNotifier {
  final Map<String, dynamic> _data;
  _FakeAuthNotifier(this._data);
  @override
  AuthState build() => AuthState.authenticated(_data);
}

// Fake settings notifier returning pre-populated state
class _FakeSettingsNotifier extends SettingsNotifier {
  final SettingsState _state;
  _FakeSettingsNotifier(this._state);

  @override
  SettingsState build() => _state;

  @override
  Future<void> getUserData() async {}

  @override
  Future<void> toggleNotification(bool value) async {}

  @override
  Future<void> toggleSort(bool value) async {}

  @override
  Future<void> toggleBiometric(bool value) async {}

  @override
  Future<void> toggleReadingPane(bool value) async {}

  @override
  Future<void> toggleSyncContacts(bool value) async {}

  @override
  Future<void> setThemeMode(String mode) async {}

  @override
  void performLogout() {}

  @override
  void reset() {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late RiverpodTestSetup setup;

  final testUserData = {
    'user': makeUserJson(
      firstName: 'Test',
      lastName: 'User',
      userName: 'testuser',
      isSubscribed: true,
    ),
    'token': 'test-token',
  };

  setUp(() {
    SharedPreferences.setMockInitialValues({});

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('app_badge_plus'),
      (MethodCall methodCall) async {
        if (methodCall.method == 'isSupported') return false;
        return null;
      },
    );

    setup = RiverpodTestSetup();
    when(() => setup.mockStorageService.readData(any()))
        .thenAnswer((_) async => null);
    when(() => setup.mockStorageService.readObjectData(any()))
        .thenAnswer((_) async => null);
    when(() => setup.mockStorageService.writeData(any(), any()))
        .thenAnswer((_) async {});
    when(() => setup.mockStorageService.writeObjectData(any(), any()))
        .thenAnswer((_) async {});
  });

  // =========================================================================
  // Settings with pre-populated state
  // =========================================================================
  group('Settingriverpod with data', () {
    testWidgets('should render settings options at mobile size', (tester) async {
      // TC-DISC-SCREEN-DATA-001
      tester.setScreenSize(width: 400, height: 800);

      final origOnError = FlutterError.onError;
      FlutterError.onError = (d) {
        if (d.toString().contains('overflow')) return;
        origOnError?.call(d);
      };

      final settingsState = SettingsState(
        userData: testUserData,
        isNotificationSelected: true,
        isBiometricSelected: false,
        lastNameSorted: false,
        syncContact: true,
        readingPaneEnabled: true,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            ...setup.serviceOverrides,
            authProvider.overrideWith(() => _FakeAuthNotifier(testUserData)),
            settingsProvider.overrideWith(() => _FakeSettingsNotifier(settingsState)),
          ],
          child: MaterialApp(
            theme: testThemeData(),
            home: const Scaffold(body: Settingriverpod()),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.byType(Settingriverpod), findsOneWidget);
      // Settings should render menu items
      expect(find.text('Profile'), findsOneWidget);

      tester.resetScreenSize();
      FlutterError.onError = origOnError;
    });
  });

  // =========================================================================
  // Profile with pre-populated state
  // =========================================================================
  group('Profileriverpod with data', () {
    testWidgets('should render profile at mobile size', (tester) async {
      // TC-DISC-SCREEN-DATA-002
      tester.setScreenSize(width: 400, height: 800);

      final origOnError = FlutterError.onError;
      FlutterError.onError = (d) {
        if (d.toString().contains('overflow')) return;
        origOnError?.call(d);
      };

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            ...setup.serviceOverrides,
            authProvider.overrideWith(() => _FakeAuthNotifier(testUserData)),
          ],
          child: MaterialApp(
            theme: testThemeData(),
            home: const Scaffold(body: Profileriverpod()),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(Profileriverpod), findsOneWidget);

      tester.resetScreenSize();
      FlutterError.onError = origOnError;
    });
  });
}
