import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb, ValueNotifier;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:optmsg/common/utilites/logger.dart';
import 'package:optmsg/services/biometric_service.dart';
import 'package:optmsg/services/storage_service.dart';

/// Single state machine for biometric lock.
///
/// Replaces the 7+ boolean/DateTime flags that were scattered across
/// _MyAppState with one enum. Every UI and lifecycle decision reads from
/// [state] and nothing else.
enum BiometricLockState {
  /// App content is visible, no overlay.
  unlocked,

  /// Splash overlay shown (app-switcher protection / brief transition).
  /// The user cannot interact with content but no biometric is required.
  privacyShield,

  /// Lock screen with "Unlock" button. Biometric is required.
  locked,

  /// Biometric dialog is active. Suppresses lifecycle re-entry.
  authenticating,
}

/// Centralised biometric lock controller.
///
/// Owns the single [state] ValueNotifier, the cached biometric-enabled flag,
/// the grace-period logic, and the native privacy overlay coordination.
/// main.dart delegates all lifecycle events here and renders a single
/// `ValueListenableBuilder<BiometricLockState>`.
class BiometricLockController {
  BiometricLockController({
    required MethodChannel privacyChannel,
    required BiometricService biometricService,
    required GlobalKey<NavigatorState> navigatorKey,
    required Future<void> Function() performLogout,
  })  : _privacyChannel = privacyChannel,
        _biometricService = biometricService,
        _navigatorKey = navigatorKey,
        _performLogout = performLogout;

  final MethodChannel _privacyChannel;
  final BiometricService _biometricService;
  final GlobalKey<NavigatorState> _navigatorKey;
  final Future<void> Function() _performLogout;
  final SecureStorageService _storage = SecureStorageService();

  // ── Public state ──────────────────────────────────────────────────────

  /// The single source of truth. UI renders from this.
  /// Defaults to [privacyShield] on mobile so the splash covers content
  /// from the very first frame (prevents content flash on cold start).
  final ValueNotifier<BiometricLockState> state =
      ValueNotifier(kIsWeb ? BiometricLockState.unlocked : BiometricLockState.privacyShield);

  // ── Internal state ────────────────────────────────────────────────────

  /// Cached biometric-enabled flag. Updated only on init and setting change.
  bool _isBiometricEnabled = false;

  /// When the app last entered `paused` (used for grace-period calculation).
  DateTime? _backgroundedAt;

  /// When an action departure was marked (link, print, file open).
  /// Auto-expires at [_actionGrace].
  DateTime? _actionDepartureAt;

  // ── Grace periods ─────────────────────────────────────────────────────

  /// How long the app can be backgrounded before requiring biometric.
  /// 2 seconds eliminates notification-shade, rotation, and dialog churn
  /// without meaningfully reducing security (the native overlay still
  /// hides content immediately on background).
  static const Duration _baseGrace = Duration(seconds: 2);

  /// Grace period for genuine action departures (link click, file open,
  /// print). 30 seconds lets the user return from the external activity
  /// without being re-prompted.
  static const Duration _actionGrace = Duration(seconds: 30);

  // ── Initialisation ────────────────────────────────────────────────────

  /// One-time setup. Reads biometric setting from storage and handles
  /// cold-start lock if the user is authenticated with biometric enabled.
  ///
  /// [hasSession] comes from `Descope.sessionManager.session != null` which
  /// is available synchronously after `loadSession()` in main().
  /// Auth state is read from SecureStorage (NOT the Riverpod provider) because
  /// the auth notifier hasn't initialized yet at `initState()` time — its
  /// `_initialize()` runs via `Future.microtask`.
  Future<void> initialize({required bool hasSession}) async {
    if (kIsWeb) return;

    try {
      final val = await _storage.readData('isBiometricEnable');
      _isBiometricEnabled = val == 'true';

      if (_isBiometricEnabled) {
        final isAuth = await _storage.readData('isAuthenticated');
        if (isAuth == 'true' && hasSession) {
          _setNativePrivacyScreen(true);
          state.value = BiometricLockState.locked;
          _waitForNavigatorAndUnlock();
          return; // Keep overlay until biometric resolves
        }
      }

      // Biometric not enabled OR user not authenticated — show content.
      state.value = BiometricLockState.unlocked;
      _setNativePrivacyScreen(false);
    } catch (e) {
      printLog('[BIOMETRIC] Cold-start init error', '$e');
      state.value = BiometricLockState.unlocked;
      _setNativePrivacyScreen(false);
    }
  }

  // ── Lifecycle delegates ───────────────────────────────────────────────

  /// Called when the app transitions to [AppLifecycleState.inactive].
  /// Shows the privacy shield so the app-switcher screenshot is branded.
  void onLifecycleInactive(bool isAuthenticated) {
    if (kIsWeb) return;
    if (!isAuthenticated || !_isBiometricEnabled) return;
    // Don't re-show overlay if we're already authenticating (dialog churn).
    if (state.value == BiometricLockState.authenticating) return;
    // Don't show overlay if we're already locked.
    if (state.value == BiometricLockState.locked) return;

    state.value = BiometricLockState.privacyShield;
  }

