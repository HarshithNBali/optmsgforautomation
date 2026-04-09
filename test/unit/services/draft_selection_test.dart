// Implements: TC-DISC-DRAFT-SEL-001..018
// Source: lib/screens/email/draft_riverpod/draft_notifier.dart (selection + UI state)
// Coverage target: Push from 47.2% toward 60%+
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:optmsg/screens/auth/auth_riverpod/auth_notifier.dart';
import 'package:optmsg/screens/email/draft_riverpod/draft_notifier.dart';

import '../../helpers/riverpod_test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late RiverpodTestSetup setup;
  late ProviderContainer container;
  late DraftNotifier notifier;

  setUp(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('app_badge_plus'),
      (MethodCall methodCall) async {
        if (methodCall.method == 'isSupported') return false;
        return null;
      },
    );
    setup = RiverpodTestSetup();
    when(() => setup.mockStorageService.readObjectData(any()))
        .thenAnswer((_) async => null);
    when(() => setup.mockStorageService.readData(any()))
        .thenAnswer((_) async => null);
    when(() => setup.mockStorageService.deleteData(any()))
        .thenAnswer((_) async {});

    container = ProviderContainer(overrides: setup.serviceOverrides);
    container.read(authProvider);
    await Future.delayed(Duration.zero);

    await runZonedGuarded(() async {
      notifier = container.read(draftProvider.notifier);
      await Future.delayed(const Duration(milliseconds: 50));
    }, (e, _) {});
  });

  tearDown(() => container.dispose());

  group('DraftNotifier selection', () {
    test('toggleSelect should add id and email', () {
      // TC-DISC-DRAFT-SEL-001
      notifier.toggleSelect(1, 'a@b.com');
      final state = container.read(draftProvider);
      expect(state.selectedEmailIds, contains(1));
      expect(state.selectedEmails, contains('a@b.com'));
    });

    test('toggleSelect should remove when already selected', () {
      // TC-DISC-DRAFT-SEL-002
      notifier.toggleSelect(1, 'a@b.com');
      notifier.toggleSelect(1, 'a@b.com');
      expect(container.read(draftProvider).selectedEmailIds, isNot(contains(1)));
    });

    test('toggleSelectFromList should add and set longPressFlag false', () {
      // TC-DISC-DRAFT-SEL-003
      notifier.toggleSelectFromList(1, 'a@b.com');
      final state = container.read(draftProvider);
      expect(state.selectedEmailIds, contains(1));
      expect(state.longPressFlag, isFalse);
    });

    test('toggleSelectFromList should set longPressFlag true when empty', () {
      // TC-DISC-DRAFT-SEL-004
      notifier.toggleSelectFromList(1, 'a@b.com');
      notifier.toggleSelectFromList(1, 'a@b.com');
      expect(container.read(draftProvider).longPressFlag, isTrue);
    });

    test('clearSelection should reset all selection state', () {
      // TC-DISC-DRAFT-SEL-005
      notifier.toggleSelect(1, 'a@b.com');
      notifier.toggleSelect(2, 'b@c.com');
      notifier.setCheckboxVisibility(true);

      notifier.clearSelection();

      final state = container.read(draftProvider);
      expect(state.selectedEmailIds, isEmpty);
      expect(state.selectedEmails, isEmpty);
      expect(state.longPressFlag, isTrue);
      expect(state.allEmailIdsFlag, isFalse);
      expect(state.showCheckboxes, isFalse);
      expect(state.lastClickedIndex, -1);
    });

    test('setSelectedFromList should set ids and emails', () {
      // TC-DISC-DRAFT-SEL-006
      notifier.setSelectedFromList([1, 2], ['a@b.com', 'b@c.com']);
      final state = container.read(draftProvider);
      expect(state.selectedEmailIds, [1, 2]);
      expect(state.selectedEmails, ['a@b.com', 'b@c.com']);
    });

    test('setSelectedFromList empty should set longPressFlag true', () {
      notifier.setSelectedFromList([1], ['a@b.com']);
      notifier.setSelectedFromList([], []);
      expect(container.read(draftProvider).longPressFlag, isTrue);
    });
  });

  group('DraftNotifier UI state', () {
    test('toggleSearch should flip isSearch', () {
      // TC-DISC-DRAFT-SEL-007
      notifier.toggleSearch();
      expect(container.read(draftProvider).isSearch, isTrue);

      notifier.toggleSearch();
      expect(container.read(draftProvider).isSearch, isFalse);
    });

    test('clearOverlayStates should not crash', () {
      // TC-DISC-DRAFT-SEL-008
      notifier.clearOverlayStates();
      // Should complete without error
    });

    test('setCheckboxVisibility should update state', () {
      // TC-DISC-DRAFT-SEL-009
      notifier.setCheckboxVisibility(true);
      expect(container.read(draftProvider).showCheckboxes, isTrue);
    });

    test('setComposeHovered should update state', () {
      // TC-DISC-DRAFT-SEL-010
      notifier.setComposeHovered(true);
      expect(container.read(draftProvider).isComposeHovered, isTrue);
    });

    test('setEmailListPaneWidth should update width', () {
      // TC-DISC-DRAFT-SEL-011
      notifier.setEmailListPaneWidth(300.0);
      expect(container.read(draftProvider).emailListPaneWidth, 300.0);
    });

    test('updateReadingPaneSettings should update flag', () {
      // TC-DISC-DRAFT-SEL-012
      notifier.updateReadingPaneSettings(false);
      expect(container.read(draftProvider).readingPaneEnabled, isFalse);

      notifier.updateReadingPaneSettings(true);
      expect(container.read(draftProvider).readingPaneEnabled, isTrue);
    });

    test('setSelectedEmailIdForReadingPane should set id', () {
      // TC-DISC-DRAFT-SEL-013
      notifier.setSelectedEmailIdForReadingPane(42);
      expect(container.read(draftProvider).selectedEmailIdForReadingPane, 42);
    });

    test('setSelectedEmailIdForReadingPane null should clear', () {
      notifier.setSelectedEmailIdForReadingPane(42);
      notifier.setSelectedEmailIdForReadingPane(null);
      expect(container.read(draftProvider).selectedEmailIdForReadingPane, isNull);
    });

    test('setCurrentlyViewed should set id and index', () {
      // TC-DISC-DRAFT-SEL-014
      notifier.setCurrentlyViewed(100, 5);
      final state = container.read(draftProvider);
      expect(state.currentlyViewedEmailId, 100);
      expect(state.selectedEmailIndex, 5);
    });
  });

  group('DraftNotifier reset', () {
    test('reset should restore initial state', () {
      // TC-DISC-DRAFT-SEL-015
      notifier.toggleSelect(1, 'a@b.com');
      notifier.setComposeHovered(true);
      notifier.setCheckboxVisibility(true);

      notifier.reset();

      final state = container.read(draftProvider);
      expect(state.selectedEmailIds, isEmpty);
      expect(state.isLoading, isFalse);
      expect(state.showCheckboxes, isFalse);
    });
  });

  group('DraftNotifier updateNotificationFlag', () {
    test('should update newNotification flag', () {
      // TC-DISC-DRAFT-SEL-016
      notifier.updateNotificationFlag(true);
      expect(container.read(draftProvider).newNotification, isTrue);

      notifier.updateNotificationFlag(false);
      expect(container.read(draftProvider).newNotification, isFalse);
    });
  });

  group('DraftState', () {
    test('should have correct defaults', () {
      // TC-DISC-DRAFT-SEL-017
      final state = container.read(draftProvider);
      expect(state.items, isEmpty);
      expect(state.isLoading, isA<bool>());
      expect(state.selectedEmailIds, isEmpty);
      expect(state.longPressFlag, isTrue);
    });
  });
}
