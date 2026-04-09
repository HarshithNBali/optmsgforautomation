/// Mock classes for all core services using mocktail.
///
/// Import this file to get access to mock implementations of all services.
/// These mocks can be configured with `when(() => mock.method()).thenReturn()`
/// or `when(() => mock.method()).thenAnswer((_) async => value)`.
library;

import 'package:mocktail/mocktail.dart';
import 'package:optmsg/services/api_service.dart';
import 'package:optmsg/services/storage_service.dart';
import 'package:optmsg/services/biometric_service.dart';
import 'package:optmsg/services/analytics_service.dart';
import 'package:optmsg/services/socket_service.dart';

// ---------------------------------------------------------------------------
// Service mocks
// ---------------------------------------------------------------------------

class MockApiService extends Mock implements ApiService {}

class MockSecureStorageService extends Mock implements SecureStorageService {}

class MockBiometricService extends Mock implements BiometricService {}

class MockAnalyticsService extends Mock implements AnalyticsService {}

class MockSocketService extends Mock implements SocketService {}

// ---------------------------------------------------------------------------
// Fake classes (for registerFallbackValue)
// ---------------------------------------------------------------------------

class FakeUri extends Fake implements Uri {}

// ---------------------------------------------------------------------------
// Default stub setups — call these in setUp() for common happy-path behavior.
// ---------------------------------------------------------------------------

/// Configures [mock] with sensible defaults for storage operations.
/// All reads return null, all writes/deletes complete successfully.
void stubStorageDefaults(MockSecureStorageService mock) {
  when(() => mock.readData(any())).thenAnswer((_) async => null);
  when(() => mock.writeData(any(), any())).thenAnswer((_) async {});
  when(() => mock.deleteData(any())).thenAnswer((_) async {});
  when(() => mock.clearAllData()).thenAnswer((_) async {});
  when(() => mock.clearSecureStorage()).thenAnswer((_) async {});
  when(() => mock.clearAllPrefs()).thenAnswer((_) async {});
  when(() => mock.setBool(any(), any())).thenAnswer((_) async {});
  when(() => mock.getBool(any())).thenAnswer((_) async => null);
  when(() => mock.setString(any(), any())).thenAnswer((_) async {});
  when(() => mock.getString(any())).thenAnswer((_) async => null);
  when(() => mock.removePref(any())).thenAnswer((_) async {});
  when(() => mock.readObjectData(any())).thenAnswer((_) async => null);
  when(() => mock.writeObjectData(any(), any())).thenAnswer((_) async {});
}

/// Configures [mock] with sensible defaults for biometric operations.
/// Biometrics available, authentication succeeds.
void stubBiometricDefaults(MockBiometricService mock) {
  when(() => mock.isBiometricAvailable()).thenAnswer((_) async => true);
  when(() => mock.authenticate(localizedReason: any(named: 'localizedReason')))
      .thenAnswer((_) async => true);
  when(() => mock.authenticateWithResult(
          localizedReason: any(named: 'localizedReason')))
      .thenAnswer((_) async => BiometricResult.success);
}

/// Configures [mock] with sensible defaults for socket operations.
/// Disconnect is a no-op, onEvent returns an empty stream, emitEventWithAck is a no-op.
void stubSocketDefaults(MockSocketService mock) {
  when(() => mock.disconnect()).thenReturn(null);
  when(() => mock.onEvent(any())).thenAnswer((_) => const Stream.empty());
  when(() => mock.initSocket(any(), any(), any())).thenAnswer((_) async {});
}

/// Configures [mock] as a no-op analytics service (all methods are void).
void stubAnalyticsDefaults(MockAnalyticsService mock) {
  when(() => mock.logEvent(any(), any())).thenReturn(null);
  when(() => mock.setUserProperty(any(), any())).thenReturn(null);
  when(() => mock.logLoginStart()).thenReturn(null);
  when(() => mock.logLoginPasskeyAttempt()).thenReturn(null);
  when(() => mock.logLoginPasskeySuccess()).thenReturn(null);
}
