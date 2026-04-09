import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:optmsg/model/auth/auth_state.dart';
import 'package:optmsg/screens/auth/auth_riverpod/auth_notifier.dart';

import '../../helpers/riverpod_test_helpers.dart';
import '../../mocks/mock_services.dart';

void main() {
  late RiverpodTestSetup setup;

  setUp(() {
    setup = RiverpodTestSetup();
    // Stub readObjectData which _initialize() calls
    when(() => setup.mockStorageService.readObjectData(any()))
        .thenAnswer((_) async => null);
  });

  group('AuthNotifier build()', () {
    test('should return initial state synchronously', () {
      final container = setup.createAuthTestContainer();
      addTearDown(container.dispose);

      final state = container.read(authProvider);

      expect(state.status, AuthStatus.unauthenticated);
      expect(state.isInitialized, false);
      expect(state.isAuthenticated, false);
      expect(state.userData, isNull);
    });

    test('should transition to unauthenticated after _initialize when Descope not ready',
        () async {
      final container = setup.createAuthTestContainer();
      addTearDown(container.dispose);

      // Initial synchronous state
      expect(container.read(authProvider).isInitialized, false);

      // Let _initialize() microtask run — Descope throws LateInitializationError
      await Future.delayed(Duration.zero);

      final state = container.read(authProvider);
      expect(state.status, AuthStatus.unauthenticated);
      expect(state.isInitialized, true);
      expect(state.isAuthenticated, false);
    });

    test('should read all service providers during build', () {
      final container = setup.createAuthTestContainer();
      addTearDown(container.dispose);

      container.read(authProvider);

      expect(container.read(apiServiceProvider), isA<MockApiService>());
      expect(container.read(storageServiceProvider),
          isA<MockSecureStorageService>());
      expect(container.read(biometricServiceProvider),
          isA<MockBiometricService>());
      expect(container.read(analyticsServiceProvider),
          isA<MockAnalyticsService>());
    });
  });

  group('AuthNotifier setAuthenticated', () {
    test('setAuthenticated(false) should set unauthenticated state', () async {
      final container = setup.createAuthTestContainer();
      addTearDown(container.dispose);

      // Let _initialize complete
      await Future.delayed(Duration.zero);

      container.read(authProvider.notifier).setAuthenticated(false);
      final state = container.read(authProvider);

      expect(state.isAuthenticated, false);
      expect(state.isInitialized, true);
      expect(state.status, AuthStatus.unauthenticated);
    });
  });

  group('AuthNotifier state transitions', () {
    test('observer captures state changes', () async {
      final observer = TestProviderObserver();
      final container = ProviderContainer(
        overrides: setup.serviceOverrides,
        observers: [observer],
      );
      addTearDown(container.dispose);

      container.read(authProvider);
      await Future.delayed(Duration.zero);

      // Should have at least the initial → unauthenticated transition
      final authChanges = observer.changes
          .where((c) => c.newValue is AuthState)
          .toList();
      expect(authChanges, isNotEmpty);
    });
  });

  group('AuthNotifier disposed guard', () {
    test(
      'should not crash when container is disposed before _initialize completes',
      () async {
        final container = setup.createAuthTestContainer();
        container.read(authProvider);
        container.dispose();
        await Future.delayed(const Duration(milliseconds: 50));
        expect(true, isTrue);
      },
    );
  });
}
