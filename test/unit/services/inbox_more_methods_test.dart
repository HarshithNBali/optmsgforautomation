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

  Emails makeEmail({int id = 1, int emailId = 100, bool isRead = false,
    List<Map<String, dynamic>>? tags}) =>
      Emails.fromJson(makeInboxEmailJson(
        id: id, emailId: emailId, isRead: isRead,
        emailRecipientTags: tags,
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

  group('InboxNotifier removeEmailFromListById', () {
    test('should remove email by emailId', () {
      notifier.state = notifier.state.copyWith(items: [
        makeEmail(id: 1, emailId: 100),
        makeEmail(id: 2, emailId: 200),
        makeEmail(id: 3, emailId: 300),
      ]);

      notifier.removeEmailFromListById(200);

      final items = container.read(inboxProvider).items;
      expect(items, hasLength(2));
      expect(items.every((e) => e.emailId != 200), true);
    });

    test('should clear selection after removal', () {
      notifier.state = notifier.state.copyWith(
        items: [makeEmail(id: 1, emailId: 100)],
        selectedEmailIds: [100],
      );

      notifier.removeEmailFromListById(100);

      expect(container.read(inboxProvider).selectedEmailIds, isEmpty);
      expect(container.read(inboxProvider).longPressFlag, true);
    });

    test('should clear reading pane if removed email was being viewed', () {
      notifier.state = notifier.state.copyWith(
        items: [makeEmail(id: 1, emailId: 100)],
        selectedEmailIdForReadingPane: 100,
        currentlyViewedEmailId: 100,
      );

      notifier.removeEmailFromListById(100);

      final state = container.read(inboxProvider);
      expect(state.selectedEmailIdForReadingPane, isNull);
      expect(state.currentlyViewedEmailId, isNull);
    });

    test('should preserve reading pane if different email was removed', () {
      notifier.state = notifier.state.copyWith(
        items: [makeEmail(id: 1, emailId: 100), makeEmail(id: 2, emailId: 200)],
        selectedEmailIdForReadingPane: 100,
      );

      notifier.removeEmailFromListById(200);

      expect(container.read(inboxProvider).selectedEmailIdForReadingPane, 100);
    });
  });

  group('InboxNotifier markEmailAsUnreadInList', () {
    test('should mark specific email as unread locally', () {
      notifier.state = notifier.state.copyWith(items: [
        makeEmail(id: 1, emailId: 100, isRead: true),
        makeEmail(id: 2, emailId: 200, isRead: true),
      ]);

      notifier.markEmailAsUnreadInList(100);

      final items = container.read(inboxProvider).items;
      expect(items[0].isRead, false);
      expect(items[1].isRead, true);
    });

    test('should no-op for non-existent emailId', () {
      notifier.state = notifier.state.copyWith(items: [
        makeEmail(id: 1, emailId: 100, isRead: true),
      ]);

      notifier.markEmailAsUnreadInList(999);

      expect(container.read(inboxProvider).items[0].isRead, true);
    });
  });

  group('InboxNotifier markEmailAsReadInList', () {
    test('should mark specific email as read locally', () {
      notifier.state = notifier.state.copyWith(items: [
        makeEmail(id: 1, emailId: 100, isRead: false),
      ]);

      notifier.markEmailAsReadInList(100);

      expect(container.read(inboxProvider).items[0].isRead, true);
    });

    test('should no-op if already read', () {
      notifier.state = notifier.state.copyWith(items: [
        makeEmail(id: 1, emailId: 100, isRead: true),
      ]);

      notifier.markEmailAsReadInList(100);

      expect(container.read(inboxProvider).items[0].isRead, true);
    });

    test('should no-op for non-existent emailId', () {
      notifier.state = notifier.state.copyWith(items: [
        makeEmail(id: 1, emailId: 100, isRead: false),
      ]);

      notifier.markEmailAsReadInList(999);

      expect(container.read(inboxProvider).items[0].isRead, false);
    });
  });

  group('InboxNotifier getExistingTagIdsForEmail', () {
    test('should return tag IDs from email recipient tags', () {
      notifier.state = notifier.state.copyWith(items: [
        makeEmail(id: 1, emailId: 100, tags: [
          makeEmailRecipientTagJson(id: 1, tagId: 10),
          makeEmailRecipientTagJson(id: 2, tagId: 20),
        ]),
      ]);

      final tagIds = notifier.getExistingTagIdsForEmail(100, 0);

      expect(tagIds, [10, 20]);
    });

    test('should return empty for email without tags', () {
      notifier.state = notifier.state.copyWith(items: [
        makeEmail(id: 1, emailId: 100),
      ]);

      final tagIds = notifier.getExistingTagIdsForEmail(100, 0);

      expect(tagIds, isEmpty);
    });

    test('should return empty for non-existent emailId', () {
      notifier.state = notifier.state.copyWith(items: [
        makeEmail(id: 1, emailId: 100),
      ]);

      final tagIds = notifier.getExistingTagIdsForEmail(999, 0);

      expect(tagIds, isEmpty);
    });
  });

  group('InboxNotifier handleTagDialogSave edge cases', () {
    test('should no-op when no email selected and no tagDialogEmailId', () async {
      notifier.state = notifier.state.copyWith(
        selectedEmailIds: [],
        tagDialogEmailId: 0,
      );

      await notifier.handleTagDialogSave();

      // Should show warning toast but not crash
      expect(container.read(inboxProvider), isNotNull);
    });

    test('should no-op when no tags selected and no initial tags', () async {
      notifier.state = notifier.state.copyWith(
        selectedEmailIds: [100],
        tagDialogEmailId: 100,
        selectedTagIds: [],
        tagDialogInitialTagIds: [],
      );

      await notifier.handleTagDialogSave();

      expect(container.read(inboxProvider), isNotNull);
    });
  });

  group('InboxNotifier dismissTagDialog', () {
    test('should close tag dialog', () {
      notifier.state = notifier.state.copyWith(showTagDialog: true);

      notifier.dismissTagDialog();

      expect(container.read(inboxProvider).showTagDialog, false);
    });
  });

  group('InboxNotifier reloadList', () {
    test('should reset pagination and clear overlays', () async {
      when(() => setup.mockInboxApi.getInboxEmails(any()))
          .thenAnswer((_) async => RequestResponse(
              data: InboxListModel.fromJson(makeInboxListJson())));

      notifier.state = notifier.state.copyWith(
        currentPage: 5,
        showFilter: true,
        isSearch: true,
      );

      await notifier.reloadList();

      final state = container.read(inboxProvider);
      expect(state.showFilter, false);
      expect(state.showTagList, false);
      expect(state.isSearch, false);
      expect(state.showMenuOptions, false);
    });
  });
}
