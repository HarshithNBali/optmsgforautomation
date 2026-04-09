import 'dart:async';

import 'package:descope/descope.dart';
import 'package:flutter/foundation.dart';

import '../common/app_manger/app_cache.dart';
import '../main.dart';
import '../screens/auth/auth_riverpod/auth_notifier.dart' show authProvider;
import '../constant/string_constant.dart' show sessionExpired;
import 'common_service.dart';
import 'session_refresh_mutex.dart';
import 'storage_service.dart';

/// Single process-wide guard for handling session expiry.
///
/// Both [ApiService] and [BaseAPIService] delegate to this class so that only
/// one expiry flow runs at a time, regardless of which service detected it.
class SessionExpiryManager {
  SessionExpiryManager._();

  /// ST-2: Use a Completer instead of a boolean flag to guarantee atomicity.
  /// Multiple concurrent 401 handlers will await the same Future rather than
  /// each starting their own cleanup (which causes iOS Keychain locking errors).
  static Completer<bool>? _expiryCompleter;

  /// Handles a 401/405 response by attempting to recover the session first.
  ///
  /// Returns `true` if the session was recovered (caller should retry the
  /// request with a fresh JWT), or `false` if the session is terminal
  /// (caller should return the error to the UI).
  ///
  /// With a 10-minute session JWT, a 401 can occur if the token expires in
  /// transit. If the refresh token (4-week TTL) is still valid, the session
  /// can be silently recovered by refreshing the JWT — no user interruption.
  ///
  /// Only logs the user out when:
  /// - The refresh token is confirmed expired locally
  /// - The Descope server explicitly rejects the refresh (DescopeException)
  /// - The session cannot be recovered from persistent storage
  ///
  /// The method is idempotent: concurrent calls return the same Future while
  /// the first is still in progress (ST-2).
  static Future<bool> handleExpiry() async {
    // ST-11: Don't clear the session mid-WebAuthn flow.
    if (SessionRefreshMutex.passkeyFlowInProgress) return false;
    // RC-2: If logout has already been initiated (by this method or by a
    // concurrent path such as the session timer), skip entirely. The first
    // caller already showed the toast and triggered navigation to /login.
    // Without this guard the second caller falls through to the terminal block
    // after _expiryCompleter is reset to null in the finally clause, producing
    // a duplicate "Session expired" toast or a concurrent clearAllData() call.
    if (SessionRefreshMutex.isLoggedOut) return false;
    if (_expiryCompleter != null) return _expiryCompleter!.future;
    _expiryCompleter = Completer<bool>();
    try {
      // --- Attempt silent recovery before logging out ---

      var session = Descope.sessionManager.session;

      // If in-memory session is null (Android memory pressure, etc.),
      // try reloading from persistent storage before giving up.
      if (session == null) {
        try {
          await Descope.sessionManager.loadSession();
          session = Descope.sessionManager.session;
        } catch (_) {}
      }

      // If the refresh token is still valid, attempt to refresh the session
      // JWT. A 401 with a valid refresh token usually means the 10-minute
      // session JWT expired in transit — this is recoverable.
      if (session != null && !session.refreshToken.isExpired) {
        try {
          await Descope.sessionManager.refreshSessionIfNeeded()
              .timeout(const Duration(seconds: 20));
          // Refresh succeeded — the 401 was caused by a stale session JWT.
          // Session is now valid again; no need to log out.
          debugPrint('[SessionExpiryManager] Recovery succeeded — 401 was '
              'caused by stale session JWT, refresh token still valid');
          _expiryCompleter!.complete(true);
          return true;
        } on DescopeException {
          // Server explicitly rejected the refresh (e.g. E064001 revocation).
          // This is permanent — proceed to logout.
          debugPrint('[SessionExpiryManager] Descope rejected refresh — '
              'proceeding to logout');
        } catch (e) {
          // RC-1: Transient error (network timeout, SocketException, WiFi→cellular
          // handoff). The refresh token is still locally valid — this is NOT a
          // confirmed session expiry. Complete the Completer cleanly and return.
          // The next API call will retry the refresh via guardedRefreshIfNeeded()
          // once the network recovers. Only DescopeException (server-side rejection
          // above) proceeds to logout.
          debugPrint('[SessionExpiryManager] Recovery attempt failed ($e) — '
              'transient error, refresh token still valid, skipping logout');
          _expiryCompleter!.complete(true);
          return true;
        }
      }

      // --- Terminal: session cannot be recovered ---

      final refreshJwt = session?.refreshJwt;
      final refreshExpired = session?.refreshToken.isExpired ?? true;
      CommonService.animatedToast(
          sessionExpired, 'error');
      SessionRefreshMutex.isLoggedOut = true;
      Descope.sessionManager.clearSession();
      // RC-6: Clear in-memory cache before auth state change so GoRouter's
      // redirect doesn't read stale values (isCheckout, signupInProgress, etc.)
      // from the previous session.
      AppCache().clear();
      providerContainer.read(authProvider.notifier).setAuthenticated(false);
      await SecureStorageService().clearAllData();
      // Only revoke server-side if the refresh token is CONFIRMED expired.
      // If the refresh token is still locally valid, the 401 was likely caused
      // by a stale session JWT (e.g. refresh failed due to transient network
      // error). Revoking a valid refresh token permanently destroys the session
      // across all devices — causing unnecessary logouts everywhere.
      // The token will expire naturally at its configured TTL (4 weeks).
      if (refreshJwt != null && refreshExpired) {
        unawaited(Descope.auth
            .revokeSessions(RevokeType.currentSession, refreshJwt)
            .timeout(const Duration(seconds: 5))
            .catchError((_) {}));
      }
      _expiryCompleter!.complete(false);
      return false;
    } catch (e, st) {
      _expiryCompleter!.completeError(e, st);
      return false;
    } finally {
      _expiryCompleter = null;
    }
  }
}
