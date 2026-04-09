import 'dart:async';
import 'package:descope/descope.dart';
import 'package:flutter/foundation.dart';

/// Single process-wide mutex for Descope JWT refresh.
///
/// Both [ApiService] and [RefreshableService] share this so that only one
/// refresh runs at a time, regardless of which service path triggered it.
///
/// The [isLoggedOut] flag is set during logout to prevent any in-flight
/// refresh from restoring a session that was just cleared.
class SessionRefreshMutex {
  SessionRefreshMutex._();

  static Completer<void>? _refreshCompleter;

  /// Set to `true` when logout begins. Checked before and after refresh to
  /// prevent a race where a concurrent refresh restores a cleared session.
  static bool isLoggedOut = false;

  /// Set to `true` while passkey enrollment is in progress. Suspends token
  /// refresh so the JWT used for WebAuthn /start matches /finish.
  static bool passkeyFlowInProgress = false;

  /// `true` while a Descope JWT refresh is in-flight. Used to suppress false
  /// "Internet disconnected" banners — a 401 during refresh is an auth issue,
  /// not a connectivity issue.
  static bool isRefreshing = false;

  /// Ensures only one Descope refresh runs at a time across the entire app.
  ///
  /// Returns normally if the refresh succeeds or there is no session.
  /// Throws if the refresh fails (callers should handle expired refresh tokens).
  static Future<void> guardedRefreshIfNeeded() async {
    // If the user is logging out or enrolling a passkey, skip the refresh.
    if (isLoggedOut || passkeyFlowInProgress) return;

    if (_refreshCompleter != null) {
      return _refreshCompleter!.future;
    }

    _refreshCompleter = Completer<void>();
    isRefreshing = true;
    try {
      await Descope.sessionManager.refreshSessionIfNeeded()
          .timeout(const Duration(seconds: 15));
      // Double-check: if logout happened while we were awaiting the refresh,
      // clear the session the refresh may have just restored.
      if (isLoggedOut) {
        Descope.sessionManager.clearSession();
      }
      _refreshCompleter!.complete();
    } catch (e) {
      debugPrint('[SessionRefreshMutex] Session refresh failed: $e');
      _refreshCompleter!.completeError(e);
      rethrow;
    } finally {
      isRefreshing = false;
      _refreshCompleter = null;
    }
  }
}
