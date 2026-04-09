// Implements: TC-DISC-DETAIL-ACT-001..015
// Source: lib/screens/email/inbox_riverpod/email_detail_notifier.dart (API action methods)
// Coverage target: Push from 64.5% to 80%+
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:optmsg/model/auth/auth_state.dart';
import 'package:optmsg/screens/auth/auth_riverpod/auth_notifier.dart';
import 'package:optmsg/screens/email/inbox_riverpod/email_detail_notifier.dart';
import 'package:optmsg/screens/email/inbox_riverpod/email_detail_state.dart';

import '../../helpers/riverpod_test_helpers.dart';
import '../../factories/test_data_factories.dart';

class _FakeAuthNotifier extends AuthNotifier {
  final Map<String, dynamic>? _data;
  _FakeAuthNotifier(this._data);
  @override
  AuthState build() =>
      _data != null ? AuthState.authenticated(_data) : AuthState.unauthenticated();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late RiverpodTestSetup setup;
  late ProviderContainer container;
  late ProviderSubscription<EmailDetailState> sub;

  setUp(() async {
    setup = RiverpodTestSetup();
    when(() => setup.mockStorageService.readData(any()))
        .thenAnswer((_) async => null);
    when(() => setup.mockStorageService.readObjectData(any()))
        .thenAnswer((_) async => null);

    // Default API stub for _init → loadEmailDetail
    when(() => setup.mockApiService.post(any(), any()))
        .thenAnswer((_) async => {'success': false, 'message': 'Test env'});
    // Stub socket operations
    when(() => setup.mockSocketService.emitEventWithAck(
          any(),
          any(),
          ackCallback: any(named: 'ackCallback'),
        )).thenReturn(null);
    when(() => setup.mockSocketService.onEvent(any()))
        .thenAnswer((_) => const Stream.empty());

    container = ProviderContainer(
      overrides: [
        ...setup.serviceOverrides,
        authProvider.overrideWith(() => _FakeAuthNotifier({
              'user': {'id': 1, 'name': 'Test'},
              'token': 'test-token',
            })),
      ],
    );
    await Future.delayed(Duration.zero);

    sub = container.listen(emailDetailProvider(99), (_, _) {});
    await Future.delayed(const Duration(milliseconds: 200));
  });

  tearDown(() {
    sub.close();
    container.dispose();
  });

