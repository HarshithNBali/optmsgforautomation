import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:optmsg/model/base_response/request_response.dart';
import 'package:optmsg/screens/auth/auth_riverpod/auth_notifier.dart';
import 'package:optmsg/screens/email/draft_riverpod/draft_notifier.dart';

import '../../helpers/riverpod_test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late RiverpodTestSetup setup;
  late ProviderContainer container;
  late DraftNotifier notifier;

  setUp(() async {
    setup = RiverpodTestSetup();
    when(() => setup.mockStorageService.readObjectData(any()))
        .thenAnswer((_) async => null);
    when(() => setup.mockStorageService.readData(any()))
        .thenAnswer((_) async => null);

    container = ProviderContainer(overrides: setup.serviceOverrides);
    container.read(authProvider);
    await Future.delayed(Duration.zero);
    notifier = container.read(draftProvider.notifier);
  });

  tearDown(() => container.dispose());

  group('DraftNotifier getAllEmails', () {
    Map<String, dynamic> makeDraftResponseJson({
      List<Map<String, dynamic>>? emails,
      bool nextPage = false,
    }) => {
      'success': true,
      'message': 'OK',
      'data': {
        'emails': emails ?? [
          {
            'id': 1, 'senderId': 1, 'subject': 'Draft 1',
            'message': '<p>Body</p>', 'isDeleted': false,
            'created': '2024-01-01T00:00:00.000Z',
            'updated': '2024-01-01T00:00:00.000Z',
            'attachments': [],
          },
        ],
        'nextPage': nextPage,
      },
    };

    test('should populate items on successful response', () async {
      when(() => setup.mockDraftApi.getDraftEmail(any()))
          .thenAnswer((_) async => RequestResponse(
              data: makeDraftResponseJson()));

      await notifier.getAllEmails('');

      final state = container.read(draftProvider);
      expect(state.items, hasLength(1));
      expect(state.isLoading, false);
      expect(state.isFetching, false);
    });

    test('should increment currentPage when nextPage is true', () async {
      when(() => setup.mockDraftApi.getDraftEmail(any()))
          .thenAnswer((_) async => RequestResponse(
              data: makeDraftResponseJson(nextPage: true)));

      await notifier.getAllEmails('');

      expect(container.read(draftProvider).currentPage, 2);
    });

    test('should handle unsuccessful API response', () async {
      when(() => setup.mockDraftApi.getDraftEmail(any()))
          .thenAnswer((_) async => RequestResponse(
              data: {'success': false, 'message': 'Error'}));

      await notifier.getAllEmails('');

      final state = container.read(draftProvider);
      expect(state.isLoading, false);
      expect(state.isFetching, false);
    });

    test('should prevent concurrent fetches', () async {
      int callCount = 0;
      when(() => setup.mockDraftApi.getDraftEmail(any()))
          .thenAnswer((_) async {
        callCount++;
        await Future.delayed(const Duration(milliseconds: 50));
        return RequestResponse(data: makeDraftResponseJson());
      });

      final f1 = notifier.getAllEmails('');
      final f2 = notifier.getAllEmails('');
      await Future.wait([f1, f2]);

      expect(callCount, 1);
    });

    test('should clear selections after successful fetch', () async {
      notifier.toggleSelect(1, 'a@b.com');

      when(() => setup.mockDraftApi.getDraftEmail(any()))
          .thenAnswer((_) async => RequestResponse(
              data: makeDraftResponseJson()));

      await notifier.getAllEmails('');

      final state = container.read(draftProvider);
      expect(state.selectedEmailIds, isEmpty);
      expect(state.allEmailIdsFlag, false);
    });
  });
}
