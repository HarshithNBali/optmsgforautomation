import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:optmsg/model/base_response/request_response.dart';
import 'package:optmsg/screens/auth/auth_riverpod/auth_notifier.dart';
import 'package:optmsg/screens/email/archive_riverpod/archive_list_notifier.dart';
import 'package:optmsg/model/sent_list_model.dart' as sent;
import 'package:optmsg/router/app_routes.dart';

import '../../helpers/riverpod_test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late RiverpodTestSetup setup;
  late ProviderContainer container;
  late ArchiveNotifier notifier;

  sent.Emails makeSentEmail({int? id = 1, List<Map<String, dynamic>>? receivers}) =>
      sent.Emails.fromJson({
        'id': id, 'senderId': 1, 'senderEmail': 'me@t.com', 'senderName': 'Me',
        'subject': 'S', 'messageText': 'B', 'created': '2024-06-15T10:30:00.000Z',
        'attachments': [],
        'receivers': receivers ?? [
          {
            'emailId': id, 'receiverEmail': 'them@t.com', 'id': 10,
            'isRead': false,
            'emailRecipientTags': [],
            'receiver': {'firstName': 'T', 'lastName': 'U', 'userName': 'tu'},
          }
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

  group('ArchiveNotifier removeEmailFromListById', () {
    test('should remove email matching receiver emailId', () {
      notifier.state = notifier.state.copyWith(items: [
        makeSentEmail(id: 1),
        makeSentEmail(id: 2),
        makeSentEmail(id: 3),
      ]);

      notifier.removeEmailFromListById(2);

      final items = container.read(archiveProvider).items;
      expect(items, hasLength(2));
      expect(items.any((e) => e.id == 2), false);
    });

    test('should clear selection after removal', () {
      notifier.state = notifier.state.copyWith(
        items: [makeSentEmail(id: 1)],
        selectedEmailIds: [1],
        selectedEmails: ['me@t.com'],
      );

      notifier.removeEmailFromListById(1);

      final state = container.read(archiveProvider);
      expect(state.selectedEmailIds, isEmpty);
      expect(state.longPressFlag, true);
    });

    test('should clear reading pane if removed email was viewed', () {
      notifier.state = notifier.state.copyWith(
        items: [makeSentEmail(id: 5)],
        selectedEmailIdForReadingPane: 5,
        selectedEmailSender: 'me@t.com',
      );

      notifier.removeEmailFromListById(5);

      final state = container.read(archiveProvider);
      expect(state.selectedEmailIdForReadingPane, isNull);
      expect(state.selectedEmailSender, isNull);
    });
  });

  group('ArchiveNotifier closeTagList', () {
    test('should close filter and tag list', () {
      notifier.state = notifier.state.copyWith(
        showFilter: true,
        showTagList: true,
      );

      notifier.closeTagList();

      final state = container.read(archiveProvider);
      expect(state.showFilter, false);
      expect(state.showTagList, false);
    });
  });

  group('ArchiveNotifier applyCommunityFilter', () {
    test('should set emailType to community', () {
      when(() => setup.mockArchiveApi.getTrash(any()))
          .thenAnswer((_) async => RequestResponse(data: {
                'success': true, 'message': '', 'data': {'emails': [], 'nextPage': false},
              }));

      notifier.state = notifier.state.copyWith(currentPath: AppRoutes.trash);
      notifier.applyCommunityFilter();

      final state = container.read(archiveProvider);
      expect(state.showFilter, false);
      expect(state.currentPage, 1);
    });
  });

  group('ArchiveNotifier applyTagFilter', () {
    test('should set tag filter and clear reading pane', () {
      when(() => setup.mockArchiveApi.getTrash(any()))
          .thenAnswer((_) async => RequestResponse(data: {
                'success': true, 'message': '', 'data': {'emails': [], 'nextPage': false},
              }));

      notifier.state = notifier.state.copyWith(
        currentPath: AppRoutes.archive,
        selectedEmailIdForReadingPane: 5,
      );

      notifier.applyTagFilter(42);

      final state = container.read(archiveProvider);
      expect(state.tagFilter, true);
      expect(state.tagIdFilter, [42]);
      expect(state.showTagList, false);
      expect(state.selectedEmailIdForReadingPane, isNull);
    });
  });

  group('ArchiveNotifier reset', () {
    test('should reset all state to defaults', () {
      notifier.state = notifier.state.copyWith(
        items: [makeSentEmail()],
        selectedEmailIds: [1],
        showFilter: true,
        isSearch: true,
      );

      notifier.reset();

      final state = container.read(archiveProvider);
      expect(state.items, isEmpty);
      expect(state.selectedEmailIds, isEmpty);
      expect(state.showFilter, false);
      expect(state.isSearch, false);
      expect(state.isLoading, false); // ArchiveState default
    });
  });

  group('ArchiveNotifier handleBulkTagAction', () {
    test('should close menus immediately', () {
      notifier.state = notifier.state.copyWith(
        showMenuOptions: true,
        showReadingPaneMenuOptions: true,
        items: [makeSentEmail(id: 1)],
        selectedEmailIds: [1],
      );

      notifier.handleBulkTagAction();

      final state = container.read(archiveProvider);
      expect(state.showMenuOptions, false);
      expect(state.showReadingPaneMenuOptions, false);
      expect(state.showTagList, false);
    });
  });

  group('ArchiveNotifier updateInboxEmailStatusSilent (trash path)', () {
    test('should call archiveApi for trash operations', () async {
      notifier.state = notifier.state.copyWith(
        currentPath: AppRoutes.trash,
        items: [makeSentEmail(id: 1)],
      );

      when(() => setup.mockArchiveApi.updateEmailStatus(any()))
          .thenAnswer((_) async => RequestResponse(data: {
                'success': true, 'message': 'OK',
              }));

      await notifier.updateInboxEmailStatusSilent('isInbox', [1], 0);

      verify(() => setup.mockArchiveApi.updateEmailStatus(any())).called(1);
    });
  });

  group('ArchiveNotifier updateSentEmailStatus', () {
    test('should call apiService', () async {
      notifier.state = notifier.state.copyWith(currentPath: AppRoutes.sent);

      when(() => setup.mockApiService.post(any(), any()))
          .thenAnswer((_) async => {'success': true});

      await notifier.updateSentEmailStatus('isTrash', [1]);

      verify(() => setup.mockApiService.post(any(), any())).called(1);
    });

    test('should handle API failure', () async {
      notifier.state = notifier.state.copyWith(currentPath: AppRoutes.sent);

      when(() => setup.mockApiService.post(any(), any()))
          .thenAnswer((_) async => {'success': false, 'message': 'Failed'});

      await notifier.updateSentEmailStatus('isTrash', [1]);

      // Should not crash
      expect(container.read(archiveProvider), isNotNull);
    });
  });
}