  group('EmailDetailNotifier API actions', () {
    // -----------------------------------------------------------------------
    // markAsUnread
    // -----------------------------------------------------------------------
    group('markAsUnread', () {
      test('should set markedAsUnread on success', () async {
        // TC-DISC-DETAIL-ACT-001
        when(() => setup.mockApiService.post(any(), any()))
            .thenAnswer((_) async => makeSuccessResponse());

        final notifier = container.read(emailDetailProvider(99).notifier);
        await notifier.markAsUnread();

        final state = container.read(emailDetailProvider(99));
        expect(state.markedAsUnread, isTrue);
      });

      test('should not set markedAsUnread on failure', () async {
        // TC-DISC-DETAIL-ACT-002
        when(() => setup.mockApiService.post(any(), any()))
            .thenAnswer((_) async => makeErrorResponse(message: 'Failed'));

        final notifier = container.read(emailDetailProvider(99).notifier);
        await notifier.markAsUnread();

        final state = container.read(emailDetailProvider(99));
        expect(state.markedAsUnread, isFalse);
      });

      test('should handle exception gracefully', () async {
        // TC-DISC-DETAIL-ACT-003
        when(() => setup.mockApiService.post(any(), any()))
            .thenThrow(Exception('Network error'));

        final notifier = container.read(emailDetailProvider(99).notifier);
        await notifier.markAsUnread();
        // Should not throw
      });
    });

    // -----------------------------------------------------------------------
    // moveToArchive
    // -----------------------------------------------------------------------
    group('moveToArchive', () {
      test('should set movedToArchive on success', () async {
        // TC-DISC-DETAIL-ACT-004
        when(() => setup.mockApiService.post(any(), any()))
            .thenAnswer((_) async => makeSuccessResponse());

        final notifier = container.read(emailDetailProvider(99).notifier);
        await notifier.moveToArchive();

        expect(container.read(emailDetailProvider(99)).movedToArchive, isTrue);
      });

      test('should not set movedToArchive on failure', () async {
        // TC-DISC-DETAIL-ACT-005
        when(() => setup.mockApiService.post(any(), any()))
            .thenAnswer((_) async => makeErrorResponse(message: 'Failed'));

        final notifier = container.read(emailDetailProvider(99).notifier);
        await notifier.moveToArchive();

        expect(container.read(emailDetailProvider(99)).movedToArchive, isFalse);
      });

      test('should handle exception gracefully', () async {
        when(() => setup.mockApiService.post(any(), any()))
            .thenThrow(Exception('Error'));

        final notifier = container.read(emailDetailProvider(99).notifier);
        await notifier.moveToArchive();
      });
    });

    // -----------------------------------------------------------------------
    // moveToTrash
    // -----------------------------------------------------------------------
    group('moveToTrash', () {
      test('should set movedToTrash on success', () async {
        // TC-DISC-DETAIL-ACT-006
        when(() => setup.mockApiService.post(any(), any()))
            .thenAnswer((_) async => makeSuccessResponse());

        final notifier = container.read(emailDetailProvider(99).notifier);
        await notifier.moveToTrash();

        expect(container.read(emailDetailProvider(99)).movedToTrash, isTrue);
      });

      test('should not set movedToTrash on failure', () async {
        // TC-DISC-DETAIL-ACT-007
        when(() => setup.mockApiService.post(any(), any()))
            .thenAnswer((_) async => makeErrorResponse(message: 'Failed'));

        final notifier = container.read(emailDetailProvider(99).notifier);
        await notifier.moveToTrash();

        expect(container.read(emailDetailProvider(99)).movedToTrash, isFalse);
      });
    });

    // -----------------------------------------------------------------------
    // addTags
    // -----------------------------------------------------------------------
    group('addTags', () {
      test('should call API with correct params', () async {
        // TC-DISC-DETAIL-ACT-008
        when(() => setup.mockApiService.post(any(), any()))
            .thenAnswer((_) async => {
                  'success': true,
                  'message': 'Tags updated',
                  'data': {
                    'emailRecipientTags': [],
                    'emailTags': [],
                  },
                });

        final notifier = container.read(emailDetailProvider(99).notifier);
        await notifier.addTags([1, 2, 3]);

        verify(() => setup.mockApiService.post('email/emails-tags', {
              'emailIds': [99],
              'tagsId': [1, 2, 3],
              'type': 'add',
            })).called(1);
      });

      test('should handle failure gracefully', () async {
        // TC-DISC-DETAIL-ACT-009
        when(() => setup.mockApiService.post(any(), any()))
            .thenAnswer((_) async => makeErrorResponse(message: 'Tag error'));

        final notifier = container.read(emailDetailProvider(99).notifier);
        await notifier.addTags([1]);
        // Should not throw
      });
    });

    // -----------------------------------------------------------------------
    // removeTags
    // -----------------------------------------------------------------------
    group('removeTags', () {
      test('should call API with delete type', () async {
        // TC-DISC-DETAIL-ACT-010
        when(() => setup.mockApiService.post(any(), any()))
            .thenAnswer((_) async => {
                  'success': true,
                  'message': 'Tags removed',
                  'data': {
                    'emailRecipientTags': [],
                    'emailTags': [],
                  },
                });

        final notifier = container.read(emailDetailProvider(99).notifier);
        await notifier.removeTags([5]);

        verify(() => setup.mockApiService.post('email/emails-tags', {
              'emailIds': [99],
              'tagsId': [5],
              'type': 'delete',
            })).called(1);
      });
    });

    // -----------------------------------------------------------------------
    // loadEmailDetail success path
    // -----------------------------------------------------------------------
    group('loadEmailDetail', () {
      test('should populate state on success with email data', () async {
        // TC-DISC-DETAIL-ACT-011
        final emailJson = {
          'success': true,
          'message': 'OK',
          'data': {
            'url': 'https://api.test.com/email/view/99',
            'email': {
              'id': 99,
              'senderEmail': 'sender@test.com',
              'subject': 'Test Subject',
              'message': '<p>Hello</p>',
              'messageText': 'Hello',
              'senderId': 2,
              'isArchive': false,
              'isTrash': false,
              'isDeleted': false,
              'created': '2024-06-15T10:30:00.000Z',
              'updated': '2024-06-15T10:30:00.000Z',
              'attachments': [],
              'sender': {'id': 2, 'firstName': 'Test', 'lastName': 'Sender'},
              'receivers': [
                {
                  'id': 1,
                  'emailId': 99,
                  'receiverEmail': 'me@test.com',
                  'type': 'to',
                  'isRead': true,
                  'isTrash': false,
                  'isArchive': false,
                  'isDeleted': false,
                  'receiver': {'id': 1, 'firstName': 'Me', 'lastName': 'User'},
                  'emailRecipientTags': [],
                },
              ],
              'emailTag': [],
            },
          },
        };

        when(() => setup.mockApiService.post(any(), any()))
            .thenAnswer((_) async => emailJson);

        final notifier = container.read(emailDetailProvider(99).notifier);
        await notifier.loadEmailDetail();
        await Future.delayed(const Duration(milliseconds: 100));

        final state = container.read(emailDetailProvider(99));
        expect(state.emailData, isNotNull);
        expect(state.error, isNull);
      });

      test('should handle error response', () async {
        // TC-DISC-DETAIL-ACT-012
        when(() => setup.mockApiService.post(any(), any()))
            .thenAnswer((_) async => makeErrorResponse(message: 'Not found'));

        final notifier = container.read(emailDetailProvider(99).notifier);
        await notifier.loadEmailDetail();

        final state = container.read(emailDetailProvider(99));
        expect(state.isLoading, isFalse);
      });
    });
  });
}
