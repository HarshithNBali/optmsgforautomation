// Implements: TC-DISC-ADDCON-001..008
// Source: lib/screens/contacts/add_contact_riverpod/add_contact_notifier.dart
// Coverage target: Push from 25.3% toward 50%+
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:optmsg/screens/contacts/add_contact_riverpod/add_contact_notifier.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer();
  });

  tearDown(() => container.dispose());

  group('AddContactNotifier', () {
    test('should have correct initial state', () {
      // TC-DISC-ADDCON-001
      final state = container.read(addContactProvider);
      expect(state.emailFieldCount, 1);
      expect(state.isLoading, isFalse);
    });

    test('should start with one email controller', () {
      // TC-DISC-ADDCON-002
      final notifier = container.read(addContactProvider.notifier);
      expect(notifier.emailControllers, hasLength(1));
    });

    test('updateEmailControllers add should increase count', () {
      // TC-DISC-ADDCON-003
      final notifier = container.read(addContactProvider.notifier);
      notifier.updateEmailControllers('add', 0);

      expect(notifier.emailControllers, hasLength(2));
      expect(container.read(addContactProvider).emailFieldCount, 2);
    });

    test('updateEmailControllers add multiple should increase count', () {
      final notifier = container.read(addContactProvider.notifier);
      notifier.updateEmailControllers('add', 0);
      notifier.updateEmailControllers('add', 0);

      expect(notifier.emailControllers, hasLength(3));
      expect(container.read(addContactProvider).emailFieldCount, 3);
    });

    test('updateEmailControllers remove should decrease count', () {
      // TC-DISC-ADDCON-004
      final notifier = container.read(addContactProvider.notifier);
      notifier.updateEmailControllers('add', 0); // now 2
      notifier.updateEmailControllers('remove', 0); // back to 1

      expect(notifier.emailControllers, hasLength(1));
      expect(container.read(addContactProvider).emailFieldCount, 1);
    });

    test('updateEmailControllers remove should not go below 1', () {
      // TC-DISC-ADDCON-005
      final notifier = container.read(addContactProvider.notifier);
      notifier.updateEmailControllers('remove', 0); // should be no-op

      expect(notifier.emailControllers, hasLength(1));
    });

    test('reset should restore to single empty controller', () {
      // TC-DISC-ADDCON-006
      final notifier = container.read(addContactProvider.notifier);
      notifier.updateEmailControllers('add', 0);
      notifier.updateEmailControllers('add', 0);

      notifier.reset();

      expect(notifier.emailControllers, hasLength(1));
      expect(container.read(addContactProvider).emailFieldCount, 1);
    });

    test('emailControllers should be unmodifiable', () {
      // TC-DISC-ADDCON-007
      final notifier = container.read(addContactProvider.notifier);
      final controllers = notifier.emailControllers;

      expect(() => controllers.add(TextEditingController()),
          throwsUnsupportedError);
    });

    test('controllers should be TextEditingController instances', () {
      // TC-DISC-ADDCON-008
      final notifier = container.read(addContactProvider.notifier);
      expect(notifier.emailControllers.first, isA<TextEditingController>());
    });
  });
}
