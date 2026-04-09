// Implements: TC-DISC-REPO-009..016
// Source: lib/repositories/draft/draft_repository.dart
// Coverage target: 95%+ (critical — API layer)
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:optmsg/model/base_response/request_response.dart';
import 'package:optmsg/repositories/draft/draft_repository.dart';
import 'package:optmsg/services/api_service.dart';

import '../../mocks/mock_repositories.dart';

void main() {
  late MockDraftApi mockDraftApi;
  late DraftRepository repository;

  setUp(() {
    mockDraftApi = MockDraftApi();
    repository = DraftRepository(draftApi: mockDraftApi);
  });

  group('DraftRepository', () {
    // -----------------------------------------------------------------------
    // fetchDrafts
    // -----------------------------------------------------------------------
    group('fetchDrafts', () {
      final draftListJson = {
        'success': true,
        'message': '',
        'data': {
          'emails': [
            {
              'id': 1,
              'senderId': 1,
              'subject': 'Draft 1',
              'message': '<p>Hello</p>',
              'isDeleted': false,
              'created': '2024-06-15T10:30:00.000Z',
              'updated': '2024-06-15T10:30:00.000Z',
              'attachments': [],
            }
          ],
          'nextPage': false,
        },
      };

      test('should return success with DraftListModel when API returns data',
          () async {
        // TC-DISC-REPO-009
        when(() => mockDraftApi.getDraftEmail(any()))
            .thenAnswer((_) async => RequestResponse(data: draftListJson));

        final result = await repository.fetchDrafts(page: 1, limit: 20);

        expect(result.isSuccess, isTrue);
        expect(result.data, isNotNull);
        expect(result.data!.success, isTrue);
        verify(() => mockDraftApi.getDraftEmail({
              'page': 1,
              'limit': 20,
              'search': '',
            })).called(1);
      });

      test('should pass search parameter when provided', () async {
        // TC-DISC-REPO-010
        when(() => mockDraftApi.getDraftEmail(any()))
            .thenAnswer((_) async => RequestResponse(data: draftListJson));

        await repository.fetchDrafts(page: 1, limit: 10, search: 'hello');

        verify(() => mockDraftApi.getDraftEmail({
              'page': 1,
              'limit': 10,
              'search': 'hello',
            })).called(1);
      });

      test('should return failure when API returns unsuccessful response',
          () async {
        final failJson = {
          'success': false,
          'message': 'Unauthorized',
          'data': {'emails': [], 'nextPage': false},
        };
        when(() => mockDraftApi.getDraftEmail(any()))
            .thenAnswer((_) async => RequestResponse(data: failJson));

        final result = await repository.fetchDrafts(page: 1, limit: 20);

        expect(result.isFailure, isTrue);
        expect(result.error, 'Unauthorized');
      });

      test('should return failure when API returns null data', () async {
        when(() => mockDraftApi.getDraftEmail(any())).thenAnswer(
            (_) async => RequestResponse<Map<String, dynamic>>());

        final result = await repository.fetchDrafts(page: 1, limit: 20);

        expect(result.isFailure, isTrue);
        expect(result.error, 'Failed to fetch drafts');
      });

      test('should return failure on NoInternetException', () async {
        when(() => mockDraftApi.getDraftEmail(any()))
            .thenThrow(NoInternetException('No internet'));

        final result = await repository.fetchDrafts(page: 1, limit: 20);

        expect(result.isFailure, isTrue);
        expect(result.error, 'No internet');
      });

      test('should return failure on generic exception', () async {
        when(() => mockDraftApi.getDraftEmail(any()))
            .thenThrow(Exception('Unexpected'));

        final result = await repository.fetchDrafts(page: 1, limit: 20);

        expect(result.isFailure, isTrue);
        expect(result.error, 'Something went wrong while fetching drafts');
      });
    });

    // -----------------------------------------------------------------------
    // deleteDrafts
    // -----------------------------------------------------------------------
    group('deleteDrafts', () {
      test('should return success when API returns success true', () async {
        // TC-DISC-REPO-011
        when(() => mockDraftApi.deleteDraft(any())).thenAnswer((_) async =>
            RequestResponse(data: {'success': true, 'message': 'Deleted'}));

        final result = await repository.deleteDrafts(draftIds: [1, 2, 3]);

        expect(result.isSuccess, isTrue);
        verify(() => mockDraftApi.deleteDraft({'draftIds': [1, 2, 3]}))
            .called(1);
      });

      test('should return failure with message when success false', () async {
        when(() => mockDraftApi.deleteDraft(any())).thenAnswer((_) async =>
            RequestResponse(
                data: {'success': false, 'message': 'Draft not found'}));

        final result = await repository.deleteDrafts(draftIds: [99]);

        expect(result.isFailure, isTrue);
        expect(result.error, 'Draft not found');
      });

      test('should return fallback message when message is null', () async {
        when(() => mockDraftApi.deleteDraft(any())).thenAnswer(
            (_) async => RequestResponse(data: {'success': false}));

        final result = await repository.deleteDrafts(draftIds: [1]);

        expect(result.isFailure, isTrue);
        expect(result.error, 'Failed to delete drafts');
      });

      test('should return failure when data is null', () async {
        when(() => mockDraftApi.deleteDraft(any())).thenAnswer(
            (_) async => RequestResponse<Map<String, dynamic>>());

        final result = await repository.deleteDrafts(draftIds: [1]);

        expect(result.isFailure, isTrue);
        expect(result.error, 'Failed to delete drafts');
      });

      test('should return failure on NoInternetException', () async {
        when(() => mockDraftApi.deleteDraft(any()))
            .thenThrow(NoInternetException('Offline'));

        final result = await repository.deleteDrafts(draftIds: [1]);

        expect(result.isFailure, isTrue);
        expect(result.error, 'Offline');
      });

      test('should return failure on generic exception', () async {
        when(() => mockDraftApi.deleteDraft(any()))
            .thenThrow(Exception('Error'));

        final result = await repository.deleteDrafts(draftIds: [1]);

        expect(result.isFailure, isTrue);
        expect(result.error, 'Something went wrong while deleting drafts');
      });
    });
  });
}
