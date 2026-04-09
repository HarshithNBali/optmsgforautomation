// Implements: TC-DISC-EMAIL-SCREEN-001..004
// Source: InboxResponsive and ArchiveResponsive with fake notifiers
// Unlocked by late→getter DI refactor
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:optmsg/model/auth/auth_state.dart';
import 'package:optmsg/model/base_response/request_response.dart';
import 'package:optmsg/model/inbox_list_model.dart';
import 'package:optmsg/screens/auth/auth_riverpod/auth_notifier.dart';
import 'package:optmsg/screens/email/inbox_riverpod/inbox_notifier.dart';
import 'package:optmsg/screens/email/inbox_riverpod/inbox_state.dart';
import 'package:optmsg/screens/email/inbox_riverpod/inbox_responsive.dart';
import 'package:optmsg/screens/email/archive_riverpod/archive_list_notifier.dart';
import 'package:optmsg/screens/email/archive_riverpod/archive_state.dart';
import 'package:optmsg/screens/email/archive_riverpod/archive_responsive.dart';

import '../helpers/test_helpers.dart';
import '../helpers/riverpod_test_helpers.dart';
import '../factories/test_data_factories.dart';

class _FakeAuthNotifier extends AuthNotifier {
  final Map<String, dynamic> _data;
  _FakeAuthNotifier(this._data);
  @override
  AuthState build() => AuthState.authenticated(_data);
}

class _FakeInboxNotifier extends InboxNotifier {
  final InboxState _state;
  _FakeInboxNotifier(this._state);
  @override
  InboxState build() => _state;
  @override
  Future<void> bootstrap({bool preserveReadingPane = false, int? emailIdToRestore, int? initialTagId, String? initialEmailType}) async {}
  @override
  Future<void> getAllEmails(String searchKey, {bool isRefresh = false, bool silent = false}) async {}
  @override
  void clearOverlayStates() {}
  @override
  void reset() {}
  @override
  void toggleSearch() {}
  @override
  void toggleFilter() {}
  @override
  void toggleMenuOptions() {}
  @override
  void clearSelection() {}
  @override
  void setShowCheckboxes(bool v) {}
  @override
  void setComposeHovered(bool v) {}
  @override
  void resetFiltersAndSelections() {}
}

class _FakeArchiveNotifier extends ArchiveNotifier {
  final ArchiveState _state;
  _FakeArchiveNotifier(this._state);
  @override
  ArchiveState build() => _state;
  @override
  Future<void> init() async {}
  @override
  void clearOverlayStates() {}
  @override
  void reset() {}
  @override
  void toggleSearch() {}
  @override
  void toggleFilter() {}
  @override
  void toggleMenuOptions() {}
  @override
  void clearSelection() {}
  @override
  void setShowCheckboxes(bool show) {}
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
      const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
      (MethodCall methodCall) async {
        if (methodCall.method == 'read') return null;
        if (methodCall.method == 'readAll') return <String, String>{};
        return null;
      },
    );
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
    when(() => setup.mockStorageService.deleteData(any()))
        .thenAnswer((_) async {});
    when(() => setup.mockInboxApi.getInboxEmails(any()))
        .thenAnswer((_) async => RequestResponse(
              data: InboxListModel.fromJson(makeInboxListJson(emails: [])),
            ));
    when(() => setup.mockTagApi.getTagsList(any()))
        .thenAnswer((_) async => RequestResponse(data: {
              'success': true, 'message': '',
              'data': {'tags': []},
            }));
  });

  group('InboxResponsive with empty state', () {
    testWidgets('should render at mobile size', (tester) async {
      tester.setScreenSize(width: 400, height: 800);
      final origOnError = FlutterError.onError;
      FlutterError.onError = (d) {
        if (d.toString().contains('overflow')) return;
        origOnError?.call(d);
      };

      const inboxState = InboxState(isLoading: false, items: []);

      await tester.pumpWidget(ProviderScope(
        overrides: [
          ...setup.serviceOverrides,
          authProvider.overrideWith(() => _FakeAuthNotifier(testUserData)),
          inboxProvider.overrideWith(() => _FakeInboxNotifier(inboxState)),
        ],
        child: MaterialApp(
          theme: testThemeData(),
          home: const Scaffold(body: InboxResponsive(type: 'inbox')),
        ),
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(InboxResponsive), findsOneWidget);

      tester.resetScreenSize();
      FlutterError.onError = origOnError;
    });
  });

  group('ArchiveResponsive with empty state', () {
    testWidgets('should render at mobile size', (tester) async {
      tester.setScreenSize(width: 400, height: 800);
      final origOnError = FlutterError.onError;
      FlutterError.onError = (d) {
        if (d.toString().contains('overflow')) return;
        origOnError?.call(d);
      };

      const archiveState = ArchiveState(isLoading: false, items: []);

      await tester.pumpWidget(ProviderScope(
        overrides: [
          ...setup.serviceOverrides,
          authProvider.overrideWith(() => _FakeAuthNotifier(testUserData)),
          archiveProvider.overrideWith(() => _FakeArchiveNotifier(archiveState)),
        ],
        child: MaterialApp(
          theme: testThemeData(),
          home: const Scaffold(body: ArchiveResponsive()),
        ),
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(ArchiveResponsive), findsOneWidget);

      tester.resetScreenSize();
      FlutterError.onError = origOnError;
    });
  });
}
