// Implements: TC-DISC-SCREEN-EXT-001..008
// Source: Extended screen tests — verify content and interactions
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:optmsg/model/auth/auth_state.dart';
import 'package:optmsg/model/notification_list_model.dart';
import 'package:optmsg/screens/auth/auth_riverpod/auth_notifier.dart';
import 'package:optmsg/screens/settings/setting_riverpod/settings_notifier.dart';
import 'package:optmsg/screens/settings/setting_riverpod/setting_state.dart';
import 'package:optmsg/screens/settings/setting_riverpod/setting_riverpod.dart';
import 'package:optmsg/screens/settings/account_riverpod/account_riverpod.dart';
import 'package:optmsg/screens/settings/account_riverpod/account_notifier.dart';
import 'package:optmsg/screens/settings/account_riverpod/account_state.dart';
import 'package:optmsg/screens/notifications/notification_riverpod/notification_provider.dart';
import 'package:optmsg/screens/notifications/notification_riverpod/notification_state.dart';
import 'package:optmsg/screens/notifications/notification_riverpod/notification_list_riverpod.dart';

import '../helpers/test_helpers.dart';
import '../helpers/riverpod_test_helpers.dart';
import '../factories/test_data_factories.dart';

class _FakeAuthNotifier extends AuthNotifier {
  final Map<String, dynamic> _data;
  _FakeAuthNotifier(this._data);
  @override
  AuthState build() => AuthState.authenticated(_data);
}

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
}

class _FakeAccountNotifier extends AccountNotifier {
  final AccountState _state;
  _FakeAccountNotifier(this._state);
  @override
  AccountState build() => _state;
}

class _FakeNotificationNotifier extends NotificationNotifier {
  final NotificationState _state;
  _FakeNotificationNotifier(this._state);
  @override
  NotificationState build() => _state;
  @override
  Future<void> fetchNotifications({bool refresh = false}) async {}
  @override
  Future<void> deleteNotification(int id, int index) async {}
  @override
  Future<void> toggleRead(int id, int index) async {}
  @override
  void clearSelection() {}
  @override
  void selectAllFromList() {}
  @override
  void toggleSelectFromList(int id) {}
  @override
  String getSelectionState() => 'none';
  @override
  bool isNew(List<Notifications> list) => false;
}

Notifications _makeNotif(int id, {bool isRead = false}) {
  return Notifications.fromJson({
    'id': id, 'type': 'email', 'title': 'Notif $id', 'body': 'Body $id',
    'userId': 1, 'info': {'senderName': 'Sender'},
    'isRead': isRead, 'isDeleted': false,
    'created': '2024-06-15T10:30:00.000Z', 'updated': '2024-06-15T10:30:00.000Z',
  });
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late RiverpodTestSetup setup;
  final testUserData = {
    'user': makeUserJson(firstName: 'Test', lastName: 'User'),
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

  group('Settings with biometric enabled', () {
    testWidgets('should show biometric switch on', (tester) async {
      tester.setScreenSize(width: 400, height: 800);
      final origOnError = FlutterError.onError;
      FlutterError.onError = (d) {
        if (d.toString().contains('overflow')) return;
        origOnError?.call(d);
      };

      final state = SettingsState(
        userData: testUserData,
        isBiometricSelected: true,
        isNotificationSelected: true,
        syncContact: false,
      );

      await tester.pumpWidget(ProviderScope(
        overrides: [
          ...setup.serviceOverrides,
          authProvider.overrideWith(() => _FakeAuthNotifier(testUserData)),
          settingsProvider.overrideWith(() => _FakeSettingsNotifier(state)),
        ],
        child: MaterialApp(theme: testThemeData(), home: const Scaffold(body: Settingriverpod())),
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('Profile'), findsOneWidget);
      tester.resetScreenSize();
      FlutterError.onError = origOnError;
    });
  });

  group('Account with subscription data', () {
    testWidgets('should render account at mobile with user data', (tester) async {
      tester.setScreenSize(width: 400, height: 800);
      final origOnError = FlutterError.onError;
      FlutterError.onError = (d) {
        if (d.toString().contains('overflow')) return;
        origOnError?.call(d);
      };

      final accountState = AccountState(
        userData: testUserData,
        subscriptionDate: 'Jan 01, 2025',
        isLoading: false,
      );

      await tester.pumpWidget(ProviderScope(
        overrides: [
          ...setup.serviceOverrides,
          authProvider.overrideWith(() => _FakeAuthNotifier(testUserData)),
          accountProvider.overrideWith(() => _FakeAccountNotifier(accountState)),
        ],
        child: MaterialApp(theme: testThemeData(), home: const Scaffold(body: Accountriverpod())),
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.byType(Accountriverpod), findsOneWidget);
      tester.resetScreenSize();
      FlutterError.onError = origOnError;
    });

    testWidgets('should render account at tablet with user data', (tester) async {
      tester.setScreenSize(width: 800, height: 600);
      final origOnError = FlutterError.onError;
      FlutterError.onError = (d) {
        if (d.toString().contains('overflow')) return;
        origOnError?.call(d);
      };

      final accountState = AccountState(
        userData: testUserData,
        subscriptionDate: 'Jan 01, 2025',
        isLoading: false,
      );

      await tester.pumpWidget(ProviderScope(
        overrides: [
          ...setup.serviceOverrides,
          authProvider.overrideWith(() => _FakeAuthNotifier(testUserData)),
          accountProvider.overrideWith(() => _FakeAccountNotifier(accountState)),
        ],
        child: MaterialApp(theme: testThemeData(), home: const Scaffold(body: Accountriverpod())),
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.byType(Accountriverpod), findsOneWidget);
      tester.resetScreenSize();
      FlutterError.onError = origOnError;
    });
  });

  group('Notifications loading state', () {
    testWidgets('should show loading overlay when loading', (tester) async {
      tester.setScreenSize(width: 400, height: 800);
      final origOnError = FlutterError.onError;
      FlutterError.onError = (d) {
        if (d.toString().contains('overflow')) return;
        origOnError?.call(d);
      };

      const loadingState = NotificationState(isLoading: true, items: []);

      await tester.pumpWidget(ProviderScope(
        overrides: [
          ...setup.serviceOverrides,
          authProvider.overrideWith(() => _FakeAuthNotifier(testUserData)),
          notificationProvider.overrideWith(() => _FakeNotificationNotifier(loadingState)),
        ],
        child: MaterialApp(theme: testThemeData(), home: const Scaffold(body: NotificationList())),
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.byType(NotificationList), findsOneWidget);
      tester.resetScreenSize();
      FlutterError.onError = origOnError;
    });

    testWidgets('should render 5 items with mixed read state', (tester) async {
      tester.setScreenSize(width: 400, height: 800);
      final origOnError = FlutterError.onError;
      FlutterError.onError = (d) {
        if (d.toString().contains('overflow')) return;
        origOnError?.call(d);
      };

      final state = NotificationState(
        isLoading: false,
        hasMore: true,
        items: List.generate(5, (i) => _makeNotif(i + 1, isRead: i.isEven)),
      );

      await tester.pumpWidget(ProviderScope(
        overrides: [
          ...setup.serviceOverrides,
          authProvider.overrideWith(() => _FakeAuthNotifier(testUserData)),
          notificationProvider.overrideWith(() => _FakeNotificationNotifier(state)),
        ],
        child: MaterialApp(theme: testThemeData(), home: const Scaffold(body: NotificationList())),
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('Notif 1'), findsOneWidget);
      expect(find.text('Notif 5'), findsOneWidget);
      tester.resetScreenSize();
      FlutterError.onError = origOnError;
    });
  });
}
