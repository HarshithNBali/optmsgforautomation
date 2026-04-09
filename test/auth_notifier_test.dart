import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:optmsg/screens/auth/auth_riverpod/auth_notifier.dart';
import 'package:optmsg/model/auth/auth_state.dart';
import 'package:optmsg/services/api_service.dart';
import 'package:optmsg/services/storage_service.dart';
import 'package:optmsg/services/biometric_service.dart';
import 'package:optmsg/services/analytics_service.dart';

// ---------------------------------------------------------------------------
// Minimal fakes — only the surface area touched during build() / _initialize()
// needs to exist. Descope is uninitialised in tests so _initialize() hits
// the LateInitializationError catch and returns early.
// ---------------------------------------------------------------------------

class FakeApiService extends Fake implements ApiService {}

class FakeStorageService extends Fake implements SecureStorageService {}

class FakeBiometricService extends Fake implements BiometricService {}

class FakeAnalyticsService extends Fake implements AnalyticsService {
  @override
  void logLoginStart() {}
}

void main() {
  group('AuthNotifier Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer(
        overrides: [
          apiServiceProvider.overrideWithValue(FakeApiService()),
          storageServiceProvider.overrideWithValue(FakeStorageService()),
          biometricServiceProvider.overrideWithValue(FakeBiometricService()),
          analyticsServiceProvider.overrideWithValue(FakeAnalyticsService()),
        ],
      );
    });

    tearDown(() => container.dispose());

    test('Initial state should be unauthenticated', () async {
      final authState = container.read(authProvider);
      // build() returns AuthState.initial() synchronously — unauthenticated
      // with isInitialized: false. _initialize() runs as a microtask.
      expect(authState.status, AuthStatus.unauthenticated);
      expect(authState.isInitialized, false);

      // Let _initialize() microtask complete (Descope not initialised →
      // caught → sets unauthenticated with isInitialized: true).
      await Future.delayed(Duration.zero);

      final settled = container.read(authProvider);
      expect(settled.status, AuthStatus.unauthenticated);
      expect(settled.isInitialized, true);
    });

    // Add more tests here for userVerify and userLogin.
    // With the provider overrides above you can now supply fake implementations
    // that return canned responses without hitting platform channels.
  });
}
