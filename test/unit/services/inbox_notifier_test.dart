import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:optmsg/model/inbox_list_model.dart';
import 'package:optmsg/screens/auth/auth_riverpod/auth_notifier.dart';
import 'package:optmsg/screens/email/inbox_riverpod/inbox_notifier.dart';

import '../../helpers/riverpod_test_helpers.dart';
import '../../factories/test_data_factories.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late RiverpodTestSetup setup;
  late ProviderContainer container;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    setup = RiverpodTestSetup();
    when(() => setup.mockStorageService.readObjectData(any()))
        .thenAnswer((_) async => null);
  });

  tearDown(() {
    container.dispose();
  });

  /// Creates a container with auth + inbox providers. Auth settles to
  /// unauthenticated (Descope not initialized in tests).
  ProviderContainer makeContainer() {
    return ProviderContainer(overrides: setup.serviceOverrides);
  }

  group('InboxNotifier build()', () {
    test('should return default InboxState', () async {
      container = makeContainer();
      // Read authProvider first so it settles
      container.read(authProvider);
      await Future.delayed(Duration.zero);

      final state = container.read(inboxProvider);
      expect(state.isLoading, true);
      expect(state.items, isEmpty);
      expect(state.currentPage, 1);
      expect(state.emailType, 'inbox');
      expect(state.selectedEmailIds, isEmpty);
    });
  });

  group('InboxNotifier pure state mutators', () {
    late InboxNotifier notifier;

    setUp(() async {
      container = makeContainer();
      container.read(authProvider);
      await Future.delayed(Duration.zero);
      notifier = container.read(inboxProvider.notifier);
    });

    test('setSearchKey should update searchKey', () {
      notifier.setSearchKey('hello');
      expect(container.read(inboxProvider).searchKey, 'hello');
    });

    test('setIsSearch should update isSearch', () {
      notifier.setIsSearch(true);
      expect(container.read(inboxProvider).isSearch, true);
    });

    test('setShowFilter should update showFilter', () {
      notifier.setShowFilter(true);
      expect(container.read(inboxProvider).showFilter, true);
    });

    test('setShowTagList should update showTagList', () {
      notifier.setShowTagList(true);
      expect(container.read(inboxProvider).showTagList, true);
    });

    test('setLongPressFlag should update longPressFlag', () {
      notifier.setLongPressFlag(false);
      expect(container.read(inboxProvider).longPressFlag, false);
    });

    test('setShowMenuOptions should update showMenuOptions', () {
      notifier.setShowMenuOptions(true);
      expect(container.read(inboxProvider).showMenuOptions, true);
    });

    test('setIsTagListForFilter should update isTagListForFilter', () {
      notifier.setIsTagListForFilter(true);
      expect(container.read(inboxProvider).isTagListForFilter, true);
    });

    test('setShowCheckboxes should update showCheckboxes and longPressFlag', () {
      notifier.setShowCheckboxes(true);
      final state = container.read(inboxProvider);
      expect(state.showCheckboxes, true);
      expect(state.longPressFlag, true);
    });

    test('setComposeHovered should update isComposeHovered', () {
      notifier.setComposeHovered(true);
      expect(container.read(inboxProvider).isComposeHovered, true);
    });

    test('setEmailListPaneWidth should update emailListPaneWidth', () {
      notifier.setEmailListPaneWidth(350.0);
      expect(container.read(inboxProvider).emailListPaneWidth, 350.0);
    });

    test('setReadingPaneHeight should update readingPaneHeight', () {
      notifier.setReadingPaneHeight(600.0);
      expect(container.read(inboxProvider).readingPaneHeight, 600.0);
    });

    test('setReadingPaneEnabled should update readingPaneEnabled', () {
      notifier.setReadingPaneEnabled(false);
      expect(container.read(inboxProvider).readingPaneEnabled, false);
    });

    test('toggleSearch should flip isSearch', () {
      expect(container.read(inboxProvider).isSearch, false);
      notifier.toggleSearch();
      expect(container.read(inboxProvider).isSearch, true);
      notifier.toggleSearch();
      expect(container.read(inboxProvider).isSearch, false);
    });

    test('toggleFilter should flip showFilter and close tagList', () {
      notifier.setShowTagList(true);
      notifier.toggleFilter();
      final state = container.read(inboxProvider);
      expect(state.showFilter, true);
      expect(state.showTagList, false);
    });

    test('toggleMenuOptions should flip showMenuOptions', () {
      notifier.toggleMenuOptions();
      expect(container.read(inboxProvider).showMenuOptions, true);
      notifier.toggleMenuOptions();
      expect(container.read(inboxProvider).showMenuOptions, false);
    });

    test('showTagListFromFilter should show tags and hide filter', () {
      notifier.setShowFilter(true);
      notifier.showTagListFromFilter();
      final state = container.read(inboxProvider);
      expect(state.showFilter, false);
      expect(state.showTagList, true);
      expect(state.isTagListForFilter, true);
    });

    test('clearOverlayStates should reset all overlays and selections', () {
      notifier.setShowFilter(true);
      notifier.setShowTagList(true);
      notifier.setIsSearch(true);
      notifier.setShowMenuOptions(true);
      notifier.handleMoveToFolderAction(); // sets showMoveOverlay: true
      notifier.clearOverlayStates();

      final state = container.read(inboxProvider);
      expect(state.showFilter, false);
      expect(state.showTagList, false);
      expect(state.isSearch, false);
      expect(state.showMenuOptions, false);
      expect(state.showMoveOverlay, false);
      expect(state.showReadingPaneMenuOptions, false);
      expect(state.showCheckboxes, false);
      expect(state.selectedEmailIds, isEmpty);
      expect(state.selectedEmails, isEmpty);
    });

    test('resetFiltersAndSelections should clear everything', () {
      notifier.setSearchKey('test');
      notifier.setIsSearch(true);
      notifier.setShowFilter(true);
      notifier.resetFiltersAndSelections();

      final state = container.read(inboxProvider);
      expect(state.tagIdFilter, isEmpty);
      expect(state.selectedTagIds, isEmpty);
      expect(state.tagFilter, false);
      expect(state.showFilter, false);
      expect(state.showTagList, false);
      expect(state.selectedEmailIds, isEmpty);
      expect(state.selectedEmails, isEmpty);
      expect(state.showCheckboxes, false);
      expect(state.searchKey, '');
      expect(state.isSearch, false);
      expect(state.selectedEmailIdForReadingPane, isNull);
    });

    test('onLongPress with longPressFlag=true should start selection', () {
      // longPressFlag defaults to true
      notifier.onLongPress(42, 'test@example.com');
      final state = container.read(inboxProvider);
      expect(state.longPressFlag, false);
      expect(state.selectedEmailIds, [42]);
      expect(state.selectedEmails, ['test@example.com']);
    });

    test('onLongPress with longPressFlag=false should clear selection', () {
      // First trigger to set longPressFlag=false
      notifier.onLongPress(42, 'test@example.com');
      // Second trigger should reset
      notifier.onLongPress(null, null);
      final state = container.read(inboxProvider);
      expect(state.longPressFlag, true);
      expect(state.selectedEmailIds, isEmpty);
      expect(state.selectedEmails, isEmpty);
    });

    test('updateReadingPaneSettings(false) should clear selection', () {
      notifier.updateReadingPaneSettings(false);
      final state = container.read(inboxProvider);
      expect(state.readingPaneEnabled, false);
      expect(state.readingPaneEnabledWeb, false);
      expect(state.selectedEmailIdForReadingPane, isNull);
      expect(state.currentlyViewedEmailId, isNull);
    });

    test('updateReadingPaneSettings(true) should enable reading pane', () {
      notifier.updateReadingPaneSettings(false);
      notifier.updateReadingPaneSettings(true);
      final state = container.read(inboxProvider);
      expect(state.readingPaneEnabled, true);
      expect(state.readingPaneEnabledWeb, true);
    });

    test('clearSelectionAfterTagAdd should reset selection', () {
      notifier.onLongPress(1, 'a@b.com');
      notifier.clearSelectionAfterTagAdd();
      final state = container.read(inboxProvider);
      expect(state.longPressFlag, true);
      expect(state.selectedEmailIds, isEmpty);
      expect(state.selectedEmails, isEmpty);
    });

    test('closeReadingPaneMenu should hide menu', () {
      notifier.closeReadingPaneMenu();
      expect(
          container.read(inboxProvider).showReadingPaneMenuOptions, false);
    });

    test('clearReadingPaneSelection should clear all reading pane fields', () {
      notifier.clearReadingPaneSelection();
      final state = container.read(inboxProvider);
      expect(state.selectedEmailIdForReadingPane, isNull);
      expect(state.currentlyViewedEmailId, isNull);
      expect(state.selectedEmailSender, isNull);
      expect(state.selectedEmailIndex, isNull);
    });

    test('reset should restore initial state', () {
      notifier.setSearchKey('test');
      notifier.setIsSearch(true);
      notifier.reset();

      final state = container.read(inboxProvider);
      expect(state.isLoading, true);
      expect(state.items, isEmpty);
      expect(state.searchKey, '');
      expect(state.isSearch, false);
      expect(state.currentPage, 1);
    });
  });

  group('InboxNotifier _markEmailAsReadLocally', () {
    late InboxNotifier notifier;

    setUp(() async {
      container = makeContainer();
      container.read(authProvider);
      await Future.delayed(Duration.zero);
      notifier = container.read(inboxProvider.notifier);
    });

    test('setSelectedEmailIdForReadingPane should mark email as read', () {
      // Populate items
      final email1 = Emails.fromJson(makeInboxEmailJson(id: 1, emailId: 100, isRead: false));
      final email2 = Emails.fromJson(makeInboxEmailJson(id: 2, emailId: 200, isRead: false));
      // Manually set items via state copyWith (simulating data load)
      notifier.state = notifier.state.copyWith(items: [email1, email2]);

      // Select email 100 for reading pane
      notifier.setSelectedEmailIdForReadingPane(100);

      final state = container.read(inboxProvider);
      // Email 100 should now be marked as read
      expect(state.items[0].isRead, true);
      // Email 200 should remain unread
      expect(state.items[1].isRead, false);
      // Reading pane should be set
      expect(state.selectedEmailIdForReadingPane, 100);
    });

    test('setCurrentlyViewedEmailId should set sender email', () {
      final email = Emails.fromJson(makeInboxEmailJson(
        id: 1, emailId: 100,
        email: makeEmailJson(senderEmail: 'sender@test.com'),
      ));
      notifier.state = notifier.state.copyWith(items: [email]);

      notifier.setCurrentlyViewedEmailId(100);

      final state = container.read(inboxProvider);
      expect(state.currentlyViewedEmailId, 100);
      expect(state.selectedEmailIdForReadingPane, 100);
      expect(state.selectedEmailSender, 'sender@test.com');
    });
  });

  group('InboxNotifier parseIds', () {
    late InboxNotifier notifier;

    setUp(() async {
      container = makeContainer();
      container.read(authProvider);
      await Future.delayed(Duration.zero);
      notifier = container.read(inboxProvider.notifier);
    });

    test('should return empty list for null', () {
      expect(notifier.parseIds(null), isEmpty);
    });

    test('should parse single int', () {
      expect(notifier.parseIds(42), [42]);
    });

    test('should parse list of ints', () {
      expect(notifier.parseIds([1, 2, 3]), [1, 2, 3]);
    });

    test('should parse string ids', () {
      expect(notifier.parseIds(['1', '2', '3']), [1, 2, 3]);
    });

    test('should skip null values in list', () {
      expect(notifier.parseIds([1, null, 3]), [1, 3]);
    });

    test('should skip invalid strings by default', () {
      expect(notifier.parseIds(['1', 'abc', '3']), [1, 3]);
    });

    test('should throw on invalid strings when throwIfInvalid=true', () {
      expect(
        () => notifier.parseIds(['1', 'abc'], throwIfInvalid: true),
        throwsA(isA<FormatException>()),
      );
    });

    test('should throw on unsupported types when throwIfInvalid=true', () {
      expect(
        () => notifier.parseIds([1.5], throwIfInvalid: true),
        throwsA(isA<FormatException>()),
      );
    });

    test('should wrap single string in list', () {
      expect(notifier.parseIds('42'), [42]);
    });
  });
}
