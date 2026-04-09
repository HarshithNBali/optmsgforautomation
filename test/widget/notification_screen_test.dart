// Implements: TC-DISC-NOTIF-SCREEN-001..004
// Source: Notification screens with pre-populated state
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:optmsg/model/auth/auth_state.dart';
import 'package:optmsg/model/notification_list_model.dart';
import 'package:optmsg/screens/auth/auth_riverpod/auth_notifier.dart';
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

/// Fake NotificationNotifier with pre-populated items
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
  Future<void> bulkDelete() async {}

  @override
  Future<void> bulkMarkAsRead() async {}

  @override
  Future<void> bulkMarkAsUnread() async {}

  @override
  void handleBulkMarkAction() {}

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

Notifications _makeNotification(int id, {bool isRead = false}) {
  return Notifications.fromJson({
    'id': id,
    'type': 'email',
    'title': 'Notification $id',
    'body': 'Body of notification $id',
    'userId': 1,
    'info': {'senderName': 'Sender $id'},
    'isRead': isRead,
    'isDeleted': false,
    'created': '2024-06-15T10:30:00.000Z',
    'updated': '2024-06-15T10:30:00.000Z',
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
  });

  group('NotificationList with items', () {
    testWidgets('should render notification items at mobile size', (tester) async {
      // TC-DISC-NOTIF-SCREEN-001
      tester.setScreenSize(width: 400, height: 800);

      final origOnError = FlutterError.onError;
      FlutterError.onError = (d) {
        if (d.toString().contains('overflow')) return;
        origOnError?.call(d);
      };

      final notifState = NotificationState(
        isLoading: false,
        hasMore: false,
        items: [
          _makeNotification(1),
          _makeNotification(2, isRead: true),
          _makeNotification(3),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            ...setup.serviceOverrides,
            authProvider.overrideWith(() => _FakeAuthNotifier(testUserData)),
            notificationProvider.overrideWith(
                () => _FakeNotificationNotifier(notifState)),
          ],
          child: MaterialApp(
            theme: testThemeData(),
            home: const Scaffold(body: NotificationList()),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.byType(NotificationList), findsOneWidget);
      // Should show notification titles
      expect(find.text('Notification 1'), findsOneWidget);
      expect(find.text('Notification 2'), findsOneWidget);

      tester.resetScreenSize();
      FlutterError.onError = origOnError;
    });

    testWidgets('should render empty state when no items', (tester) async {
      // TC-DISC-NOTIF-SCREEN-002
      tester.setScreenSize(width: 400, height: 800);

      final origOnError = FlutterError.onError;
      FlutterError.onError = (d) {
        if (d.toString().contains('overflow')) return;
        origOnError?.call(d);
      };

      const notifState = NotificationState(
        isLoading: false,
        hasMore: false,
        items: [],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            ...setup.serviceOverrides,
            authProvider.overrideWith(() => _FakeAuthNotifier(testUserData)),
            notificationProvider.overrideWith(
                () => _FakeNotificationNotifier(notifState)),
          ],
          child: MaterialApp(
            theme: testThemeData(),
            home: const Scaffold(body: NotificationList()),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.byType(NotificationList), findsOneWidget);
      // Should show empty state
      expect(find.text('No notifications yet'), findsOneWidget);

      tester.resetScreenSize();
      FlutterError.onError = origOnError;
    });

    testWidgets('should render at tablet size with items', (tester) async {
      // TC-DISC-NOTIF-SCREEN-003
      tester.setScreenSize(width: 800, height: 600);

      final origOnError = FlutterError.onError;
      FlutterError.onError = (d) {
        if (d.toString().contains('overflow')) return;
        origOnError?.call(d);
      };

      final notifState = NotificationState(
        isLoading: false,
        hasMore: false,
        items: [_makeNotification(1), _makeNotification(2)],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            ...setup.serviceOverrides,
            authProvider.overrideWith(() => _FakeAuthNotifier(testUserData)),
            notificationProvider.overrideWith(
                () => _FakeNotificationNotifier(notifState)),
          ],
          child: MaterialApp(
            theme: testThemeData(),
            home: const Scaffold(body: NotificationList()),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.byType(NotificationList), findsOneWidget);

      tester.resetScreenSize();
      FlutterError.onError = origOnError;
    });

    testWidgets('should render at desktop size with items', (tester) async {
      // TC-DISC-NOTIF-SCREEN-004
      tester.setScreenSize(width: 1200, height: 800);

      final origOnError = FlutterError.onError;
      FlutterError.onError = (d) {
        if (d.toString().contains('overflow')) return;
        origOnError?.call(d);
      };

      final notifState = NotificationState(
        isLoading: false,
        hasMore: false,
        items: [_makeNotification(1)],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            ...setup.serviceOverrides,
            authProvider.overrideWith(() => _FakeAuthNotifier(testUserData)),
            notificationProvider.overrideWith(
                () => _FakeNotificationNotifier(notifState)),
          ],
          child: MaterialApp(
            theme: testThemeData(),
            home: const Scaffold(body: NotificationList()),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.byType(NotificationList), findsOneWidget);

      tester.resetScreenSize();
      FlutterError.onError = origOnError;
    });
  });
}
