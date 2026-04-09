import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:optmsg/model/base_response/request_response.dart';
import 'package:optmsg/model/contact_list_model.dart';
import 'package:optmsg/screens/auth/auth_riverpod/auth_notifier.dart';
import 'package:optmsg/screens/email/archive_riverpod/archive_list_notifier.dart';
import 'package:optmsg/screens/contacts/contacts_riverpod/contact_list_notifier.dart';
import 'package:optmsg/router/app_routes.dart';

import '../../helpers/riverpod_test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late RiverpodTestSetup setup;

  setUp(() {
    setup = RiverpodTestSetup();
    when(() => setup.mockStorageService.readObjectData(any())).thenAnswer((_) async => null);
    when(() => setup.mockStorageService.readData(any())).thenAnswer((_) async => null);
    when(() => setup.mockStorageService.deleteData(any())).thenAnswer((_) async {});
    when(() => setup.mockStorageService.writeData(any(), any())).thenAnswer((_) async {});
  });

  // ===== ArchiveNotifier updateInboxEmailStatus (archive path) =====
  group('ArchiveNotifier updateInboxEmailStatus archive path', () {
    late ProviderContainer container;
    late ArchiveNotifier notifier;

    setUp(() async {
      container = ProviderContainer(overrides: setup.serviceOverrides);
      container.read(authProvider);
      await Future.delayed(Duration.zero);

      await runZonedGuarded(() async {
        notifier = container.read(archiveProvider.notifier);
        await Future.delayed(const Duration(milliseconds: 50));
      }, (e, _) {});
    });

    tearDown(() => container.dispose());

    test('should call apiService.post for archive to trash move', () async {
      notifier.state = notifier.state.copyWith(currentPath: AppRoutes.archive);

      when(() => setup.mockApiService.post(any(), any()))
          .thenAnswer((_) async => {'success': true, 'message': 'OK'});

      await notifier.updateInboxEmailStatus('isTrash', [1], 0);

      // Should call post at least once (remove from archive) + once (set trash flag)
      verify(() => setup.mockApiService.post(any(), any())).called(greaterThanOrEqualTo(1));
    });

    test('should handle archive path failure', () async {
      notifier.state = notifier.state.copyWith(currentPath: AppRoutes.archive);

      when(() => setup.mockApiService.post(any(), any()))
          .thenAnswer((_) async => {'success': false, 'message': 'Failed'});

      await notifier.updateInboxEmailStatus('isTrash', [1], 0);

      // Should not crash
      expect(container.read(archiveProvider), isNotNull);
    });
  });

  // ===== ArchiveNotifier updateInboxEmailStatus (sent path) =====
  group('ArchiveNotifier updateInboxEmailStatus sent path', () {
    late ProviderContainer container;
    late ArchiveNotifier notifier;

    setUp(() async {
      container = ProviderContainer(overrides: setup.serviceOverrides);
      container.read(authProvider);
      await Future.delayed(Duration.zero);

      await runZonedGuarded(() async {
        notifier = container.read(archiveProvider.notifier);
        await Future.delayed(const Duration(milliseconds: 50));
      }, (e, _) {});
    });

    tearDown(() => container.dispose());

    test('should handle sent to inbox move', () async {
      notifier.state = notifier.state.copyWith(currentPath: AppRoutes.sent);

      when(() => setup.mockApiService.post(any(), any()))
          .thenAnswer((_) async => {'success': true, 'message': 'OK'});

      await notifier.updateInboxEmailStatus('isInbox', [1], 0);

      verify(() => setup.mockApiService.post(any(), any())).called(greaterThanOrEqualTo(1));
    });

    test('should handle sent to trash move', () async {
      notifier.state = notifier.state.copyWith(currentPath: AppRoutes.sent);

      when(() => setup.mockApiService.post(any(), any()))
          .thenAnswer((_) async => {'success': true, 'message': 'Moved'});

      await notifier.updateInboxEmailStatus('isTrash', [1, 2], 0);

      verify(() => setup.mockApiService.post(any(), any())).called(greaterThanOrEqualTo(1));
    });

    test('should handle sent path API failure', () async {
      notifier.state = notifier.state.copyWith(currentPath: AppRoutes.sent);

      when(() => setup.mockApiService.post(any(), any()))
          .thenAnswer((_) async => {'success': false, 'message': 'Error'});

      await notifier.updateInboxEmailStatus('isTrash', [1], 0);

      expect(container.read(archiveProvider), isNotNull);
    });
  });

  // ===== ArchiveNotifier updateInboxEmailStatus (trash path) =====
  group('ArchiveNotifier updateInboxEmailStatus trash path', () {
    late ProviderContainer container;
    late ArchiveNotifier notifier;

    setUp(() async {
      container = ProviderContainer(overrides: setup.serviceOverrides);
      container.read(authProvider);
      await Future.delayed(Duration.zero);

      await runZonedGuarded(() async {
        notifier = container.read(archiveProvider.notifier);
        await Future.delayed(const Duration(milliseconds: 50));
      }, (e, _) {});
    });

    tearDown(() => container.dispose());

    test('should call archiveApi for trash to inbox', () async {
      notifier.state = notifier.state.copyWith(currentPath: AppRoutes.trash);

      when(() => setup.mockArchiveApi.updateEmailStatus(any()))
          .thenAnswer((_) async => RequestResponse(data: {
                'success': true, 'message': 'Restored',
              }));
      when(() => setup.mockApiService.post(any(), any()))
          .thenAnswer((_) async => {'success': true});

      await notifier.updateInboxEmailStatus('isInbox', [1], 0);

      verify(() => setup.mockArchiveApi.updateEmailStatus(any())).called(1);
    });

    test('should handle trash permanent delete (isTrash → isDeleted)', () async {
      notifier.state = notifier.state.copyWith(currentPath: AppRoutes.trash);

      when(() => setup.mockArchiveApi.updateEmailStatus(any()))
          .thenAnswer((_) async => RequestResponse(data: {
                'success': true, 'message': 'Deleted',
              }));

      await notifier.updateInboxEmailStatus('isTrash', [1], 0);

      // isTrash maps to isDeleted key for trash path
      verify(() => setup.mockArchiveApi.updateEmailStatus({
            'key': 'isDeleted',
            'emailIds': [1],
            'value': true,
          })).called(1);
    });
  });

  // ===== ContactListNotifier =====
  group('ContactListNotifier expanded', () {
    late ProviderContainer container;
    late ContactListNotifier notifier;

    setUp(() async {
      container = ProviderContainer(overrides: setup.serviceOverrides);
      container.read(authProvider);
      await Future.delayed(Duration.zero);
      notifier = container.read(contactListProvider.notifier);
    });

    tearDown(() => container.dispose());

    test('searchFilterContact should filter by name', () {
      final c1 = Contacts.fromJson({
        'id': 1, 'firstName': 'Alice', 'lastName': 'Smith',
        'company': 'Acme', 'phones': null, 'emails': null,
      });
      final c2 = Contacts.fromJson({
        'id': 2, 'firstName': 'Bob', 'lastName': 'Jones',
        'company': 'Beta', 'phones': null, 'emails': null,
      });
      final c3 = Contacts.fromJson({
        'id': 3, 'firstName': 'Charlie', 'lastName': 'Smith',
        'company': 'Gamma', 'phones': null, 'emails': null,
      });
      notifier.state = notifier.state.copyWith(
        allContacts: [c1, c2, c3],
        filteredContacts: [c1, c2, c3],
      );

      notifier.searchFilterContact('Smith');

      final state = container.read(contactListProvider);
      expect(state.filteredContacts, hasLength(2));
      expect(state.filteredContacts[0].lastName, 'Smith');
      expect(state.searchText, 'Smith');
    });

    test('searchFilterContact should filter by company', () {
      final c1 = Contacts.fromJson({
        'id': 1, 'firstName': 'Alice', 'lastName': 'A',
        'company': 'Acme Corp', 'phones': null, 'emails': null,
      });
      final c2 = Contacts.fromJson({
        'id': 2, 'firstName': 'Bob', 'lastName': 'B',
        'company': 'Beta Inc', 'phones': null, 'emails': null,
      });
      notifier.state = notifier.state.copyWith(
        allContacts: [c1, c2],
        filteredContacts: [c1, c2],
      );

      notifier.searchFilterContact('Acme');

      expect(container.read(contactListProvider).filteredContacts, hasLength(1));
      expect(container.read(contactListProvider).filteredContacts[0].company, 'Acme Corp');
    });

    test('searchFilterContact empty should show all contacts', () {
      final c1 = Contacts.fromJson({
        'id': 1, 'firstName': 'A', 'lastName': 'B',
        'company': '', 'phones': null, 'emails': null,
      });
      notifier.state = notifier.state.copyWith(
        allContacts: [c1],
        filteredContacts: [],
        searchText: 'old',
      );

      notifier.searchFilterContact('');

      expect(container.read(contactListProvider).filteredContacts, hasLength(1));
      expect(container.read(contactListProvider).searchText, '');
    });

    test('clearSelection should reset selectedContact', () {
      notifier.clearSelection();
      expect(container.read(contactListProvider).selectedContact, isNull);
    });

    test('setIsSearch should update flag', () {
      notifier.setIsSearch(true);
      expect(container.read(contactListProvider).isSearch, true);
    });

    test('setLoading should update flag', () {
      notifier.setLoading(false);
      expect(container.read(contactListProvider).isLoading, false);
    });
  });
}
