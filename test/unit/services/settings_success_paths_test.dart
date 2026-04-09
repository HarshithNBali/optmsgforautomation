import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:optmsg/model/base_response/request_response.dart';
import 'package:optmsg/model/auth/auth_state.dart';
import 'package:optmsg/screens/auth/auth_riverpod/auth_notifier.dart';
import 'package:optmsg/screens/settings/setting_riverpod/settings_notifier.dart';

import '../../helpers/riverpod_test_helpers.dart';

/// AuthNotifier that supports updateUserField for testing Settings success paths.
class _FullFakeAuthNotifier extends AuthNotifier {
  Map<String, dynamic> _userData;
  _FullFakeAuthNotifier(this._userData);

  @override
  AuthState build() => AuthState.authenticated(_userData);

  @override
  Future<void> updateUserField(String field, dynamic value) async {
    final user = Map<String, dynamic>.from(_userData['user'] ?? {});
    user[field] = value;
    _userData = {..._userData, 'user': user};
    state = AuthState.authenticated(_userData);
  }
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

  group('SettingsNotifier toggleNotification SUCCESS path', () {
    test('should update state and call updateUserField on success', () async {
      when(() => setup.mockSettingApi.toggleNotification(any()))
          .thenAnswer((_) async => RequestResponse(data: {
                'success': true,
                'message': 'Notifications disabled',
              }));

      final container = ProviderContainer(
        overrides: [
          ...setup.serviceOverrides,
          authProvider.overrideWith(() => _FullFakeAuthNotifier(Map.from(fakeUserData))),
        ],
      );
      addTearDown(container.dispose);
      await Future.delayed(Duration.zero);
      final notifier = container.read(settingsProvider.notifier);
      await Future.delayed(const Duration(milliseconds: 100));

      await notifier.toggleNotification(false);

      // The updateUserField should have been called → auth userData updated
      final authState = container.read(authProvider);
      expect(authState.userData!['user']['isNotification'], false);
    });
  });

  group('SettingsNotifier toggleSort SUCCESS path', () {
    test('should update sort setting via updateUserField', () async {
      when(() => setup.mockSettingApi.contactSortToggle(any()))
          .thenAnswer((_) async => RequestResponse(data: {
                'success': true,
                'message': 'Sort updated',
              }));

      final container = ProviderContainer(
        overrides: [
          ...setup.serviceOverrides,
          authProvider.overrideWith(() => _FullFakeAuthNotifier(Map.from(fakeUserData))),
        ],
      );
      addTearDown(container.dispose);
      await Future.delayed(Duration.zero);
      final notifier = container.read(settingsProvider.notifier);
      await Future.delayed(const Duration(milliseconds: 100));

      await notifier.toggleSort(false); // !false = true

      final authState = container.read(authProvider);
      expect(authState.userData!['user']['sortLastName'], true);
    });
  });

  group('SettingsNotifier toggleSyncContacts SUCCESS path', () {
    test('should update contactSynch via updateUserField', () async {
      when(() => setup.mockSettingApi.toggleContactSynch(any()))
          .thenAnswer((_) async => RequestResponse(data: {
                'success': true,
                'message': 'Sync updated',
              }));

      final container = ProviderContainer(
        overrides: [
          ...setup.serviceOverrides,
          authProvider.overrideWith(() => _FullFakeAuthNotifier(Map.from(fakeUserData))),
        ],
      );
      addTearDown(container.dispose);
      await Future.delayed(Duration.zero);
      final notifier = container.read(settingsProvider.notifier);
      await Future.delayed(const Duration(milliseconds: 100));

      await notifier.toggleSyncContacts(false);

      final authState = container.read(authProvider);
      expect(authState.userData!['user']['contactSynch'], false);
    });
  });

  group('SettingsNotifier toggleBiometric SUCCESS path (disable)', () {
    test('should update isDeviceBiometrics via API', () async {
      when(() => setup.mockSettingApi.deviceBiometric(any()))
          .thenAnswer((_) async => RequestResponse(data: {
                'success': true,
                'message': 'OK',
                'data': {'isDeviceBiometrics': false},
              }));

      final container = ProviderContainer(
        overrides: [
          ...setup.serviceOverrides,
          authProvider.overrideWith(() => _FullFakeAuthNotifier(Map.from(fakeUserData))),
        ],
      );
      addTearDown(container.dispose);
      await Future.delayed(Duration.zero);
      final notifier = container.read(settingsProvider.notifier);
      await Future.delayed(const Duration(milliseconds: 100));

      await notifier.toggleBiometric(false);

      expect(container.read(settingsProvider).isBiometricSelected, false);
    });
  });
}
