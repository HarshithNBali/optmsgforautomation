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

    container = ProviderContainer(overrides: setup.serviceOverrides);
    container.read(authProvider);
    await Future.delayed(Duration.zero);

    // ArchiveNotifier.build() fires Future.microtask(init) which cascades
    // into SettingsNotifier → LocalAuthentication (platform channel).
    // We run in a guarded zone to absorb those MissingPluginExceptions.
    await runZonedGuarded(() async {
      notifier = container.read(archiveProvider.notifier);
      // Let the init microtask fire and fail silently
      await Future.delayed(const Duration(milliseconds: 50));
    }, (e, _) {
      // Absorb MissingPluginException from platform channels in microtasks
    });
  });

  tearDown(() => container.dispose());

  group('ArchiveNotifier build()', () {
    test('should return initial state', () {
      final state = container.read(archiveProvider);
      // isLoading may be true or settled depending on how far init got
      expect(state.items, isEmpty);
    });
  });

  group('ArchiveNotifier pure state mutators', () {
    test('toggleSearch should flip isSearch', () {
      notifier.toggleSearch();
      expect(container.read(archiveProvider).isSearch, true);
      notifier.toggleSearch();
      expect(container.read(archiveProvider).isSearch, false);
    });

    test('toggleFilter should flip showFilter and close tagList', () {
      notifier.toggleFilter();
      final state = container.read(archiveProvider);
      expect(state.showFilter, true);
      expect(state.showTagList, false);
    });

    test('toggleMenuOptions should flip', () {
      notifier.toggleMenuOptions();
      expect(container.read(archiveProvider).showMenuOptions, true);
      notifier.toggleMenuOptions();
      expect(container.read(archiveProvider).showMenuOptions, false);
    });

    test('closeMenuOptions', () {
      notifier.toggleMenuOptions();
      notifier.closeMenuOptions();
      expect(container.read(archiveProvider).showMenuOptions, false);
    });

    test('closeFilter', () {
      notifier.toggleFilter();
      notifier.closeFilter();
      expect(container.read(archiveProvider).showFilter, false);
    });

    test('clearOverlayStates should reset overlays', () {
      notifier.toggleSearch();
      notifier.handleMoveAction(); // sets showMoveOverlay: true
      notifier.clearOverlayStates();
      final state = container.read(archiveProvider);
      expect(state.isSearch, false);
      expect(state.searchKey, '');
      expect(state.showCheckboxes, false);
      expect(state.selectedEmailIds, isEmpty);
      expect(state.showMoveOverlay, false);
      expect(state.showReadingPaneMenuOptions, false);
    });

    test('setSelectedEmails', () {
      notifier.setSelectedEmails([1, 2], ['a@b.com', 'c@d.com']);
      final state = container.read(archiveProvider);
      expect(state.selectedEmailIds, [1, 2]);
      expect(state.longPressFlag, false);
    });

    test('setSelectedEmails empty resets longPressFlag', () {
      notifier.setSelectedEmails([1], ['a@b.com']);
      notifier.setSelectedEmails([], []);
      expect(container.read(archiveProvider).longPressFlag, true);
    });

    test('setShowCheckboxes', () {
      notifier.setShowCheckboxes(true);
      expect(container.read(archiveProvider).showCheckboxes, true);
    });

    test('setEmailListPaneWidth', () {
      notifier.setEmailListPaneWidth(350.0);
      expect(container.read(archiveProvider).emailListPaneWidth, 350.0);
    });

    test('updateReadingPane', () {
      notifier.updateReadingPane(id: 42, index: 3, sender: 't@t.com');
      final state = container.read(archiveProvider);
      expect(state.selectedEmailIdForReadingPane, 42);
      expect(state.selectedEmailIndex, 3);
      expect(state.selectedEmailSender, 't@t.com');
    });

    test('clearReadingPaneSelection', () {
      notifier.updateReadingPane(id: 42, index: 3, sender: 's@t.com');
      notifier.clearReadingPaneSelection();
      final state = container.read(archiveProvider);
      expect(state.selectedEmailIdForReadingPane, isNull);
      expect(state.selectedEmailIndex, isNull);
    });

    test('setReadingPaneSelection', () {
      notifier.setReadingPaneSelection(99, 5, 'x@y.com');
      final state = container.read(archiveProvider);
      expect(state.selectedEmailIdForReadingPane, 99);
      expect(state.selectedEmailIndex, 5);
      expect(state.selectedEmailSender, 'x@y.com');
    });

    test('open/closeReadingPaneMenu', () {
      notifier.openReadingPaneMenu();
      expect(container.read(archiveProvider).showReadingPaneMenuOptions, true);
      notifier.closeReadingPaneMenu();
      expect(container.read(archiveProvider).showReadingPaneMenuOptions, false);
    });
  });
}
