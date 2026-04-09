import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:optmsg/model/contact_list_model.dart';
import 'package:optmsg/screens/auth/auth_riverpod/auth_notifier.dart';
import 'package:optmsg/screens/contacts/contacts_riverpod/contact_list_notifier.dart';
import 'package:optmsg/screens/contacts/contacts_riverpod/contact_state.dart';

import '../../helpers/riverpod_test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late RiverpodTestSetup setup;
  late ProviderContainer container;
  late ContactListNotifier notifier;

  setUp(() async {
    setup = RiverpodTestSetup();
    when(() => setup.mockStorageService.readObjectData(any()))
        .thenAnswer((_) async => null);
    when(() => setup.mockStorageService.readData(any()))
        .thenAnswer((_) async => null);

    container = ProviderContainer(overrides: setup.serviceOverrides);
    container.read(authProvider);
    await Future.delayed(Duration.zero);
    notifier = container.read(contactListProvider.notifier);
  });

  tearDown(() => container.dispose());

  group('ContactListNotifier build()', () {
    test('should return default ContactState', () {
      final state = container.read(contactListProvider);
      expect(state.isLoading, true);
      expect(state.allContacts, isEmpty);
      expect(state.filteredContacts, isEmpty);
      expect(state.isSearch, false);
      expect(state.searchText, '');
      expect(state.selectedContact, isNull);
    });
  });

  group('ContactState', () {
    test('hasContacts should reflect filteredContacts', () {
      expect(const ContactState().hasContacts, false);
    });

    test('copyWith should work', () {
      final modified = const ContactState().copyWith(
        isLoading: false,
        isSearch: true,
        searchText: 'test',
      );
      expect(modified.isLoading, false);
      expect(modified.isSearch, true);
      expect(modified.searchText, 'test');
    });
  });

  group('ContactListNotifier pure mutators', () {
    test('setIsSearch should update isSearch', () {
      notifier.setIsSearch(true);
      expect(container.read(contactListProvider).isSearch, true);
    });

    test('clearSelection should clear selectedContact', () {
      notifier.clearSelection();
      expect(container.read(contactListProvider).selectedContact, isNull);
    });

    test('setLoading should update isLoading', () {
      notifier.setLoading(false);
      expect(container.read(contactListProvider).isLoading, false);
    });

    test('updateReadingPaneSettings(false) should clear selection', () {
      notifier.updateReadingPaneSettings(false);
      final state = container.read(contactListProvider);
      expect(state.readingPaneEnabled, false);
      expect(state.selectedContact, isNull);
      expect(state.clearSelectedContact, true);
    });

    test('updateReadingPaneSettings(true) should enable', () {
      notifier.updateReadingPaneSettings(false);
      notifier.updateReadingPaneSettings(true);
      expect(container.read(contactListProvider).readingPaneEnabled, true);
    });

    test('updateSortSetting should re-sort contacts', () {
      final c1 = Contacts.fromJson({
        'id': 1, 'firstName': 'Zara', 'lastName': 'Adams',
        'company': '', 'phones': null, 'emails': null,
      });
      final c2 = Contacts.fromJson({
        'id': 2, 'firstName': 'Alice', 'lastName': 'Zulu',
        'company': '', 'phones': null, 'emails': null,
      });
      // Need userData set for updateSortSetting to not early-return
      notifier.state = notifier.state.copyWith(
        allContacts: [c1, c2],
        filteredContacts: [c1, c2],
        userData: {'user': {'sortLastName': false}},
      );

      // Sort by first name
      notifier.updateSortSetting(false);
      final byFirst = container.read(contactListProvider).filteredContacts;
      expect(byFirst.first.firstName, 'Alice');

      // Sort by last name
      notifier.updateSortSetting(true);
      final byLast = container.read(contactListProvider).filteredContacts;
      expect(byLast.first.lastName, 'Adams');
    });
  });

  group('ContactListNotifier search', () {
    test('should filter contacts by search text', () {
      final c1 = Contacts.fromJson({
        'id': 1, 'firstName': 'Alice', 'lastName': 'Smith',
        'company': 'Acme', 'phones': null, 'emails': null,
      });
      final c2 = Contacts.fromJson({
        'id': 2, 'firstName': 'Bob', 'lastName': 'Jones',
        'company': 'Beta', 'phones': null, 'emails': null,
      });
      notifier.state = notifier.state.copyWith(
        allContacts: [c1, c2],
        filteredContacts: [c1, c2],
      );

      notifier.searchFilterContact('Alice');
      final state = container.read(contactListProvider);
      expect(state.filteredContacts, hasLength(1));
      expect(state.filteredContacts.first.firstName, 'Alice');
    });

    test('should show all contacts when search is empty', () {
      final c1 = Contacts.fromJson({
        'id': 1, 'firstName': 'Alice', 'lastName': 'Smith',
        'company': '', 'phones': null, 'emails': null,
      });
      final c2 = Contacts.fromJson({
        'id': 2, 'firstName': 'Bob', 'lastName': 'Jones',
        'company': '', 'phones': null, 'emails': null,
      });
      notifier.state = notifier.state.copyWith(
        allContacts: [c1, c2],
        filteredContacts: [c1],
        searchText: 'Alice',
      );

      notifier.searchFilterContact('');
      expect(container.read(contactListProvider).filteredContacts, hasLength(2));
    });
  });
}
