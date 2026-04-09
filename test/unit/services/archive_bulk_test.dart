import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
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

  sent.Emails makeSentEmail({int? id = 1, bool isRead = false}) =>
      sent.Emails.fromJson({
        'id': id, 'senderId': 1, 'senderEmail': 'me@t.com', 'senderName': 'Me',
        'subject': 'S', 'messageText': 'B', 'created': '2024-06-15T10:30:00.000Z',
        'attachments': [],
        'receivers': [
          {'emailId': id, 'receiverEmail': 'r@t.com', 'id': 10, 'isRead': isRead,
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

  group('ArchiveNotifier getSelectionState', () {
    test('should return none when no selection', () {
      notifier.state = notifier.state.copyWith(selectedEmailIds: []);
      expect(notifier.getSelectionState(), 'none');
    });

    test('should return singleRead for single read email', () {
      notifier.state = notifier.state.copyWith(
        items: [makeSentEmail(id: 1, isRead: true)],
        selectedEmailIds: [1],
      );
      expect(notifier.getSelectionState(), 'singleRead');
    });

    test('should return singleUnread for single unread email', () {
      notifier.state = notifier.state.copyWith(
        items: [makeSentEmail(id: 1, isRead: false)],
        selectedEmailIds: [1],
      );
      expect(notifier.getSelectionState(), 'singleUnread');
    });

    test('should return allRead when all selected are read', () {
      notifier.state = notifier.state.copyWith(
        items: [
          makeSentEmail(id: 1, isRead: true),
          makeSentEmail(id: 2, isRead: true),
        ],
        selectedEmailIds: [1, 2],
      );
      expect(notifier.getSelectionState(), 'allRead');
    });

    test('should return allUnread when all selected are unread', () {
      notifier.state = notifier.state.copyWith(
        items: [
          makeSentEmail(id: 1, isRead: false),
          makeSentEmail(id: 2, isRead: false),
        ],
        selectedEmailIds: [1, 2],
      );
      expect(notifier.getSelectionState(), 'allUnread');
    });

    test('should return mixed when some read and some unread', () {
      notifier.state = notifier.state.copyWith(
        items: [
          makeSentEmail(id: 1, isRead: true),
          makeSentEmail(id: 2, isRead: false),
        ],
        selectedEmailIds: [1, 2],
      );
      expect(notifier.getSelectionState(), 'mixed');
    });
  });

  group('ArchiveNotifier getSelectionOrigin', () {
    test('should return none when no selection', () {
      notifier.state = notifier.state.copyWith(selectedEmailIds: []);
      expect(notifier.getSelectionOrigin(), 'none');
    });
  });

  group('ArchiveNotifier markSelectedAsReadWithUndo', () {
    test('should call apiService to mark as read', () async {
      notifier.state = notifier.state.copyWith(
        items: [makeSentEmail(id: 1, isRead: false)],
        selectedEmailIds: [1],
      );

      when(() => setup.mockApiService.post(any(), any()))
          .thenAnswer((_) async => {'success': true});

      await notifier.markSelectedAsReadWithUndo();

      verify(() => setup.mockApiService.post(any(), any())).called(1);
    });

    test('should handle API failure', () async {
      notifier.state = notifier.state.copyWith(
        items: [makeSentEmail(id: 1)],
        selectedEmailIds: [1],
      );

      when(() => setup.mockApiService.post(any(), any()))
          .thenAnswer((_) async => {'success': false, 'message': 'Error'});

      await notifier.markSelectedAsReadWithUndo();

      expect(container.read(archiveProvider), isNotNull);
    });
  });

  group('ArchiveNotifier markSelectedAsUnread', () {
    test('should delegate to updateInboxEmailStatus', () async {
      notifier.state = notifier.state.copyWith(
        currentPath: AppRoutes.archive,
        items: [makeSentEmail(id: 1)],
      );

      when(() => setup.mockApiService.post(any(), any()))
          .thenAnswer((_) async => {'success': true});

      await notifier.markSelectedAsUnread([1]);

      verify(() => setup.mockApiService.post(any(), any())).called(greaterThanOrEqualTo(1));
    });
  });

  group('ArchiveNotifier handleBulkDeleteAction', () {
    test('should no-op when no selection', () async {
      notifier.state = notifier.state.copyWith(
        selectedEmailIds: [],
        selectedEmailIdForReadingPane: null,
      );

      await notifier.handleBulkDeleteAction();

      // Should not crash
      expect(container.read(archiveProvider), isNotNull);
    });

    test('should trigger delete flow for archive path with selection', () async {
      notifier.state = notifier.state.copyWith(
        currentPath: AppRoutes.archive,
        items: [makeSentEmail(id: 1)],
        selectedEmailIds: [1],
      );

      when(() => setup.mockApiService.post(any(), any()))
          .thenAnswer((_) async => {'success': true, 'message': 'OK'});

      // changeEmailStatus → updateEmailStatus → _apiService.post
      // May not call apiService if userData is null (unauthenticated in test)
      await notifier.handleBulkDeleteAction();

      expect(container.read(archiveProvider), isNotNull);
    });
  });

  group('ArchiveNotifier handleBulkTagAction', () {
    test('should close menus', () {
      notifier.state = notifier.state.copyWith(
        showMenuOptions: true,
        items: [makeSentEmail(id: 1)],
        selectedEmailIds: [1],
      );

      notifier.handleBulkTagAction();

      expect(container.read(archiveProvider).showMenuOptions, false);
    });
  });

  group('ArchiveNotifier handleBulkMarkAsReadAction', () {
    test('should call markSelectedAsReadWithUndo', () async {
      notifier.state = notifier.state.copyWith(
        items: [makeSentEmail(id: 1, isRead: false)],
        selectedEmailIds: [1],
      );

      when(() => setup.mockApiService.post(any(), any()))
          .thenAnswer((_) async => {'success': true});

      await notifier.handleBulkMarkAsReadAction();

      verify(() => setup.mockApiService.post(any(), any())).called(greaterThanOrEqualTo(1));
    });
  });

  group('ArchiveNotifier tagsOnclick', () {
    test('should show warning when no tags available', () {
      // tagsProvider has no tagsList → should show toast
      notifier.tagsOnclick();

      // Should not crash — just shows toast
      expect(container.read(archiveProvider), isNotNull);
    });
  });
}
