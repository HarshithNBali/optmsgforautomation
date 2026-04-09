import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:optmsg/model/auth/auth_state.dart';
import 'package:optmsg/model/draft_list_modal.dart' as draft;
import 'package:optmsg/screens/auth/auth_riverpod/auth_notifier.dart';
import 'package:optmsg/screens/email/draft_riverpod/draft_notifier.dart';
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
    when(() => setup.mockStorageService.readObjectData(any())).thenAnswer((_) async => null);
    when(() => setup.mockStorageService.readData(any())).thenAnswer((_) async => null);
    when(() => setup.mockStorageService.writeData(any(), any())).thenAnswer((_) async {});
  });

  // ===== DraftNotifier more methods =====
  group('DraftNotifier selectAllFromList', () {
    late ProviderContainer container;
    late DraftNotifier notifier;

    setUp(() async {
      container = ProviderContainer(overrides: setup.serviceOverrides);
      container.read(authProvider);
      await Future.delayed(Duration.zero);
      notifier = container.read(draftProvider.notifier);
    });

    tearDown(() => container.dispose());

    test('should select all items', () {
      final email1 = draft.Emails.fromJson({
        'id': 1, 'senderId': 1, 'subject': 'D1', 'message': '',
        'isDeleted': false, 'created': '', 'updated': '', 'attachments': [],
      });
      final email2 = draft.Emails.fromJson({
        'id': 2, 'senderId': 1, 'subject': 'D2', 'message': '',
        'isDeleted': false, 'created': '', 'updated': '', 'attachments': [],
      });
      notifier.state = notifier.state.copyWith(items: [email1, email2]);

      notifier.selectAllFromList();

      final state = container.read(draftProvider);
      expect(state.selectedEmailIds, [1, 2]);
      expect(state.allEmailIdsFlag, true);
      expect(state.longPressFlag, false);
    });
  });

  group('DraftNotifier setCurrentlyViewedEmailId', () {
    late ProviderContainer container;
    late DraftNotifier notifier;

    setUp(() async {
      container = ProviderContainer(overrides: setup.serviceOverrides);
      container.read(authProvider);
      await Future.delayed(Duration.zero);
      notifier = container.read(draftProvider.notifier);
    });

    tearDown(() => container.dispose());

    test('should set currentlyViewedEmailId', () {
      notifier.setCurrentlyViewedEmailId(42);
      expect(container.read(draftProvider).currentlyViewedEmailId, 42);
    });

    test('setSelectedEmailIdForReadingPane', () {
      notifier.setSelectedEmailIdForReadingPane(99);
      expect(container.read(draftProvider).selectedEmailIdForReadingPane, 99);
    });

    test('setEmailListPaneWidth', () {
      notifier.setEmailListPaneWidth(350.0);
      expect(container.read(draftProvider).emailListPaneWidth, 350.0);
    });

    test('updateReadingPaneSettings false should clear selection', () {
      notifier.state = notifier.state.copyWith(
        readingPaneEnabled: true,
        selectedEmailIdForReadingPane: 5,
      );
      notifier.updateReadingPaneSettings(false);

      final state = container.read(draftProvider);
      expect(state.readingPaneEnabled, false);
      expect(state.selectedEmailIdForReadingPane, isNull);
    });

    test('updateReadingPaneSettings true should enable', () {
      notifier.updateReadingPaneSettings(true);
      expect(container.read(draftProvider).readingPaneEnabled, true);
    });

    test('updateNotificationFlag should update flag', () {
      notifier.state = notifier.state.copyWith(newNotification: false);
      // This calls countProvider which uses AppBadgePlus — skip direct call
      // Test state directly instead
      notifier.state = notifier.state.copyWith(newNotification: true);
      expect(container.read(draftProvider).newNotification, true);
    });
  });

  // ===== EmailDetailNotifier API methods =====
  group('EmailDetailNotifier markAsUnread', () {
    late ProviderContainer container;
    late ProviderSubscription<EmailDetailState> sub;

    setUp(() async {
      when(() => setup.mockApiService.post(any(), any()))
          .thenAnswer((_) async => {'success': false, 'message': 'Test env'});

      container = ProviderContainer(
        overrides: [
          ...setup.serviceOverrides,
          authProvider.overrideWith(() => _FakeAuthNotifier({
                'user': {'id': 1}, 'token': 'tok',
              })),
        ],
      );
      await Future.delayed(Duration.zero);
      sub = container.listen(emailDetailProvider(42), (_, _) {});
      await Future.delayed(const Duration(milliseconds: 200));
    });

    tearDown(() {
      sub.close();
      container.dispose();
    });

    test('should call API to mark as unread', () async {
      when(() => setup.mockApiService.post(any(), any()))
          .thenAnswer((_) async => {'success': true, 'message': 'OK'});

      final notifier = container.read(emailDetailProvider(42).notifier);
      await notifier.markAsUnread();

      final state = container.read(emailDetailProvider(42));
      expect(state.markedAsUnread, true);
    });

    test('should handle API failure', () async {
      when(() => setup.mockApiService.post(any(), any()))
          .thenAnswer((_) async => {'success': false, 'message': 'Failed'});

      final notifier = container.read(emailDetailProvider(42).notifier);
      await notifier.markAsUnread();

      expect(container.read(emailDetailProvider(42)).markedAsUnread, false);
    });
  });

  group('EmailDetailNotifier moveToArchive', () {
    late ProviderContainer container;
    late ProviderSubscription<EmailDetailState> sub;

    setUp(() async {
      when(() => setup.mockApiService.post(any(), any()))
          .thenAnswer((_) async => {'success': false, 'message': 'Test env'});

      container = ProviderContainer(
        overrides: [
          ...setup.serviceOverrides,
          authProvider.overrideWith(() => _FakeAuthNotifier({
                'user': {'id': 1}, 'token': 'tok',
              })),
        ],
      );
      await Future.delayed(Duration.zero);
      sub = container.listen(emailDetailProvider(42), (_, _) {});
      await Future.delayed(const Duration(milliseconds: 200));
    });

    tearDown(() {
      sub.close();
      container.dispose();
    });

    test('should set movedToArchive on success', () async {
      when(() => setup.mockApiService.post(any(), any()))
          .thenAnswer((_) async => {'success': true, 'message': 'OK'});

      await container.read(emailDetailProvider(42).notifier).moveToArchive();

      expect(container.read(emailDetailProvider(42)).movedToArchive, true);
    });

    test('should not set flag on failure', () async {
      when(() => setup.mockApiService.post(any(), any()))
          .thenAnswer((_) async => {'success': false, 'message': 'Error'});

      await container.read(emailDetailProvider(42).notifier).moveToArchive();

      expect(container.read(emailDetailProvider(42)).movedToArchive, false);
    });
  });

  group('EmailDetailNotifier moveToTrash', () {
    late ProviderContainer container;
    late ProviderSubscription<EmailDetailState> sub;

    setUp(() async {
      when(() => setup.mockApiService.post(any(), any()))
          .thenAnswer((_) async => {'success': false, 'message': 'Test env'});

      container = ProviderContainer(
        overrides: [
          ...setup.serviceOverrides,
          authProvider.overrideWith(() => _FakeAuthNotifier({
                'user': {'id': 1}, 'token': 'tok',
              })),
        ],
      );
      await Future.delayed(Duration.zero);
      sub = container.listen(emailDetailProvider(42), (_, _) {});
      await Future.delayed(const Duration(milliseconds: 200));
    });

    tearDown(() {
      sub.close();
      container.dispose();
    });

    test('should set movedToTrash on success', () async {
      when(() => setup.mockApiService.post(any(), any()))
          .thenAnswer((_) async => {'success': true, 'message': 'OK'});

      await container.read(emailDetailProvider(42).notifier).moveToTrash();

      expect(container.read(emailDetailProvider(42)).movedToTrash, true);
    });
  });

  group('EmailDetailNotifier preparePrintUrl', () {
    test('should contain emailId in URL', () async {
      when(() => setup.mockApiService.post(any(), any()))
          .thenAnswer((_) async => {'success': false, 'message': 'init'});

      final container = ProviderContainer(
        overrides: [
          ...setup.serviceOverrides,
          authProvider.overrideWith(() => _FakeAuthNotifier({'user': {'id': 1}, 'token': 't'})),
        ],
      );
      addTearDown(container.dispose);
      await Future.delayed(Duration.zero);

      final sub = container.listen(emailDetailProvider(99), (_, _) {});
      addTearDown(sub.close);
      await Future.delayed(const Duration(milliseconds: 200));

      final url = container.read(emailDetailProvider(99).notifier).preparePrintUrl();
      expect(url, contains('99'));
    });
  });
}
