import 'package:flutter_test/flutter_test.dart';
import 'package:optmsg/services/action_biometric_guard.dart';

void main() {
  group('ActionBiometricGuard', () {
    test('markDeparture does not throw when no controller is set', () {
      // When MyApp.lockController is null (e.g., on web or before init),
      // markDeparture should be a safe no-op.
      expect(() => ActionBiometricGuard.markDeparture(), returnsNormally);
    });

    test('markReturn does not throw when no controller is set', () {
      expect(() => ActionBiometricGuard.markReturn(), returnsNormally);
    });
  });
}
