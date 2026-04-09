import 'dart:async';

import 'package:optmsg/common/utilites/logger.dart';
import 'package:optmsg/screens/auth/auth_riverpod/auth_notifier.dart';
import 'package:optmsg/services/descope_api_service.dart';
import 'package:descope/descope.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../model/auth/passkey_state.dart';
import '../../../services/analytics_service.dart';
import '../../../services/api_service.dart';
import '../../../services/common_service.dart';
import '../../../services/session_refresh_mutex.dart';
import 'package:optmsg/common/app_manger/app_cache.dart';
import '../../../services/storage_service.dart';
import '../../../constant/string_constant.dart';

final passkeyProvider =
    NotifierProvider<PasskeyNotifier, PasskeyState>(PasskeyNotifier.new);

class PasskeyNotifier extends Notifier<PasskeyState> {
  final AnalyticsService _analytics = AnalyticsService.instance;
  bool _disposed = false;

  /// B-02: Static completer prevents concurrent _init() calls from racing.
  /// Reset on each build() so a fresh provider gets a fresh init.
  static Completer<void>? _initCompleter;

  late final SecureStorageService _storage;

  @override
  PasskeyState build() {
    _storage = ref.read(storageServiceProvider);
    _disposed = false;
    _initCompleter = null; // Reset for this provider lifecycle
    ref.onDispose(() {
      _disposed = true;
      _initCompleter = null;
      // A-08: Clear the flag on disposal so a mid-flight navigation doesn't
      // permanently block JWT refreshes.
      SessionRefreshMutex.passkeyFlowInProgress = false;
    });
    Future.microtask(_init);
    return const PasskeyState();
  }

  /// Initialize passkey screen
  /// B-02: Protected by a Completer — if already in-flight, returns the
  /// existing future instead of starting a concurrent read/write cycle.
  Future<void> _init() async {
    if (_initCompleter != null) return _initCompleter!.future;
    _initCompleter = Completer<void>();

    try {
      await _doInit();
      _initCompleter?.complete();
    } catch (e) {
      _initCompleter?.completeError(e);
    }
  }

  Future<void> _doInit() async {
    if (_disposed) return;
    state = state.copyWith(isLoading: true);

    try {
      // Load user data from in-memory auth state (single source of truth)
      final userData = ref.read(authProvider).userData;
      if (_disposed) return;

      // Check device-local onboarding completion flag (survives logout)
      final onboardingDone =
          await _storage.readData('hasCompletedOnboarding') == 'true';
      if (_disposed) return;

      // Check passkey support
      bool supported = false;
      try {
        supported = await Descope.passkey.isSupported();
      } catch (_) {
        // Passkey not supported on this device
      }
      if (_disposed) return;

      state = state.copyWith(
        userData: userData,
        passkeySupported: supported,
        hasCompletedOnboarding: onboardingDone,
        isLoading: false,
      );
    } catch (e) {
      if (_disposed) return;
      state = state.copyWith(
        errorMessage: 'Failed to load user data',
        isLoading: false,
      );
    }
  }

