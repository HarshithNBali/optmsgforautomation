// Implements: TC-DISC-INBOX-EXT-001..015
// Source: lib/screens/email/inbox_riverpod/inbox_notifier.dart
// Coverage target: Push from 43.5% toward 50%+ via API method tests
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:optmsg/model/base_response/request_response.dart';
import 'package:optmsg/model/inbox_list_model.dart';
import 'package:optmsg/screens/auth/auth_riverpod/auth_notifier.dart';
import 'package:optmsg/screens/email/inbox_riverpod/inbox_notifier.dart';

import '../../helpers/riverpod_test_helpers.dart';
import '../../factories/test_data_factories.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late RiverpodTestSetup setup;
  late ProviderContainer container;
  late InboxNotifier notifier;

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
    when(() => setup.mockStorageService.writeData(any(), any()))
        .thenAnswer((_) async {});
    when(() => setup.mockStorageService.deleteData(any()))
        .thenAnswer((_) async {});

    // Stub inbox API to return empty list
    when(() => setup.mockInboxApi.getInboxEmails(any()))
        .thenAnswer((_) async => RequestResponse(
              data: InboxListModel.fromJson(makeInboxListJson(emails: [])),
            ));
    when(() => setup.mockInboxApi.updateEmailStatus(any()))
        .thenAnswer((_) async => RequestResponse(data: {'success': true}));

    container = ProviderContainer(overrides: setup.serviceOverrides);
    container.read(authProvider);
    await Future.delayed(Duration.zero);

    await runZonedGuarded(() async {
      notifier = container.read(inboxProvider.notifier);
      await Future.delayed(const Duration(milliseconds: 200));
    }, (e, _) {});
  });

  tearDown(() => container.dispose());

  group('InboxNotifier extended selection tests', () {
    test('toggleSelectFromList should add email to selection', () {
      // TC-DISC-INBOX-EXT-001
      notifier.toggleSelectFromList(42, 'test@test.com');
      final state = container.read(inboxProvider);
      expect(state.selectedEmailIds, contains(42));
    });

    test('toggleSelectFromList should remove when already selected', () {
      // TC-DISC-INBOX-EXT-002
      notifier.toggleSelectFromList(42, 'test@test.com');
      notifier.toggleSelectFromList(42, 'test@test.com');
      expect(container.read(inboxProvider).selectedEmailIds, isNot(contains(42)));
    });

    test('selectAllFromList should select all items', () {
      // TC-DISC-INBOX-EXT-003
      notifier.selectAllFromList();
      final state = container.read(inboxProvider);
      expect(state.allEmailIdsFlag, isTrue);
    });

    test('clearSelection should reset selection state', () {
      // TC-DISC-INBOX-EXT-004
      notifier.toggleSelectFromList(1, 'a@b.com');
      notifier.clearSelection();
      final state = container.read(inboxProvider);
      expect(state.selectedEmailIds, isEmpty);
      expect(state.longPressFlag, isTrue);
      expect(state.showCheckboxes, isFalse);
    });

    test('setSelectedFromList should set specific ids', () {
      notifier.setSelectedFromList([1, 2, 3], ['a@b.com', 'c@d.com', 'e@f.com']);
      expect(container.read(inboxProvider).selectedEmailIds, [1, 2, 3]);
    });
  });

  group('InboxNotifier overlay state', () {
    test('toggleSearch should flip isSearch', () {
      // TC-DISC-INBOX-EXT-005
      notifier.toggleSearch();
      expect(container.read(inboxProvider).isSearch, isTrue);
      notifier.toggleSearch();
      expect(container.read(inboxProvider).isSearch, isFalse);
    });

    test('toggleFilter should flip showFilter', () {
      notifier.toggleFilter();
      expect(container.read(inboxProvider).showFilter, isTrue);
    });

    test('toggleMenuOptions should flip showMenuOptions', () {
      notifier.toggleMenuOptions();
      expect(container.read(inboxProvider).showMenuOptions, isTrue);
    });

    test('clearOverlayStates should close all overlays', () {
      // TC-DISC-INBOX-EXT-006
      notifier.toggleFilter();
      notifier.handleMoveToFolderAction(); // sets showMoveOverlay: true
      notifier.clearOverlayStates();
      final state = container.read(inboxProvider);
      expect(state.showFilter, isFalse);
      expect(state.showMenuOptions, isFalse);
      expect(state.showTagList, isFalse);
      expect(state.showMoveOverlay, isFalse);
      expect(state.showReadingPaneMenuOptions, isFalse);
    });

    test('setShowCheckboxes should update state', () {
      notifier.setShowCheckboxes(true);
      expect(container.read(inboxProvider).showCheckboxes, isTrue);
    });

    test('setComposeHovered should update state', () {
      notifier.setComposeHovered(true);
      expect(container.read(inboxProvider).isComposeHovered, isTrue);
    });
  });

  group('InboxNotifier reading pane', () {
    test('setEmailListPaneWidth should update width', () {
      // TC-DISC-INBOX-EXT-007
      notifier.setEmailListPaneWidth(400.0);
      expect(container.read(inboxProvider).emailListPaneWidth, 400.0);
    });

    test('updateReadingPaneSettings should toggle', () {
      notifier.updateReadingPaneSettings(false);
      expect(container.read(inboxProvider).readingPaneEnabled, isFalse);
      notifier.updateReadingPaneSettings(true);
      expect(container.read(inboxProvider).readingPaneEnabled, isTrue);
    });

    test('clearReadingPaneSelection should reset', () {
      // TC-DISC-INBOX-EXT-008
      notifier.clearReadingPaneSelection();
      expect(container.read(inboxProvider).selectedEmailIdForReadingPane, isNull);
    });

    test('closeReadingPaneMenu should clear menu state', () {
      notifier.closeReadingPaneMenu();
      expect(container.read(inboxProvider).showReadingPaneMenuOptions, isFalse);
    });
  });

  group('InboxNotifier filter', () {
    test('applyTagFilter should set tag filter', () {
      // TC-DISC-INBOX-EXT-009
      notifier.applyTagFilter(5);
      final state = container.read(inboxProvider);
      expect(state.tagFilter, isTrue);
      expect(state.tagIdFilter, contains(5));
    });

    test('clearTagFilterAndRefresh should clear tag filter', () {
      // TC-DISC-INBOX-EXT-010
      notifier.applyTagFilter(5);
      notifier.clearTagFilterAndRefresh('');
      expect(container.read(inboxProvider).tagFilter, isFalse);
    });
  });

  group('InboxNotifier reset', () {
    test('reset should restore initial state', () {
      // TC-DISC-INBOX-EXT-011
      notifier.toggleSelectFromList(1, 'a@b.com');
      notifier.setComposeHovered(true);
      notifier.setShowCheckboxes(true);

      notifier.reset();

      final state = container.read(inboxProvider);
      expect(state.selectedEmailIds, isEmpty);
      expect(state.isComposeHovered, isFalse);
      expect(state.showCheckboxes, isFalse);
    });
  });

  group('InboxNotifier resetFiltersAndSelections', () {
    test('should clear selections', () {
      // TC-DISC-INBOX-EXT-012
      notifier.toggleSelectFromList(1, 'a@b.com');

      notifier.resetFiltersAndSelections();

      final state = container.read(inboxProvider);
      expect(state.selectedEmailIds, isEmpty);
    });
  });
}
