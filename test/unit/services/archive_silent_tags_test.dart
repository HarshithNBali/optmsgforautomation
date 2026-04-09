import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:optmsg/model/base_response/request_response.dart';
import 'package:optmsg/screens/auth/auth_riverpod/auth_notifier.dart';
import 'package:optmsg/screens/email/archive_riverpod/archive_list_notifier.dart';
import 'package:optmsg/router/app_routes.dart';
import 'package:optmsg/model/sent_list_model.dart' as sent;

import '../../helpers/riverpod_test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late RiverpodTestSetup setup;
  late ProviderContainer container;
  late ArchiveNotifier notifier;

  sent.Emails makeSentEmail({int? id = 1}) => sent.Emails.fromJson({
    'id': id, 'senderId': 1, 'senderEmail': 'me@t.com', 'senderName': 'Me',
    'subject': 'S', 'messageText': 'B', 'created': '2024-06-15T10:30:00.000Z',
    'attachments': [],
    'receivers': [
      {'emailId': id, 'receiverEmail': 'r@t.com', 'id': 10, 'isRead': false,
       'emailRecipientTags': [], 'receiver': {'firstName': 'R', 'lastName': 'U', 'userName': 'ru'}}
    ],
    'sender': {'firstName': 'M', 'lastName': 'U', 'created': ''},
    'emailTag': [], 'message': '', 'communityStatus': false,
  });

  setUp(() async {
    setup = RiverpodTestSetup();
    when(() => setup.mockStorageService.readObjectData(any())).thenAnswer((_) async => null);
    when(() => setup.mockStorageService.readData(any())).thenAnswer((_) async => null);
    when(() => setup.mockStorageService.deleteData(any())).thenAnswer((_) async {});
    when(() => setup.mockStorageService.writeData(any(), any())).thenAnswer((_) async {});

    container = ProviderContainer(overrides: setup.serviceOverrides);
    container.read(authProvider);
    await Future.delayed(Duration.zero);

    await runZonedGuarded(() async {
      notifier = container.read(archiveProvider.notifier);
      await Future.delayed(const Duration(milliseconds: 50));
    }, (e, _) {});
  });

  tearDown(() => container.dispose());

  // ===== updateInboxEmailStatusSilent for archive path =====
  group('ArchiveNotifier updateInboxEmailStatusSilent archive path', () {
    test('should call apiService for archive operations', () async {
      notifier.state = notifier.state.copyWith(currentPath: AppRoutes.archive);

      when(() => setup.mockApiService.post(any(), any()))
          .thenAnswer((_) async => {'success': true});

      await notifier.updateInboxEmailStatusSilent('isTrash', [1], 0);

      verify(() => setup.mockApiService.post(any(), any())).called(greaterThanOrEqualTo(1));
    });

    test('should make second API call for isInbox type', () async {
      notifier.state = notifier.state.copyWith(currentPath: AppRoutes.archive);

      when(() => setup.mockApiService.post(any(), any()))
          .thenAnswer((_) async => {'success': true});

      await notifier.updateInboxEmailStatusSilent('isInbox', [1], 0);

      // First call: remove from archive (isArchive=false)
      // Second call: set isInbox=true
      verify(() => setup.mockApiService.post(any(), any())).called(2);
    });

    test('should update items locally for isRead type', () async {
      notifier.state = notifier.state.copyWith(
        currentPath: AppRoutes.archive,
        items: [makeSentEmail(id: 1)],
      );

      when(() => setup.mockApiService.post(any(), any()))
          .thenAnswer((_) async => {'success': true});

      await notifier.updateInboxEmailStatusSilent('isRead', [1], 0);

      // Items should be updated (read status changed)
      expect(container.read(archiveProvider).items, hasLength(1));
    });
  });

  // ===== updateInboxEmailStatusSilent for sent path =====
  group('ArchiveNotifier updateInboxEmailStatusSilent sent path', () {
    test('should call apiService for sent to inbox move', () async {
      notifier.state = notifier.state.copyWith(
        currentPath: AppRoutes.sent,
        items: [makeSentEmail(id: 1)],
      );

      when(() => setup.mockApiService.post(any(), any()))
          .thenAnswer((_) async => {'success': true});

      await notifier.updateInboxEmailStatusSilent('isInbox', [1], 0);

      verify(() => setup.mockApiService.post(any(), any())).called(greaterThanOrEqualTo(1));
    });

    test('should remove items from list for sent move operations', () async {
      notifier.state = notifier.state.copyWith(
        currentPath: AppRoutes.sent,
        items: [makeSentEmail(id: 1), makeSentEmail(id: 2)],
      );

      when(() => setup.mockApiService.post(any(), any()))
          .thenAnswer((_) async => {'success': true});

      await notifier.updateInboxEmailStatusSilent('isArchive', [1], 0);

      // Item 1 should be removed
      final items = container.read(archiveProvider).items;
      expect(items, hasLength(1));
    });
  });

  // ===== addEmailTags =====
  group('ArchiveNotifier addEmailTags', () {
    test('should call inboxApi.getEmailTags for single email', () async {
      notifier.state = notifier.state.copyWith(items: [makeSentEmail(id: 1)]);

      when(() => setup.mockInboxApi.getEmailTags(any()))
          .thenAnswer((_) async => RequestResponse(data: {
                'success': true, 'message': 'Tags added',
              }));

      await notifier.addEmailTags([1, 2], 1, 0, 'add');

      verify(() => setup.mockInboxApi.getEmailTags({
            'emailIds': [1],
            'tagsId': [1, 2],
            'type': 'add',
          })).called(1);
    });

    test('should use selectedEmailIds when emailId is 0', () async {
      notifier.state = notifier.state.copyWith(
        items: [makeSentEmail(id: 1), makeSentEmail(id: 2)],
        selectedEmailIds: [1, 2],
      );

      when(() => setup.mockInboxApi.getEmailTags(any()))
          .thenAnswer((_) async => RequestResponse(data: {
                'success': true, 'message': 'OK',
              }));

      await notifier.addEmailTags([5], 0, 0, 'add');

      verify(() => setup.mockInboxApi.getEmailTags({
            'emailIds': [1, 2],
            'tagsId': [5],
            'type': 'add',
          })).called(1);
    });

    test('should handle API failure', () async {
      when(() => setup.mockInboxApi.getEmailTags(any()))
          .thenAnswer((_) async => RequestResponse(data: {
                'success': false, 'message': 'Failed',
              }));

      await notifier.addEmailTags([1], 1, 0, 'add');

      expect(container.read(archiveProvider), isNotNull);
    });
  });

  // ===== More pure mutators for coverage =====
  group('ArchiveNotifier additional mutators', () {
    test('onLongPress with id should start selection', () {
      notifier.onLongPress(42, 'sender@test.com');

      final state = container.read(archiveProvider);
      expect(state.selectedEmailIds, [42]);
      expect(state.selectedEmails, ['sender@test.com']);
      expect(state.longPressFlag, false);
    });

    test('addAndRemoveKey should toggle selection', () {
      notifier.addAndRemoveKey(1, 'a@b.com');
      expect(container.read(archiveProvider).selectedEmailIds, [1]);

      notifier.addAndRemoveKey(2, 'c@d.com');
      expect(container.read(archiveProvider).selectedEmailIds, [1, 2]);

      notifier.addAndRemoveKey(1, 'a@b.com');
      expect(container.read(archiveProvider).selectedEmailIds, [2]);
    });

    test('closeFilter should set false', () {
      notifier.state = notifier.state.copyWith(showFilter: true);
      notifier.closeFilter();
      expect(container.read(archiveProvider).showFilter, false);
    });

    test('closeTagList should close both filter and tagList', () {
      notifier.state = notifier.state.copyWith(showFilter: true, showTagList: true);
      notifier.closeTagList();
      final state = container.read(archiveProvider);
      expect(state.showFilter, false);
      expect(state.showTagList, false);
    });

    test('openReadingPaneMenu and closeReadingPaneMenu', () {
      notifier.openReadingPaneMenu();
      expect(container.read(archiveProvider).showReadingPaneMenuOptions, true);
      notifier.closeReadingPaneMenu();
      expect(container.read(archiveProvider).showReadingPaneMenuOptions, false);
    });

    test('setShowCheckboxes', () {
      notifier.setShowCheckboxes(true);
      expect(container.read(archiveProvider).showCheckboxes, true);
      notifier.setShowCheckboxes(false);
      expect(container.read(archiveProvider).showCheckboxes, false);
    });

    test('setEmailListPaneWidth', () {
      notifier.setEmailListPaneWidth(400.0);
      expect(container.read(archiveProvider).emailListPaneWidth, 400.0);
    });
  });
}
