import 'dart:async';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:descope/descope.dart';
import 'package:optmsg/constant/app_config.dart';
import 'package:optmsg/main.dart' show firebaseReady;

import 'package:shared_preferences/shared_preferences.dart';
import 'package:optmsg/model/auth/auth_state.dart';
import 'package:optmsg/model/login_model.dart';
import 'package:optmsg/services/api_service.dart';
import 'package:optmsg/services/storage_service.dart';
import 'package:optmsg/services/common_service.dart';
import 'package:optmsg/services/biometric_service.dart';
import 'package:optmsg/repositories/end_point/end_point.dart';
import 'package:optmsg/common/app_manger/app_cache.dart';
import 'package:optmsg/common/utilites/logger.dart';
import 'package:optmsg/services/descope_error_mapper.dart';
import 'package:optmsg/router/app_router.dart' show muteRouterRefresh;
import 'package:optmsg/router/route_observer_service.dart';
import 'package:optmsg/services/analytics_service.dart';
import 'package:optmsg/services/session_refresh_mutex.dart';
import 'package:optmsg/services/socket_service.dart';
import 'package:app_badge_plus/app_badge_plus.dart';
import 'package:optmsg/repositories/email/inbox_api.dart';
import 'package:optmsg/repositories/email/draft_api.dart';
import 'package:optmsg/repositories/tags/tag_api.dart';
import 'package:optmsg/repositories/setting/setting_api.dart';
import 'package:optmsg/repositories/email/archive_api.dart';
import 'package:optmsg/repositories/account/account_api.dart';
import 'package:optmsg/services/html_sanitizer_service.dart';

const String _tag = '[AUTH]';

/// Validates a subscription from a login response.
/// Paid (non-free) users are always valid; free users must have a future end-date.
/// This is exported so that OTP screens can apply the same logic without duplication.
bool isSubscriptionValid(LoginModel login) {
  final user = login.data.user;
  if (!(user.isFreeUser ?? false)) return true;
  final raw = user.subscriptionEndDate ?? 0;
  // Backend sends seconds since epoch. Convert to milliseconds for Dart.
  // A seconds-based timestamp for any reasonable date (before year 2100)
  // will be below 4,102,444,800 (~13 digits in ms vs ~10 in seconds).
  // We use 10,000,000,000 as a safe threshold that works until year 2286.
  final endMs = raw < 10000000000 ? raw * 1000 : raw;
  return DateTime.fromMillisecondsSinceEpoch(endMs).isAfter(DateTime.now());
}

// ---------------------------------------------------------------------------
// Service providers — override these in tests to inject fakes/mocks.
// ---------------------------------------------------------------------------
final apiServiceProvider = Provider<ApiService>((ref) => ApiService());
final storageServiceProvider =
    Provider<SecureStorageService>((ref) => SecureStorageService());
final biometricServiceProvider =
    Provider<BiometricService>((ref) => BiometricService());
final analyticsServiceProvider =
    Provider<AnalyticsService>((ref) => AnalyticsService.instance);
final socketServiceProvider =
    Provider<SocketService>((ref) => SocketService());

// Repository providers — override in tests to inject mocks.
final inboxApiProvider = Provider<InboxApi>((ref) => InboxApi());
final draftApiProvider = Provider<DraftApi>((ref) => DraftApi());
final tagApiProvider = Provider<TagApi>((ref) => TagApi());
final settingApiProvider = Provider<SettingApi>((ref) => SettingApi());
final archiveApiProvider = Provider<ArchiveApi>((ref) => ArchiveApi());
final accountApiProvider = Provider<AccountApi>((ref) => AccountApi());

final authProvider = NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);


class AuthNotifier extends Notifier<AuthState> {
  late final ApiService _apiService;
  late final SecureStorageService _storageService;
  late final BiometricService _biometricService;
  late final AnalyticsService _analytics;

  Timer? _debounceTimer;
  bool _disposed = false;

  @override
  AuthState build() {
    _apiService = ref.read(apiServiceProvider);
    _storageService = ref.read(storageServiceProvider);
    _biometricService = ref.read(biometricServiceProvider);
    _analytics = ref.read(analyticsServiceProvider);
    _disposed = false;
    ref.onDispose(() {
      _disposed = true;
      _debounceTimer?.cancel();
    });
    Future.microtask(_initialize);
    return AuthState.initial();
  }

  // ─── Firebase observability helpers ──────────────────────────────────────

