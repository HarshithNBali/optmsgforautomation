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
      Emails.fromJson(makeInboxEmailJson(id: id, emailId: emailId, isRead: isRead));

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

  group('InboxNotifier handleMarkUnread', () {
    test('should toggle read status for selected emails', () async {
      notifier.state = notifier.state.copyWith(items: [
        makeEmail(id: 1, emailId: 100, isRead: true),
        makeEmail(id: 2, emailId: 200, isRead: true),
        makeEmail(id: 3, emailId: 300, isRead: false),
      ], selectedEmailIds: [100, 200]);

      when(() => setup.mockInboxApi.updateEmailStatus(any()))
          .thenAnswer((_) async => RequestResponse(data: {
                'success': true, 'message': 'Updated',
              }));

      await notifier.handleMarkUnread();

      final state = container.read(inboxProvider);
      // Emails 100, 200 were read → now unread (isRead: false → toggled to false since all were read)
      expect(state.items[0].isRead, false);
      expect(state.items[1].isRead, false);
      // Email 300 unchanged
      expect(state.items[2].isRead, false);
      // Selection should be cleared
      expect(state.selectedEmailIds, isEmpty);
    });

    test('should use reading pane email when no selection', () async {
      notifier.state = notifier.state.copyWith(
        items: [makeEmail(id: 1, emailId: 100, isRead: true)],
        selectedEmailIds: [],
        selectedEmailIdForReadingPane: 100,
      );

      when(() => setup.mockInboxApi.updateEmailStatus(any()))
          .thenAnswer((_) async => RequestResponse(data: {
                'success': true, 'message': 'OK',
              }));

      await notifier.handleMarkUnread();

      verify(() => setup.mockInboxApi.updateEmailStatus(any())).called(1);
    });

    test('should no-op when no selection and no reading pane', () async {
      notifier.state = notifier.state.copyWith(
        items: [makeEmail()],
        selectedEmailIds: [],
        selectedEmailIdForReadingPane: null,
      );

      await notifier.handleMarkUnread();

      verifyNever(() => setup.mockInboxApi.updateEmailStatus(any()));
    });

    test('should handle API failure gracefully', () async {
      notifier.state = notifier.state.copyWith(
        items: [makeEmail(isRead: true)],
        selectedEmailIds: [100],
      );

      when(() => setup.mockInboxApi.updateEmailStatus(any()))
          .thenAnswer((_) async => RequestResponse(data: {
                'success': false, 'message': 'Error',
              }));

      await notifier.handleMarkUnread();

      // Items should remain unchanged
      expect(container.read(inboxProvider).items[0].isRead, true);
    });
  });

  group('InboxNotifier handleArchive / handleDelete', () {
    setUp(() {
      // Stub the API calls that changeStatusWithUndo triggers
      when(() => setup.mockInboxApi.updateEmailStatus(any()))
          .thenAnswer((_) async => RequestResponse(data: {
                'success': true, 'message': 'OK',
              }));
      // Stub archive refresh (triggered by changeStatusWithUndo)
      when(() => setup.mockArchiveApi.getTrash(any()))
          .thenAnswer((_) async => RequestResponse(data: {
                'success': true, 'message': '', 'data': {'emails': [], 'nextPage': false},
              }));
    });

    test('handleArchive should remove selected items from list', () {
      notifier.state = notifier.state.copyWith(
        items: [makeEmail(id: 1, emailId: 100), makeEmail(id: 2, emailId: 200)],
        selectedEmailIds: [100, 200],
      );

      notifier.handleArchive();

      final state = container.read(inboxProvider);
      expect(state.items, isEmpty);
      expect(state.selectedEmailIds, isEmpty);
    });

    test('handleArchive should use reading pane email when no selection', () {
      notifier.state = notifier.state.copyWith(
        items: [makeEmail(id: 1, emailId: 100)],
        selectedEmailIds: [],
        selectedEmailIdForReadingPane: 100,
      );

      notifier.handleArchive();

      expect(container.read(inboxProvider).items, isEmpty);
    });

    test('handleArchive should no-op when nothing selected', () {
      notifier.state = notifier.state.copyWith(
        items: [makeEmail()],
        selectedEmailIds: [],
        selectedEmailIdForReadingPane: null,
      );

      notifier.handleArchive();

      expect(container.read(inboxProvider).items, hasLength(1));
    });

    test('handleDelete should remove selected items', () {
      notifier.state = notifier.state.copyWith(
        items: [makeEmail(id: 1, emailId: 100)],
        selectedEmailIds: [100],
      );

      notifier.handleDelete();

      expect(container.read(inboxProvider).items, isEmpty);
    });

    test('handleDelete should use reading pane email', () {
      notifier.state = notifier.state.copyWith(
        items: [makeEmail(id: 1, emailId: 100)],
        selectedEmailIds: [],
        selectedEmailIdForReadingPane: 100,
      );

      notifier.handleDelete();

      expect(container.read(inboxProvider).items, isEmpty);
    });
  });

  group('InboxNotifier changeStatusWithUndo', () {
    setUp(() {
      when(() => setup.mockInboxApi.updateEmailStatus(any()))
          .thenAnswer((_) async => RequestResponse(data: {
                'success': true, 'message': 'OK',
              }));
      when(() => setup.mockArchiveApi.getTrash(any()))
          .thenAnswer((_) async => RequestResponse(data: {
                'success': true, 'message': '', 'data': {'emails': [], 'nextPage': false},
              }));
    });

    test('should remove items by emailId and clear selection', () async {
      notifier.state = notifier.state.copyWith(items: [
        makeEmail(id: 1, emailId: 100),
        makeEmail(id: 2, emailId: 200),
        makeEmail(id: 3, emailId: 300),
      ]);

      await notifier.changeStatusWithUndo('isArchive', [100, 300]);

      final state = container.read(inboxProvider);
      expect(state.items, hasLength(1));
      expect(state.items[0].emailId, 200);
      expect(state.selectedEmailIds, isEmpty);
      expect(state.longPressFlag, true);
    });

    test('should no-op for empty ids', () async {
      notifier.state = notifier.state.copyWith(items: [makeEmail()]);

      await notifier.changeStatusWithUndo('isTrash', []);

      expect(container.read(inboxProvider).items, hasLength(1));
    });

    test('should clear reading pane if viewed email is removed', () async {
      notifier.state = notifier.state.copyWith(
        items: [makeEmail(id: 1, emailId: 100)],
        selectedEmailIdForReadingPane: 100,
        currentlyViewedEmailId: 100,
      );

      await notifier.changeStatusWithUndo('isTrash', [100]);

      final state = container.read(inboxProvider);
      expect(state.selectedEmailIdForReadingPane, isNull);
      expect(state.currentlyViewedEmailId, isNull);
    });
  });

  // updateNotificationFlag calls countProvider which triggers AppBadgePlus
  // platform channel — tested via countProvider tests instead.

  group('InboxNotifier clearSelection', () {
    test('should clear all selection state', () {
      notifier.onLongPress(1, 'a@b.com');
      notifier.clearSelection();

      final state = container.read(inboxProvider);
      expect(state.selectedEmailIds, isEmpty);
      expect(state.selectedEmails, isEmpty);
      expect(state.longPressFlag, true);
      expect(state.allEmailIdsFlag, false);
    });
  });
}