  /// Called when the app transitions to [AppLifecycleState.paused].
  /// Records the background timestamp for grace-period calculation.
  void onLifecyclePaused(bool isAuthenticated) {
    if (kIsWeb) return;

    // Native overlay for ALL authenticated users (app-switcher protection).
    if (isAuthenticated) {
      _setNativePrivacyScreen(true);
    }

    // Don't record background during biometric dialog — its own lifecycle
    // churn (paused->resumed) would cause an infinite lock loop.
    if (state.value == BiometricLockState.authenticating) return;

    if (isAuthenticated && _isBiometricEnabled) {
      _backgroundedAt = DateTime.now();
      // Only show lock immediately if NOT within action grace.
      if (!_isActionDepartureActive) {
        state.value = BiometricLockState.locked;
      } else {
        // Action departure — keep privacy shield, decide on resume.
        if (state.value == BiometricLockState.unlocked) {
          state.value = BiometricLockState.privacyShield;
        }
      }
    }
  }

  /// Called when the app transitions to [AppLifecycleState.resumed].
  /// Core decision: check grace period, then lock or unlock.
  Future<void> onLifecycleResumed(bool isAuthenticated) async {
    if (kIsWeb) return;

    // Not authenticated — nothing to protect.
    if (!isAuthenticated) {
      state.value = BiometricLockState.unlocked;
      _hideNativePrivacyOverlay();
      _backgroundedAt = null;
      return;
    }

    // Already authenticating — don't interfere.
    if (state.value == BiometricLockState.authenticating) return;

    // Biometric not enabled — dismiss everything.
    if (!_isBiometricEnabled) {
      state.value = BiometricLockState.unlocked;
      _hideNativePrivacyOverlay();
      _setNativePrivacyScreen(false);
      _backgroundedAt = null;
      return;
    }

    // No background event recorded — was just rotation or notification shade
    // that didn't reach `paused`, or _backgroundedAt was already consumed.
    final backgrounded = _backgroundedAt;
    if (backgrounded == null) {
      // If we showed a privacy shield during inactive, dismiss it now.
      if (state.value == BiometricLockState.privacyShield) {
        state.value = BiometricLockState.unlocked;
        _hideNativePrivacyOverlay();
      }
      return;
    }

    // Grace period check.
    final elapsed = DateTime.now().difference(backgrounded);
    final effectiveGrace = _isActionDepartureActive ? _actionGrace : _baseGrace;

    if (elapsed < effectiveGrace) {
      printLog('[BIOMETRIC] Within grace — skip lock',
          'elapsed=${elapsed.inMilliseconds}ms grace=${effectiveGrace.inSeconds}s');
      state.value = BiometricLockState.unlocked;
      _hideNativePrivacyOverlay();
      _backgroundedAt = null;
      return;
    }

    // Outside grace — lock and prompt biometric.
    printLog('[BIOMETRIC] Locking app', 'elapsed=${elapsed.inMilliseconds}ms');
    state.value = BiometricLockState.locked;
    await triggerUnlock();
  }

  // ── Biometric unlock ──────────────────────────────────────────────────

  /// Shows the biometric dialog and handles success/fail/retry/logout.
  Future<void> triggerUnlock() async {
    if (state.value == BiometricLockState.authenticating) return;
    state.value = BiometricLockState.authenticating;

    try {
      // Hide native overlay so the biometric animation is visible.
      _hideNativePrivacyOverlay();

      final result = await _biometricService.authenticateWithResult();
      printLog('[BIOMETRIC] Unlock result', result.toString());

      if (result == BiometricResult.success) {
        _unlock();
      } else if (result == BiometricResult.hardwareUnavailable) {
        // Fail-open: user already proved identity via Descope.
        printLog('[BIOMETRIC] Hardware unavailable — fail-open', '');
        _unlock();
      } else {
        // User failed or cancelled — show retry dialog.
        printLog('[BIOMETRIC] First attempt failed — showing retry', '');
        final retry = await _showRetryDialog();
        if (retry == true) {
          final retryResult =
              await _biometricService.authenticateWithResult();
          if (retryResult == BiometricResult.success ||
              retryResult == BiometricResult.hardwareUnavailable) {
            _unlock();
          } else {
            printLog('[BIOMETRIC] Retry failed — logging out', '');
            await _performLogout();
            _unlock(); // Dismiss overlay after logout
          }
        } else {
          printLog('[BIOMETRIC] User chose logout', '');
          await _performLogout();
          _unlock(); // Dismiss overlay after logout
        }
      }
    } catch (e) {
      printLog('[BIOMETRIC] Unlock error', '$e');
      // On unexpected error, fail-open rather than trapping the user.
      _unlock();
    }
  }

