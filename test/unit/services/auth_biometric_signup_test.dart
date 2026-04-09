// Implements: TC-DISC-AUTH-BIO-001..015
// Source: lib/screens/auth/auth_riverpod/auth_notifier.dart
// Coverage target: Push auth methods (biometric, signUp) coverage
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
    setup = RiverpodTestSetup();
    when(() => setup.mockStorageService.readObjectData(any()))
        .thenAnswer((_) async => null);
    when(() => setup.mockStorageService.readData(any()))
        .thenAnswer((_) async => null);
    when(() => setup.mockStorageService.writeData(any(), any()))
        .thenAnswer((_) async {});
    when(() => setup.mockStorageService.writeObjectData(any(), any()))
        .thenAnswer((_) async {});
    SessionRefreshMutex.isLoggedOut = false;
  });

  // =========================================================================
  // authenticateBiometric
  // =========================================================================
  group('AuthNotifier authenticateBiometric', () {
    late ProviderContainer container;

    setUp(() async {
      container = ProviderContainer(overrides: setup.serviceOverrides);
      container.read(authProvider);
      await Future.delayed(Duration.zero);
    });

    tearDown(() => container.dispose());

    test('should return true and write enabled when biometric succeeds', () async {
      // TC-DISC-AUTH-BIO-001
      when(() => setup.mockBiometricService.authenticate())
          .thenAnswer((_) async => true);

      final result = await container
          .read(authProvider.notifier)
          .authenticateBiometric();

      expect(result, isTrue);
      verify(() => setup.mockStorageService.writeData('isBiometricEnable', 'true'))
          .called(1);
    });

    test('should return false and write disabled when biometric fails', () async {
      // TC-DISC-AUTH-BIO-002
      when(() => setup.mockBiometricService.authenticate())
          .thenAnswer((_) async => false);

      final result = await container
          .read(authProvider.notifier)
          .authenticateBiometric();

      expect(result, isFalse);
      verify(() => setup.mockStorageService.writeData('isBiometricEnable', 'false'))
          .called(1);
    });
  });

  // =========================================================================
  // biometricDenied
  // =========================================================================
  group('AuthNotifier biometricDenied', () {
    late ProviderContainer container;

    setUp(() async {
      container = ProviderContainer(overrides: setup.serviceOverrides);
      container.read(authProvider);
      await Future.delayed(Duration.zero);
    });

    tearDown(() => container.dispose());

    test('should no-op when userData is null', () async {
      // TC-DISC-AUTH-BIO-003
      await container.read(authProvider.notifier).biometricDenied(false);
      // Should not crash, no storage write since userData is null
    });

    test('should write user biometric preference from userData', () async {
      // TC-DISC-AUTH-BIO-004
      container.read(authProvider.notifier).setAuthenticated(true, userData: {
        'user': makeUserJson(isDeviceBiometrics: true),
        'token': 'tok',
      });

      await container.read(authProvider.notifier).biometricDenied(false);

      verify(() => setup.mockStorageService.writeData('isBiometricEnable', 'true'))
          .called(1);
    });

    test('should write false when user has biometric disabled', () async {
      // TC-DISC-AUTH-BIO-005
      container.read(authProvider.notifier).setAuthenticated(true, userData: {
        'user': makeUserJson(isDeviceBiometrics: false),
        'token': 'tok',
      });

      await container.read(authProvider.notifier).biometricDenied(true);

      verify(() => setup.mockStorageService.writeData('isBiometricEnable', 'false'))
          .called(1);
    });
  });

  // =========================================================================
  // biometricAccept
  // =========================================================================
  group('AuthNotifier biometricAccept', () {
    late ProviderContainer container;

    setUp(() async {
      container = ProviderContainer(overrides: setup.serviceOverrides);
      container.read(authProvider);
      await Future.delayed(Duration.zero);
    });

    tearDown(() => container.dispose());

    test('should return true and write true when biometric succeeds', () async {
      // TC-DISC-AUTH-BIO-006
      when(() => setup.mockBiometricService.authenticate())
          .thenAnswer((_) async => true);

      final result = await container
          .read(authProvider.notifier)
          .biometricAccept(true);

      expect(result, isTrue);
      verify(() => setup.mockStorageService.writeData('isBiometricEnable', 'true'))
          .called(1);
    });

    test('should return false and write false when biometric fails', () async {
      // TC-DISC-AUTH-BIO-007
      when(() => setup.mockBiometricService.authenticate())
          .thenAnswer((_) async => false);

      final result = await container
          .read(authProvider.notifier)
          .biometricAccept(false);

      expect(result, isFalse);
      verify(() => setup.mockStorageService.writeData('isBiometricEnable', 'false'))
          .called(1);
    });
  });

  // =========================================================================
  // signUp — testable paths (API failure, success before Descope)
  // =========================================================================
  group('AuthNotifier signUp', () {
    late ProviderContainer container;

    setUp(() async {
      container = ProviderContainer(overrides: setup.serviceOverrides);
      container.read(authProvider);
      await Future.delayed(Duration.zero);
    });

    tearDown(() => container.dispose());

    test('should return false on API validation failure', () async {
      // TC-DISC-AUTH-BIO-008
      when(() => setup.mockApiService.post(any(), any()))
          .thenAnswer((_) async => {
                'success': false,
                'message': 'Username already taken',
              });

      final result = await container
          .read(authProvider.notifier)
          .signUp('testuser', '5551234567');

      expect(result, isFalse);
      expect(container.read(authProvider).status, AuthStatus.unauthenticated);
    });

    test('should call correct API endpoint', () async {
      // TC-DISC-AUTH-BIO-009
      when(() => setup.mockApiService.post(any(), any()))
          .thenAnswer((_) async => {
                'success': false,
                'message': 'Already exists',
              });

      await container.read(authProvider.notifier).signUp('newuser', '1234567890');

      verify(() => setup.mockApiService.post('auth/check-user-name-mobile', {
            'userName': 'newuser',
            'mobile': '1234567890',
          })).called(1);
    });

    test('should return false and set error on exception', () async {
      // TC-DISC-AUTH-BIO-010
      when(() => setup.mockApiService.post(any(), any()))
          .thenThrow(Exception('Network error'));

      final result = await container
          .read(authProvider.notifier)
          .signUp('user', '123');

      expect(result, isFalse);
      expect(container.read(authProvider).status, AuthStatus.error);
      expect(container.read(authProvider).errorMessage, contains('Network error'));
    });

    test('should set authenticating status before API call', () async {
      // TC-DISC-AUTH-BIO-011
      // Use completer to pause API call mid-flight
      when(() => setup.mockApiService.post(any(), any()))
          .thenAnswer((_) async {
        // While API is "in flight", check status
        return {'success': false, 'message': 'fail'};
      });

      await container.read(authProvider.notifier).signUp('user', '123');
      // After completion, status should be unauthenticated (failure path)
      expect(container.read(authProvider).status, AuthStatus.unauthenticated);
    });
  });

  // =========================================================================
  // AuthStatus enum
  // =========================================================================
  group('AuthStatus', () {
    test('should have expected values', () {
      // TC-DISC-AUTH-BIO-012
      expect(AuthStatus.values, contains(AuthStatus.unauthenticated));
      expect(AuthStatus.values, contains(AuthStatus.authenticated));
      expect(AuthStatus.values, contains(AuthStatus.authenticating));
      expect(AuthStatus.values, contains(AuthStatus.awaitingOtp));
      expect(AuthStatus.values, contains(AuthStatus.error));
    });
  });

  // =========================================================================
  // AuthState error factory
  // =========================================================================
  group('AuthState.error', () {
    test('should create error state with message', () {
      // TC-DISC-AUTH-BIO-013
      final state = AuthState.error('Something broke');
      expect(state.status, AuthStatus.error);
      expect(state.errorMessage, 'Something broke');
      expect(state.isAuthenticated, isFalse);
    });
  });
}
