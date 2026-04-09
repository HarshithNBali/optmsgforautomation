import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;
import 'package:go_router/go_router.dart';
import 'package:optmsg/common/utilites/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:optmsg/router/app_routes.dart';
import 'package:optmsg/main.dart' show firebaseReady;

const _kLastRouteKey = 'lastRoute';

/// Last path we tracked — used to deduplicate rapid-fire notifications
/// from both the delegate listener and the redirect callback.
String? _lastTrackedPath;

/// Persists the current route path whenever GoRouter navigates,
/// and logs screen views to Firebase Analytics + Crashlytics.
///
/// NOTE: This delegate listener does NOT fire reliably for intra-ShellRoute
/// navigations. The primary tracking hook is [logScreenView] called from the
/// GoRouter `redirect` callback in `app_router.dart`. This listener serves as
/// a supplementary fallback.
void trackRouteChanges(GoRouter router) {
  router.routerDelegate.addListener(() {
    final uri = router.routerDelegate.currentConfiguration.uri;
    final location = uri.toString();
    if (location.isNotEmpty) {
      if (location != '/') _saveRoute(location);
      logScreenView(uri.path);
    }
  });
}

// ─── Route persistence ───────────────────────────────────────────────────────

/// GR-18: Only persist routes that don't depend on ephemeral `extra` data.
/// Routes like /contacts/view-contact/5 or /reply/42 would crash on restore
/// because their required extras are lost across app restarts.
const _restorableRoutes = {
  AppRoutes.inbox,
  AppRoutes.archive,
  AppRoutes.sent,
  AppRoutes.drafts,
  AppRoutes.trash,
  AppRoutes.spam,
  AppRoutes.contacts,
  AppRoutes.settings,
  AppRoutes.tags,
  AppRoutes.helpCenter,
  AppRoutes.notifications,
  AppRoutes.compose,
  AppRoutes.subscriptionDetail,
};

Future<void> _saveRoute(String route) async {
  // Strip query parameters for the restorable check.
  final path = Uri.tryParse(route)?.path ?? route;
  if (!_restorableRoutes.contains(path)) return;
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLastRouteKey, route);
  } catch (_) {}
}

/// Returns the last persisted route, or [AppRoutes.home] if none exists.
Future<String> getInitialRoute() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_kLastRouteKey);
    if (saved != null && saved.isNotEmpty) return saved;
  } catch (_) {}
  return AppRoutes.home;
}

/// Clears the persisted route (call on logout).
Future<void> clearPersistedRoute() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kLastRouteKey);
  } catch (_) {}
}

// ─── Firebase screen tracking ────────────────────────────────────────────────

final _numericOrUuid = RegExp(r'^\d+$|^[0-9a-f-]{36}$');
final _riverpodSuffix = RegExp(r'-riverpro?d$');

/// Converts a URI path to a clean, human-readable screen name.
///
/// Examples:
///   `/inbox`                      → `inbox`
///   `/inbox/email?id=42`           → `inbox_email`
///   `/contacts/view-riverpod/5`   → `contacts_view_detail`
///   `/settings/profile`           → `settings_profile`
///   `/tags/7`                     → `tags_detail`
///   `/legal/privacy`              → `legal_privacy`
String screenNameFromPath(String path) {
  if (path == '/' || path.isEmpty) return 'home';

  final segments = path.split('/').where((s) => s.isNotEmpty).toList();
  final cleaned = segments.map((s) {
    if (_numericOrUuid.hasMatch(s)) return 'detail';
    return s.replaceAll(_riverpodSuffix, '');
  }).toList();

  return cleaned.join('_').replaceAll('-', '_');
}

/// Logs the current screen to Firebase Analytics and sets a Crashlytics key.
///
/// Includes deduplication: if [path] matches the last tracked path, the call
/// is a no-op. This prevents duplicate events when both the delegate listener
/// and the redirect callback fire for the same navigation.
void logScreenView(String path) {
  if (!firebaseReady) return;
  if (path == _lastTrackedPath) return;
  _lastTrackedPath = path;

  try {
    final screenName = screenNameFromPath(path);
    if (kDebugMode) {
      printLog('FirebaseAnalytics', 'screen_view: $screenName (path: $path)');
    }
    FirebaseAnalytics.instance.logScreenView(
      screenName: screenName,
      screenClass: screenName,
    );

    if (!kIsWeb) {
      FirebaseCrashlytics.instance.setCustomKey('current_screen', screenName);
    }
  } catch (e) {
    if (kDebugMode) {
      printLog('FirebaseAnalytics', 'logScreenView error: $e');
    }
  }
}
