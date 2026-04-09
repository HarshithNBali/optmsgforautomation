// Tests for the simplified ActionBiometricGuard API.
// The grace period logic now lives in BiometricLockController,
// which requires a full integration test with mocked MethodChannel.
import 'package:flutter_test/flutter_test.dart';
import 'package:optmsg/services/action_biometric_guard.dart';

void main() {
  group('ActionBiometricGuard', () {
    test('markDeparture is safe when controller is null', () {
      // On web or before MyApp initializes, no controller is set.
      expect(() => ActionBiometricGuard.markDeparture(), returnsNormally);
    });

    test('markReturn is safe when controller is null', () {
      expect(() => ActionBiometricGuard.markReturn(), returnsNormally);
    });
  });
}
