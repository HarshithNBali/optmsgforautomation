import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:optmsg/model/base_response/request_response.dart';
import 'package:optmsg/model/inbox_list_model.dart';
import 'package:optmsg/screens/auth/auth_riverpod/auth_notifier.dart';
import 'package:optmsg/screens/email/inbox_riverpod/inbox_notifier.dart';

import '../../helpers/riverpod_test_helpers.dart';
import '../../factories/test_data_factories.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late RiverpodTestSetup setup;
  late ProviderContainer container;
  late InboxNotifier notifier;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    setup = RiverpodTestSetup();
    when(() => setup.mockStorageService.readObjectData(any()))
        .thenAnswer((_) async => null);
    when(() => setup.mockStorageService.readData(any()))
        .thenAnswer((_) async => null);

    container = ProviderContainer(overrides: setup.serviceOverrides);
    container.read(authProvider);
    await Future.delayed(Duration.zero);
    notifier = container.read(inboxProvider.notifier);
  });

  tearDown(() => container.dispose());

  group('InboxNotifier getAllEmails', () {
    test('should populate items on successful response', () async {
      final inboxModel = InboxListModel.fromJson(makeInboxListJson(
        emails: [
          makeInboxEmailJson(id: 1, emailId: 100),
          makeInboxEmailJson(id: 2, emailId: 200),
          makeInboxEmailJson(id: 3, emailId: 300),
        ],
        nextPage: false,
      ));

      when(() => setup.mockInboxApi.getInboxEmails(any()))
          .thenAnswer((_) async => RequestResponse(data: inboxModel));

      await notifier.getAllEmails('');

      final state = container.read(inboxProvider);
      expect(state.items, hasLength(3));
      expect(state.isLoading, false);
      expect(state.isFetching, false);
      expect(state.errorMessage, isNull);
      expect(state.inboxList, isNotNull);
      expect(state.inboxList!.success, true);
    });

    test('should set loading state on page 1', () async {
      final inboxModel = InboxListModel.fromJson(makeInboxListJson());

      when(() => setup.mockInboxApi.getInboxEmails(any()))
          .thenAnswer((_) async {
        // Check loading state while request is in-flight
        final midState = container.read(inboxProvider);
        expect(midState.isFetching, true);
        return RequestResponse(data: inboxModel);
      });

      await notifier.getAllEmails('');
    });

    test('should handle empty inbox', () async {
      final inboxModel = InboxListModel.fromJson(makeInboxListJson(
        emails: [],
        nextPage: false,
      ));

      when(() => setup.mockInboxApi.getInboxEmails(any()))
          .thenAnswer((_) async => RequestResponse(data: inboxModel));

      await notifier.getAllEmails('');

      final state = container.read(inboxProvider);
      expect(state.items, isEmpty);
      expect(state.isLoading, false);
    });

    test('should increment currentPage when nextPage is true', () async {
      final inboxModel = InboxListModel.fromJson(makeInboxListJson(
        emails: [makeInboxEmailJson()],
        nextPage: true,
      ));

      when(() => setup.mockInboxApi.getInboxEmails(any()))
          .thenAnswer((_) async => RequestResponse(data: inboxModel));

      await notifier.getAllEmails('');

      final state = container.read(inboxProvider);
      expect(state.currentPage, 2);
    });

    test('should not increment currentPage when nextPage is false', () async {
      final inboxModel = InboxListModel.fromJson(makeInboxListJson(
        nextPage: false,
      ));

      when(() => setup.mockInboxApi.getInboxEmails(any()))
          .thenAnswer((_) async => RequestResponse(data: inboxModel));

      await notifier.getAllEmails('');

      expect(container.read(inboxProvider).currentPage, 1);
    });

    test('should pass search key and email type in request', () async {
      final inboxModel = InboxListModel.fromJson(makeInboxListJson());
      Map<String, dynamic>? capturedData;

      when(() => setup.mockInboxApi.getInboxEmails(any()))
          .thenAnswer((invocation) async {
        capturedData = invocation.positionalArguments[0];
        return RequestResponse(data: inboxModel);
      });

      await notifier.getAllEmails('test search');

      expect(capturedData, isNotNull);
      expect(capturedData!['search'], 'test search');
      expect(capturedData!['type'], 'inbox');
      expect(capturedData!['page'], 1);
    });

    test('should handle unsuccessful API response', () async {
      final inboxModel = InboxListModel.fromJson({
        'success': false,
        'message': 'Server error',
        'data': null,
      });

      when(() => setup.mockInboxApi.getInboxEmails(any()))
          .thenAnswer((_) async => RequestResponse(data: inboxModel));

      await notifier.getAllEmails('');

      final state = container.read(inboxProvider);
      expect(state.isLoading, false);
      expect(state.isFetching, false);
      expect(state.errorMessage, 'Server error');
    });

    test('should handle unsuccessful response with empty message (401)', () async {
      final inboxModel = InboxListModel.fromJson({
        'success': false,
        'message': '',
        'data': null,
      });

      when(() => setup.mockInboxApi.getInboxEmails(any()))
          .thenAnswer((_) async => RequestResponse(data: inboxModel));

      await notifier.getAllEmails('');

      final state = container.read(inboxProvider);
      expect(state.isLoading, false);
      // Empty message from 401 — errorMessage is still set
      expect(state.errorMessage, '');
    });

    test('should prevent concurrent fetches', () async {
      final inboxModel = InboxListModel.fromJson(makeInboxListJson());
      int callCount = 0;

      when(() => setup.mockInboxApi.getInboxEmails(any()))
          .thenAnswer((_) async {
        callCount++;
        await Future.delayed(const Duration(milliseconds: 50));
        return RequestResponse(data: inboxModel);
      });

      // Fire two concurrent calls
      final future1 = notifier.getAllEmails('');
      final future2 = notifier.getAllEmails(''); // should be skipped

      await Future.wait([future1, future2]);

      // Only one API call should have been made
      expect(callCount, 1);
    });
  });

  group('InboxNotifier refresh', () {
    test('should reset pagination and call getAllEmails', () async {
      final inboxModel = InboxListModel.fromJson(makeInboxListJson());

      when(() => setup.mockInboxApi.getInboxEmails(any()))
          .thenAnswer((_) async => RequestResponse(data: inboxModel));

      await notifier.refresh();

      final state = container.read(inboxProvider);
      expect(state.isSearch, true);
      expect(state.isLoading, false);
    });
  });
}
