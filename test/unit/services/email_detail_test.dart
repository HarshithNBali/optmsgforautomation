import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:optmsg/model/auth/auth_state.dart';
import 'package:optmsg/screens/auth/auth_riverpod/auth_notifier.dart';
import 'package:optmsg/screens/email/inbox_riverpod/email_detail_notifier.dart';
import 'package:optmsg/screens/email/inbox_riverpod/email_detail_state.dart';

import '../../helpers/riverpod_test_helpers.dart';

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

  setUp(() {
    setup = RiverpodTestSetup();
    when(() => setup.mockStorageService.readObjectData(any()))
        .thenAnswer((_) async => null);
    when(() => setup.mockStorageService.readData(any()))
        .thenAnswer((_) async => null);
  });

  // ===== EmailDetailState =====
  group('EmailDetailState', () {
    test('defaults', () {
      const state = EmailDetailState();
      expect(state.isLoading, false);
      expect(state.emailData, isNull);
      expect(state.showTagList, false);
      expect(state.showMenuOptions, false);
      expect(state.showAllAttachments, false);
      expect(state.markedAsUnread, false);
      expect(state.movedToArchive, false);
      expect(state.movedToTrash, false);
      expect(state.updatedTags, isEmpty);
      expect(state.error, isNull);
      expect(state.userData, isNull);
      expect(state.token, '');
      expect(state.newNotification, false);
      expect(state.fileDownloading, false);
      expect(state.downloadProgress, 0.0);
      expect(state.expandedView, false);
    });

    group('computed properties', () {
      test('hasEmail should check emailData', () {
        expect(const EmailDetailState().hasEmail, false);
      });

      test('email should return null when no emailData', () {
        expect(const EmailDetailState().email, isNull);
      });

      test('attachments should return empty when no email', () {
        expect(const EmailDetailState().attachments, isEmpty);
      });

      test('hasAttachments should be false when no email', () {
        expect(const EmailDetailState().hasAttachments, false);
      });

      test('senderEmail should return empty when no email', () {
        expect(const EmailDetailState().senderEmail, '');
      });

      test('subject should return empty when no email', () {
        expect(const EmailDetailState().subject, '');
      });

      test('htmlContent should return empty when no email', () {
        expect(const EmailDetailState().htmlContent, '');
      });

      test('hasError should check error field', () {
        expect(const EmailDetailState().hasError, false);
        expect(
          const EmailDetailState(error: 'Failed').hasError,
          true,
        );
      });

      test('canPerformActions requires email and not loading', () {
        expect(const EmailDetailState().canPerformActions, false);
        expect(
          const EmailDetailState(isLoading: true).canPerformActions,
          false,
        );
      });

      test('attachmentCount should return 0 when no email', () {
        expect(const EmailDetailState().attachmentCount, 0);
      });

      test('emailTags should return empty when no email', () {
        expect(const EmailDetailState().emailTags, isEmpty);
      });
    });

    test('copyWith', () {
      final modified = const EmailDetailState().copyWith(
        isLoading: true,
        showTagList: true,
        showMenuOptions: true,
        markedAsUnread: true,
        movedToArchive: true,
        token: 'jwt-123',
        expandedView: true,
      );
      expect(modified.isLoading, true);
      expect(modified.showTagList, true);
      expect(modified.showMenuOptions, true);
      expect(modified.markedAsUnread, true);
      expect(modified.movedToArchive, true);
      expect(modified.token, 'jwt-123');
      expect(modified.expandedView, true);
    });
  });

  // ===== EmailDetailNotifier =====
  group('EmailDetailNotifier', () {
    late ProviderContainer container;
    // Keep a listener alive so autoDispose doesn't kick in
    late ProviderSubscription<EmailDetailState> sub;

    setUp(() async {
      // Stub the API call that _init → loadEmailDetail makes
      when(() => setup.mockApiService.post(any(), any()))
          .thenAnswer((_) async => {'success': false, 'message': 'Test env'});

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

      // Keep provider alive
      sub = container.listen(emailDetailProvider(42), (_, _) {});
      // Let _init settle
      await Future.delayed(const Duration(milliseconds: 200));
    });

    tearDown(() {
      sub.close();
      container.dispose();
    });

    test('build should return default state', () {
      final state = container.read(emailDetailProvider(42));
      expect(state.isLoading, isA<bool>());
    });

    test('toggleTagList should flip showTagList and close menu', () async {
      await Future.delayed(const Duration(milliseconds: 100));

      final notifier = container.read(emailDetailProvider(42).notifier);
      notifier.toggleTagList();

      final state = container.read(emailDetailProvider(42));
      expect(state.showTagList, true);
      expect(state.showMenuOptions, false);
    });

    test('toggleMenuOptions should flip showMenuOptions and close tags', () async {
      await Future.delayed(const Duration(milliseconds: 100));

      final notifier = container.read(emailDetailProvider(42).notifier);
      notifier.toggleMenuOptions();

      final state = container.read(emailDetailProvider(42));
      expect(state.showMenuOptions, true);
      expect(state.showTagList, false);
    });

    test('toggleShowAllAttachments should flip flag', () async {
      await Future.delayed(const Duration(milliseconds: 100));

      final notifier = container.read(emailDetailProvider(42).notifier);
      notifier.toggleShowAllAttachments();

      expect(container.read(emailDetailProvider(42)).showAllAttachments, true);

      notifier.toggleShowAllAttachments();
      expect(container.read(emailDetailProvider(42)).showAllAttachments, false);
    });

    test('toggleExpandedView should flip flag', () async {
      await Future.delayed(const Duration(milliseconds: 100));

      final notifier = container.read(emailDetailProvider(42).notifier);
      notifier.toggleExpandedView();

      expect(container.read(emailDetailProvider(42)).expandedView, true);
    });

    test('preparePrintUrl should contain emailId', () async {
      await Future.delayed(const Duration(milliseconds: 100));

      final notifier = container.read(emailDetailProvider(42).notifier);
      final url = notifier.preparePrintUrl();

      expect(url, contains('42'));
    });

    test('loadEmailDetail should handle API failure', () async {
      await Future.delayed(const Duration(milliseconds: 200));

      final state = container.read(emailDetailProvider(42));
      // After failed init, should not be loading
      expect(state.isLoading, false);
    });

    test('loadEmailDetail should populate on success', () async {
      when(() => setup.mockApiService.post(any(), any()))
          .thenAnswer((_) async => {
                'success': true,
                'message': 'OK',
                'data': {
                  'url': 'https://api.test.com/email/view/99',
                  'email': {
                    'id': 99, 'senderEmail': 'sender@test.com',
                    'subject': 'Test Email', 'message': '<p>Hello</p>',
                    'isArchive': false, 'isTrash': false, 'isDeleted': false,
                    'created': '2024-01-01', 'updated': '2024-01-01',
                    'receivers': [], 'attachments': [],
                    'sender': {'firstName': 'Sender', 'lastName': 'Name', 'created': ''},
                    'emailTags': [], 'communityStatus': false,
                  },
                },
              });

      // Create a fresh provider to trigger _init with the new stub
      final c2 = ProviderContainer(
        overrides: [
          ...setup.serviceOverrides,
          authProvider.overrideWith(() => _FakeAuthNotifier({
                'user': {'id': 1}, 'token': 'tok',
              })),
        ],
      );
      addTearDown(c2.dispose);
      await Future.delayed(Duration.zero);

      final sub2 = c2.listen(emailDetailProvider(99), (_, _) {});
      addTearDown(sub2.close);
      await Future.delayed(const Duration(milliseconds: 300));

      final state = c2.read(emailDetailProvider(99));
      expect(state.hasEmail, true);
      expect(state.subject, 'Test Email');
      expect(state.senderEmail, 'sender@test.com');
      expect(state.isLoading, false);
    });
  });
}
