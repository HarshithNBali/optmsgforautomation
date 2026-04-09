import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/test_helpers.dart';
import 'helpers/riverpod_test_helpers.dart';
import 'mocks/mock_services.dart';
import 'mocks/mock_repositories.dart';
import 'factories/test_data_factories.dart';

void main() {
  group('Test Infrastructure Smoke Tests', () {
    test('mock services can be instantiated', () {
      final apiService = MockApiService();
      final storageService = MockSecureStorageService();
      final biometricService = MockBiometricService();
      final analyticsService = MockAnalyticsService();

      expect(apiService, isNotNull);
      expect(storageService, isNotNull);
      expect(biometricService, isNotNull);
      expect(analyticsService, isNotNull);
    });

    test('mock repositories can be instantiated', () {
      final inboxApi = MockInboxApi();
      final settingApi = MockSettingApi();

      expect(inboxApi, isNotNull);
      expect(settingApi, isNotNull);
    });

    test('default storage stubs work', () async {
      final mock = MockSecureStorageService();
      stubStorageDefaults(mock);

      final result = await mock.readData('anyKey');
      expect(result, isNull);
    });

    test('test data factories produce valid JSON', () {
      final userJson = makeUserJson();
      expect(userJson['id'], 1);
      expect(userJson['firstName'], 'Test');
      expect(userJson['userName'], 'testuser');

      final loginJson = makeLoginJson();
      expect(loginJson['success'], true);
      expect(loginJson['data']['token'], isNotEmpty);

      final inboxJson = makeInboxListJson();
      expect(inboxJson['data']['emails'], isList);
      expect(inboxJson['data']['emails'], isNotEmpty);

      final profileJson = makeProfileJson();
      expect(profileJson['success'], true);
      expect(profileJson['data']['firstName'], 'Test');
    });

    test('test data factories accept overrides', () {
      final userJson = makeUserJson(
        id: 42,
        firstName: 'Jane',
        isSubscribed: false,
      );
      expect(userJson['id'], 42);
      expect(userJson['firstName'], 'Jane');
      expect(userJson['isSubscribed'], false);
    });

    test('RiverpodTestSetup creates container with overrides', () {
      final setup = RiverpodTestSetup();
      final container = setup.createAuthTestContainer();

      expect(container, isNotNull);
      container.dispose();
    });

    test('createContainer helper registers teardown', () {
      final container = createContainer();
      expect(container, isNotNull);
      // addTearDown will auto-dispose
    });

    test('makeTestableWidget wraps in ProviderScope + MaterialApp', () {
      // Just verify it doesn't throw
      final widget = makeTestableWidget(
        const SizedBox(),
      );
      expect(widget, isNotNull);
    });

    test('error response factories produce valid JSON', () {
      final error = makeErrorResponse(message: 'Not found');
      expect(error['success'], false);
      expect(error['message'], 'Not found');

      final fieldError = makeFieldErrorResponse();
      expect(fieldError['errors'], isList);
      expect(fieldError['errors'].first['field'], 'email');
    });
  });
}
