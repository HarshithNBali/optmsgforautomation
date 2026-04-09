// Implements: TC-DISC-ARCH-BULK-001..020
// Source: lib/screens/email/archive_riverpod/archive_list_notifier.dart
// Coverage target: Push archive notifier from 36% toward 50%+
import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:optmsg/screens/auth/auth_riverpod/auth_notifier.dart';
import 'package:optmsg/screens/email/archive_riverpod/archive_list_notifier.dart';

import '../../helpers/riverpod_test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late RiverpodTestSetup setup;
  late ProviderContainer container;
  late ArchiveNotifier notifier;

  setUp(() async {
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
      notifier = container.read(archiveProvider.notifier);
      await Future.delayed(const Duration(milliseconds: 50));
    }, (e, _) {});
  });

  tearDown(() => container.dispose());

  group('ArchiveNotifier selection', () {
    test('onLongPress should add to selectedEmailIds', () {
      // TC-DISC-ARCH-BULK-001
      notifier.onLongPress(42, 'test@email.com');
      final state = container.read(archiveProvider);
      expect(state.selectedEmailIds, contains(42));
      expect(state.selectedEmails, contains('test@email.com'));
    });

    test('onLongPress should toggle off when already selected', () {
      // TC-DISC-ARCH-BULK-002
      notifier.onLongPress(42, 'test@email.com');
      notifier.onLongPress(42, 'test@email.com');
      final state = container.read(archiveProvider);
      expect(state.selectedEmailIds, isNot(contains(42)));
    });

    test('onLongPress with null id should no-op', () {
      notifier.onLongPress(null, null);
      expect(container.read(archiveProvider).selectedEmailIds, isEmpty);
    });

    test('addAndRemoveKey should add id and email', () {
      // TC-DISC-ARCH-BULK-003
      notifier.addAndRemoveKey(1, 'a@b.com');
      final state = container.read(archiveProvider);
      expect(state.selectedEmailIds, contains(1));
      expect(state.selectedEmails, contains('a@b.com'));
    });

    test('addAndRemoveKey should remove when already present', () {
      // TC-DISC-ARCH-BULK-004
      notifier.addAndRemoveKey(1, 'a@b.com');
      notifier.addAndRemoveKey(1, 'a@b.com');
      final state = container.read(archiveProvider);
      expect(state.selectedEmailIds, isNot(contains(1)));
    });

    test('clearSelection should reset all selection state', () {
      // TC-DISC-ARCH-BULK-005
      notifier.addAndRemoveKey(1, 'a@b.com');
      notifier.addAndRemoveKey(2, 'b@c.com');
      notifier.setShowCheckboxes(true);

      notifier.clearSelection();

      final state = container.read(archiveProvider);
      expect(state.selectedEmailIds, isEmpty);
      expect(state.selectedEmails, isEmpty);
      expect(state.longPressFlag, isTrue);
      expect(state.allEmailIdsFlag, isFalse);
      expect(state.showCheckboxes, isFalse);
    });

    test('setShowCheckboxes should update state', () {
      notifier.setShowCheckboxes(true);
      expect(container.read(archiveProvider).showCheckboxes, isTrue);
    });
  });

  group('ArchiveNotifier overlay state', () {
    test('tagsOnclick should not crash when no tags loaded', () {
      // TC-DISC-ARCH-BULK-006
      // tagsOnclick checks if tags are loaded before showing tag list
      notifier.tagsOnclick();
      // When no tags loaded, shows toast instead — showTagList stays false
      final state = container.read(archiveProvider);
      expect(state.showTagList, isFalse);
    });

    test('clearOverlayStates should close all overlays', () {
      // TC-DISC-ARCH-BULK-007
      notifier.tagsOnclick();
      notifier.handleMoveAction(); // sets showMoveOverlay: true
      notifier.clearOverlayStates();

      final state = container.read(archiveProvider);
      expect(state.showTagList, isFalse);
      expect(state.showMenuOptions, isFalse);
      expect(state.showFilter, isFalse);
      expect(state.showMoveOverlay, isFalse);
      expect(state.showReadingPaneMenuOptions, isFalse);
    });

    test('closeMenuOptions should close menu', () {
      notifier.closeMenuOptions();
      expect(container.read(archiveProvider).showMenuOptions, isFalse);
    });

    test('closeFilter should close filter', () {
      notifier.closeFilter();
      expect(container.read(archiveProvider).showFilter, isFalse);
    });

    test('closeTagList should close tag list', () {
      notifier.tagsOnclick();
      notifier.closeTagList();
      expect(container.read(archiveProvider).showTagList, isFalse);
    });
  });

  group('ArchiveNotifier reading pane', () {
    test('setEmailListPaneWidth should update width', () {
      // TC-DISC-ARCH-BULK-008
      notifier.setEmailListPaneWidth(350.0);
      expect(container.read(archiveProvider).emailListPaneWidth, 350.0);
    });

    test('updateReadingPaneSettings should update enabled flag', () {
      // TC-DISC-ARCH-BULK-009
      notifier.updateReadingPaneSettings(true);
      expect(container.read(archiveProvider).readingPaneEnabled, isTrue);

      notifier.updateReadingPaneSettings(false);
      expect(container.read(archiveProvider).readingPaneEnabled, isFalse);
    });

    test('openReadingPaneMenu should set flag', () {
      notifier.openReadingPaneMenu();
      expect(container.read(archiveProvider).showReadingPaneMenuOptions, isTrue);
    });

    test('closeReadingPaneMenu should clear flag', () {
      notifier.openReadingPaneMenu();
      notifier.closeReadingPaneMenu();
      expect(container.read(archiveProvider).showReadingPaneMenuOptions, isFalse);
    });

    test('clearReadingPaneSelection should reset reading pane state', () {
      notifier.clearReadingPaneSelection();
      final state = container.read(archiveProvider);
      expect(state.selectedEmailIdForReadingPane, isNull);
    });
  });

  group('ArchiveNotifier search and filter', () {
    test('toggleSearch should flip search state', () {
      // TC-DISC-ARCH-BULK-010
      notifier.toggleSearch();
      expect(container.read(archiveProvider).isSearch, isTrue);

      notifier.toggleSearch();
      expect(container.read(archiveProvider).isSearch, isFalse);
    });

    test('toggleFilter should flip filter state', () {
      notifier.toggleFilter();
      expect(container.read(archiveProvider).showFilter, isTrue);
    });

    test('toggleMenuOptions should flip menu state', () {
      notifier.toggleMenuOptions();
      expect(container.read(archiveProvider).showMenuOptions, isTrue);
    });

    test('applyTagFilter should set tag filter', () {
      // TC-DISC-ARCH-BULK-011
      notifier.applyTagFilter(1);
      expect(container.read(archiveProvider).tagFilter, isTrue);
    });

    test('clearTagFilter should clear filter', () {
      notifier.applyTagFilter(1);
      notifier.clearTagFilter();
      expect(container.read(archiveProvider).tagFilter, isFalse);
    });
  });

  group('ArchiveNotifier bulk action handlers', () {
    test('handleMoveAction should set showMoveOverlay', () {
      // TC-DISC-ARCH-BULK-012
      notifier.handleMoveAction();
      expect(container.read(archiveProvider).showMoveOverlay, isTrue);
    });

    test('dismissMoveOverlay should clear showMoveOverlay', () {
      // TC-DISC-ARCH-BULK-013
      notifier.handleMoveAction();
      notifier.dismissMoveOverlay();
      expect(container.read(archiveProvider).showMoveOverlay, isFalse);
    });

    test('markEmailAsUnreadById should not crash on empty list', () {
      // TC-DISC-ARCH-BULK-014
      notifier.markEmailAsUnreadById(999);
    });

    test('removeEmailFromListById should not crash on empty list', () {
      notifier.removeEmailFromListById(999);
    });

    test('reset should restore initial state', () {
      // TC-DISC-ARCH-BULK-015
      notifier.setShowCheckboxes(true);
      notifier.addAndRemoveKey(1, 'a@b.com');
      notifier.tagsOnclick();

      notifier.reset();

      final state = container.read(archiveProvider);
      expect(state.selectedEmailIds, isEmpty);
      expect(state.showTagList, isFalse);
    });
  });

  group('ArchiveState computed properties', () {
    test('hasEmails should be false for empty list', () {
      expect(container.read(archiveProvider).hasEmails, isFalse);
    });

    test('hasSelection should be false when nothing selected', () {
      expect(container.read(archiveProvider).hasSelection, isFalse);
    });

    test('hasSelection should be true after selection', () {
      notifier.addAndRemoveKey(1, 'a@b.com');
      expect(container.read(archiveProvider).hasSelection, isTrue);
    });

    test('selectedCount should return correct count', () {
      notifier.addAndRemoveKey(1, 'a@b.com');
      notifier.addAndRemoveKey(2, 'b@c.com');
      expect(container.read(archiveProvider).selectedCount, 2);
    });
  });
}
