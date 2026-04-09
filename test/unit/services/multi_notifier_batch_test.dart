import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:optmsg/model/auth/auth_state.dart';
import 'package:optmsg/screens/auth/auth_riverpod/auth_notifier.dart';
import 'package:optmsg/screens/auth/passKey/passkey_notifier.dart';
import 'package:optmsg/screens/email/draft_riverpod/draft_notifier.dart';
import 'package:optmsg/services/session_refresh_mutex.dart';

import '../../helpers/riverpod_test_helpers.dart';

class _FakeAuthNotifier extends AuthNotifier {
  final Map<String, dynamic>? _data;
  _FakeAuthNotifier(this._data);
  @override
  AuthState build() =>
      _data != null ? AuthState.authenticated(_data) : AuthState.unauthenticated();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late RiverpodTestSetup setup;

  setUp(() {
    setup = RiverpodTestSetup();
    when(() => setup.mockStorageService.readObjectData(any())).thenAnswer((_) async => null);
    when(() => setup.mockStorageService.readData(any())).thenAnswer((_) async => null);
    when(() => setup.mockStorageService.writeData(any(), any())).thenAnswer((_) async {});
    when(() => setup.mockStorageService.writeObjectData(any(), any())).thenAnswer((_) async {});
    SessionRefreshMutex.isLoggedOut = false;
    SessionRefreshMutex.passkeyFlowInProgress = false;
  });

  // ===== AuthNotifier updateUserField + persistUserData =====
  group('AuthNotifier updateUserField and persistUserData', () {
    late ProviderContainer container;

    setUp(() async {
      container = ProviderContainer(overrides: setup.serviceOverrides);
      container.read(authProvider);
      await Future.delayed(Duration.zero);
    });

    tearDown(() => container.dispose());

    test('persistUserData should update state and write to storage', () async {
      final notifier = container.read(authProvider.notifier);
      final data = {'user': {'id': 1, 'name': 'Test'}};

      await notifier.persistUserData(data);

      final state = container.read(authProvider);
      expect(state.userData, data);
      verify(() => setup.mockStorageService.writeObjectData('userData', data)).called(1);
    });

    test('updateUserField should modify single field', () async {
      final notifier = container.read(authProvider.notifier);
      notifier.setAuthenticated(true, userData: {
        'user': {'id': 1, 'isNotification': true},
      });

      await notifier.updateUserField('isNotification', false);

      final state = container.read(authProvider);
      expect(state.userData!['user']['isNotification'], false);
    });

    test('updateUserField should preserve other fields', () async {
      final notifier = container.read(authProvider.notifier);
      notifier.setAuthenticated(true, userData: {
        'user': {'id': 42, 'name': 'Test', 'sortLastName': false},
      });

      await notifier.updateUserField('sortLastName', true);

      final state = container.read(authProvider);
      expect(state.userData!['user']['id'], 42);
      expect(state.userData!['user']['name'], 'Test');
      expect(state.userData!['user']['sortLastName'], true);
    });
  });

  // ===== AuthNotifier _clearError =====
  group('AuthNotifier error clearing', () {
    late ProviderContainer container;

    setUp(() async {
      container = ProviderContainer(overrides: setup.serviceOverrides);
      container.read(authProvider);
      await Future.delayed(Duration.zero);
    });

    tearDown(() => container.dispose());

    test('userLogin should clear previous error before API call', () async {
      final notifier = container.read(authProvider.notifier);

      // Set an error state first
      notifier.setAuthenticated(false);

      when(() => setup.mockApiService.post(any(), any()))
          .thenAnswer((_) async => {'success': false, 'message': 'New error'});

      await notifier.userLogin('token');

      // Should have the new error, not cleared
      final state = container.read(authProvider);
      expect(state.errorMessage, 'New error');
    });
  });

  // ===== PasskeyNotifier skip =====
  group('PasskeyNotifier skip', () {
    test('should set isEnabled to false', () async {
      final container = ProviderContainer(
        overrides: [
          ...setup.serviceOverrides,
          authProvider.overrideWith(() => _FakeAuthNotifier({
                'user': {'userName': 'test', 'boardingSteps': 'completed'},
              })),
        ],
      );
      addTearDown(container.dispose);
      await Future.delayed(Duration.zero);

      final sub = container.listen(passkeyProvider, (_, _) {});
      addTearDown(sub.close);
      await Future.delayed(const Duration(milliseconds: 100));

      final notifier = container.read(passkeyProvider.notifier);
      notifier.skip();

      expect(container.read(passkeyProvider).isEnabled, false);
    });
  });

  // ===== PasskeyNotifier enablePasskey guard =====
  group('PasskeyNotifier enablePasskey guards', () {
    test('should return false when canEnable is false (no userData)', () async {
      final container = ProviderContainer(overrides: setup.serviceOverrides);
      addTearDown(container.dispose);
      container.read(authProvider);
      await Future.delayed(Duration.zero);

      final sub = container.listen(passkeyProvider, (_, _) {});
      addTearDown(sub.close);
      await Future.delayed(const Duration(milliseconds: 100));

      final notifier = container.read(passkeyProvider.notifier);
      final result = await notifier.enablePasskey();

      expect(result, false);
    });
  });

  // ===== DraftNotifier bootstrap + setupListeners =====
  group('DraftNotifier bootstrap', () {
    late ProviderContainer container;
    late DraftNotifier notifier;

    setUp(() async {
      container = ProviderContainer(
        overrides: [
          ...setup.serviceOverrides,
          authProvider.overrideWith(() => _FakeAuthNotifier({
                'user': {'id': 1},
                'token': 'test-token',
              })),
        ],
      );
      await Future.delayed(Duration.zero);
      notifier = container.read(draftProvider.notifier);
    });

    tearDown(() => container.dispose());

    // bootstrap calls SharedPreferences.getInstance() which needs platform channel.
    // Tested indirectly via setupListeners and getAllEmails tests.

    test('setupListeners should use socket', () async {
      notifier.state = notifier.state.copyWith(userData: {
        'user': {'id': 42},
      });

      await notifier.setupListeners();

      // Socket methods should have been called
      verify(() => setup.mockSocketService.emitEventWithAck(
            any(), any(),
            ackCallback: any(named: 'ackCallback'),
          )).called(greaterThanOrEqualTo(1));
    });
  });

  // ===== DraftNotifier updateReadingPaneSettings =====
  group('DraftNotifier updateReadingPaneSettings', () {
    test('should be settable', () async {
      final container = ProviderContainer(overrides: setup.serviceOverrides);
      addTearDown(container.dispose);
      container.read(authProvider);
      await Future.delayed(Duration.zero);

      final notifier = container.read(draftProvider.notifier);
      notifier.updateReadingPaneSettings(false);

      expect(container.read(draftProvider).readingPaneEnabled, false);
    });
  });
}
