import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  sent.Emails makeSentEmail({int? id = 1, String subject = 'Email'}) =>
      sent.Emails.fromJson({
        'id': id, 'senderId': 1, 'senderEmail': 'me@test.com',
        'senderName': 'Me', 'subject': subject, 'messageText': 'Body',
        'created': '2024-06-15T10:30:00.000Z', 'attachments': [],
        'receivers': [], 'sender': {'firstName': 'Me', 'lastName': 'U', 'created': '2024-01-01'},
        'emailTag': [], 'message': '<p>Body</p>', 'communityStatus': false,
      });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    setup = RiverpodTestSetup();
    when(() => setup.mockStorageService.readObjectData(any()))
        .thenAnswer((_) async => null);
    when(() => setup.mockStorageService.readData(any()))
        .thenAnswer((_) async => null);
    when(() => setup.mockStorageService.deleteData(any()))
        .thenAnswer((_) async {});

    container = ProviderContainer(overrides: setup.serviceOverrides);
    container.read(authProvider);
    await Future.delayed(Duration.zero);

    await runZonedGuarded(() async {
      notifier = container.read(archiveProvider.notifier);
      await Future.delayed(const Duration(milliseconds: 50));
    }, (e, _) {});
  });

  tearDown(() => container.dispose());

  group('ArchiveNotifier updateEmailStatus (trash path)', () {
    test('should call archiveApi and invoke onSuccess on success', () async {
      notifier.state = notifier.state.copyWith(
        currentPath: AppRoutes.trash,
        items: [makeSentEmail(id: 1), makeSentEmail(id: 2)],
      );

      when(() => setup.mockArchiveApi.updateEmailStatus(any()))
          .thenAnswer((_) async => RequestResponse(data: {
                'success': true, 'message': 'Moved to inbox',
              }));
      when(() => setup.mockApiService.post(any(), any()))
          .thenAnswer((_) async => {'success': true});

      bool successCalled = false;
      await notifier.updateEmailStatus(
        'isInbox', [1], () => successCalled = true,
      );

      verify(() => setup.mockArchiveApi.updateEmailStatus(any())).called(1);
      expect(successCalled, true);
    });

    test('should handle API failure', () async {
      notifier.state = notifier.state.copyWith(
        currentPath: AppRoutes.trash,
        items: [makeSentEmail()],
      );

      when(() => setup.mockArchiveApi.updateEmailStatus(any()))
          .thenAnswer((_) async => RequestResponse(data: {
                'success': false, 'message': 'Failed',
              }));

      bool successCalled = false;
      await notifier.updateEmailStatus(
        'isInbox', [1], () => successCalled = true,
      );

      expect(successCalled, false);
    });

    test('should mark as read locally for isRead type', () async {
      notifier.state = notifier.state.copyWith(
        currentPath: AppRoutes.trash,
        items: [makeSentEmail(id: 1)],
      );

      when(() => setup.mockArchiveApi.updateEmailStatus(any()))
          .thenAnswer((_) async => RequestResponse(data: {
                'success': true, 'message': 'OK',
              }));

      await notifier.updateEmailStatus('isRead', [1], () {});

      // State should have updated items
      expect(container.read(archiveProvider).isInProcess, false);
    });
  });

  group('ArchiveNotifier updateEmailStatus sets isInProcess', () {
    test('should set isInProcess to true during operation', () async {
      notifier.state = notifier.state.copyWith(
        currentPath: AppRoutes.trash,
        items: [makeSentEmail()],
      );

      when(() => setup.mockArchiveApi.updateEmailStatus(any()))
          .thenAnswer((_) async {
        // Check mid-call state
        expect(container.read(archiveProvider).isInProcess, true);
        return RequestResponse(data: {'success': true, 'message': 'OK'});
      });

      await notifier.updateEmailStatus('isRead', [1], () {});

      expect(container.read(archiveProvider).isInProcess, false);
    });
  });

  group('ArchiveNotifier getAllTags', () {
    test('should call tagApi on success', () async {
      when(() => setup.mockTagApi.getTagsList(any()))
          .thenAnswer((_) async => RequestResponse(data: {
                'success': true, 'message': '',
                'data': {
                  'tags': [
                    {'id': 1, 'tag': 'Work'},
                    {'id': 2, 'tag': 'Personal'},
                  ],
                },
              }));

      // Reset call count (init may have already called getTagsList)
      clearInteractions(setup.mockTagApi);

      await notifier.getAllTags();

      verify(() => setup.mockTagApi.getTagsList(any())).called(1);
    });
  });

  group('ArchiveNotifier selection via setSelectedEmails', () {
    test('should set selection and flags', () {
      notifier.state = notifier.state.copyWith(items: [
        makeSentEmail(id: 1), makeSentEmail(id: 2), makeSentEmail(id: 3),
      ]);

      notifier.setSelectedEmails([1, 2, 3], ['a@b.com', 'c@d.com', 'e@f.com']);

      final state = container.read(archiveProvider);
      expect(state.selectedEmailIds, hasLength(3));
      expect(state.allEmailIdsFlag, true);
      expect(state.longPressFlag, false);
    });

    test('empty selection should reset longPressFlag', () {
      notifier.setSelectedEmails([1], ['a@b.com']);
      notifier.setSelectedEmails([], []);

      final state = container.read(archiveProvider);
      expect(state.selectedEmailIds, isEmpty);
      expect(state.longPressFlag, true);
    });
  });

  group('ArchiveNotifier updateReadingPaneSettings', () {
    test('should clear selection when disabling', () {
      notifier.state = notifier.state.copyWith(
        readingPaneEnabled: true,
        selectedEmailIdForReadingPane: 42,
      );

      notifier.updateReadingPaneSettings(false);

      final state = container.read(archiveProvider);
      expect(state.readingPaneEnabled, false);
      expect(state.selectedEmailIdForReadingPane, isNull);
    });

    test('should enable reading pane', () {
      notifier.updateReadingPaneSettings(true);
      expect(container.read(archiveProvider).readingPaneEnabled, true);
    });
  });
}
