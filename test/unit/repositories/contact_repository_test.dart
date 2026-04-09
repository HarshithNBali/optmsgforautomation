// Implements: TC-DISC-REPO-001..008
// Source: lib/repositories/contact/contact_repository.dart
// Coverage target: 95%+ (critical — API layer)
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:optmsg/model/base_response/request_response.dart';
import 'package:optmsg/model/contact_list_model.dart';
import 'package:optmsg/repositories/contact/contact_repository.dart';
import 'package:optmsg/services/api_service.dart';

import '../../mocks/mock_repositories.dart';

void main() {
  late MockContactApi mockContactApi;
  late ContactRepository repository;

  setUp(() {
    mockContactApi = MockContactApi();
    repository = ContactRepository(contactApi: mockContactApi);
  });

  group('ContactRepository', () {
    // -----------------------------------------------------------------------
    // fetchContacts
    // -----------------------------------------------------------------------
    group('fetchContacts', () {
      test('should return success with ContactListModel when API returns data',
          () async {
        // TC-DISC-REPO-001
        final contactListModel = ContactListModel.fromJson({
          'success': true,
          'message': 'Contacts fetched',
          'data': {'contacts': [], 'nextPage': false},
        });

        when(() => mockContactApi.getContactList(any()))
            .thenAnswer((_) async => RequestResponse(data: contactListModel));

        final result =
            await repository.fetchContacts(page: 1, limit: 20);

        expect(result.isSuccess, isTrue);
        expect(result.data, isNotNull);
        expect(result.data!.success, isTrue);
        verify(() => mockContactApi.getContactList({
              'page': 1,
              'limit': 20,
              'search': '',
            })).called(1);
      });

      test('should pass search parameter when provided', () async {
        // TC-DISC-REPO-002
        final contactListModel = ContactListModel.fromJson({
          'success': true,
          'message': '',
          'data': {'contacts': [], 'nextPage': false},
        });

        when(() => mockContactApi.getContactList(any()))
            .thenAnswer((_) async => RequestResponse(data: contactListModel));

        await repository.fetchContacts(page: 1, limit: 10, search: 'john');

        verify(() => mockContactApi.getContactList({
              'page': 1,
              'limit': 10,
              'search': 'john',
            })).called(1);
      });

      test('should return failure when API returns unsuccessful response',
          () async {
        final contactListModel = ContactListModel.fromJson({
          'success': false,
          'message': 'Unauthorized',
          'data': {'contacts': [], 'nextPage': false},
        });

        when(() => mockContactApi.getContactList(any()))
            .thenAnswer((_) async => RequestResponse(data: contactListModel));

        final result = await repository.fetchContacts(page: 1, limit: 20);

        expect(result.isFailure, isTrue);
        expect(result.error, 'Unauthorized');
      });

      test('should return failure when API returns null data', () async {
        when(() => mockContactApi.getContactList(any()))
            .thenAnswer((_) async => RequestResponse<ContactListModel>());

        final result = await repository.fetchContacts(page: 1, limit: 20);

        expect(result.isFailure, isTrue);
        expect(result.error, 'Failed to fetch contacts');
      });

      test('should return failure on NoInternetException', () async {
        when(() => mockContactApi.getContactList(any()))
            .thenThrow(NoInternetException('No internet connection'));

        final result = await repository.fetchContacts(page: 1, limit: 20);

        expect(result.isFailure, isTrue);
        expect(result.error, 'No internet connection');
      });

      test('should return failure on generic exception', () async {
        when(() => mockContactApi.getContactList(any()))
            .thenThrow(Exception('Unexpected'));

        final result = await repository.fetchContacts(page: 1, limit: 20);

        expect(result.isFailure, isTrue);
        expect(result.error,
            'Something went wrong while fetching contacts');
      });
    });

    // -----------------------------------------------------------------------
    // fetchContactDetails
    // -----------------------------------------------------------------------
    group('fetchContactDetails', () {
      test('should return success when API returns successful data', () async {
        // TC-DISC-REPO-003
        final responseData = {'success': true, 'data': {'id': 1}};
        when(() => mockContactApi.getContactDetails(any()))
            .thenAnswer((_) async => RequestResponse(data: responseData));

        final result = await repository.fetchContactDetails(contactId: 1);

        expect(result.isSuccess, isTrue);
        expect(result.data!['success'], isTrue);
        verify(() => mockContactApi.getContactDetails({'id': 1})).called(1);
      });

      test('should return failure when API response has success false',
          () async {
        when(() => mockContactApi.getContactDetails(any()))
            .thenAnswer((_) async =>
                RequestResponse(data: {'success': false}));

        final result = await repository.fetchContactDetails(contactId: 1);

        expect(result.isFailure, isTrue);
        expect(result.error, 'Failed to fetch contact details');
      });

      test('should return failure when API returns null data', () async {
        when(() => mockContactApi.getContactDetails(any())).thenAnswer(
            (_) async => RequestResponse<Map<String, dynamic>>());

        final result = await repository.fetchContactDetails(contactId: 1);

        expect(result.isFailure, isTrue);
        expect(result.error, 'Failed to fetch contact details');
      });

      test('should return failure on NoInternetException', () async {
        when(() => mockContactApi.getContactDetails(any()))
            .thenThrow(NoInternetException('Offline'));

        final result = await repository.fetchContactDetails(contactId: 1);

        expect(result.isFailure, isTrue);
        expect(result.error, 'Offline');
      });

      test('should return failure on generic exception', () async {
        when(() => mockContactApi.getContactDetails(any()))
            .thenThrow(Exception('Crash'));

        final result = await repository.fetchContactDetails(contactId: 1);

        expect(result.isFailure, isTrue);
        expect(result.error,
            'Something went wrong while fetching contact details');
      });
    });

    // -----------------------------------------------------------------------
    // deleteContact
    // -----------------------------------------------------------------------
    group('deleteContact', () {
      test('should return success when API returns success true', () async {
        // TC-DISC-REPO-004
        when(() => mockContactApi.contactDelete(any())).thenAnswer(
            (_) async => RequestResponse(
                data: {'success': true, 'message': 'Deleted'}));

        final result = await repository.deleteContact(contactId: 5);

        expect(result.isSuccess, isTrue);
        verify(() => mockContactApi.contactDelete({'id': 5})).called(1);
      });

      test('should return failure with message from API when success false',
          () async {
        when(() => mockContactApi.contactDelete(any())).thenAnswer(
            (_) async => RequestResponse(
                data: {'success': false, 'message': 'Not found'}));

        final result = await repository.deleteContact(contactId: 5);

        expect(result.isFailure, isTrue);
        expect(result.error, 'Not found');
      });

      test('should return fallback message when API message is null',
          () async {
        when(() => mockContactApi.contactDelete(any())).thenAnswer(
            (_) async => RequestResponse(data: {'success': false}));

        final result = await repository.deleteContact(contactId: 5);

        expect(result.isFailure, isTrue);
        expect(result.error, 'Failed to delete contact');
      });

      test('should return failure when data is null', () async {
        when(() => mockContactApi.contactDelete(any())).thenAnswer(
            (_) async => RequestResponse<Map<String, dynamic>>());

        final result = await repository.deleteContact(contactId: 5);

        expect(result.isFailure, isTrue);
        expect(result.error, 'Failed to delete contact');
      });

      test('should return failure on NoInternetException', () async {
        when(() => mockContactApi.contactDelete(any()))
            .thenThrow(NoInternetException('No connection'));

        final result = await repository.deleteContact(contactId: 5);

        expect(result.isFailure, isTrue);
        expect(result.error, 'No connection');
      });

      test('should return failure on generic exception', () async {
        when(() => mockContactApi.contactDelete(any()))
            .thenThrow(Exception('Error'));

        final result = await repository.deleteContact(contactId: 5);

        expect(result.isFailure, isTrue);
        expect(result.error,
            'Something went wrong while deleting contact');
      });
    });

    // -----------------------------------------------------------------------
    // addDeleteEmail
    // -----------------------------------------------------------------------
    group('addDeleteEmail', () {
      test('should return success when API returns success', () async {
        // TC-DISC-REPO-005
        when(() => mockContactApi.addDeleteEmail(any())).thenAnswer(
            (_) async =>
                RequestResponse(data: {'success': true, 'message': 'Done'}));

        final result = await repository.addDeleteEmail(
          email: 'test@example.com',
          contactId: 1,
          type: 'add',
        );

        expect(result.isSuccess, isTrue);
        verify(() => mockContactApi.addDeleteEmail({
              'email': 'test@example.com',
              'contactId': 1,
              'type': 'add',
            })).called(1);
      });

      test('should return failure with message when success false', () async {
        when(() => mockContactApi.addDeleteEmail(any())).thenAnswer(
            (_) async => RequestResponse(
                data: {'success': false, 'message': 'Duplicate email'}));

        final result = await repository.addDeleteEmail(
          email: 'test@example.com',
          contactId: 1,
          type: 'add',
        );

        expect(result.isFailure, isTrue);
        expect(result.error, 'Duplicate email');
      });

      test('should return fallback message when API message is null',
          () async {
        when(() => mockContactApi.addDeleteEmail(any())).thenAnswer(
            (_) async => RequestResponse(data: {'success': false}));

        final result = await repository.addDeleteEmail(
          email: 'test@example.com',
          contactId: 1,
          type: 'delete',
        );

        expect(result.isFailure, isTrue);
        expect(result.error, 'Failed to process email');
      });

      test('should return failure on NoInternetException', () async {
        when(() => mockContactApi.addDeleteEmail(any()))
            .thenThrow(NoInternetException('Offline'));

        final result = await repository.addDeleteEmail(
          email: 'x@y.com',
          contactId: 1,
          type: 'add',
        );

        expect(result.isFailure, isTrue);
        expect(result.error, 'Offline');
      });

      test('should return failure on generic exception', () async {
        when(() => mockContactApi.addDeleteEmail(any()))
            .thenThrow(Exception('Boom'));

        final result = await repository.addDeleteEmail(
          email: 'x@y.com',
          contactId: 1,
          type: 'add',
        );

        expect(result.isFailure, isTrue);
        expect(result.error,
            'Something went wrong while processing email');
      });
    });
  });
}
