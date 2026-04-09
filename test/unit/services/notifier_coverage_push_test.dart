import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:optmsg/model/base_response/request_response.dart';
import 'package:optmsg/model/auth/auth_state.dart';
import 'package:optmsg/screens/auth/auth_riverpod/auth_notifier.dart';
import 'package:optmsg/screens/settings/setting_riverpod/settings_notifier.dart';
import 'package:optmsg/screens/tags/tag_riverpod/tags_notifier.dart';
import 'package:optmsg/screens/settings/account_riverpod/account_notifier.dart';

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
  final fakeUserData = {
    'user': {
      'id': 1,
      'sortLastName': false,
      'isNotification': true,
      'contactSynch': true,
      'isDeviceBiometrics': false,
    },
    'token': 'test-token',
  };

  setUp(() {
    setup = RiverpodTestSetup();
    when(() => setup.mockStorageService.readObjectData(any())).thenAnswer((_) async => null);
    when(() => setup.mockStorageService.readData(any())).thenAnswer((_) async => null);
    when(() => setup.mockStorageService.writeData(any(), any())).thenAnswer((_) async {});
    when(() => setup.mockStorageService.writeObjectData(any(), any())).thenAnswer((_) async {});
  });

  // ===== SettingsNotifier toggleNotification revert =====
  group('SettingsNotifier toggleNotification revert scenarios', () {
    test('should revert on exception', () async {
      when(() => setup.mockSettingApi.toggleNotification(any()))
          .thenThrow(Exception('Network'));

      final container = ProviderContainer(
        overrides: [
          ...setup.serviceOverrides,
          authProvider.overrideWith(() => _FakeAuthNotifier(fakeUserData)),
        ],
      );
      addTearDown(container.dispose);
      await Future.delayed(Duration.zero);
      final notifier = container.read(settingsProvider.notifier);
      await Future.delayed(const Duration(milliseconds: 100));

      await notifier.toggleNotification(false);

      expect(container.read(settingsProvider).isNotificationSelected, true);
    });

    test('should no-op when userData is null', () async {
      final container = ProviderContainer(overrides: setup.serviceOverrides);
      addTearDown(container.dispose);
      container.read(authProvider);
      await Future.delayed(Duration.zero);

      final notifier = container.read(settingsProvider.notifier);
      await Future.delayed(const Duration(milliseconds: 100));
      notifier.reset();

      await notifier.toggleNotification(false);

      verifyNever(() => setup.mockSettingApi.toggleNotification(any()));
    });
  });

  // ===== SettingsNotifier toggleSort revert =====
  group('SettingsNotifier toggleSort revert', () {
    test('should revert on exception', () async {
      when(() => setup.mockSettingApi.contactSortToggle(any()))
          .thenThrow(Exception('Network'));

      final container = ProviderContainer(
        overrides: [
          ...setup.serviceOverrides,
          authProvider.overrideWith(() => _FakeAuthNotifier(fakeUserData)),
        ],
      );
      addTearDown(container.dispose);
      await Future.delayed(Duration.zero);
      final notifier = container.read(settingsProvider.notifier);
      await Future.delayed(const Duration(milliseconds: 100));

      await notifier.toggleSort(true);

      // Should revert — initial was false from fakeUserData
      expect(container.read(settingsProvider).lastNameSorted, false);
    });
  });

  // ===== SettingsNotifier toggleSyncContacts =====
  group('SettingsNotifier toggleSyncContacts', () {
    test('should call API with false', () async {
      when(() => setup.mockSettingApi.toggleContactSynch(any()))
          .thenAnswer((_) async => RequestResponse(data: {
                'success': true, 'message': 'Sync disabled',
              }));

      final container = ProviderContainer(
        overrides: [
          ...setup.serviceOverrides,
          authProvider.overrideWith(() => _FakeAuthNotifier(fakeUserData)),
        ],
      );
      addTearDown(container.dispose);
      await Future.delayed(Duration.zero);
      final notifier = container.read(settingsProvider.notifier);
      await Future.delayed(const Duration(milliseconds: 100));

      await notifier.toggleSyncContacts(false);

      verify(() => setup.mockSettingApi.toggleContactSynch({
            'contactSynch': false,
          })).called(1);
    });

    test('should revert on exception', () async {
      when(() => setup.mockSettingApi.toggleContactSynch(any()))
          .thenThrow(Exception('Network'));

      final container = ProviderContainer(
        overrides: [
          ...setup.serviceOverrides,
          authProvider.overrideWith(() => _FakeAuthNotifier(fakeUserData)),
        ],
      );
      addTearDown(container.dispose);
      await Future.delayed(Duration.zero);
      final notifier = container.read(settingsProvider.notifier);
      await Future.delayed(const Duration(milliseconds: 100));

      await notifier.toggleSyncContacts(false);

      expect(container.read(settingsProvider).syncContact, true);
    });
  });

  // ===== SettingsNotifier reset =====
  group('SettingsNotifier reset', () {
    test('should clear all state', () async {
      final container = ProviderContainer(
        overrides: [
          ...setup.serviceOverrides,
          authProvider.overrideWith(() => _FakeAuthNotifier(fakeUserData)),
        ],
      );
      addTearDown(container.dispose);
      await Future.delayed(Duration.zero);
      final notifier = container.read(settingsProvider.notifier);
      await Future.delayed(const Duration(milliseconds: 100));

      notifier.reset();

      final state = container.read(settingsProvider);
      expect(state.userData, isNull);
      expect(state.isLoading, false);
    });
  });

  // ===== TagsNotifier setEditFlag / setId / setTagsList =====
  group('TagsNotifier expanded', () {
    test('setEditFlag and setId', () async {
      final container = ProviderContainer(overrides: setup.serviceOverrides);
      addTearDown(container.dispose);
      container.read(authProvider);
      await Future.delayed(Duration.zero);

      final notifier = container.read(tagsProvider.notifier);

      notifier.setEditFlag(true);
      expect(container.read(tagsProvider).editFlag, true);

      notifier.setId(42);
      expect(container.read(tagsProvider).id, 42);

      notifier.setEditFlag(false);
      expect(container.read(tagsProvider).editFlag, false);

      notifier.setId(0);
      expect(container.read(tagsProvider).id, 0);
    });

    test('reset should clear all state', () async {
      final container = ProviderContainer(overrides: setup.serviceOverrides);
      addTearDown(container.dispose);
      container.read(authProvider);
      await Future.delayed(Duration.zero);

      final notifier = container.read(tagsProvider.notifier);
      notifier.setEditFlag(true);
      notifier.setId(5);
      notifier.reset();

      final state = container.read(tagsProvider);
      expect(state.editFlag, false);
      expect(state.id, isNull);
      expect(state.tagsList, isNull);
    });
  });

  // ===== AccountNotifier formatTimestamp + loadUser =====
  group('AccountNotifier expanded', () {
    test('formatTimestamp edge cases', () async {
      final container = ProviderContainer(overrides: setup.serviceOverrides);
      addTearDown(container.dispose);
      container.read(authProvider);
      await Future.delayed(Duration.zero);

      final notifier = container.read(accountProvider.notifier);

      // 0 timestamp
      final result0 = notifier.formatTimestamp(0);
      expect(result0, isNotEmpty);

      // Very large timestamp
      final resultLarge = notifier.formatTimestamp(2000000000);
      expect(resultLarge, contains('2033'));
    });

    test('loadUser with created date should populate subscriptionDate', () async {
      final container = ProviderContainer(
        overrides: [
          ...setup.serviceOverrides,
          authProvider.overrideWith(() => _FakeAuthNotifier(<String, dynamic>{
                'user': <String, dynamic>{
                  'created': '2024-01-01T00:00:00.000Z',
                  'isFreeUser': false,
                },
              })),
        ],
      );
      addTearDown(container.dispose);
      await Future.delayed(Duration.zero);

      await container.read(accountProvider.notifier).loadUser();

      final state = container.read(accountProvider);
      expect(state.userData, isNotNull);
      expect(state.subscriptionDate, isNotEmpty);
    });

    test('loadUser without subscription date', () async {
      final container = ProviderContainer(
        overrides: [
          ...setup.serviceOverrides,
          authProvider.overrideWith(() => _FakeAuthNotifier({
                'user': {'id': 1},
              })),
        ],
      );
      addTearDown(container.dispose);
      await Future.delayed(Duration.zero);

      await container.read(accountProvider.notifier).loadUser();

      final state = container.read(accountProvider);
      expect(state.userData, isNotNull);
    });
  });
}
