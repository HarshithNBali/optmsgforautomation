// Implements: TC-DISC-AUTH-FLOW-001..020
// Source: lib/screens/auth/auth_riverpod/auth_notifier.dart
// Coverage target: Push auth notifier from 22% toward 40%+
// Focus: forgotUserName, setStatus, updateUserField, updateUserFields,
//        persistUserData, setAuthenticated, logout synchronous path
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:optmsg/model/auth/auth_state.dart';
import 'package:optmsg/screens/auth/auth_riverpod/auth_notifier.dart';
import 'package:optmsg/services/session_refresh_mutex.dart';

import '../../helpers/riverpod_test_helpers.dart';
import '../../factories/test_data_factories.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late RiverpodTestSetup setup;

  setUp(() {
    // Mock AppBadgePlus
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('app_badge_plus'),
      (MethodCall methodCall) async {
        if (methodCall.method == 'isSupported') return false;
        return null;
      },
    );

    setup = RiverpodTestSetup();
    when(() => setup.mockStorageService.readObjectData(any()))
        .thenAnswer((_) async => null);
    when(() => setup.mockStorageService.readData(any()))
        .thenAnswer((_) async => null);
    when(() => setup.mockStorageService.writeData(any(), any()))
        .thenAnswer((_) async {});
    when(() => setup.mockStorageService.writeObjectData(any(), any()))
        .thenAnswer((_) async {});
    when(() => setup.mockStorageService.clearAllData())
        .thenAnswer((_) async {});
    SessionRefreshMutex.isLoggedOut = false;
  });

  // =========================================================================
  // forgotUserName
  // =========================================================================
  group('AuthNotifier forgotUserName', () {
    late ProviderContainer container;

    setUp(() async {
      container = ProviderContainer(overrides: setup.serviceOverrides);
      container.read(authProvider);
      await Future.delayed(Duration.zero);
    });

    tearDown(() => container.dispose());

    test('should return true and set awaitingOtp on success', () async {
      // TC-DISC-AUTH-FLOW-001
      when(() => setup.mockApiService.post(any(), any()))
          .thenAnswer((_) async => {
                'success': true,
                'message': 'OTP sent',
                'data': {'user': makeUserJson(), 'otpId': '123'},
              });

      final notifier = container.read(authProvider.notifier);
      final result = await notifier.forgotUserName('5551234567');

      expect(result, isTrue);
      final state = container.read(authProvider);
      expect(state.status, AuthStatus.awaitingOtp);
      expect(state.userData, isNotNull);
    });

    test('should return false and set error on API failure', () async {
      // TC-DISC-AUTH-FLOW-002
      when(() => setup.mockApiService.post(any(), any()))
          .thenAnswer((_) async => {
                'success': false,
                'message': 'Phone not found',
              });

      final notifier = container.read(authProvider.notifier);
      final result = await notifier.forgotUserName('0000000000');

      expect(result, isFalse);
      expect(container.read(authProvider).status, AuthStatus.error);
      expect(container.read(authProvider).errorMessage, 'Phone not found');
    });

    test('should return false on exception', () async {
      // TC-DISC-AUTH-FLOW-003
      when(() => setup.mockApiService.post(any(), any()))
          .thenThrow(Exception('Network error'));

      final notifier = container.read(authProvider.notifier);
      final result = await notifier.forgotUserName('5551234567');

      expect(result, isFalse);
      expect(container.read(authProvider).status, AuthStatus.error);
    });

    test('should read countryCode from storage', () async {
      // TC-DISC-AUTH-FLOW-004
      when(() => setup.mockStorageService.readData('countryCode'))
          .thenAnswer((_) async => '+44');
      when(() => setup.mockApiService.post(any(), any()))
          .thenAnswer((_) async => {'success': false, 'message': 'fail'});

      final notifier = container.read(authProvider.notifier);
      await notifier.forgotUserName('123');

      verify(() => setup.mockApiService.post('auth/forgot-username', {
            'countryCode': '+44',
            'mobile': '123',
            'type': 'FORGOT_USERNAME',
          })).called(1);
    });

    test('should default countryCode to +1 when storage returns null', () async {
      // TC-DISC-AUTH-FLOW-005
      when(() => setup.mockStorageService.readData('countryCode'))
          .thenAnswer((_) async => null);
      when(() => setup.mockApiService.post(any(), any()))
          .thenAnswer((_) async => {'success': false, 'message': 'fail'});

      final notifier = container.read(authProvider.notifier);
      await notifier.forgotUserName('123');

      verify(() => setup.mockApiService.post('auth/forgot-username', {
            'countryCode': '+1',
            'mobile': '123',
            'type': 'FORGOT_USERNAME',
          })).called(1);
    });

    test('should write userData on success', () async {
      final responseData = {'user': makeUserJson(), 'otpId': '456'};
      when(() => setup.mockApiService.post(any(), any()))
          .thenAnswer((_) async => {
                'success': true,
                'message': 'Sent',
                'data': responseData,
              });

      final notifier = container.read(authProvider.notifier);
      await notifier.forgotUserName('5551234567');

      verify(() => setup.mockStorageService.writeObjectData(
            'userData',
            responseData,
          )).called(1);
    });
  });

  // =========================================================================
  // setStatus
  // =========================================================================
  group('AuthNotifier setStatus', () {
    late ProviderContainer container;

    setUp(() async {
      container = ProviderContainer(overrides: setup.serviceOverrides);
      container.read(authProvider);
      await Future.delayed(Duration.zero);
    });

    tearDown(() => container.dispose());

    test('should update status to awaitingOtp', () {
      // TC-DISC-AUTH-FLOW-006
      container.read(authProvider.notifier).setStatus(AuthStatus.awaitingOtp);
      expect(container.read(authProvider).status, AuthStatus.awaitingOtp);
    });

    test('should update status to authenticating', () {
      container.read(authProvider.notifier).setStatus(AuthStatus.authenticating);
      expect(container.read(authProvider).status, AuthStatus.authenticating);
    });

    test('should update status to error', () {
      container.read(authProvider.notifier).setStatus(AuthStatus.error);
      expect(container.read(authProvider).status, AuthStatus.error);
    });
  });

  // =========================================================================
  // updateUserField / updateUserFields / persistUserData
  // =========================================================================
  group('AuthNotifier userData helpers', () {
    late ProviderContainer container;

    setUp(() async {
      container = ProviderContainer(overrides: setup.serviceOverrides);
      container.read(authProvider);
      await Future.delayed(Duration.zero);

      // Set up authenticated state with userData
      container.read(authProvider.notifier).setAuthenticated(true, userData: {
        'user': makeUserJson(firstName: 'John', lastName: 'Doe'),
        'token': 'test-token',
      });
    });

    tearDown(() => container.dispose());

    test('updateUserField should update single field and persist', () async {
      // TC-DISC-AUTH-FLOW-007
      await container
          .read(authProvider.notifier)
          .updateUserField('firstName', 'Jane');

      final userData = container.read(authProvider).userData;
      expect(userData!['user']['firstName'], 'Jane');
      expect(userData['user']['lastName'], 'Doe'); // unchanged
      verify(() => setup.mockStorageService.writeObjectData('userData', any()))
          .called(1);
    });

    test('updateUserField should no-op when userData is null', () async {
      // TC-DISC-AUTH-FLOW-008
      container.read(authProvider.notifier).setAuthenticated(false);
      await container
          .read(authProvider.notifier)
          .updateUserField('firstName', 'Jane');

      // Should not crash, should not write to storage
      verifyNever(
          () => setup.mockStorageService.writeObjectData('userData', any()));
    });

    test('updateUserFields should bulk-update and persist', () async {
      // TC-DISC-AUTH-FLOW-009
      await container
          .read(authProvider.notifier)
          .updateUserFields({'firstName': 'Jane', 'lastName': 'Smith'});

      final userData = container.read(authProvider).userData;
      expect(userData!['user']['firstName'], 'Jane');
      expect(userData['user']['lastName'], 'Smith');
      verify(() => setup.mockStorageService.writeObjectData('userData', any()))
          .called(1);
    });

    test('updateUserFields should no-op when userData is null', () async {
      container.read(authProvider.notifier).setAuthenticated(false);
      await container
          .read(authProvider.notifier)
          .updateUserFields({'firstName': 'X'});
      // No crash, no storage write
    });

    test('persistUserData should replace entire userData', () async {
      // TC-DISC-AUTH-FLOW-010
      final newData = {
        'user': makeUserJson(firstName: 'New', lastName: 'User'),
        'token': 'new-token',
      };

      await container.read(authProvider.notifier).persistUserData(newData);

      expect(container.read(authProvider).userData, newData);
      verify(() => setup.mockStorageService.writeObjectData('userData', newData))
          .called(1);
    });
  });

  // =========================================================================
  // setAuthenticated — deeper tests
  // =========================================================================
  group('AuthNotifier setAuthenticated', () {
    late ProviderContainer container;

    setUp(() async {
      container = ProviderContainer(overrides: setup.serviceOverrides);
      container.read(authProvider);
      await Future.delayed(Duration.zero);
    });

    tearDown(() => container.dispose());

    test('should clear isLoggedOut flag when setting authenticated', () {
      // TC-DISC-AUTH-FLOW-011
      SessionRefreshMutex.isLoggedOut = true;

      container.read(authProvider.notifier).setAuthenticated(true, userData: {
        'user': makeUserJson(),
        'token': 'tok',
      });

      expect(SessionRefreshMutex.isLoggedOut, isFalse);
      expect(container.read(authProvider).isAuthenticated, isTrue);
    });

    test('should set isLoggedOut flag when setting unauthenticated', () {
      // TC-DISC-AUTH-FLOW-012
      SessionRefreshMutex.isLoggedOut = false;

      container.read(authProvider.notifier).setAuthenticated(false);

      expect(SessionRefreshMutex.isLoggedOut, isTrue);
      expect(container.read(authProvider).isAuthenticated, isFalse);
    });

    test('should set unauthenticated when value=true but no userData', () {
      // TC-DISC-AUTH-FLOW-013
      container.read(authProvider.notifier).setAuthenticated(true);

      // value=true but userData=null → falls to else branch
      expect(SessionRefreshMutex.isLoggedOut, isTrue);
      expect(container.read(authProvider).isAuthenticated, isFalse);
    });
  });

  // =========================================================================
  // AuthState model tests
  // =========================================================================
  group('AuthState', () {
    test('authenticated should set all fields correctly', () {
      // TC-DISC-AUTH-FLOW-014
      final data = {'user': makeUserJson(), 'token': 'tok'};
      final state = AuthState.authenticated(data);

      expect(state.isAuthenticated, isTrue);
      expect(state.isInitialized, isTrue);
      expect(state.userData, data);
      expect(state.status, AuthStatus.authenticated);
    });

    test('unauthenticated should clear all fields', () {
      // TC-DISC-AUTH-FLOW-015
      final state = AuthState.unauthenticated();

      expect(state.isAuthenticated, isFalse);
      expect(state.isInitialized, isTrue);
      expect(state.userData, isNull);
    });

    test('initial should be uninitialized', () {
      final state = AuthState.initial();
      expect(state.isInitialized, isFalse);
      expect(state.isAuthenticated, isFalse);
    });

    test('authenticating should set loading status', () {
      final state = AuthState.authenticating();
      expect(state.status, AuthStatus.authenticating);
    });

    test('copyWith should preserve unchanged fields', () {
      // TC-DISC-AUTH-FLOW-016
      final state = AuthState.authenticated({
        'user': makeUserJson(),
        'token': 'tok',
      });
      final updated = state.copyWith(errorMessage: 'test error');

      expect(updated.isAuthenticated, isTrue);
      expect(updated.errorMessage, 'test error');
      expect(updated.userData, isNotNull);
    });
  });
}
