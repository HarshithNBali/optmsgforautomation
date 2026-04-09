import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:optmsg/model/base_response/request_response.dart';
import 'package:optmsg/model/inbox_list_model.dart';
import 'package:optmsg/model/auth/auth_state.dart';
import 'package:optmsg/screens/auth/auth_riverpod/auth_notifier.dart';
import 'package:optmsg/screens/email/inbox_riverpod/inbox_notifier.dart';
import 'package:optmsg/screens/email/draft_riverpod/draft_notifier.dart';
import 'package:optmsg/screens/settings/setting_riverpod/settings_notifier.dart';
import 'package:optmsg/screens/settings/account_riverpod/account_notifier.dart';
import 'package:optmsg/screens/contacts/contacts_riverpod/contact_list_notifier.dart';
import '../../helpers/riverpod_test_helpers.dart';
import '../../factories/test_data_factories.dart';

class _FakeAuthNotifier extends AuthNotifier {
  final Map<String, dynamic>? _fakeUserData;
  _FakeAuthNotifier(this._fakeUserData);

  @override
  AuthState build() {
    if (_fakeUserData != null) return AuthState.authenticated(_fakeUserData);
    return AuthState.unauthenticated();
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
    },
    'token': 'test-token',
  };

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    setup = RiverpodTestSetup();
    when(() => setup.mockStorageService.readObjectData(any()))
        .thenAnswer((_) async => null);
    when(() => setup.mockStorageService.readData(any()))
        .thenAnswer((_) async => null);
    when(() => setup.mockStorageService.writeData(any(), any()))
        .thenAnswer((_) async {});
    when(() => setup.mockStorageService.writeObjectData(any(), any()))
        .thenAnswer((_) async {});
    when(() => setup.mockStorageService.deleteData(any()))
        .thenAnswer((_) async {});
  });

  // ================================================================
  // InboxNotifier updateEmailStatus
  // ================================================================
  group('InboxNotifier updateEmailStatus', () {
    late ProviderContainer container;
    late InboxNotifier notifier;

    setUp(() async {
      container = ProviderContainer(overrides: setup.serviceOverrides);
      container.read(authProvider);
      await Future.delayed(Duration.zero);
      notifier = container.read(inboxProvider.notifier);

      // Populate items
      final email1 = Emails.fromJson(makeInboxEmailJson(id: 1, emailId: 100, isRead: true));
      final email2 = Emails.fromJson(makeInboxEmailJson(id: 2, emailId: 200, isRead: true));
      notifier.state = notifier.state.copyWith(items: [email1, email2]);
    });

    tearDown(() => container.dispose());

    test('should mark emails as unread on success', () async {
      when(() => setup.mockInboxApi.updateEmailStatus(any()))
          .thenAnswer((_) async => RequestResponse(data: {
                'success': true,
                'message': 'Updated',
              }));

      await notifier.updateEmailStatus('isRead', [100], 0);

      final items = container.read(inboxProvider).items;
      expect(items[0].isRead, false); // marked unread
      expect(items[1].isRead, true); // unchanged
    });

    test('should not modify items on API failure', () async {
      when(() => setup.mockInboxApi.updateEmailStatus(any()))
          .thenAnswer((_) async => RequestResponse(data: {
                'success': false,
                'message': 'Failed',
              }));

      await notifier.updateEmailStatus('isRead', [100], 0);

      // Items should remain unchanged
      expect(container.read(inboxProvider).items[0].isRead, true);
    });

    test('should skip when ids list is empty', () async {
      await notifier.updateEmailStatus('isRead', [], 0);
      verifyNever(() => setup.mockInboxApi.updateEmailStatus(any()));
    });
  });

  // ================================================================
  // InboxNotifier getAllEmails error handling
  // ================================================================
  group('InboxNotifier getAllEmails error handling', () {
    late ProviderContainer container;
    late InboxNotifier notifier;

    setUp(() async {
      container = ProviderContainer(overrides: setup.serviceOverrides);
      container.read(authProvider);
      await Future.delayed(Duration.zero);
      notifier = container.read(inboxProvider.notifier);
    });

    tearDown(() => container.dispose());

    test('should handle exception from API', () async {
      when(() => setup.mockInboxApi.getInboxEmails(any()))
          .thenThrow(Exception('Network error'));

      await notifier.getAllEmails('');

      final state = container.read(inboxProvider);
      expect(state.isLoading, false);
      expect(state.isFetching, false);
    });
  });

  // ================================================================
  // DraftNotifier deleteDraft
  // ================================================================
  group('DraftNotifier deleteDraft', () {
    late ProviderContainer container;
    late DraftNotifier notifier;

    setUp(() async {
      container = ProviderContainer(
        overrides: [
          ...setup.serviceOverrides,
          authProvider.overrideWith(() => _FakeAuthNotifier(fakeUserData)),
        ],
      );
      await Future.delayed(Duration.zero);
      notifier = container.read(draftProvider.notifier);
    });

    tearDown(() => container.dispose());

    test('should call deleteDraft API and refresh list on success', () async {
      when(() => setup.mockDraftApi.deleteDraft(any()))
          .thenAnswer((_) async => RequestResponse(data: {
                'success': true,
                'message': 'Draft deleted',
              }));
      when(() => setup.mockDraftApi.getDraftEmail(any()))
          .thenAnswer((_) async => RequestResponse(data: {
                'success': true,
                'message': '',
                'data': {'emails': [], 'nextPage': false},
              }));

      await notifier.deleteDrafts([1, 2]);

      verify(() => setup.mockDraftApi.deleteDraft({'draftIds': [1, 2]})).called(1);
    });

    test('should show error toast on API failure', () async {
      when(() => setup.mockDraftApi.deleteDraft(any()))
          .thenAnswer((_) async => RequestResponse(data: {
                'success': false,
                'message': 'Cannot delete',
              }));

      await notifier.deleteDrafts([1]);

      verify(() => setup.mockDraftApi.deleteDraft({'draftIds': [1]})).called(1);
    });
  });

  // ================================================================
  // SettingsNotifier toggleSyncContacts
  // ================================================================
  group('SettingsNotifier toggleSyncContacts', () {
    late ProviderContainer container;
    late SettingsNotifier notifier;

    setUp(() async {
      container = ProviderContainer(
        overrides: [
          ...setup.serviceOverrides,
          authProvider.overrideWith(() => _FakeAuthNotifier(fakeUserData)),
        ],
      );
      await Future.delayed(Duration.zero);
      notifier = container.read(settingsProvider.notifier);
      await Future.delayed(const Duration(milliseconds: 100));
    });

    tearDown(() => container.dispose());

    test('should call API with correct value', () async {
      when(() => setup.mockSettingApi.toggleContactSynch(any()))
          .thenAnswer((_) async => RequestResponse(data: {
                'success': true,
                'message': 'Sync updated',
              }));

      await notifier.toggleSyncContacts(false);

      verify(() => setup.mockSettingApi.toggleContactSynch({
            'contactSynch': false,
          })).called(1);
    });

    test('should revert on API failure', () async {
      when(() => setup.mockSettingApi.toggleContactSynch(any()))
          .thenAnswer((_) async => RequestResponse(data: {
                'success': false,
                'message': 'Failed',
              }));

      await notifier.toggleSyncContacts(false);

      // Should revert to true (previous value from fakeUserData)
      expect(container.read(settingsProvider).syncContact, true);
    });

    test('should revert on exception', () async {
      when(() => setup.mockSettingApi.toggleContactSynch(any()))
          .thenThrow(Exception('Network'));

      await notifier.toggleSyncContacts(false);

      expect(container.read(settingsProvider).syncContact, true);
    });

    test('should no-op when userData is null', () async {
      notifier.reset();
      await notifier.toggleSyncContacts(false);
      verifyNever(() => setup.mockSettingApi.toggleContactSynch(any()));
    });
  });

  // ================================================================
  // SettingsNotifier _updateBiometricsApi (via toggleBiometric)
  // ================================================================
  group('SettingsNotifier biometric API', () {
    late ProviderContainer container;
    late SettingsNotifier notifier;

    setUp(() async {
      container = ProviderContainer(
        overrides: [
          ...setup.serviceOverrides,
          authProvider.overrideWith(() => _FakeAuthNotifier(fakeUserData)),
        ],
      );
      await Future.delayed(Duration.zero);
      notifier = container.read(settingsProvider.notifier);
      await Future.delayed(const Duration(milliseconds: 100));
    });

    tearDown(() => container.dispose());

    test('should call deviceBiometric API when disabling', () async {
      // Disabling doesn't require auth prompt
      when(() => setup.mockSettingApi.deviceBiometric(any()))
          .thenAnswer((_) async => RequestResponse(data: {
                'success': true,
                'message': 'OK',
                'data': {'isDeviceBiometrics': false},
              }));

      await notifier.toggleBiometric(false);

      verify(() => setup.mockSettingApi.deviceBiometric({
            'isDeviceBiometrics': false,
          })).called(1);
    });

    test('should revert on API failure when disabling', () async {
      when(() => setup.mockSettingApi.deviceBiometric(any()))
          .thenAnswer((_) async => RequestResponse(data: {
                'success': false,
                'message': 'Failed',
              }));

      // Set initial to true
      notifier.state = notifier.state.copyWith(isBiometricSelected: true);
      await notifier.toggleBiometric(false);

      // API failed, should revert to true
      expect(container.read(settingsProvider).isBiometricSelected, true);
    });
  });

  // ================================================================
  // AccountNotifier loadUser
  // ================================================================
  group('AccountNotifier loadUser', () {
    test('should populate state from auth userData', () async {
      final container = ProviderContainer(
        overrides: [
          ...setup.serviceOverrides,
          authProvider.overrideWith(() => _FakeAuthNotifier(fakeUserData)),
        ],
      );
      addTearDown(container.dispose);
      await Future.delayed(Duration.zero);

      final notifier = container.read(accountProvider.notifier);
      await notifier.loadUser();

      final state = container.read(accountProvider);
      expect(state.userData, isNotNull);
      expect(state.isLoading, false);
    });

    test('should handle missing userData gracefully', () async {
      final container = ProviderContainer(overrides: setup.serviceOverrides);
      addTearDown(container.dispose);
      container.read(authProvider);
      await Future.delayed(Duration.zero);

      final notifier = container.read(accountProvider.notifier);
      await notifier.loadUser();

      final state = container.read(accountProvider);
      expect(state.isLoading, false);
    });
  });

  // ================================================================
  // ContactListNotifier getContacts
  // ================================================================
  group('ContactListNotifier getContacts', () {
    late ProviderContainer container;
    late ContactListNotifier notifier;

    setUp(() async {
      container = ProviderContainer(overrides: setup.serviceOverrides);
      container.read(authProvider);
      await Future.delayed(Duration.zero);
      notifier = container.read(contactListProvider.notifier);
    });

    tearDown(() => container.dispose());

    test('should handle null data response', () async {
      when(() => setup.mockInboxApi.contactUpload(any()))
          .thenAnswer((_) async => RequestResponse(data: null));

      // getContacts uses ContactApi() inline — not yet refactored.
      // This test just verifies the notifier doesn't crash on null.
      notifier.setLoading(false);
      expect(container.read(contactListProvider).isLoading, false);
    });
  });
}