  void _unlock() {
    state.value = BiometricLockState.unlocked;
    _hideNativePrivacyOverlay();
    _backgroundedAt = null;
    // Force the engine to schedule a new frame (Android BiometricPrompt
    // can leave the rendering pipeline idle).
    WidgetsBinding.instance.scheduleFrame();
  }

  // ── Auth state changes ────────────────────────────────────────────────

  /// Called after a successful login. Dismisses overlays without prompting.
  void onAuthenticated() {
    if (kIsWeb) return;
    _backgroundedAt = null;
    state.value = BiometricLockState.unlocked;
    _hideNativePrivacyOverlay();
    // Refresh cached flag — the login may have set biometric preference.
    _refreshBiometricSetting();
  }

  /// Called when auth initializes to unauthenticated (login screen).
  void onUnauthenticated() {
    if (kIsWeb) return;
    state.value = BiometricLockState.unlocked;
    _hideNativePrivacyOverlay();
    _setNativePrivacyScreen(false);
  }

  /// Called when the user logs out.
  void onLoggedOut() {
    if (kIsWeb) return;
    _backgroundedAt = null;
    _actionDepartureAt = null;
    _isBiometricEnabled = false;
    state.value = BiometricLockState.unlocked;
    _hideNativePrivacyOverlay();
    _setNativePrivacyScreen(false);
  }

  // ── Biometric setting ─────────────────────────────────────────────────

  /// Called from settings toggle (via callback). Updates cached flag.
  void onBiometricSettingChanged(bool enabled) {
    _isBiometricEnabled = enabled;
    if (!enabled) {
      // Disable all overlays.
      if (state.value != BiometricLockState.unlocked) {
        state.value = BiometricLockState.unlocked;
        _hideNativePrivacyOverlay();
      }
      _setNativePrivacyScreen(false);
    } else {
      _setNativePrivacyScreen(true);
    }
  }

  /// Re-reads biometric setting from storage (async). Used after login
  /// when the server may have set the user's biometric preference.
  Future<void> _refreshBiometricSetting() async {
    final val = await _storage.readData('isBiometricEnable');
    _isBiometricEnabled = val == 'true';
    _setNativePrivacyScreen(_isBiometricEnabled);
  }

  // ── Action departures ─────────────────────────────────────────────────

  /// Mark an action departure (link click, file open, print, download).
  /// Applies a 30-second grace period on return instead of the 2-second base.
  void markActionDeparture() {
    if (kIsWeb || !_isBiometricEnabled) return;
    _actionDepartureAt = DateTime.now();
  }

  /// Mark that the action is complete (e.g., print dialog dismissed).
  void markActionReturn() {
    _actionDepartureAt = null;
  }

  /// Whether an action departure is active and within the 30-second window.
  bool get _isActionDepartureActive {
    if (_actionDepartureAt == null) return false;
    if (DateTime.now().difference(_actionDepartureAt!) > _actionGrace) {
      _actionDepartureAt = null; // auto-expire
      return false;
    }
    return true;
  }

  /// Public getter for use by other lifecycle observers (e.g., DraftResponsive).
  bool get isActionDepartureActive => _isActionDepartureActive;

  // ── Native overlay coordination ───────────────────────────────────────

  void _setNativePrivacyScreen(bool enabled) {
    _privacyChannel
        .invokeMethod('setPrivacyScreenEnabled', enabled)
        .catchError(
            (e) => printLog('[PRIVACY] Failed to set native privacy', '$e'));
  }

  Future<void> _hideNativePrivacyOverlay() async {
    try {
      await _privacyChannel
          .invokeMethod('hidePrivacyOverlay')
          .timeout(const Duration(milliseconds: 500));
    } catch (e) {
      printLog('[PRIVACY] hidePrivacyOverlay failed', '$e');
    }
  }

  // ── Retry dialog ──────────────────────────────────────────────────────

  Future<bool?> _showRetryDialog() async {
    BuildContext? ctx = _navigatorKey.currentContext;
    if (ctx == null) {
      // Navigator not ready (cold-start race). Poll briefly.
      for (int i = 0; i < 50; i++) {
        await Future.delayed(const Duration(milliseconds: 100));
        ctx = _navigatorKey.currentContext;
        if (ctx != null) break;
      }
      if (ctx == null) return true; // Force retry rather than silent logout
    }
    return showDialog<bool>(
      context: ctx,
      barrierDismissible: false,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Authentication Failed'),
        content: const Text(
          'Would you like to try again? You can also use your device passcode.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(false),
            child: const Text('Log Out'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogCtx).pop(true),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  // ── Cold-start helper ─────────────────────────────────────────────────

  void _waitForNavigatorAndUnlock() {
    if (_navigatorKey.currentContext != null) {
      triggerUnlock();
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      for (int i = 0; i < 50; i++) {
        if (_navigatorKey.currentContext != null) break;
        await Future.delayed(const Duration(milliseconds: 100));
      }
      triggerUnlock();
    });
  }

  // ── Cleanup ───────────────────────────────────────────────────────────

  void dispose() {
    state.dispose();
  }
}
