// Implements: TC-DISC-REPO-017..028
// Source: lib/repositories/inbox/email_detail_repository.dart
// Coverage target: 95%+ (critical — API layer)
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:optmsg/repositories/inbox/email_detail_repository.dart';
import 'package:optmsg/services/api_service.dart';

import '../../mocks/mock_services.dart';
import '../../factories/test_data_factories.dart';

void main() {
  late MockApiService mockApiService;
  late EmailDetailRepository repository;

  setUp(() {
    mockApiService = MockApiService();
    repository = EmailDetailRepository(apiService: mockApiService);
  });

  group('EmailDetailRepository', () {
    // -----------------------------------------------------------------------
    // fetchEmailDetail
    // -----------------------------------------------------------------------
    group('fetchEmailDetail', () {
      test('should return success with ViewEmailModel when API succeeds',
          () async {
        // TC-DISC-REPO-017
        final responseJson = {
          'success': true,
          'message': 'Email fetched',
          'data': {
            'id': 1,
            'emailId': 100,
            'receiverId': 1,
            'isRead': true,
            'email': makeEmailJson(id: 100),
            'emailRecipientTags': [],
          },
        };

        when(() => mockApiService.post(any(), any()))
            .thenAnswer((_) async => responseJson);

        final result = await repository.fetchEmailDetail(emailId: 100);

        expect(result.isSuccess, isTrue);
        expect(result.data, isNotNull);
        verify(() => mockApiService.post('email/view-email', {'emailId': 100}))
            .called(1);
      });

      test('should return failure when API returns success false', () async {
        when(() => mockApiService.post(any(), any())).thenAnswer(
            (_) async => {'success': false, 'message': 'Email not found'});

        final result = await repository.fetchEmailDetail(emailId: 999);

        expect(result.isFailure, isTrue);
        expect(result.error, 'Email not found');
      });

      test('should return fallback message when message is null', () async {
        when(() => mockApiService.post(any(), any()))
            .thenAnswer((_) async => {'success': false});

        final result = await repository.fetchEmailDetail(emailId: 1);

        expect(result.isFailure, isTrue);
        expect(result.error, 'Failed to load email');
      });

      test('should return failure on NoInternetException', () async {
        when(() => mockApiService.post(any(), any()))
            .thenThrow(NoInternetException('No internet'));

        final result = await repository.fetchEmailDetail(emailId: 1);

        expect(result.isFailure, isTrue);
        expect(result.error, 'No internet');
      });

      test('should return failure on generic exception', () async {
        when(() => mockApiService.post(any(), any()))
            .thenThrow(Exception('Parse error'));

        final result = await repository.fetchEmailDetail(emailId: 1);

        expect(result.isFailure, isTrue);
        expect(result.error, 'Something went wrong while loading email');
      });
    });

    // -----------------------------------------------------------------------
    // updateEmailStatus
    // -----------------------------------------------------------------------
    group('updateEmailStatus', () {
      test('should return success when API returns success true', () async {
        // TC-DISC-REPO-018
        when(() => mockApiService.post(any(), any())).thenAnswer(
            (_) async => makeSuccessResponse(message: 'Status updated'));

        final result = await repository.updateEmailStatus(
          key: 'isRead',
          emailIds: [1, 2],
          value: true,
        );

        expect(result.isSuccess, isTrue);
        verify(() => mockApiService.post('email/update-email-status', {
              'key': 'isRead',
              'emailIds': [1, 2],
              'value': true,
            })).called(1);
      });

      test('should return failure when API returns success false', () async {
        when(() => mockApiService.post(any(), any())).thenAnswer(
            (_) async =>
                makeErrorResponse(message: 'Invalid email IDs'));

        final result = await repository.updateEmailStatus(
          key: 'isRead',
          emailIds: [999],
          value: false,
        );

        expect(result.isFailure, isTrue);
        expect(result.error, 'Invalid email IDs');
      });

      test('should return fallback message when message is null', () async {
        when(() => mockApiService.post(any(), any()))
            .thenAnswer((_) async => {'success': false});

        final result = await repository.updateEmailStatus(
          key: 'isArchive',
          emailIds: [1],
          value: true,
        );

        expect(result.isFailure, isTrue);
        expect(result.error, 'Failed to update email status');
      });

      test('should return failure on NoInternetException', () async {
        when(() => mockApiService.post(any(), any()))
            .thenThrow(NoInternetException('Offline'));

        final result = await repository.updateEmailStatus(
          key: 'isRead',
          emailIds: [1],
          value: true,
        );

        expect(result.isFailure, isTrue);
        expect(result.error, 'Offline');
      });

      test('should return failure on generic exception', () async {
        when(() => mockApiService.post(any(), any()))
            .thenThrow(Exception('Crash'));

        final result = await repository.updateEmailStatus(
          key: 'isRead',
          emailIds: [1],
          value: true,
        );

        expect(result.isFailure, isTrue);
        expect(result.error, 'Something went wrong while updating email');
      });
    });

    // -----------------------------------------------------------------------
    // manageEmailTags
    // -----------------------------------------------------------------------
    group('manageEmailTags', () {
      test('should return success when API returns success true', () async {
        // TC-DISC-REPO-019
        when(() => mockApiService.post(any(), any())).thenAnswer(
            (_) async => makeSuccessResponse(message: 'Tags updated'));

        final result = await repository.manageEmailTags(
          emailIds: [1],
          tagIds: [10, 20],
          type: 'add',
        );

        expect(result.isSuccess, isTrue);
        verify(() => mockApiService.post('email/emails-tags', {
              'emailIds': [1],
              'tagsId': [10, 20],
              'type': 'add',
            })).called(1);
      });

      test('should return failure when API returns success false', () async {
        when(() => mockApiService.post(any(), any()))
            .thenAnswer((_) async => makeErrorResponse(message: 'Tag error'));

        final result = await repository.manageEmailTags(
          emailIds: [1],
          tagIds: [10],
          type: 'delete',
        );

        expect(result.isFailure, isTrue);
        expect(result.error, 'Tag error');
      });

      test('should return failure on NoInternetException', () async {
        when(() => mockApiService.post(any(), any()))
            .thenThrow(NoInternetException('No net'));

        final result = await repository.manageEmailTags(
          emailIds: [1],
          tagIds: [10],
          type: 'add',
        );

        expect(result.isFailure, isTrue);
        expect(result.error, 'No net');
      });

      test('should return failure on generic exception', () async {
        when(() => mockApiService.post(any(), any()))
            .thenThrow(Exception('Error'));

        final result = await repository.manageEmailTags(
          emailIds: [1],
          tagIds: [10],
          type: 'add',
        );

        expect(result.isFailure, isTrue);
        expect(result.error, 'Something went wrong while managing tags');
      });
    });

    // -----------------------------------------------------------------------
    // permanentlyDeleteEmail
    // -----------------------------------------------------------------------
    group('permanentlyDeleteEmail', () {
      test('should return success when API returns success true', () async {
        // TC-DISC-REPO-020
        when(() => mockApiService.post(any(), any())).thenAnswer(
            (_) async => makeSuccessResponse(message: 'Deleted'));

        final result = await repository.permanentlyDeleteEmail(emailId: 42);

        expect(result.isSuccess, isTrue);
        verify(() => mockApiService.post('email/delete-email', {
              'emailIds': [42],
            })).called(1);
      });

      test('should return failure when API returns success false', () async {
        when(() => mockApiService.post(any(), any()))
            .thenAnswer((_) async => makeErrorResponse(message: 'Not found'));

        final result = await repository.permanentlyDeleteEmail(emailId: 99);

        expect(result.isFailure, isTrue);
        expect(result.error, 'Not found');
      });

      test('should return failure on NoInternetException', () async {
        when(() => mockApiService.post(any(), any()))
            .thenThrow(NoInternetException('Disconnected'));

        final result = await repository.permanentlyDeleteEmail(emailId: 1);

        expect(result.isFailure, isTrue);
        expect(result.error, 'Disconnected');
      });

      test('should return failure on generic exception', () async {
        when(() => mockApiService.post(any(), any()))
            .thenThrow(Exception('Boom'));

        final result = await repository.permanentlyDeleteEmail(emailId: 1);

        expect(result.isFailure, isTrue);
        expect(result.error, 'Something went wrong while deleting email');
      });
    });
  });
}
