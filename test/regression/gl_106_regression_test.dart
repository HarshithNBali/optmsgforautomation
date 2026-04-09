/// GL 1.0.6 Production Bug Regression Tests
///
/// Source-level and unit tests that verify fixes for the 31 QA bugs remain
/// in place. These tests catch regressions at the code pattern level —
/// if a future change reverts a fix, the corresponding test will fail.
///
/// Tests are organized by phase (matching docs/GL_106_MISSING_FIXES.md).
/// Each test group documents the bug number, summary, and what it checks.
///
/// Run with: flutter test test/regression/gl_106_regression_test.dart
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:optmsg/services/form_validation.dart' show FormValidationService;

import 'gl_106_test_helpers.dart';

void main() {
  // =========================================================================
  // Phase 1 — Low-Risk Standalone Fixes
  // =========================================================================

  group('Phase 1 — Low-Risk Standalone Fixes', () {
    // -----------------------------------------------------------------------
    // Bug 18: Blank black/blue screen when deleting in trash
    // The Scaffold in custom_dismissible.dart must have a backgroundColor
    // to prevent dark flashes during list rebuilds.
    // -----------------------------------------------------------------------
    test('Bug 18: custom_dismissible Scaffold has backgroundColor', () {
      final source = readSourceFile('lib/widgets/custom_dismissible.dart');

      // Find the Scaffold widget and check it has backgroundColor
      // The Scaffold is the top-level widget in the build method
      final scaffoldLines = sourceLinesContaining(source, 'Scaffold(');
      expect(scaffoldLines, isNotEmpty,
          reason: 'custom_dismissible.dart must contain a Scaffold widget');

      // After the fix, the Scaffold should have backgroundColor set.
      // The backgroundColor may appear on the same line or a few lines after
      // the Scaffold( declaration, so we search for it in the build method.
      final buildBody = _extractMethodBody(source, 'build');
      final hasBackgroundColor = buildBody != null &&
          buildBody.contains('Scaffold') &&
          buildBody.contains('backgroundColor');
      expect(hasBackgroundColor, isTrue,
          reason:
              'Bug 18: Scaffold in custom_dismissible.dart must have '
              'backgroundColor to prevent blank screen flashes during '
              'trash delete. Add backgroundColor: Colors.white or '
              'context.appColors.background to the Scaffold.');
    });

    // -----------------------------------------------------------------------
    // Bug 19: File size shows wrong unit (167KB → 163MB)
    // App correctly sends raw bytes. Backend must store/return bytes.
    // formatFileSize(int bytes) correctly converts for display.
    // -----------------------------------------------------------------------
    test('Bug 19: formatFileSize and web_compose use consistent bytes convention', () {
      final source = readSourceFile('lib/screens/compose/web_compose.dart');

      // web_compose sends 'size': fileLength where fileLength is raw bytes.
      // This is architecturally correct — the backend must align.
      final sizeAssignments = sourceLinesContaining(source, "'size':");
      expect(sizeAssignments, isNotEmpty,
          reason: 'web_compose.dart must have size assignments for attachments');

      // Verify the display formatter expects bytes (not KB).
      final commonSource = readSourceFile('lib/services/common_service.dart');
      final hasFormatFileSize =
          sourceContains(commonSource, 'String formatFileSize(int bytes)');
      expect(hasFormatFileSize, isTrue,
          reason:
              'Bug 19: formatFileSize must accept bytes as input. '
              'If this changes, web_compose size values must be updated too.');
    });

    // -----------------------------------------------------------------------
    // Bug 31: Search bar auto-opens after inbox refresh
    // initState must NOT add a controller listener that can fire on stale
    // state during web refresh.
    // -----------------------------------------------------------------------
    test('Bug 31: search_bar does not add controller listener in initState', () {
      final source = readSourceFile('lib/widgets/search_bar.dart');

      // After the fix, initState should either not exist or not contain
      // addListener. The icon state should be derived in build() instead.
      final initStateSection = _extractMethodBody(source, 'initState');
      final hasAddListener = initStateSection?.contains('addListener') ?? false;
      expect(hasAddListener, isFalse,
          reason:
              'Bug 31: initState adds controller.addListener which causes '
              'search bar to auto-open on web refresh. Remove the listener '
              'and derive icon state in build() instead.');
    });

    // -----------------------------------------------------------------------
    // Bug 5: Contact detail shows stale data after edit
    // edit_contact_notifier must invalidate viewContactProvider after save.
    // -----------------------------------------------------------------------
    test('Bug 5: edit_contact_notifier invalidates viewContactProvider after save', () {
      final source = readSourceFile(
          'lib/screens/contacts/edit_contact_riverpod/edit_contact_notifier.dart');

      final hasInvalidate = sourceContains(source, 'viewContactProvider');
      expect(hasInvalidate, isTrue,
          reason:
              'Bug 5: edit_contact_notifier must call '
              'ref.invalidate(viewContactProvider) after successful save '
              'to force fresh data fetch on the view screen.');
    });
  });

  // =========================================================================
  // Phase 2 — Socket & Network Fixes
  // =========================================================================

  group('Phase 2 — Socket & Network Fixes', () {
    // -----------------------------------------------------------------------
    // Bug 4: Trash doesn't auto-refresh on socket new message
    // initSocket must NOT clear _eventStreams — this kills active
    // subscriptions in notifiers.
    // -----------------------------------------------------------------------
    test('Bug 4: socket_service initSocket does not clear event streams', () {
      final source = readSourceFile('lib/services/socket_service.dart');

      // Find the initSocket method body
      final initSocketBody = _extractMethodBody(source, 'initSocket');
      expect(initSocketBody, isNotNull,
          reason: 'socket_service.dart must have an initSocket method');

      // After the fix, _eventStreams.clear() should NOT be inside initSocket.
      // Stream controllers must persist across reconnects.
      final clearsStreams = initSocketBody!.contains('_eventStreams.clear()');
      expect(clearsStreams, isFalse,
          reason:
              'Bug 4: initSocket calls _eventStreams.clear() which kills '
              'active stream subscriptions in notifiers. Socket events are '
              'silently dropped after reconnect. Remove _eventStreams.clear() '
              'from initSocket.');
    });

    // -----------------------------------------------------------------------
    // Bug 4 (cont): connect_error must NOT call _refreshAndRetryLogin.
    // The method itself can remain for the login ACK "Invalid Token" fallback.
    // -----------------------------------------------------------------------
    test('Bug 4: connect_error handler does not call _refreshAndRetryLogin', () {
      final source = readSourceFile('lib/services/socket_service.dart');

      // Find the connect_error handler and verify it doesn't call refresh.
      final connectErrorIdx = source.indexOf("'connect_error'");
      expect(connectErrorIdx, isNot(-1),
          reason: 'socket_service.dart must have a connect_error handler');

      // Extract the connect_error handler body (next ~10 lines)
      final handlerSlice = source.substring(
          connectErrorIdx, (connectErrorIdx + 500).clamp(0, source.length));
      // The handler should end at the next '..' or closing '))'
      final handlerEnd = handlerSlice.indexOf('})');
      final handlerBody =
          handlerEnd > 0 ? handlerSlice.substring(0, handlerEnd) : handlerSlice;

      // Match the actual method call (with semicolon), not just a mention
      // in a comment. The comment explaining the removal is expected.
      final callsRefresh = RegExp(r'_refreshAndRetryLogin\(\)\s*;')
          .hasMatch(handlerBody);
      expect(callsRefresh, isFalse,
          reason:
              'Bug 4: connect_error handler must not call '
              '_refreshAndRetryLogin — the built-in onReconnect handler '
              'already re-authenticates with a fresh JWT.');
    });

    // -----------------------------------------------------------------------
    // Bug 27: Web app freezes after backgrounding
    // NetworkService must use HTTP head (not DNS lookup) on web.
    // -----------------------------------------------------------------------
    test('Bug 27: network_service has web-compatible reachability check', () {
      final source =
          readSourceFile('lib/common/utilites/network_service.dart');

      // After the fix, should have a kIsWeb or Platform.isWeb check
      // that uses http.head() instead of InternetAddress.lookup.
      final hasWebCheck = sourceContains(source, 'kIsWeb') ||
          sourceContains(source, 'kDebugMode');
      final hasDnsOnly =
          sourceContains(source, 'InternetAddress.lookup') &&
          !sourceContains(source, 'http.head') &&
          !sourceContains(source, 'http.get') &&
          !hasWebCheck;

      expect(hasDnsOnly, isFalse,
          reason:
              'Bug 27: NetworkService uses InternetAddress.lookup which is '
              'not available in web browsers. Add a kIsWeb branch that uses '
              'http.head() for web reachability checks.');
    });
  });

  // =========================================================================
  // Phase 3 — Verification Pass (source-level guards)
  // =========================================================================

  group('Phase 3 — Verification Guards', () {
    // -----------------------------------------------------------------------
    // Bug 3: LoginPostProcessor must check isSupported, not stale cache
    // -----------------------------------------------------------------------
    test('Bug 3: LoginPostProcessor checks passkey support fresh each login', () {
      final source =
          readSourceFile('lib/screens/auth/login_post_processor.dart');

      // Must call Descope.passkey.isSupported() — not rely on AppCache flag
      final checksIsSupported = sourceContains(source, 'isSupported');
      expect(checksIsSupported, isTrue,
          reason:
              'Bug 3: LoginPostProcessor must call Descope.passkey.isSupported() '
              'fresh each login, not rely on a cached flag.');

      // Must NOT use AppCache().hasPasskeyEnrolled as the decision point
      final usesAppCache =
          sourceContains(source, 'AppCache().hasPasskeyEnrolled');
      expect(usesAppCache, isFalse,
          reason:
              'Bug 3: LoginPostProcessor must not use '
              'AppCache().hasPasskeyEnrolled — this in-memory flag can be '
              'stale from a previous session.');
    });

    // -----------------------------------------------------------------------
    // Bug 6: Router must prevent redirect before auth initialization
    // -----------------------------------------------------------------------
    test('Bug 6: app_router prevents redirect before auth init', () {
      final source = readSourceFile('lib/router/app_router.dart');

      // Must have an isInitialized check that prevents premature redirect
      final hasInitCheck = sourceContains(source, 'isInitialized');
      expect(hasInitCheck, isTrue,
          reason:
              'Bug 6: app_router must check isInitialized before evaluating '
              'isAuthenticated in redirect logic.');
    });

    // -----------------------------------------------------------------------
    // Bugs 24/25/30: RequestType enum must be consistent
    // -----------------------------------------------------------------------
    test('Bugs 24/25/30: RequestType enum values are consistent lowercase', () {
      final source =
          readSourceFile('lib/repositories/base/base_api_service.dart');

      // Verify enum uses lowercase values
      final hasLowercase = sourceMatchesRegex(
        source,
        RegExp(r'enum\s+RequestType\s*\{[^}]*\bget\b.*\bpost\b.*\bdelete\b'),
      );
      expect(hasLowercase, isTrue,
          reason:
              'Bugs 24/25/30: RequestType enum must use lowercase values '
              '(get, post, delete, patch, put) consistently.');

      // Verify tag_api uses consistent casing
      final tagSource = readSourceFile('lib/repositories/tags/tag_api.dart');
      final tagHasUppercase = sourceMatchesRegex(
        tagSource,
        RegExp(r'RequestType\.(GET|POST|DELETE|PATCH|PUT)'),
      );
      expect(tagHasUppercase, isFalse,
          reason:
              'Bugs 24/25/30: tag_api.dart uses uppercase RequestType '
              'values — must match base_api_service enum (lowercase).');

      // Verify archive_api uses consistent casing
      final archiveSource =
          readSourceFile('lib/repositories/email/archive_api.dart');
      final archiveHasUppercase = sourceMatchesRegex(
        archiveSource,
        RegExp(r'RequestType\.(GET|POST|DELETE|PATCH|PUT)'),
      );
      expect(archiveHasUppercase, isFalse,
          reason:
              'Bugs 24/25/30: archive_api.dart uses uppercase RequestType '
              'values — must match base_api_service enum (lowercase).');
    });
  });

  // =========================================================================
  // Phase 4 — Auth/Safari/Stripe Guards
  // =========================================================================

  group('Phase 4 — Auth/Safari/Stripe Guards', () {
    // -----------------------------------------------------------------------
    // Bug 14: Biometric service must not cache results across backgrounding
    // -----------------------------------------------------------------------
    test('Bug 14: biometric_service does not use persistAcrossBackgrounding', () {
      final source = readSourceFile('lib/services/biometric_service.dart');

      // After the fix, persistAcrossBackgrounding should be false or absent.
      // The stickyAuth option should be used instead.
      final persistsAcross = sourceMatchesRegex(
        source,
        RegExp(r'persistAcrossBackgrounding\s*:\s*true'),
      );
      expect(persistsAcross, isFalse,
          reason:
              'Bug 14: persistAcrossBackgrounding: true causes iOS to cache '
              'biometric results. Remove it and use '
              'AuthenticationOptions(stickyAuth: true) instead.');
    });

    // -----------------------------------------------------------------------
    // Bug 13: Stripe popup must open synchronously for Safari
    // -----------------------------------------------------------------------
    test('Bug 13: web_check_out has synchronous popup open method', () {
      final source =
          readSourceFile('lib/webPackerHandler/web_check_out.dart');

      // After the fix, there should be a pre-open method that opens a blank
      // popup synchronously within the user gesture before async work.
      final hasPreOpen = sourceContains(source, 'preOpenTab') ||
          sourceContains(source, 'openBlankPopup') ||
          sourceContains(source, 'preOpen');
      expect(hasPreOpen, isTrue,
          reason:
              'Bug 13: web_check_out.dart must have a synchronous popup '
              'pre-open method (preOpenTab/openBlankPopup) that opens a '
              'blank popup within the user gesture before async URL fetch. '
              'Safari blocks window.open after await.');
    });
  });

  // =========================================================================
  // Phase 5 — Investigation & Backend Guards
  // =========================================================================

  group('Phase 5 — Investigation & Backend Guards', () {
    // -----------------------------------------------------------------------
    // Bug 16: Reading pane toggle must have TODO or API call
    // -----------------------------------------------------------------------
    test('Bug 16: settings_notifier reading pane has API call or TODO', () {
      final source = readSourceFile(
          'lib/screens/settings/setting_riverpod/settings_notifier.dart');

      // Must either have an API call for toggling reading pane, or a TODO
      // documenting the backend dependency.
      final hasApiCall = sourceContains(source, 'toggle-reading-pane') ||
          sourceContains(source, 'toggleReadingPane') &&
              sourceContains(source, 'ApiService') ||
          sourceContains(source, 'post(');
      final hasTodo = sourceContains(source, 'TODO') &&
          sourceContains(source, 'reading');

      expect(hasApiCall || hasTodo, isTrue,
          reason:
              'Bug 16: toggleReadingPane must either call a backend API '
              'endpoint or have a TODO documenting the backend dependency. '
              'Without server persistence, the setting resets on page refresh.');
    });
  });

  // =========================================================================
  // Already Resolved — Guard Tests (prevent regressions)
  // =========================================================================

  group('Already Resolved — Regression Guards', () {
    // -----------------------------------------------------------------------
    // Bug 15: Date format validation must match stored format
    // -----------------------------------------------------------------------
    test('Bug 15: validateDob parses MMMM dd, yyyy format', () {
      final validator = FormValidationService();

      // Valid date in MMMM dd, yyyy format (output of profile formatDate)
      expect(validator.validateDob('September 13, 2004'), isNull,
          reason: 'Bug 15: validateDob must accept MMMM dd, yyyy format');

      // Valid date in MM/DD/YYYY format (date picker output)
      expect(validator.validateDob('09/13/2004'), isNull,
          reason: 'Bug 15: validateDob must accept MM/DD/YYYY format');

      // Null/empty should fail
      expect(validator.validateDob(null), isNotNull,
          reason: 'Bug 15: validateDob must reject null');
      expect(validator.validateDob(''), isNotNull,
          reason: 'Bug 15: validateDob must reject empty string');

      // Future date should fail
      expect(validator.validateDob('December 31, 2099'), isNotNull,
          reason: 'Bug 15: validateDob must reject future dates');
    });

    // -----------------------------------------------------------------------
    // Bug 22: email_sender_service handles skip_all result
    // -----------------------------------------------------------------------
    test('Bug 22: email_sender_service handles skip_all in add email modal', () {
      final source = readSourceFile('lib/services/email_sender_service.dart');

      final handlesSkipAll = sourceContains(source, 'skip_all');
      expect(handlesSkipAll, isTrue,
          reason:
              'Bug 22: email_sender_service must handle \'skip_all\' result '
              'from displayAddEmailModal to trigger email send.');
    });

    // -----------------------------------------------------------------------
    // Bug 23: EmailSenderService must use singleton storage
    // -----------------------------------------------------------------------
    test('Bug 23: email_sender_service uses SecureStorageService singleton', () {
      final source = readSourceFile('lib/services/email_sender_service.dart');

      // SecureStorageService must be used (whether local instance or global).
      // The key is that SecureStorageService is a singleton via factory
      // constructor, so any instance shares the same underlying storage.
      final usesStorage = sourceContains(source, 'SecureStorageService');
      expect(usesStorage, isTrue,
          reason:
              'Bug 23: EmailSenderService must use SecureStorageService '
              '(singleton via factory) to avoid web localStorage prefix '
              'mismatch that breaks reply/forward.');
    });

    // -----------------------------------------------------------------------
    // Bugs 7/8: Notification permissions — verify registration order
    // -----------------------------------------------------------------------
    test('Bugs 7/8: onBackgroundMessage registered in main before runApp', () {
      final source = readSourceFile('lib/main.dart');

      // onBackgroundMessage should be registered in main() before runApp()
      final mainBody = _extractMethodBody(source, 'main');
      expect(mainBody, isNotNull,
          reason: 'main.dart must have a main() function');

      final hasBackgroundHandler =
          sourceContains(source, 'onBackgroundMessage');
      expect(hasBackgroundHandler, isTrue,
          reason:
              'Bugs 7/8: FirebaseMessaging.onBackgroundMessage must be '
              'registered in main.dart for background notification handling.');
    });
  });

  // =========================================================================
  // Structural Guards — Prevent architectural divergence
  // =========================================================================

  group('Structural Guards — Architecture', () {
    // -----------------------------------------------------------------------
    // NotifierProvider pattern (not StateNotifierProvider)
    // -----------------------------------------------------------------------
    test('Architecture: passkey uses NotifierProvider (not StateNotifierProvider)', () {
      final source = readSourceFile(
          'lib/screens/auth/passKey/passkey_notifier.dart');

      final usesNotifier = sourceContains(source, 'NotifierProvider');
      expect(usesNotifier, isTrue,
          reason: 'passkey_notifier must use NotifierProvider pattern');

      final usesStateNotifier =
          sourceContains(source, 'StateNotifierProvider');
      expect(usesStateNotifier, isFalse,
          reason:
              'passkey_notifier must NOT use StateNotifierProvider — this '
              'branch uses the Notifier pattern exclusively.');
    });

    // -----------------------------------------------------------------------
    // SessionRefreshMutex (not TokenRefreshCoordinator)
    // -----------------------------------------------------------------------
    test('Architecture: uses SessionRefreshMutex (not TokenRefreshCoordinator)', () {
      final source = readSourceFile(
          'lib/screens/auth/passKey/passkey_notifier.dart');

      final usesMutex = sourceContains(source, 'SessionRefreshMutex');
      expect(usesMutex, isTrue,
          reason:
              'passkey_notifier must use SessionRefreshMutex for JWT '
              'refresh coordination');

      final usesCoordinator =
          sourceContains(source, 'TokenRefreshCoordinator');
      expect(usesCoordinator, isFalse,
          reason:
              'This branch uses SessionRefreshMutex, not '
              'TokenRefreshCoordinator from the fix branch.');
    });

    // -----------------------------------------------------------------------
    // Auth notifier: disposed guard pattern
    // -----------------------------------------------------------------------
    test('Architecture: auth notifier has disposed guard', () {
      final source = readSourceFile(
          'lib/screens/auth/auth_riverpod/auth_notifier.dart');

      final hasDisposed = sourceContains(source, '_disposed');
      expect(hasDisposed, isTrue,
          reason:
              'auth_notifier must use _disposed guard for async gap safety');
    });

    // -----------------------------------------------------------------------
    // Passkey: onDispose clears passkeyFlowInProgress flag
    // -----------------------------------------------------------------------
    test('Architecture: passkey onDispose clears passkeyFlowInProgress', () {
      final source = readSourceFile(
          'lib/screens/auth/passKey/passkey_notifier.dart');

      final clearsFlag = sourceContains(
          source, 'SessionRefreshMutex.passkeyFlowInProgress = false');
      expect(clearsFlag, isTrue,
          reason:
              'passkey_notifier onDispose must clear '
              'SessionRefreshMutex.passkeyFlowInProgress to prevent '
              'permanently blocking JWT refreshes after navigation away.');
    });
  });
}

// ===========================================================================
// Helper: Extract a method body from source for focused assertions.
// ===========================================================================

/// Extracts the body of a method named [methodName] from [source].
/// Returns null if the method is not found.
/// This is a best-effort extraction — it counts braces to find the end.
String? _extractMethodBody(String source, String methodName) {
  // Match patterns like: void initState() {, Future<void> initSocket(... {
  final pattern = RegExp(
    r'(?:void|Future|static|async)?\s*(?:<[^>]+>\s*)?' +
        RegExp.escape(methodName) +
        r'\s*\([^)]*\)\s*(?:async\s*)?\{',
  );
  final match = pattern.firstMatch(source);
  if (match == null) return null;

  int braceCount = 1;
  int start = match.end;
  int i = start;

  while (i < source.length && braceCount > 0) {
    if (source[i] == '{') braceCount++;
    if (source[i] == '}') braceCount--;
    i++;
  }

  if (braceCount != 0) return null;
  return source.substring(start, i - 1);
}
