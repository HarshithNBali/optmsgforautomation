import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:optmsg/model/base_response/request_response.dart';
import 'package:optmsg/screens/auth/auth_riverpod/auth_notifier.dart';
import 'package:optmsg/screens/email/archive_riverpod/archive_list_notifier.dart';
import 'package:optmsg/router/app_routes.dart';

import '../../helpers/riverpod_test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late RiverpodTestSetup setup;
  late ProviderContainer container;
  late ArchiveNotifier notifier;

  Map<String, dynamic> makeSentResponse({
    List<Map<String, dynamic>>? emails,
    bool nextPage = false,
  }) => {
    'success': true, 'message': '',
    'data': {
      'emails': emails ?? [
        {
          'id': 1, 'senderId': 1, 'senderEmail': 'me@test.com',
          'senderName': 'Me', 'subject': 'Email', 'messageText': 'Body',
          'created': '2024-06-15T10:30:00.000Z', 'attachments': [],
          'receivers': [], 'sender': {'firstName': 'Me', 'lastName': 'User', 'created': '2024-01-01'},
          'emailTag': [], 'message': '<p>Body</p>', 'communityStatus': false,
        },
      ],
      'nextPage': nextPage,
    },
  };

  setUp(() async {
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

  group('ArchiveNotifier getAllEmails (archive path)', () {
    test('should populate items on successful response', () async {
      notifier.state = notifier.state.copyWith(currentPath: AppRoutes.archive);

      when(() => setup.mockArchiveApi.getTrash(any()))
          .thenAnswer((_) async => RequestResponse(data: makeSentResponse()));

      await notifier.getAllEmails('');

      final state = container.read(archiveProvider);
      expect(state.items, hasLength(1));
      expect(state.isLoading, false);
      expect(state.isFetching, false);
    });

    test('should handle unsuccessful API response', () async {
      notifier.state = notifier.state.copyWith(currentPath: AppRoutes.archive);

      when(() => setup.mockArchiveApi.getTrash(any()))
          .thenAnswer((_) async => RequestResponse(
              data: {'success': false, 'message': 'Server error'}));

      await notifier.getAllEmails('');

      final state = container.read(archiveProvider);
      expect(state.isLoading, false);
      expect(state.isFetching, false);
    });
  });

  group('ArchiveNotifier getAllEmails (sent path)', () {
    test('should call getSentMails for sent path', () async {
      notifier.state = notifier.state.copyWith(currentPath: AppRoutes.sent);

      when(() => setup.mockArchiveApi.getSentMails(any()))
          .thenAnswer((_) async => RequestResponse(data: makeSentResponse()));

      await notifier.getAllEmails('');

      verify(() => setup.mockArchiveApi.getSentMails(any())).called(1);
      verifyNever(() => setup.mockArchiveApi.getTrash(any()));
    });
  });

  group('ArchiveNotifier getAllEmails (trash path)', () {
    test('should call getTrash for trash path', () async {
      notifier.state = notifier.state.copyWith(currentPath: AppRoutes.trash);

      when(() => setup.mockArchiveApi.getTrash(any()))
          .thenAnswer((_) async => RequestResponse(data: makeSentResponse()));

      await notifier.getAllEmails('');

      verify(() => setup.mockArchiveApi.getTrash(any())).called(1);
      verifyNever(() => setup.mockArchiveApi.getSentMails(any()));
    });
  });

  group('ArchiveNotifier getAllEmails pagination', () {
    test('should increment currentPage when nextPage is true', () async {
      notifier.state = notifier.state.copyWith(currentPath: AppRoutes.archive);

      when(() => setup.mockArchiveApi.getTrash(any()))
          .thenAnswer((_) async => RequestResponse(
              data: makeSentResponse(nextPage: true)));

      await notifier.getAllEmails('');

      expect(container.read(archiveProvider).currentPage, 2);
    });

    test('should prevent concurrent fetches', () async {
      notifier.state = notifier.state.copyWith(currentPath: AppRoutes.archive);
      int callCount = 0;

      when(() => setup.mockArchiveApi.getTrash(any()))
          .thenAnswer((_) async {
        callCount++;
        await Future.delayed(const Duration(milliseconds: 50));
        return RequestResponse(data: makeSentResponse());
      });

      final f1 = notifier.getAllEmails('');
      final f2 = notifier.getAllEmails('');
      await Future.wait([f1, f2]);

      expect(callCount, 1);
    });
  });
}
