import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:optmsg/screens/auth/auth_riverpod/auth_notifier.dart';
import 'package:optmsg/screens/email/draft_riverpod/draft_notifier.dart';

import '../../helpers/riverpod_test_helpers.dart';

void main() {
  late RiverpodTestSetup setup;
  late ProviderContainer container;

  setUp(() {
    setup = RiverpodTestSetup();
    when(() => setup.mockStorageService.readObjectData(any()))
        .thenAnswer((_) async => null);
  });

  tearDown(() => container.dispose());

  ProviderContainer makeContainer() =>
      ProviderContainer(overrides: setup.serviceOverrides);

  group('DraftNotifier build()', () {
    test('should return default DraftState', () async {
      container = makeContainer();
      container.read(authProvider);
      await Future.delayed(Duration.zero);

      final state = container.read(draftProvider);
      expect(state.isLoading, false);
      expect(state.items, isEmpty);
      expect(state.currentPage, 1);
      expect(state.emailType, 'draft');
    });
  });

  group('DraftNotifier selection methods', () {
    late DraftNotifier notifier;

    setUp(() async {
      container = makeContainer();
      container.read(authProvider);
      await Future.delayed(Duration.zero);
      notifier = container.read(draftProvider.notifier);
    });

    test('toggleSelect should add item to selection', () {
      notifier.toggleSelect(1, 'a@b.com');
      final state = container.read(draftProvider);
      expect(state.selectedEmailIds, [1]);
      expect(state.selectedEmails, ['a@b.com']);
      expect(state.longPressFlag, false);
    });

    test('toggleSelect should remove item from selection', () {
      notifier.toggleSelect(1, 'a@b.com');
      notifier.toggleSelect(1, 'a@b.com');
      final state = container.read(draftProvider);
      expect(state.selectedEmailIds, isEmpty);
      expect(state.selectedEmails, isEmpty);
    });

    test('toggleSelectFromList should toggle and update longPressFlag', () {
      notifier.toggleSelectFromList(1, 'a@b.com');
      expect(container.read(draftProvider).longPressFlag, false);

      notifier.toggleSelectFromList(1, 'a@b.com');
      expect(container.read(draftProvider).longPressFlag, true);
    });

    test('clearSelection should reset all selection state', () {
      notifier.toggleSelect(1, 'a@b.com');
      notifier.toggleSelect(2, 'c@d.com');
      notifier.clearSelection();

      final state = container.read(draftProvider);
      expect(state.selectedEmailIds, isEmpty);
      expect(state.selectedEmails, isEmpty);
      expect(state.longPressFlag, true);
      expect(state.showCheckboxes, false);
    });

    test('setSelectedFromList should set specific selections', () {
      notifier.setSelectedFromList([1, 2], ['a@b.com', 'c@d.com']);
      final state = container.read(draftProvider);
      expect(state.selectedEmailIds, [1, 2]);
      expect(state.selectedEmails, ['a@b.com', 'c@d.com']);
    });
  });

  group('DraftNotifier UI mutators', () {
    late DraftNotifier notifier;

    setUp(() async {
      container = makeContainer();
      container.read(authProvider);
      await Future.delayed(Duration.zero);
      notifier = container.read(draftProvider.notifier);
    });

    test('toggleSearch should flip isSearch', () {
      notifier.toggleSearch();
      expect(container.read(draftProvider).isSearch, true);
      notifier.toggleSearch();
      expect(container.read(draftProvider).isSearch, false);
    });

    test('clearOverlayStates should reset overlays and selection', () {
      notifier.toggleSearch();
      notifier.toggleSelect(1, 'x@y.com');
      notifier.clearOverlayStates();

      final state = container.read(draftProvider);
      expect(state.isSearch, false);
      expect(state.searchKey, '');
      expect(state.showCheckboxes, false);
      expect(state.selectedEmailIds, isEmpty);
    });

    test('setCurrentlyViewed should set reading pane state', () {
      notifier.setCurrentlyViewed(42, 3);
      final state = container.read(draftProvider);
      expect(state.currentlyViewedEmailId, 42);
      expect(state.selectedEmailIdForReadingPane, 42);
      expect(state.selectedEmailIndex, 3);
    });

    test('setCheckboxVisibility should update showCheckboxes', () {
      notifier.setCheckboxVisibility(true);
      expect(container.read(draftProvider).showCheckboxes, true);
    });

    test('setComposeHovered should update isComposeHovered', () {
      notifier.setComposeHovered(true);
      expect(container.read(draftProvider).isComposeHovered, true);
    });

    test('setSelectedEmailIdForReadingPane should update', () {
      notifier.setSelectedEmailIdForReadingPane(99);
      expect(container.read(draftProvider).selectedEmailIdForReadingPane, 99);
    });

    test('setEmailListPaneWidth should update', () {
      notifier.setEmailListPaneWidth(300.0);
      expect(container.read(draftProvider).emailListPaneWidth, 300.0);
    });
  });

}
