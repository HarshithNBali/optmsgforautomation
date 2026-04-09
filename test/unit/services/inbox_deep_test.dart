import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  Emails makeEmail({int id = 1, int emailId = 100, bool isRead = false}) =>
      Emails.fromJson(makeInboxEmailJson(id: id, emailId: emailId, isRead: isRead,
        email: makeEmailJson(senderEmail: 'sender$id@test.com'),
      ));

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    setup = RiverpodTestSetup();
    when(() => setup.mockStorageService.readObjectData(any()))
        .thenAnswer((_) async => null);
    when(() => setup.mockStorageService.readData(any()))
        .thenAnswer((_) async => null);

    container = ProviderContainer(overrides: setup.serviceOverrides);
    container.read(authProvider);
    await Future.delayed(Duration.zero);
    notifier = container.read(inboxProvider.notifier);
  });

  tearDown(() => container.dispose());

  // ===== Selection methods =====
  group('InboxNotifier toggleSelectFromList', () {
    test('should add item to selection', () {
      notifier.state = notifier.state.copyWith(items: [
        makeEmail(id: 1, emailId: 100),
        makeEmail(id: 2, emailId: 200),
      ]);

      notifier.toggleSelectFromList(100, 'sender1@test.com');

      final state = container.read(inboxProvider);
      expect(state.selectedEmailIds, [100]);
      expect(state.selectedEmails, ['sender1@test.com']);
      expect(state.longPressFlag, false);
    });

    test('should remove item from selection', () {
      notifier.state = notifier.state.copyWith(
        items: [makeEmail(id: 1, emailId: 100)],
        selectedEmailIds: [100],
        selectedEmails: ['sender1@test.com'],
      );

      notifier.toggleSelectFromList(100, 'sender1@test.com');

      final state = container.read(inboxProvider);
      expect(state.selectedEmailIds, isEmpty);
      expect(state.longPressFlag, true);
    });

    test('should set allEmailIdsFlag when all items selected', () {
      notifier.state = notifier.state.copyWith(items: [
        makeEmail(id: 1, emailId: 100),
        makeEmail(id: 2, emailId: 200),
      ]);

      notifier.toggleSelectFromList(100, 'a@b.com');
      notifier.toggleSelectFromList(200, 'c@d.com');

      expect(container.read(inboxProvider).allEmailIdsFlag, true);
    });
  });

  group('InboxNotifier selectAllFromList', () {
    test('should select all items', () {
      notifier.state = notifier.state.copyWith(items: [
        makeEmail(id: 1, emailId: 100),
        makeEmail(id: 2, emailId: 200),
        makeEmail(id: 3, emailId: 300),
      ]);

      notifier.selectAllFromList();

      final state = container.read(inboxProvider);
      expect(state.selectedEmailIds, [100, 200, 300]);
      expect(state.allEmailIdsFlag, true);
      expect(state.longPressFlag, false);
    });
  });

  group('InboxNotifier setSelectedFromList', () {
    test('should set specific selections', () {
      notifier.state = notifier.state.copyWith(items: [
        makeEmail(id: 1, emailId: 100),
        makeEmail(id: 2, emailId: 200),
      ]);

      notifier.setSelectedFromList([100], ['a@b.com']);

      final state = container.read(inboxProvider);
      expect(state.selectedEmailIds, [100]);
      expect(state.selectedEmails, ['a@b.com']);
      expect(state.allEmailIdsFlag, false);
    });
  });

  // ===== Tag dialog methods =====
  group('InboxNotifier tag dialog', () {
    test('showList should open tag dialog with email data', () {
      notifier.state = notifier.state.copyWith(items: [
        makeEmail(id: 1, emailId: 100),
      ]);

      notifier.showList(100, 0);

      final state = container.read(inboxProvider);
      expect(state.showTagDialog, true);
      expect(state.tagDialogEmailId, 100);
      expect(state.tagDialogItemIndex, 0);
      expect(state.tagDialogIsMove, false);
    });

    test('showList with isMove=true should set move flag', () {
      notifier.state = notifier.state.copyWith(items: [makeEmail()]);

      notifier.showList(100, 0, isMove: true);

      expect(container.read(inboxProvider).tagDialogIsMove, true);
    });

    test('dismissTagDialog should close dialog', () {
      notifier.state = notifier.state.copyWith(showTagDialog: true);

      notifier.dismissTagDialog();

      expect(container.read(inboxProvider).showTagDialog, false);
    });

    test('updateSelectedTagIds should update tag selection', () {
      notifier.updateSelectedTagIds([1, 2, 3]);

      expect(container.read(inboxProvider).selectedTagIds, [1, 2, 3]);
    });
  });

  // ===== Filter methods =====
  group('InboxNotifier applyUnreadFilter', () {
    test('should set emailType to unread and clear filter', () {
      notifier.applyUnreadFilter('');

      final state = container.read(inboxProvider);
      expect(state.emailType, 'unread');
      expect(state.showFilter, false);
      expect(state.currentPage, 1);
      expect(state.selectedEmailIdForReadingPane, isNull);
    });
  });

  group('InboxNotifier applyTagFilter', () {
    test('should set tag filter and reset pagination', () {
      notifier.applyTagFilter(5);

      final state = container.read(inboxProvider);
      expect(state.tagFilter, true);
      expect(state.tagIdFilter, [5]);
      expect(state.currentPage, 1);
      expect(state.showTagList, false);
    });
  });

  group('InboxNotifier clearUnreadFilter', () {
    test('should reset to inbox type', () {
      notifier.state = notifier.state.copyWith(emailType: 'unread');

      when(() => setup.mockInboxApi.getInboxEmails(any()))
          .thenAnswer((_) async => RequestResponse(
              data: InboxListModel.fromJson(makeInboxListJson())));

      notifier.clearUnreadFilter('');

      final state = container.read(inboxProvider);
      expect(state.emailType, 'inbox');
      expect(state.showFilter, false);
    });
  });

  group('InboxNotifier clearTagFilterAndRefresh', () {
    test('should clear tag filter and reset', () {
      notifier.state = notifier.state.copyWith(
        tagFilter: true,
        tagIdFilter: [1, 2],
      );

      when(() => setup.mockInboxApi.getInboxEmails(any()))
          .thenAnswer((_) async => RequestResponse(
              data: InboxListModel.fromJson(makeInboxListJson())));

      notifier.clearTagFilterAndRefresh('');

      final state = container.read(inboxProvider);
      expect(state.tagFilter, false);
      expect(state.tagIdFilter, isEmpty);
      expect(state.emailType, 'inbox');
    });
  });

  // handleMoveToFolderAction and handleTagAction use addPostFrameCallback
  // which requires widget test pump — tested via showList directly above.

  group('InboxNotifier handleMoveToFolderAction', () {
    test('should close menus immediately', () {
      notifier.state = notifier.state.copyWith(
        showMenuOptions: true,
        showReadingPaneMenuOptions: true,
        items: [makeEmail(id: 1, emailId: 100)],
        selectedEmailIds: [100],
      );

      notifier.handleMoveToFolderAction();

      final state = container.read(inboxProvider);
      expect(state.showMenuOptions, false);
      expect(state.showReadingPaneMenuOptions, false);
      expect(state.showTagList, false);
    });
  });

  group('InboxNotifier handleTagAction', () {
    test('should close menus immediately', () {
      notifier.state = notifier.state.copyWith(
        showMenuOptions: true,
        showReadingPaneMenuOptions: true,
        items: [makeEmail(id: 1, emailId: 100)],
        selectedEmailIds: [100],
      );

      notifier.handleTagAction();

      final state = container.read(inboxProvider);
      expect(state.showMenuOptions, false);
      expect(state.showReadingPaneMenuOptions, false);
    });
  });

  // ===== _updateBadgeFromSocket =====
  group('InboxNotifier badge', () {
    test('_markEmailAsReadLocally should update item read status', () {
      notifier.state = notifier.state.copyWith(items: [
        makeEmail(id: 1, emailId: 100, isRead: false),
        makeEmail(id: 2, emailId: 200, isRead: false),
      ]);

      // Trigger via setSelectedEmailIdForReadingPane which calls _markEmailAsReadLocally
      notifier.setSelectedEmailIdForReadingPane(100);

      final items = container.read(inboxProvider).items;
      expect(items[0].isRead, true);
      expect(items[1].isRead, false);
    });
  });
}
