// Implements: TC-DISC-CON-SEL-001..020
// Source: lib/screens/contacts/contacts_riverpod/contact_list_notifier.dart
// Coverage target: Push from 18.7% toward 35%+
import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:optmsg/screens/auth/auth_riverpod/auth_notifier.dart';
import 'package:optmsg/screens/contacts/contacts_riverpod/contact_list_notifier.dart';

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
    when(() => setup.mockStorageService.writeData(any(), any()))
        .thenAnswer((_) async {});

    container = ProviderContainer(overrides: setup.serviceOverrides);
    container.read(authProvider);
    await Future.delayed(Duration.zero);

    await runZonedGuarded(() async {
      notifier = container.read(contactListProvider.notifier);
      await Future.delayed(const Duration(milliseconds: 100));
    }, (e, _) {});
  });

  tearDown(() => container.dispose());

  group('ContactListNotifier selection methods', () {
    test('onLongPress should enter multi-select mode with contact', () {
      // TC-DISC-CON-SEL-001
      notifier.onLongPress(42);
      final state = container.read(contactListProvider);
      expect(state.selectedContactIds, contains(42));
      expect(state.longPressFlag, isFalse);
    });

    test('onLongPress again should exit multi-select mode', () {
      // TC-DISC-CON-SEL-002
      notifier.onLongPress(42); // enter
      notifier.onLongPress(42); // exit
      final state = container.read(contactListProvider);
      expect(state.selectedContactIds, isEmpty);
      expect(state.longPressFlag, isTrue);
    });

    test('toggleSelectContact should add contact id', () {
      // TC-DISC-CON-SEL-003
      notifier.toggleSelectContact(10);
      expect(container.read(contactListProvider).selectedContactIds, contains(10));
    });

    test('toggleSelectContact should remove when already selected', () {
      notifier.toggleSelectContact(10);
      notifier.toggleSelectContact(10);
      expect(container.read(contactListProvider).selectedContactIds, isNot(contains(10)));
    });

    test('clearMultiSelection should reset all selection state', () {
      // TC-DISC-CON-SEL-004
      notifier.onLongPress(1);
      notifier.onLongPress(2);
      notifier.setShowCheckboxes(true);

      notifier.clearMultiSelection();

      final state = container.read(contactListProvider);
      expect(state.selectedContactIds, isEmpty);
      expect(state.longPressFlag, isTrue);
      expect(state.allContactsFlag, isFalse);
      expect(state.showCheckboxes, isFalse);
      expect(state.lastClickedIndex, -1);
    });

    test('setShowCheckboxes should update state', () {
      // TC-DISC-CON-SEL-005
      notifier.setShowCheckboxes(true);
      expect(container.read(contactListProvider).showCheckboxes, isTrue);
    });

    test('setSelectedFromList should set contact ids', () {
      // TC-DISC-CON-SEL-006
      notifier.setSelectedFromList([1, 3, 5]);
      final state = container.read(contactListProvider);
      expect(state.selectedContactIds, [1, 3, 5]);
      expect(state.longPressFlag, isFalse);
    });

    test('setSelectedFromList with empty list should set longPressFlag true', () {
      notifier.setSelectedFromList([1]);
      notifier.setSelectedFromList([]);
      expect(container.read(contactListProvider).longPressFlag, isTrue);
    });
  });

  group('ContactListNotifier filter methods', () {
    test('toggleFilter should flip showFilter', () {
      // TC-DISC-CON-SEL-007
      notifier.toggleFilter();
      expect(container.read(contactListProvider).showFilter, isTrue);

      notifier.toggleFilter();
      expect(container.read(contactListProvider).showFilter, isFalse);
    });

    test('setShowFilter should set value directly', () {
      notifier.setShowFilter(true);
      expect(container.read(contactListProvider).showFilter, isTrue);

      notifier.setShowFilter(false);
      expect(container.read(contactListProvider).showFilter, isFalse);
    });

    test('setContactTypeFilter should set filter type', () {
      // TC-DISC-CON-SEL-008
      notifier.setContactTypeFilter('optmsg');
      final state = container.read(contactListProvider);
      expect(state.contactTypeFilter, 'optmsg');
      expect(state.showFilter, isFalse); // closes filter overlay
    });

    test('clearContactTypeFilter should reset filter', () {
      // TC-DISC-CON-SEL-009
      notifier.setContactTypeFilter('optmsg');
      notifier.clearContactTypeFilter();
      expect(container.read(contactListProvider).contactTypeFilter, 'all');
    });
  });

  group('ContactListNotifier reading pane', () {
    test('enableReadingPaneForNativeTabletLandscape should set flag', () {
      // TC-DISC-CON-SEL-010
      notifier.enableReadingPaneForNativeTabletLandscape(true);
      expect(container.read(contactListProvider).readingPaneEnabled, isTrue);
    });

    test('clearSelectionContact should clear selectedContact', () {
      // TC-DISC-CON-SEL-011
      notifier.clearSelectionContact();
      expect(container.read(contactListProvider).selectedContact, isNull);
    });
  });

  group('ContactListNotifier contact operations', () {
    test('deleteContactRecord should not crash on empty list', () {
      // TC-DISC-CON-SEL-012
      notifier.deleteContactRecord(999);
      // Should not throw
    });

    test('setLoading should update state', () {
      notifier.setLoading(true);
      expect(container.read(contactListProvider).isLoading, isTrue);
    });
  });

  group('ContactState computed properties', () {
    test('hasContacts should be false for empty list', () {
      // TC-DISC-CON-SEL-013
      expect(container.read(contactListProvider).hasContacts, isFalse);
    });

    test('selectedContactIds should be empty when nothing selected', () {
      expect(container.read(contactListProvider).selectedContactIds, isEmpty);
    });

    test('selectedContactIds should have items after toggleSelectContact', () {
      notifier.onLongPress(1); // enter multi-select
      notifier.toggleSelectContact(2); // add second
      expect(container.read(contactListProvider).selectedContactIds, isNotEmpty);
    });

    test('selectedCount should return correct count', () {
      notifier.onLongPress(1); // enter multi-select with 1
      notifier.toggleSelectContact(2); // add 2
      expect(container.read(contactListProvider).selectedCount, 2);
    });
  });
}
