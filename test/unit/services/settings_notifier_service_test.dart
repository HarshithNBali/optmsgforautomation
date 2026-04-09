import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:optmsg/model/base_response/request_response.dart';
import 'package:optmsg/model/auth/auth_state.dart';
import 'package:optmsg/screens/auth/auth_riverpod/auth_notifier.dart';
import 'package:optmsg/screens/settings/setting_riverpod/settings_notifier.dart';

import '../../helpers/riverpod_test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late RiverpodTestSetup setup;
  late ProviderContainer container;
  late SettingsNotifier notifier;

  final fakeUserData = {
    'user': {
      'sortLastName': false,
      'isNotification': true,
      'contactSynch': true,
    },
    'token': 'test-token',
  };

  setUp(() async {
    setup = RiverpodTestSetup();
    when(() => setup.mockStorageService.readObjectData(any()))
        .thenAnswer((_) async => null);
    when(() => setup.mockStorageService.readData(any()))
        .thenAnswer((_) async => null);
    when(() => setup.mockStorageService.writeData(any(), any()))
        .thenAnswer((_) async {});

    container = ProviderContainer(
      overrides: [
        ...setup.serviceOverrides,
        authProvider.overrideWith(() => _FakeAuthNotifier(fakeUserData)),
      ],
    );
    await Future.delayed(Duration.zero);

    notifier = container.read(settingsProvider.notifier);
    // Let _init settle
    await Future.delayed(const Duration(milliseconds: 100));
  });

  tearDown(() => container.dispose());

  group('SettingsNotifier toggleNotification', () {
    test('should call API with correct value on toggle', () async {
      when(() => setup.mockSettingApi.toggleNotification(any()))
          .thenAnswer((_) async => RequestResponse(data: {
                'success': true,
                'message': 'Notifications disabled',
              }));

      await notifier.toggleNotification(false);

      verify(() => setup.mockSettingApi.toggleNotification({
            'isNotification': false,
          })).called(1);
    });

    test('should revert on API failure', () async {
      when(() => setup.mockSettingApi.toggleNotification(any()))
          .thenAnswer((_) async => RequestResponse(data: {
                'success': false,
                'message': 'Failed',
              }));

      await notifier.toggleNotification(false);

      final state = container.read(settingsProvider);
      // Should revert to the previous value (true)
      expect(state.isNotificationSelected, true);
    });

    test('should revert on exception', () async {
      when(() => setup.mockSettingApi.toggleNotification(any()))
          .thenThrow(Exception('Network error'));

      await notifier.toggleNotification(false);

      expect(container.read(settingsProvider).isNotificationSelected, true);
    });

    test('should no-op when userData is null', () async {
      // Reset to no userData
      notifier.reset();

      await notifier.toggleNotification(false);

      // Should not have called the API
      verifyNever(() => setup.mockSettingApi.toggleNotification(any()));
    });
  });

  group('SettingsNotifier toggleSort', () {
    test('should call API with toggled value on success', () async {
      when(() => setup.mockSettingApi.contactSortToggle(any()))
          .thenAnswer((_) async => RequestResponse(data: {
                'success': true,
                'message': 'Sort updated',
              }));

      await notifier.toggleSort(false); // !false = true → sets lastNameSorted: true

      verify(() => setup.mockSettingApi.contactSortToggle(any())).called(1);
    });

    test('should revert on API failure', () async {
      when(() => setup.mockSettingApi.contactSortToggle(any()))
          .thenAnswer((_) async => RequestResponse(data: {
                'success': false,
                'message': 'Failed',
              }));

      // Initial value is false (from fakeUserData)
      await notifier.toggleSort(false);

      final state = container.read(settingsProvider);
      // Should revert to initial value
      expect(state.lastNameSorted, false);
    });

    test('should no-op when userData is null', () async {
      notifier.reset();

      await notifier.toggleSort(true);

      verifyNever(() => setup.mockSettingApi.contactSortToggle(any()));
    });
  });

  group('SettingsNotifier toggleReadingPane', () {
    test('should update readingPaneEnabled and persist to storage', () async {
      await notifier.toggleReadingPane(false);

      final state = container.read(settingsProvider);
      expect(state.readingPaneEnabled, false);

      verify(() =>
              setup.mockStorageService.writeData('readingPaneEnabled', 'false'))
          .called(1);
    });

    test('should toggle back to true', () async {
      await notifier.toggleReadingPane(false);
      await notifier.toggleReadingPane(true);

      expect(container.read(settingsProvider).readingPaneEnabled, true);
    });
  });
}

class _FakeAuthNotifier extends AuthNotifier {
  final Map<String, dynamic>? _fakeUserData;
  _FakeAuthNotifier(this._fakeUserData);

  @override
  AuthState build() {
    if (_fakeUserData != null) {
      return AuthState.authenticated(_fakeUserData);
    }
    return AuthState.unauthenticated();
  }
}
