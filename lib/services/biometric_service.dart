import 'package:local_auth/local_auth.dart';
import 'package:optmsg/common/utilites/logger.dart';

/// Result of a biometric authentication attempt, distinguishing hardware
/// issues from user cancellation so callers can decide the correct fallback.
enum BiometricResult {
  success,
  failed, // User cancelled or failed authentication
  hardwareUnavailable, // No enrolled biometrics or sensor error
}

class BiometricService {
  final LocalAuthentication _localAuthentication = LocalAuthentication();

  // Check if biometric authentication is available on the device
  Future<bool> isBiometricAvailable() async {
    try {
      bool canCheckBiometrics = await _localAuthentication.canCheckBiometrics;
      printLog(
          '[BIOMETRIC] isBiometricAvailable', canCheckBiometrics.toString());
      return canCheckBiometrics;
    } catch (e) {
      printLog('[BIOMETRIC] isBiometricAvailable exception', e.toString());
      return false;
    }
  }

  /// Authenticate with a rich result that distinguishes hardware-unavailable
  /// from user cancellation/failure.
  Future<BiometricResult> authenticateWithResult({
    String localizedReason = 'Please authenticate to access the app',
  }) async {
    try {
      bool isAvailable = await isBiometricAvailable();
      if (!isAvailable) {
        printLog(
            '[BIOMETRIC] authenticate', 'Skipped — not available on device');
        return BiometricResult.hardwareUnavailable;
      }

      printLog('[BIOMETRIC] authenticate', 'Showing system prompt...');
      // Bug 14: persistAcrossBackgrounding must be false (the default) so iOS
      // does not cache the biometric result across app-switch cycles.
      // _checkAndLockIfNeeded() in main.dart handles the re-prompt on resume.
      bool authenticated = await _localAuthentication.authenticate(
        localizedReason: localizedReason,
      );

      printLog('[BIOMETRIC] authenticate result', authenticated.toString());
      return authenticated ? BiometricResult.success : BiometricResult.failed;
    } catch (e) {
      printLog('[BIOMETRIC] authenticate exception', e.toString());
      return BiometricResult.failed;
    }
  }

  // Authenticate using biometric (legacy bool API).
  // [localizedReason] overrides the default prompt shown by the OS dialog.
  Future<bool> authenticate({
    String localizedReason = 'Please authenticate to access the app',
  }) async {
    final result =
        await authenticateWithResult(localizedReason: localizedReason);
    return result == BiometricResult.success;
  }
}
