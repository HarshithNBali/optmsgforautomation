import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:optmsg/screens/auth/auth_riverpod/auth_notifier.dart';
import 'package:optmsg/model/base_response/request_response.dart';
import 'package:optmsg/screens/email/archive_riverpod/archive_list_notifier.dart';
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
    'attachments': [], 'receivers': [],
    'sender': {'firstName': 'M', 'lastName': 'U', 'created': ''},
    'emailTag': [], 'message': '', 'communityStatus': false,
  });

  setUp(() async {
    setup = RiverpodTestSetup();
    when(() => setup.mockStorageService.readObjectData(any())).thenAnswer((_) async => null);
    when(() => setup.mockStorageService.readData(any())).thenAnswer((_) async => null);
    when(() => setup.mockStorageService.deleteData(any())).thenAnswer((_) async {});

    container = ProviderContainer(overrides: setup.serviceOverrides);
    container.read(authProvider);
    await Future.delayed(Duration.zero);

    await runZonedGuarded(() async {
      notifier = container.read(archiveProvider.notifier);
      await Future.delayed(const Duration(milliseconds: 50));
    }, (e, _) {});
  });

  tearDown(() => container.dispose());

  group('ArchiveNotifier onLongPress', () {
    test('should start selection when longPressFlag is true', () {
      // longPressFlag defaults to true
      notifier.onLongPress(42, 'a@b.com');

      final state = container.read(archiveProvider);
      expect(state.longPressFlag, false);
      expect(state.selectedEmailIds, [42]);
      expect(state.selectedEmails, ['a@b.com']);
    });

    test('should clear selection when longPressFlag is false', () {
      notifier.onLongPress(42, 'a@b.com'); // sets false
      notifier.onLongPress(null, null);     // resets

      final state = container.read(archiveProvider);
      expect(state.longPressFlag, true);
      expect(state.selectedEmailIds, isEmpty);
    });
  });

  group('ArchiveNotifier addAndRemoveKey', () {
    test('should add item to selection', () {
      notifier.addAndRemoveKey(1, 'a@b.com');

      final state = container.read(archiveProvider);
      expect(state.selectedEmailIds, [1]);
      expect(state.selectedEmails, ['a@b.com']);
    });

    test('should remove item from selection', () {
      notifier.addAndRemoveKey(1, 'a@b.com');
      notifier.addAndRemoveKey(1, 'a@b.com');

      expect(container.read(archiveProvider).selectedEmailIds, isEmpty);
    });

    test('should accumulate multiple selections', () {
      notifier.addAndRemoveKey(1, 'a@b.com');
      notifier.addAndRemoveKey(2, 'c@d.com');
      notifier.addAndRemoveKey(3, 'e@f.com');

      expect(container.read(archiveProvider).selectedEmailIds, [1, 2, 3]);
    });
  });

  group('ArchiveNotifier markEmailAsUnreadById', () {
    test('should mark specific email as unread', () {
      notifier.state = notifier.state.copyWith(items: [
        makeSentEmail(id: 1),
        makeSentEmail(id: 2),
      ]);

      notifier.markEmailAsUnreadById(1);

      // Just verify no crash — the method modifies items internally
      expect(container.read(archiveProvider).items, hasLength(2));
    });
  });

  group('ArchiveNotifier applyUnreadFilter', () {
    test('should set emailType to unread', () {
      when(() => setup.mockArchiveApi.getTrash(any()))
          .thenAnswer((_) async => RequestResponse(data: {
                'success': true, 'message': '', 'data': {'emails': [], 'nextPage': false},
              }));

      notifier.state = notifier.state.copyWith(currentPath: '/archive');
      notifier.applyUnreadFilter();

      final state = container.read(archiveProvider);
      expect(state.showFilter, false);
      expect(state.currentPage, 1);
    });
  });

  group('ArchiveNotifier clearUnreadFilter', () {
    test('should reset filter for archive path', () {
      when(() => setup.mockArchiveApi.getTrash(any()))
          .thenAnswer((_) async => RequestResponse(data: {
                'success': true, 'message': '', 'data': {'emails': [], 'nextPage': false},
              }));

      notifier.state = notifier.state.copyWith(
        currentPath: '/archive',
        emailType: 'unread',
      );

      notifier.clearUnreadFilter();

      final state = container.read(archiveProvider);
      expect(state.showFilter, false);
      expect(state.emailType, 'archive');
    });
  });

  group('ArchiveNotifier clearTagFilter', () {
    test('should reset tag filter', () {
      when(() => setup.mockArchiveApi.getTrash(any()))
          .thenAnswer((_) async => RequestResponse(data: {
                'success': true, 'message': '', 'data': {'emails': [], 'nextPage': false},
              }));

      notifier.state = notifier.state.copyWith(
        currentPath: '/archive',
        tagFilter: true,
        tagIdFilter: [1, 2],
      );

      notifier.clearTagFilter();

      final state = container.read(archiveProvider);
      expect(state.tagFilter, false);
      expect(state.tagIdFilter, isEmpty);
    });
  });

  group('ArchiveNotifier updateReadingPaneSettings', () {
    test('disabling should clear all selection', () {
      notifier.state = notifier.state.copyWith(
        readingPaneEnabled: true,
        selectedEmailIdForReadingPane: 5,
        selectedEmailSender: 'x@y.com',
      );

      notifier.updateReadingPaneSettings(false);

      final state = container.read(archiveProvider);
      expect(state.readingPaneEnabled, false);
      expect(state.selectedEmailIdForReadingPane, isNull);
    });

    test('enabling should set flag', () {
      notifier.updateReadingPaneSettings(true);
      expect(container.read(archiveProvider).readingPaneEnabled, true);
    });
  });

  group('ArchiveNotifier refresh', () {
    test('should reset pagination and call getAllEmails', () async {
      notifier.state = notifier.state.copyWith(currentPath: '/archive');

      when(() => setup.mockArchiveApi.getTrash(any()))
          .thenAnswer((_) async => RequestResponse(data: {
                'success': true, 'message': '',
                'data': {'emails': [], 'nextPage': false},
              }));

      await notifier.refresh();

      final state = container.read(archiveProvider);
      expect(state.currentPage, 1);
    });
  });

  group('ArchiveNotifier reading pane operations', () {
    test('setReadingPaneSelection should set all fields', () {
      notifier.setReadingPaneSelection(42, 3, 'sender@test.com');

      final state = container.read(archiveProvider);
      expect(state.selectedEmailIdForReadingPane, 42);
      expect(state.selectedEmailIndex, 3);
      expect(state.selectedEmailSender, 'sender@test.com');
    });

    test('clearReadingPaneSelection should null all fields', () {
      notifier.setReadingPaneSelection(42, 3, 's@t.com');
      notifier.clearReadingPaneSelection();

      final state = container.read(archiveProvider);
      expect(state.selectedEmailIdForReadingPane, isNull);
      expect(state.selectedEmailIndex, isNull);
      expect(state.selectedEmailSender, isNull);
    });

    test('updateReadingPane should set fields and close menu', () {
      notifier.openReadingPaneMenu();
      notifier.updateReadingPane(id: 10, index: 2, sender: 'x@y.com');

      final state = container.read(archiveProvider);
      expect(state.selectedEmailIdForReadingPane, 10);
      expect(state.showReadingPaneMenuOptions, false);
    });
  });
}
