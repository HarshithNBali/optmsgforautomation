// Implements: TC-DISC-DRAFT-SCREEN-001..002
// Source: DraftResponsive with fake notifier (unlocked by late→getter refactor)
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:optmsg/model/auth/auth_state.dart';
import 'package:optmsg/screens/auth/auth_riverpod/auth_notifier.dart';
import 'package:optmsg/screens/email/draft_riverpod/draft_notifier.dart';
import 'package:optmsg/screens/email/draft_riverpod/draft_state.dart';
import 'package:optmsg/screens/email/draft_riverpod/draft_responsive.dart';

import '../helpers/test_helpers.dart';
import '../helpers/riverpod_test_helpers.dart';
import '../factories/test_data_factories.dart';

class _FakeAuthNotifier extends AuthNotifier {
  final Map<String, dynamic> _data;
  _FakeAuthNotifier(this._data);
  @override
  AuthState build() => AuthState.authenticated(_data);
}

class _FakeDraftNotifier extends DraftNotifier {
  final DraftState _state;
  _FakeDraftNotifier(this._state);
  @override
  DraftState build() => _state;
  @override
  Future<void> bootstrap({int? emailIdToRestore}) async {}
  @override
  Future<void> getAllEmails(String searchKey, {bool isRefresh = false}) async {}
  @override
  void toggleSearch() {}
  @override
  void clearOverlayStates() {}
  @override
  void reset() {}
  @override
  void setComposeHovered(bool v) {}
  @override
  void setCheckboxVisibility(bool v) {}
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
  });

  group('DraftResponsive with fake notifier', () {
    testWidgets('should render empty drafts at mobile size', (tester) async {
      tester.setScreenSize(width: 400, height: 800);
      final origOnError = FlutterError.onError;
      FlutterError.onError = (d) {
        if (d.toString().contains('overflow')) return;
        origOnError?.call(d);
      };

      const draftState = DraftState(isLoading: false, items: []);

      await tester.pumpWidget(ProviderScope(
        overrides: [
          ...setup.serviceOverrides,
          authProvider.overrideWith(() => _FakeAuthNotifier(testUserData)),
          draftProvider.overrideWith(() => _FakeDraftNotifier(draftState)),
        ],
        child: MaterialApp(
          theme: testThemeData(),
          home: const Scaffold(body: DraftResponsive()),
        ),
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(DraftResponsive), findsOneWidget);

      tester.resetScreenSize();
      FlutterError.onError = origOnError;
    });
  });
}
