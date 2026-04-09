// Implements: TC-DISC-EDIT-CON-001..012
// Source: lib/screens/contacts/edit_contact_riverpod/edit_contact_notifier.dart
//         lib/screens/contacts/view_contact_riverpod/view_contact_notifier.dart
// Coverage target: Push from 0% toward 40%+
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:optmsg/model/contact_email_details.dart';
import 'package:optmsg/model/contact_list_model.dart';
import 'package:optmsg/screens/auth/auth_riverpod/auth_notifier.dart';
import 'package:optmsg/screens/contacts/edit_contact_riverpod/edit_contact_notifier.dart';
import 'package:optmsg/screens/contacts/view_contact_riverpod/view_contact_notifier.dart';

import '../../helpers/riverpod_test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // =========================================================================
  // EditContactNotifier
  // =========================================================================
  group('EditContactNotifier', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() => container.dispose());

    test('should have correct initial state', () {
      // TC-DISC-EDIT-CON-001
      final state = container.read(editContactProvider);
      expect(state.isLoading, isFalse);
    });

    test('should start with zero controllers (build adds none)', () {
      // TC-DISC-EDIT-CON-002
      final notifier = container.read(editContactProvider.notifier);
      expect(notifier.emailControllers, isEmpty);
    });

    test('init should populate controllers from contacts', () {
      // TC-DISC-EDIT-CON-003
      final notifier = container.read(editContactProvider.notifier);
      notifier.init([
        Contact(id: 1, email: 'a@b.com'),
        Contact(id: 2, email: 'c@d.com'),
      ]);

      expect(notifier.emailControllers, hasLength(2));
      expect(notifier.emailControllers[0].text, 'a@b.com');
      expect(notifier.emailControllers[1].text, 'c@d.com');
      expect(container.read(editContactProvider).emailFieldCount, 2);
    });

    test('updateEmailControllers add should increase count', () {
      // TC-DISC-EDIT-CON-004
      final notifier = container.read(editContactProvider.notifier);
      notifier.init([Contact(id: 1, email: 'a@b.com')]);

      notifier.updateEmailControllers('add', 0);

      expect(notifier.emailControllers, hasLength(2));
      expect(container.read(editContactProvider).emailFieldCount, 2);
    });

    test('updateEmailControllers remove should decrease count', () {
      // TC-DISC-EDIT-CON-005
      final notifier = container.read(editContactProvider.notifier);
      notifier.init([
        Contact(id: 1, email: 'a@b.com'),
        Contact(id: 2, email: 'c@d.com'),
      ]);

      notifier.updateEmailControllers('remove', 0);

      expect(notifier.emailControllers, hasLength(1));
    });

    test('updateEmailControllers remove should not go below 1', () {
      final notifier = container.read(editContactProvider.notifier);
      notifier.init([Contact(id: 1, email: 'a@b.com')]);

      notifier.updateEmailControllers('remove', 0); // should be no-op

      expect(notifier.emailControllers, hasLength(1));
    });

    test('reset should clear all controllers and state', () {
      // TC-DISC-EDIT-CON-006
      final notifier = container.read(editContactProvider.notifier);
      notifier.init([
        Contact(id: 1, email: 'a@b.com'),
        Contact(id: 2, email: 'c@d.com'),
      ]);

      notifier.reset();

      expect(notifier.emailControllers, isEmpty);
    });

    test('emailControllers should be unmodifiable', () {
      // TC-DISC-EDIT-CON-007
      final notifier = container.read(editContactProvider.notifier);
      expect(
        () => notifier.emailControllers.add(TextEditingController()),
        throwsUnsupportedError,
      );
    });
  });

  // =========================================================================
  // ViewContactNotifier
  // =========================================================================
  group('ViewContactNotifier', () {
    late ProviderContainer container;
    late RiverpodTestSetup setup;

    setUp(() async {
      setup = RiverpodTestSetup();
      when(() => setup.mockStorageService.readObjectData(any()))
          .thenAnswer((_) async => null);
      when(() => setup.mockStorageService.readData(any()))
          .thenAnswer((_) async => null);

      container = ProviderContainer(overrides: setup.serviceOverrides);
      container.read(authProvider);
      await Future.delayed(Duration.zero);
    });

    tearDown(() => container.dispose());

    test('should have correct initial state', () {
      // TC-DISC-EDIT-CON-008
      final state = container.read(viewContactProvider);
      expect(state.emails, isEmpty);
      expect(state.isSubmitting, isFalse);
      expect(state.loadingContactDetails, isFalse);
      expect(state.contact, isNull);
    });

    test('updateContact should set contact in state', () {
      // TC-DISC-EDIT-CON-009
      final contact = Contacts(
        id: 42,
        firstName: 'John',
        lastName: 'Doe',
        company: '',
        emails: [],
      );

      container.read(viewContactProvider.notifier).updateContact(contact);

      expect(container.read(viewContactProvider).contact, isNotNull);
      expect(container.read(viewContactProvider).contact!.id, 42);
    });

    test('build should reset state on rebuild', () {
      // TC-DISC-EDIT-CON-010
      final contact = Contacts(
        id: 1, firstName: 'A', lastName: 'B', company: '', emails: [],
      );
      container.read(viewContactProvider.notifier).updateContact(contact);

      container.invalidate(viewContactProvider);
      final state = container.read(viewContactProvider);

      expect(state.contact, isNull);
      expect(state.emails, isEmpty);
    });
  });
}