  void _setFirebaseUser(Map<String, dynamic> data) {
    if (!firebaseReady) return;
    try {
      final userId = data['user']?['id']?.toString();
      if (userId != null) {
        // L-08: Crashlytics is not available on web.
        if (!kIsWeb) FirebaseCrashlytics.instance.setUserIdentifier(userId);
        FirebaseAnalytics.instance.setUserId(id: userId);
      }
      final planName = data['user']?['planName']?.toString() ?? 'unknown';
      final isFree = (data['user']?['isFreeUser'] ?? false).toString();
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.setCustomKey('subscription_plan', planName);
        FirebaseCrashlytics.instance.setCustomKey('is_free_user', isFree);
      }
      FirebaseAnalytics.instance
          .setUserProperty(name: 'subscription_plan', value: planName);
      FirebaseAnalytics.instance
          .setUserProperty(name: 'is_free_user', value: isFree);
    } catch (_) {}
  }

  void _clearFirebaseUser() {
    if (!firebaseReady) return;
    try {
      // L-08: Crashlytics is not available on web.
      if (!kIsWeb) FirebaseCrashlytics.instance.setUserIdentifier('');
      FirebaseAnalytics.instance.setUserId(id: null);
      FirebaseAnalytics.instance
          .setUserProperty(name: 'subscription_plan', value: null);
      FirebaseAnalytics.instance
          .setUserProperty(name: 'is_free_user', value: null);
    } catch (_) {}
  }

  void _firebaseLog(String message) {
    if (!firebaseReady || kIsWeb) return;
    try {
      FirebaseCrashlytics.instance.log(message);
    } catch (_) {}
  }

  // ─── Initialization ────────────────────────────────────────────────────────

  Future<void> _initialize() async {
    // Use the Descope session as the primary source of truth.
    // loadSession() + refreshSessionIfNeeded() were already called in main()
    // before runApp(), so the session is either valid here or null (expired).
    late final DescopeSession? session;
    try {
      session = Descope.sessionManager.session;
    } catch (e) {
      if (e is! Error || !e.toString().contains('LateInitializationError')) rethrow;
      // Descope.setup() hasn't been called yet — provider was read too early.
      // Mark as unauthenticated; the router will show the login screen.
      printLog(_tag, 'Descope not initialized yet — treating as unauthenticated');
      if (_disposed) return;
      state = AuthState.unauthenticated();
      return;
    }
    final userData = await _storageService.readObjectData('userData');
    if (_disposed) return;

    if (session != null && !session.refreshToken.isExpired && userData != null) {
      // M-06: If session JWT is expired, try refreshing before marking authenticated.
      if (session.sessionToken.isExpired) {
        try {
          await Descope.sessionManager.refreshSessionIfNeeded();
        } catch (e) {
          // Only treat as unauthenticated if the refresh token is confirmed
          // expired OR if Descope explicitly rejected the refresh (server-side
          // revocation, e.g. E064001). Transient errors (network, timeout)
          // should not wipe a valid session — the periodic timer will retry.
          // DescopeException = server rejected refresh permanently.
          final current = Descope.sessionManager.session;
          if (current == null || current.refreshToken.isExpired || e is DescopeException) {
            Descope.sessionManager.clearSession();
            state = AuthState.unauthenticated();
            return;
          }
          // Refresh token still valid and error was transient (network) —
          // proceed with stale session JWT. The next API call or timer tick
          // will retry the refresh.
        }
      }
      state = AuthState.authenticated(userData);
      _setFirebaseUser(userData);
      // Clear stale signup flag on app restart if user is already authenticated
      // (they completed signup in a previous session).
      final isSubscribed = userData['user']?['isSubscribed'] == true;
      if (isSubscribed) {
        await _storageService.writeData('signupInProgress', 'false');
        AppCache().setSignupInProgress('false');
        // Bug 20: Clear stale isCheckout flag from a previous payment session.
        // Without this, the Stripe recovery guard in app_router could fire
        // incorrectly on subsequent logins.
        await _storageService.writeData('isCheckout', 'false');
        AppCache().setIsCheckout('false');
        if (kIsWeb) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.remove('isCheckout');
        }
      }
    } else if (session != null && !session.refreshToken.isExpired && userData == null) {
      // ST-3 (web) + ST-12 (mobile): The Descope session is valid but
      // userData is missing. On web this happens when sessionStorage is
      // cleared on page refresh. On iOS/Android it happens when the OS kills
      // the process under memory pressure or after extended background time
      // and flutter_secure_storage returns null on cold start.
      //
      // In both cases the fix is the same: refresh the JWT if needed, then
      // re-fetch the user profile from the backend.
      if (session.sessionToken.isExpired) {
        try {
          await Descope.sessionManager.refreshSessionIfNeeded();
        } catch (e) {
          final current = Descope.sessionManager.session;
          if (current == null || current.refreshToken.isExpired || e is DescopeException) {
            Descope.sessionManager.clearSession();
            state = AuthState.unauthenticated();
            return;
          }
        }
      }
      // N-5 (revised): Retry with exponential backoff so transient network
      // issues at cold start (airplane mode, slow connectivity) don't
      // unnecessarily log the user out when the refresh token is still valid.
      // CS-2: Reduced from [1,2,4,8]s (~30s total) to [200ms, 500ms, 1s, 2s]
      // (~4s total). The old 30s delays caused a very long splash screen on
      // Android when userData was missing (memory pressure, keychain edge case).
      // If the server is genuinely unreachable, 30s doesn't help — the user
      // will be prompted to retry on the login screen instead.
      const backoffDelays = [200, 500, 1000, 2000]; // milliseconds between retries
      for (var attempt = 0; attempt < 5; attempt++) {
        try {
          final response = await _apiService.get('user/get-profile');
          if (_disposed) return;
          if (response['success'] == true && response['data'] != null) {
            final restoredUserData = <String, dynamic>{'user': response['data']};
            await _storageService.writeObjectData('userData', restoredUserData);
            // Sync send limits from server (if included in profile response)
            SendLimits.updateFromServer(
                response['data']['sendLimits'] as Map<String, dynamic>?);
            state = AuthState.authenticated(restoredUserData);
            _setFirebaseUser(restoredUserData);
            return;
          }
          // A-09: Only treat explicit 401/403 as terminal (user truly not
          // authorised). Other failures (404 during propagation delay, 500,
          // 503, 429) are retried.
          final statusCode = response['statusCode'];
          if (statusCode == 401 || statusCode == 403) {
            break; // Terminal — don't retry.
          }
          // Non-success but retryable — fall through to retry logic.
          if (attempt < 4) {
            await Future.delayed(Duration(milliseconds: backoffDelays[attempt]));
            if (_disposed) return;
            continue;
          }
        } catch (_) {
          if (attempt < 4) {
            await Future.delayed(Duration(milliseconds: backoffDelays[attempt]));
            if (_disposed) return;
          }
          // Final attempt failed — fall through to unauthenticated.
        }
      }
      if (_disposed) return;
      Descope.sessionManager.clearSession();
      state = AuthState.unauthenticated();
    } else {
      // Clear any lingering Descope session so its JWT is never sent to
      // unauthenticated endpoints (e.g. the login endpoint returns 500 if it
      // receives a Descope JWT — even a valid one — from a previous session).
      if (Descope.sessionManager.session != null) {
        Descope.sessionManager.clearSession();
      }
      state = AuthState.unauthenticated();
    }
  }

  /// Clears any previous error so stale messages don't persist through retries.
  void _clearError() {
    if (state.hasError) {
      state = state.copyWith(status: AuthStatus.unauthenticated, errorMessage: null);
    }
  }

  // ================= VERIFICATION & LOGIN =================

  Future<void> userVerify(String userName) async {
    _clearError();
    _firebaseLog('auth: userVerify started');
    _analytics.logLoginStart();
    // Clear any stale Descope session before login to prevent 500 errors from stale JWT
    Descope.sessionManager.clearSession();
    if (kIsWeb) {
      await _storageService.writeData('upgradePopupShownAfterLogin', "false");
    } else {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('upgradePopupShownAfterLogin', false);
    }
    if (_disposed) return;

    state = AuthState.authenticating();

    // ─── WEB EARLY PASSKEY ──────────────────────────────────────────────────
    // On web, browsers (especially Safari) require navigator.credentials.get()
    // to be called within the browser's transient user-activation window (~5 s
    // after the button click).  The userVerify API call below can consume most
    // of that window on a slow connection, causing the WebAuthn ceremony to be
    // rejected even though the credential is valid.
    //
    // If the user's enrollment flag is persisted from a previous session, we
    // attempt sign-in HERE — before the API round-trip — keeping the call well
    // within the activation window (~15 ms vs potentially 3+ s).
    //
    // On success: return immediately (no API call needed).
    // On failure: set webEarlyPasskeyTried=true so the API-based flow skips the
    //             duplicate attempt and goes straight to the OTP fallback.
    bool webEarlyPasskeyTried = false;
    if (kIsWeb) {
      final enrolled =
          await _storageService.readData('hasPasskeyEnrolled') == 'true';
      if (enrolled) {
        bool supported = false;
        try {
          supported = await Descope.passkey.isSupported();
        } catch (_) {}
        if (supported) {
          webEarlyPasskeyTried = true;
          try {
            // A-06: Refresh session before passkey signIn so a stale JWT
            // doesn't cause the WebAuthn ceremony to fail silently.
            try {
              await Descope.sessionManager.refreshSessionIfNeeded();
            } catch (_) {
              // Best-effort — don't block the passkey flow on refresh failure.
            }
            printLog(_tag, 'Early web passkey attempt for: $userName');
            _firebaseLog('auth: early web passkey signIn');
            _analytics.logLoginPasskeyAttempt();
            final authResponse = await Descope.passkey
                .signIn(loginId: userName)
                .timeout(
                  const Duration(seconds: 30),
                  onTimeout: () =>
                      throw Exception('Passkey sign-in timed out'),
                );
            if (_disposed) return;

            final session =
                DescopeSession.fromAuthenticationResponse(authResponse);
            Descope.sessionManager.manageSession(session);
            _analytics.logLoginPasskeySuccess();

            final deviceToken =
                (await _storageService.readData('deviceToken')) ?? '';
            AppCache().setIsPasskeyPageOpen(true);
            SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.setBool('isPasskeyPageOpenStatus', true);
            if (_disposed) return;

            await userLogin(deviceToken);
            return; // ✅ Passkey succeeded — skip API call entirely
          } catch (e) {
            final causeInfo =
                e is DescopeException ? ' cause=${e.cause}' : '';
            printLog(_tag,
                'Early web passkey FAILED, continuing to API: $e$causeInfo');
            _firebaseLog(
                'auth: early web passkey failed, continuing to API flow');
            _analytics.logLoginPasskeyFail(e.toString());
            if (kDebugMode) {
              final desc = e is DescopeException ? e.desc : e.toString();
              CommonService.animatedToast('Passkey failed: $desc', 'error');
            }
          }
        }
      }
    }
    // ────────────────────────────────────────────────────────────────────────

    try {
      final response = await _apiService.post(
        EndPoints.userVerify.path,
        {'userName': userName},
      );
      if (_disposed) return;

      if (response['success'] == true) {
        if (response['data']['webauth'] != null &&
            response['data']['webauth']) {
          // Persist passkey enrollment status so the router can skip the
          // AddPassKey setup screen even when sign-in itself fails (e.g. on
          // iOS first launch before Associated Domains are cached, or on
          // Android before Digital Asset Links are verified).
          await _storageService.writeData('hasPasskeyEnrolled', 'true');
          AppCache().setHasPasskeyEnrolled(true);

          bool passkeySucceeded = false;

          // On web, skip the passkey attempt if the early attempt above
          // already ran — repeating it would just fail again for the same
          // reason and show a duplicate error toast.
          if (!webEarlyPasskeyTried) {
            bool passkeySupported = false;

            try {
              passkeySupported = await Descope.passkey.isSupported();
              printLog(_tag, 'Passkey isSupported() = $passkeySupported');
            } catch (e) {
              printLog("PasskeySupport", "isSupported() threw: $e");
            }
            if (_disposed) return;

            printLog(_tag, 'Passkey gate: passkeySupported=$passkeySupported, webauth=${response['data']['webauth']}');
            _firebaseLog('auth: passkey gate supported=$passkeySupported webauth=${response['data']['webauth']}');

            // Always attempt passkey sign-in when the backend confirms the
            // user has an enrolled passkey (webauth=true), even if
            // isSupported() returns false.  On fresh installs, iOS Associated
            // Domains and Android Digital Asset Links may not be verified yet,
            // causing isSupported() to return false even though the credential
            // exists.  The sign-in call is wrapped in try/catch, so a failure
            // still falls through to OTP safely.
            if (passkeySupported || response['data']['webauth'] == true) {
              try {
                printLog(_tag, 'Passkey signIn starting for: $userName');
                _firebaseLog('auth: passkey signIn starting');
                _analytics.logLoginPasskeyAttempt();
                final authResponse =
                    await Descope.passkey.signIn(loginId: userName).timeout(
                          const Duration(seconds: 30),
                          onTimeout: () =>
                              throw Exception('Passkey sign-in timed out'),
                        );
                if (_disposed) return;

                final session =
                    DescopeSession.fromAuthenticationResponse(authResponse);
                // manageSession() persists both JWTs automatically via the SDK.
                // No manual storage write is needed.
                Descope.sessionManager.manageSession(session);
                _analytics.logLoginPasskeySuccess();

                String deviceToken =
                    (await _storageService.readData('deviceToken')) ?? '';

                AppCache().setIsPasskeyPageOpen(true);
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.setBool('isPasskeyPageOpenStatus', true);
                if (_disposed) return;

                // Always call userLogin() so the backend records the session,
                // validates the subscription, and registers the device token.
                // Passing an empty string is safe — the backend handles it.
                await userLogin(deviceToken);
                passkeySucceeded = true;
                return;
              } catch (e, stackTrace) {
                // Passkey sign-in failed. Common causes on first launch:
                //   • iOS: Associated Domains not yet cached by the OS
                //   • Android: Digital Asset Links not yet verified post-install
                //   • User cancelled the system biometric prompt
                // Fall through to OTP so login can still complete. The
                // hasPasskeyEnrolled flag above ensures the router won't route
                // the user to AddPassKey setup afterward.
                final causeInfo =
                    e is DescopeException ? ' cause=${e.cause}' : '';
                printLog("PasskeySignIn",
                    "FAILED type=${e.runtimeType} error=$e$causeInfo");
                _firebaseLog(
                    'auth: passkey signIn FAILED type=${e.runtimeType} error=$e$causeInfo');
                if (firebaseReady && !kIsWeb) {
                  try {
                    FirebaseCrashlytics.instance.recordError(
                      e,
                      stackTrace,
                      reason: 'passkey_signin_failed',
                      fatal: false,
                    );
                  } catch (_) {}
                }
                _analytics.logLoginPasskeyFail(e.toString());
                if (kDebugMode) {
                  final desc = e is DescopeException ? '${e.code}: ${e.desc}' : e.toString();
                  CommonService.animatedToast(
                      'Passkey failed: $desc', 'error');
                }
                printLog("PasskeySignIn",
                    "Sign-in failed (may succeed on next launch): $e");
              }
            }
            if (_disposed) return;
          } else {
            printLog(_tag,
                'Skipping duplicate passkey attempt — early web attempt already ran');
          }

          if (!passkeySucceeded) {
            printLog(_tag, 'Passkey did not succeed, falling back to OTP');
            _firebaseLog('auth: passkey failed, OTP fallback');
            await _storageService.writeObjectData('userData', response['data']);
            try {
              await Descope.otp
                  .signIn(method: DeliveryMethod.sms, loginId: userName);
              _analytics.logLoginOtpSent(isFallback: true);
              if (_disposed) return;
              state = state.copyWith(
                status: AuthStatus.awaitingOtp,
                verifyUser: response,
                isDescopeLogin: true,
              );
            } on DescopeException catch (e) {
              if (_disposed) return;
              final msg = mapDescopeError(e);
              CommonService.animatedToast(msg, 'error');
              state = AuthState.error(msg, type: AuthErrorType.descopeError);
            }
          }
        } else {
          await _storageService.writeObjectData('userData', response['data']);
          _analytics.logLoginOtpSent(isFallback: false);
          if (_disposed) return;
          CommonService.animatedToast(response['message'], 'success');
          state = state.copyWith(
            status: AuthStatus.awaitingOtp,
            verifyUser: response,
            isDescopeLogin: false,
          );
        }
      } else {
        CommonService.animatedToast(
            response['message'] ?? 'Verification failed', 'error');
        state = AuthState.error(response['message'] ?? 'Verification failed');
      }
    } catch (e) {
      if (_disposed) return;
      state = AuthState.error(e.toString());
    }
  }

  Future<AuthState> userLogin(String deviceToken) async {
    _clearError();
    _firebaseLog('auth: login attempt');
    printLog("AuthNotifier", "userLogin with deviceToken: $deviceToken");
    state = AuthState.authenticating();
    try {
      final response = await _apiService.post(
        EndPoints.login.path,
        {"deviceToken": deviceToken},
      );
      if (_disposed) return state;
      printLog(
          "AuthNotifier", "userLogin response success: ${response['success']} (${response['success'].runtimeType}), message: ${response['message']}, statusCode: ${response['statusCode']}");

      if (response['success'] == true) {
        LoginModel login = LoginModel.fromJson(response);
        final bool isValid = isSubscriptionValid(login);
        printLog("AuthNotifier", "userLogin isSubscriptionValid: $isValid");

        if (isValid) {
          await _storageService.writeObjectData('userData', response['data']);
          await _storageService.writeData('isAuthenticated', 'true');
          await _storageService.writeData('isBiometricEnable',
              login.data.user.isDeviceBiometrics.toString());
          if (_disposed) return state;

          if (kIsWeb) {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.setBool('upgradePopupShownAfterLogin', false);
          }
          if (_disposed) return state;

          // Reset the logout flag so the shared refresh mutex is operational
          // again for the new session (C-AUTH-01).
          SessionRefreshMutex.isLoggedOut = false;
          state = AuthState.authenticated(response['data']);
          // The auth listener in main.dart calls _lockController.onAuthenticated()
          // which handles suppressing biometric after login.
          _setFirebaseUser(response['data']);
          _firebaseLog('auth: login success');
          // Determine login method from whether a passkey session was used
          final method = (Descope.sessionManager.session != null &&
                  await SharedPreferences.getInstance()
                      .then((p) => p.getBool('isPasskeyPageOpenStatus') ?? false))
              ? 'passkey'
              : 'otp';
          _analytics.logLoginSuccess(method);
        } else {
          CommonService.animatedToast(
              response['message'] ?? 'Subscription invalid', 'error');
          _firebaseLog('auth: login failed — subscription invalid');
          _analytics.logLoginFailed('subscription_invalid');
          state = AuthState.error(
              response['message'] ?? 'Subscription invalid',
              type: AuthErrorType.subscriptionInvalid);
        }
      } else {
        CommonService.animatedToast(
            response['message'] ?? 'Login failed', 'error');
        _analytics.logLoginFailed('invalid_credentials');
        state = AuthState.error(
            response['message'] ?? 'Login failed',
            type: AuthErrorType.invalidCredentials);
      }
    } catch (e) {
      if (_disposed) return state;
      final errorType = e is NoInternetException
          ? AuthErrorType.network
          : AuthErrorType.generic;
      _analytics.logLoginFailed(errorType.name);
      state = AuthState.error(e.toString(), type: errorType);
      if (e is! NoInternetException) {
        CommonService.animatedToast(e.toString(), 'error');
      }
    }
    return state;
  }

  Future<void> otpInit(String loginId) async {
    final userData = state.userData;
    final countryCode = await _storageService.readData('countryCode') ?? '+1';
    if (_disposed) return;
    final mobile = userData?['user']?['mobile'] ?? loginId;

    state = state.copyWith(
      mobile: mobile,
      countryCode: countryCode,
      formattedPhone: CommonService().formatPhoneNumber(countryCode, mobile),
    );
  }

  // ================= OTP =================

  Future<void> verifyDescopeOtp(String userName, String otp) async {
    _clearError();
    state = state.copyWith(status: AuthStatus.authenticating);
    try {
      final authResponse = await Descope.otp.verify(
        method: DeliveryMethod.sms,
        loginId: userName,
        code: otp,
      );
      if (_disposed) return;

      final session = DescopeSession.fromAuthenticationResponse(authResponse);
      // manageSession() persists both JWTs automatically via the SDK.
      // No manual storage write is needed.
      Descope.sessionManager.manageSession(session);
      // AF-2: Verify session actually persisted. On iOS with Keychain locking
      // the SDK may fail silently, leaving no persisted JWT.
      if (Descope.sessionManager.session == null) {
        throw Exception('Session failed to persist after OTP verification');
      }
      _analytics.logLoginOtpVerified();
      // Status stays 'authenticating' — caller is responsible for calling
      // userLogin() (login flow) or navigating to setupProfile (signup flow).
    } catch (e) {
      if (_disposed) return;
      _analytics.logLoginOtpFailed(e.toString());
      if (e is DescopeException) {
        final msg = mapDescopeError(e);
        state = AuthState.error(msg);
        CommonService.animatedToast(msg, 'error');
      } else {
        state = AuthState.error(e.toString());
        CommonService.animatedToast(e.toString(), 'error');
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>> verifyLegacyOtp(String otp) async {
    _clearError();
    state = state.copyWith(status: AuthStatus.authenticating);
    try {
      final response = await _apiService.post(
        'auth/verify-otp',
        {
          "id": state.verifyUser?['data']?['id'] ?? state.userData?['id'],
          "otp": otp,
        },
      );
      if (_disposed) return response;
      state = state.copyWith(status: AuthStatus.unauthenticated);
      return response;
    } catch (e) {
      if (_disposed) rethrow;
      state = AuthState.error(e.toString());
      CommonService.animatedToast(e.toString(), 'error');
      rethrow;
    }
  }

  Future<void> resendOtp(String userName,
      {bool isLogin = true, String? loginId}) async {
    _clearError();
    state = state.copyWith(status: AuthStatus.authenticating);
    try {
      if (isLogin) {
        await Descope.otp.signIn(method: DeliveryMethod.sms, loginId: userName);
      } else {
        String countryCode =
            await _storageService.readData('countryCode') ?? '+1';
        await Descope.otp.signUp(
          method: DeliveryMethod.sms,
          loginId: userName,
          // H-05: Strip spaces/dashes so the combined value is valid E.164.
          details: SignUpDetails(
              phone: countryCode +
                  (loginId ?? '').replaceAll(RegExp(r'\D'), '')),
        );
      }
      if (_disposed) return;
      state = state.copyWith(status: AuthStatus.awaitingOtp);
      CommonService.animatedToast('Otp sent', 'success');
    } catch (e) {
      if (_disposed) return;
      // AF-1: Stay on awaitingOtp so GoRouter doesn't redirect to login.
      // The user is still on the OTP screen and can retry.
      state = state.copyWith(status: AuthStatus.awaitingOtp);
      if (e is DescopeException) {
        CommonService.animatedToast(mapDescopeError(e), 'error');
      } else {
        CommonService.animatedToast(e.toString(), 'error');
      }
    }
  }

  // ================= SIGNUP =================

  Future<void> checkUserName(String userName) async {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () async {
      if (_disposed) return;
      try {
        final response = await _apiService.post(
          'auth/check-user-name',
          {"userName": userName},
        );
        if (_disposed) return;
        if (response['success']) {
          final isAvailable = response['data']['isAvailable'] as bool;
          _analytics.logSignupUsernameCheck(isAvailable);
          state = state.copyWith(isUserNameAvailable: isAvailable);
        }
      } catch (e) {
        printLog("CheckUserName", "Error: $e");
      }
    });
  }

  Future<bool> signUp(String userName, String phone) async {
    _clearError();
    _analytics.logSignupStart();
    state = state.copyWith(status: AuthStatus.authenticating);
    try {
      final response = await _apiService.post(
        'auth/check-user-name-mobile',
        {
          "userName": userName,
          "mobile": phone,
        },
      );
      if (_disposed) return false;

      if (response['success']) {
        String countryCode =
            await _storageService.readData('countryCode') ?? '+1';
        await Descope.otp.signUp(
          method: DeliveryMethod.sms,
          loginId: userName,
          // H-05: Strip spaces/dashes so the combined value is valid E.164.
          details: SignUpDetails(
              phone: countryCode + phone.replaceAll(RegExp(r'\D'), '')),
        );
        _analytics.logSignupOtpSent();
        await _storageService.writeData('loginId', phone);
        if (_disposed) return false;
        state = state.copyWith(
            status: AuthStatus.awaitingOtp, isDescopeLogin: true);
        return true;
      } else {
        CommonService.animatedToast(response['message'], 'error');
        state = state.copyWith(status: AuthStatus.unauthenticated);
        return false;
      }
    } catch (e) {
      if (_disposed) return false;
      state = AuthState.error(e.toString());
      CommonService.animatedToast(e.toString(), 'error');
      return false;
    }
  }

  // ================= BIOMETRIC =================

  Future<bool> authenticateBiometric() async {
    final authenticated = await _biometricService.authenticate();
    if (_disposed) return authenticated;
    await _storageService.writeData(
      'isBiometricEnable',
      authenticated ? 'true' : 'false',
    );
    return authenticated;
  }

  Future<void> biometricDenied(bool webAuthn) async {
    final userData = state.userData;
    if (userData == null) return;

    final isBiometricEnabled = userData['user']?['isDeviceBiometrics'] ?? false;

    await _storageService.writeData(
      'isBiometricEnable',
      isBiometricEnabled.toString(),
    );
  }

  Future<bool> biometricAccept(bool isMobileLayout) async {
    final authenticated = await _biometricService.authenticate();
    if (_disposed) return authenticated;

    // ✅ FIX: Store 'true' whenever authenticated — not gated on isMobileLayout.
    // Tablet users were being denied because isMobileLayout=false on large screens.
    // Web/Desktop: local_auth.isBiometricAvailable() returns false → authenticated=false → 'false' stored. Safe.
    await _storageService.writeData(
      'isBiometricEnable',
      authenticated ? 'true' : 'false',
    );
    return authenticated;
  }

  // ================= ACTIONS =================

  Future<bool> forgotUserName(String phone) async {
    _clearError();
    state = state.copyWith(status: AuthStatus.authenticating);
    try {
      final countryCode = await _storageService.readData('countryCode') ?? '+1';
      final response = await _apiService.post(
        'auth/forgot-username',
        {
          "countryCode": countryCode,
          "mobile": phone,
          "type": "FORGOT_USERNAME",
        },
      );
      if (_disposed) return false;

      if (response['success']) {
        await _storageService.writeObjectData('userData', response['data']);
        if (_disposed) return false;
        state = state.copyWith(
          status: AuthStatus.awaitingOtp,
          userData: response['data'],
        );
        CommonService.animatedToast(response['message'], 'success');
        return true;
      } else {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: response['message'],
        );
        CommonService.animatedToast(response['message'], 'error');
        return false;
      }
    } catch (e) {
      if (_disposed) return false;
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
      CommonService.animatedToast(e.toString(), 'error');
      return false;
    }
  }

  void setStatus(AuthStatus status) {
    state = state.copyWith(status: status);
  }

  // ─── userData single-source-of-truth helpers ─────────────────────────────
  //
  // All userData mutations MUST go through these methods so the in-memory
  // AuthState and encrypted storage stay in sync.  Consumers should NEVER
  // call secureStorageService.updateObjectData('userData', ...) directly.

  /// Update a single field inside `userData['user']` and persist to storage.
  Future<void> updateUserField(String field, dynamic value) async {
    final current = state.userData;
    if (current == null) return;
    final updatedUser = <String, dynamic>{
      ...(current['user'] as Map<String, dynamic>? ?? {}),
      field: value,
    };
    final updated = <String, dynamic>{...current, 'user': updatedUser};
    state = state.copyWith(userData: updated);
    await _storageService.writeObjectData('userData', updated);
  }

  /// Bulk-update multiple fields inside `userData['user']` and persist.
  Future<void> updateUserFields(Map<String, dynamic> fields) async {
    final current = state.userData;
    if (current == null) return;
    final updatedUser = <String, dynamic>{
      ...(current['user'] as Map<String, dynamic>? ?? {}),
      ...fields,
    };
    final updated = <String, dynamic>{...current, 'user': updatedUser};
    state = state.copyWith(userData: updated);
    await _storageService.writeObjectData('userData', updated);
  }

  /// Replace the entire userData map in both memory and storage.
  /// Use this after login/signup when the server returns a fresh userData blob.
  Future<void> persistUserData(Map<String, dynamic> userData) async {
    state = state.copyWith(userData: userData);
    await _storageService.writeObjectData('userData', userData);
  }

  void setAuthenticated(bool value, {Map<String, dynamic>? userData}) {
    if (value && userData != null) {
      // Clear the logout flag so the shared refresh mutex is operational
      // again for the new session.
      SessionRefreshMutex.isLoggedOut = false;
      state = AuthState.authenticated(userData);
    } else {
      // Signal the shared mutex to abort any in-flight refresh attempts.
      SessionRefreshMutex.isLoggedOut = true;
      state = AuthState.unauthenticated();
    }
  }

  /// Single canonical logout path for the entire app.
  ///
  /// Auth state is flipped synchronously so GoRouter redirects to /login
  /// immediately. All cleanup (API call, Descope revocation, storage wipe,
  /// socket disconnect, badge reset, SharedPreferences) runs in a background
  /// Future so it never blocks the UI.
  Future<void> logout() async {
    _firebaseLog('auth: logout');
    _analytics.logEvent('logout');
    _clearFirebaseUser();
    // Capture JWTs before clearing the session so background cleanup can
    // authenticate its API calls.
    final sessionJwt = Descope.sessionManager.session?.sessionJwt;
    final refreshJwt = Descope.sessionManager.session?.refreshJwt;
    SessionRefreshMutex.isLoggedOut = true;
    Descope.sessionManager.clearSession();
    AppCache().clear();
    HtmlSanitizerService.clearPreviewCache();
    state = AuthState.unauthenticated();

    // Best-effort cleanup in the background — errors are swallowed.
    unawaited(Future(() async {
      // Disconnect the socket before any async work so no further messages
      // arrive on a stale session.
      SocketService().disconnect();

      if (!kIsWeb && await AppBadgePlus.isSupported()) {
        try {
          await AppBadgePlus.updateBadge(0);
        } catch (_) {}
      }

      // Backend logout is best-effort. On web the HTTP error surfaces in the
      // browser console even when caught, so skip it — the Descope session
      // revocation below is what actually invalidates the session.
      if (!kIsWeb) {
        try {
          await _apiService.post(
            EndPoints.logout.path,
            {},
            additionalHeaders: sessionJwt != null
                ? {'authorization': sessionJwt, 'tokentype': 'descope'}
                : null,
          );
        } catch (_) {}
      }
      if (refreshJwt != null) {
        for (var attempt = 0; attempt < 2; attempt++) {
          try {
            await Descope.auth
                .revokeSessions(RevokeType.currentSession, refreshJwt)
                .timeout(const Duration(seconds: 5));
            break;
          } catch (e) {
            printLog("Logout", "Descope server revocation error (attempt ${attempt + 1}): $e");
            if (attempt == 0) await Future.delayed(const Duration(seconds: 5));
          }
        }
      }
      await _storageService.clearAllData();

      // Clear persisted route so the next session starts fresh.
      await clearPersistedRoute();

      // Clear SharedPreferences flags that should reset on logout.
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('upgradePopupShownAfterLogin');
        await prefs.remove('isPasskeyPageOpenStatus');
        AppCache().setIsPasskeyPageOpen(false);
      } catch (_) {}
    }));
  }

  Future<bool> setupProfile({
    required String firstName,
    required String lastName,
    required String dob,
    required String deviceToken,
    required String userName,
    required Function() onSuccess,
  }) async {
    _clearError();
    _analytics.logSignupProfileSubmit();
    state = state.copyWith(status: AuthStatus.authenticating);
    try {
      final countryCode = await _storageService.readData('countryCode') ?? '+1';
      if (_disposed) return false;
      final descopeUser = Descope.sessionManager.session?.user;

      if (descopeUser == null) {
        state = state.copyWith(
            status: AuthStatus.error, errorMessage: 'User session not found');
        return false;
      }

      if (descopeUser.loginIds.isEmpty) {
        state = state.copyWith(
            status: AuthStatus.error,
            errorMessage: 'No login ID returned from Descope');
        return false;
      }

      final response = await _apiService.post(
        'auth/signup-descope',
        {
          "userName": descopeUser.loginIds[0],
          "firstName": firstName,
          "lastName": lastName,
          "dob": dob,
          "deviceToken": deviceToken,
          "descopeData": DescopeUser.toJson(descopeUser),
          "countryCode": countryCode,
          "phone": descopeUser.phone
        },
      );
      if (_disposed) return false;

      if (response['success']) {
        await _storageService.writeObjectData('userData', response['data']);

        // Update local Descope user info
        Descope.sessionManager.updateUser(DescopeUser(
          descopeUser.userId,
          descopeUser.loginIds,
          descopeUser.createdAt,
          '$firstName $lastName',
          descopeUser.picture,
          '$userName$emailExtension',
          descopeUser.isVerifiedEmail,
          descopeUser.phone,
          descopeUser.isVerifiedPhone,
          {'dob': dob},
          firstName,
          descopeUser.middleName,
          lastName,
          descopeUser.hasPassword,
          descopeUser.status,
          descopeUser.roleNames,
          descopeUser.ssoAppIds,
          descopeUser.oauthProviders,
        ));

        await _storageService.writeData('isAuthenticated', 'true');
        await _storageService.writeData('signupInProgress', 'true');
        AppCache().setSignupInProgress('true');
        if (_disposed) return false;
        // Mute GoRouter's refreshListenable so the auth state change
        // doesn't trigger a refresh that flattens the navigation stack.
        // onSuccess() will navigate (push) then unmute so subsequent
        // auth changes (logout, session expiry) work normally.
        muteRouterRefresh();
        state = AuthState.authenticated(response['data']);
        _setFirebaseUser(response['data']);
        _firebaseLog('auth: signup success');
        _analytics.logSignupComplete();
        onSuccess();

        return true;
      } else {
        // Do NOT call onSuccess() for any failure — including "user already exists".
        // Calling onSuccess() with empty userData would break downstream screens.
        state = state.copyWith(
            status: AuthStatus.error,
            errorMessage: response['message'],
            isReadOnly: false);
        CommonService.animatedToast(response['message'], 'error');
        return false;
      }
    } catch (e) {
      if (_disposed) return false;
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
      CommonService.animatedToast('Something went wrong', 'error');
      return false;
    }
  }

}