  /// Enable passkey
  Future<bool> enablePasskey() async {
    _analytics.logPasskeyEnrollStart();
    printLog('[PASSKEY] enablePasskey called',
        'canEnable=${state.canEnable} passkeySupported=${state.passkeySupported} hasUserData=${state.hasUserData} isLoading=${state.isLoading}');

    if (!state.canEnable) {
      printLog('[PASSKEY] blocked', 'canEnable=false — returning false');
      return false;
    }

    state = state.copyWith(isEnabling: true, errorMessage: null);
    SessionRefreshMutex.passkeyFlowInProgress = true;

    try {
      // ⚠️ DO NOT refresh session here.
      // Refreshing creates a new JWT before passkey.add() starts registration.
      // Descope binds the WebAuthn challenge to the JWT used in /start.
      // If a refresh happens mid-flow (during HiddenActivity), the /finish
      // call uses a different JWT → challenge mismatch → "Error signing registration".
      // Use the existing stable session directly.
      final session = Descope.sessionManager.session;
      printLog('PasskeyNotifier',
          'session=${session == null ? "NULL" : "present"} refreshJwt.length=${session?.refreshJwt.length ?? 0}');

      if (session == null) {
        printLog(
            'PasskeyNotifier', 'No active session — cannot enroll passkey');
        throw Exception('No active Descope session found');
      }

      final loginId = state.loginId;
      printLog('PasskeyNotifier',
          'Calling passkey.add() loginId="$loginId"');

      if (loginId.isEmpty) {
        throw Exception('loginId is empty — cannot enroll passkey');
      }

      // Add passkey via Descope — uses stable session, no pre-refresh.
      // A short timeout would be harmful (iOS Face ID + iCloud Keychain
      // sync regularly exceeds 30s), but a 5-minute ceiling prevents the
      // UI from hanging indefinitely if the user dismisses the system
      // dialog and iOS never fires the cancellation callback.
      await Descope.passkey.add(
        loginId: loginId,
        refreshJwt: session.refreshJwt,
      ).timeout(
        const Duration(minutes: 5),
        onTimeout: () => throw Exception(
            'Passkey setup is taking too long. Try again later.'),
      );
      // H-19: Guard after every async gap
      if (_disposed) return false;
      printLog('PasskeyNotifier', 'Descope.passkey.add() SUCCEEDED');

      // Update webauthn status
      await _updateWebAuthn();
      if (_disposed) return false;

      // Send notification
      await _sendNotification();
      if (_disposed) return false;

      // Passkey registration is complete — allow session refresh again
      // before the verification call which needs a valid JWT.
      SessionRefreshMutex.passkeyFlowInProgress = false;

      // Verify passkey was added (non-fatal — passkey is already registered)
      bool webauthn = true; // default to success since add() succeeded
      try {
        final response = await DescopeApiService().get('v1/auth/me');
        if (_disposed) return false;
        webauthn = response['webauthn'] ?? true;
        printLog('PasskeyNotifier', 'Final webauthn=$webauthn');
      } catch (e) {
        if (_disposed) return false;
        printLog('PasskeyNotifier',
            'Verification call failed (non-fatal, passkey already added): $e');
      }

      if (webauthn) {
        _analytics.logPasskeyEnrollSuccess();
        // Persist enrollment so the router knows the user has a passkey and
        // won't show the AddPassKey setup screen again on subsequent launches.
        await _storage.writeData('hasPasskeyEnrolled', 'true');
        AppCache().setHasPasskeyEnrolled(true);
      }
      state = state.copyWith(
        isEnabled: webauthn,
        isEnabling: false,
      );

      return webauthn;
    } on DescopeException catch (e) {
      _analytics.logPasskeyEnrollFail(e.desc);
      printLog('PasskeyNotifier',
          'DescopeException: code=${e.code} desc="${e.desc}" message="${e.message}"');

      // Case 1: server confirms passkey already registered — silent success.
      final isAlreadyEnrolled = e.desc.toLowerCase().contains('already') ||
          e.code == 'E062107';
      if (isAlreadyEnrolled) {
        await _storage.writeData('hasPasskeyEnrolled', 'true');
        AppCache().setHasPasskeyEnrolled(true);
        state = state.copyWith(isEnabled: true, isEnabling: false);
        return true;
      }

      // Case 2: device already has a passkey credential for this user (e.g.
      // after app reinstall where local flags were cleared). Mark enrolled so
      // the Add Passkey page is skipped on the next login, then show a clear
      // message instead of the raw Descope error.
      final isDevicePasskeyConflict =
          e.desc.toLowerCase().contains('authentication failed');
      if (isDevicePasskeyConflict) {
        await _storage.writeData('hasPasskeyEnrolled', 'true');
        AppCache().setHasPasskeyEnrolled(true);
        CommonService.animatedToast('Passkey already exists', 'error');
        state = state.copyWith(isEnabled: true, isEnabling: false);
        return true;
      }

      final errorMsg = e.desc.isNotEmpty ? e.desc : catchError;
      state = state.copyWith(
        errorMessage: errorMsg,
        isEnabling: false,
      );
      CommonService.animatedToast(errorMsg, 'error');
      return false;
    } catch (e) {
      _analytics.logPasskeyEnrollFail(e.toString());
      printLog('PasskeyNotifier',
          'Unexpected exception type=${e.runtimeType} error=$e');
      state = state.copyWith(
        errorMessage: catchError,
        isEnabling: false,
      );
      CommonService.animatedToast(catchError, 'error');
      return false;
    } finally {
      // A-08: Guarantee the flag is always cleared — even if the notifier
      // is disposed mid-flight or an unexpected exception type is thrown.
      SessionRefreshMutex.passkeyFlowInProgress = false;
    }
  }

  /// Skip passkey setup
  void skip() {
    _analytics.logPasskeyEnrollSkip();
    state = state.copyWith(isEnabled: false);
  }

  /// Update webauthn status in database
  Future<void> _updateWebAuthn() async {
    try {
      await ApiService().post('user/update-webauth-descope', {
        "webauth": true,
      });
    } catch (e) {
      CommonService.animatedToast(catchError, 'error');
    }
  }

  /// Send notification about passkey addition
  Future<void> _sendNotification() async {
    try {
      await ApiService().post('user/send-notification', {"type": "passKeyAdd"});
    } catch (e) {
      CommonService.animatedToast(catchError, 'error');
    }
  }
}
