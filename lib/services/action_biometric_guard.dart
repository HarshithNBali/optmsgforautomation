import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:optmsg/main.dart' show MyApp;

/// Marks action departures (link click, file open, print, download)
/// so the biometric lock controller applies a 30-second grace period
/// on return instead of the 2-second base grace.
class ActionBiometricGuard {
  /// Mark an action departure. Call BEFORE launching the external activity.
  static void markDeparture() {
    if (kIsWeb) return;
    MyApp.lockController?.markActionDeparture();
  }

  /// Mark that the action is complete. Call AFTER the external activity.
  static void markReturn() {
    if (kIsWeb) return;
    MyApp.lockController?.markActionReturn();
  }
}
