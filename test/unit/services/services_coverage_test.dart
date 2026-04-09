import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:descope/descope.dart';
import 'package:optmsg/services/descope_error_mapper.dart';
import 'package:optmsg/services/update_provider.dart';
import 'package:optmsg/services/reg_exp_service.dart';
import 'package:optmsg/services/analytics_service.dart';
import 'package:optmsg/services/web_utils_stub.dart' as web_stub;
import 'package:optmsg/services/biometric_service.dart';
import 'package:optmsg/services/session_refresh_mutex.dart';
import 'package:optmsg/services/overlay_manager.dart';

void main() {
  // ===== mapDescopeError =====
  group('mapDescopeError', () {
    test('should map E061001 to incorrect code message', () {
      const e = DescopeException(code: 'E061001', desc: '', message: '');
      expect(mapDescopeError(e), 'That code is incorrect. Please try again.');
    });

    test('should map E061002 to expired code message', () {
      const e = DescopeException(code: 'E061002', desc: '', message: '');
      expect(mapDescopeError(e), contains('expired'));
    });

    test('should map E062001 to no account message', () {
      const e = DescopeException(code: 'E062001', desc: '', message: '');
      expect(mapDescopeError(e), 'No account found with that username.');
    });

    test('should map E064001 to incorrect username', () {
      const e = DescopeException(code: 'E064001', desc: '', message: '');
      expect(mapDescopeError(e), 'Incorrect username.');
    });

    test('should return generic message for unknown code', () {
      const e = DescopeException(code: 'E999999', desc: '', message: '');
      expect(mapDescopeError(e), 'Something went wrong. Please try again.');
    });
  });

  // ===== UpdateProvider =====
  group('UpdateNotifier', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() => container.dispose());

    test('default state', () {
      final state = container.read(updateProvider);
      expect(state.isUpdateDialogVisible, false);
      expect(state.isOptionalUpdateDismissed, false);
    });

    test('setUpdateDialogVisible should update flag', () {
      container.read(updateProvider.notifier).setUpdateDialogVisible(true);
      expect(container.read(updateProvider).isUpdateDialogVisible, true);
    });

    test('dismissOptionalUpdate should update flag', () {
      container.read(updateProvider.notifier).dismissOptionalUpdate();
      expect(container.read(updateProvider).isOptionalUpdateDismissed, true);
    });

    test('UpdateState copyWith', () {
      final modified = const UpdateState().copyWith(
        isUpdateDialogVisible: true,
        isOptionalUpdateDismissed: true,
      );
      expect(modified.isUpdateDialogVisible, true);
      expect(modified.isOptionalUpdateDismissed, true);
    });
  });

  // ===== RegExpService =====
  group('validCharactersRegex', () {
    test('should match valid username characters', () {
      expect(validCharactersRegex.hasMatch('testuser'), true);
      expect(validCharactersRegex.hasMatch('test.user'), true);
      expect(validCharactersRegex.hasMatch('test-user'), true);
      expect(validCharactersRegex.hasMatch('test_user'), true);
      expect(validCharactersRegex.hasMatch('TestUser123'), true);
    });

    test('should reject invalid characters', () {
      expect(validCharactersRegex.hasMatch('test user'), false);
      expect(validCharactersRegex.hasMatch('test@user'), false);
      expect(validCharactersRegex.hasMatch('test!user'), false);
      expect(validCharactersRegex.hasMatch('test#user'), false);
    });

    test('should match empty string', () {
      expect(validCharactersRegex.hasMatch(''), true);
    });
  });

  // ===== AnalyticsService constants =====
  group('AnalyticsService', () {
    test('event name constants should be non-empty strings', () {
      expect(AnalyticsService.loginStart, isNotEmpty);
      expect(AnalyticsService.loginPasskeyAttempt, isNotEmpty);
      expect(AnalyticsService.loginPasskeySuccess, isNotEmpty);
      expect(AnalyticsService.loginPasskeyFail, isNotEmpty);
      expect(AnalyticsService.loginOtpSent, isNotEmpty);
      expect(AnalyticsService.loginOtpVerified, isNotEmpty);
      expect(AnalyticsService.loginOtpFailed, isNotEmpty);
      expect(AnalyticsService.loginSuccess, isNotEmpty);
      expect(AnalyticsService.loginFailed, isNotEmpty);
    });

    test('passkey enrollment constants', () {
      expect(AnalyticsService.passkeyEnrollStart, isNotEmpty);
      expect(AnalyticsService.passkeyEnrollSuccess, isNotEmpty);
      expect(AnalyticsService.passkeyEnrollSkip, isNotEmpty);
      expect(AnalyticsService.passkeyEnrollFail, isNotEmpty);
    });

    test('signup constants', () {
      expect(AnalyticsService.signupStart, isNotEmpty);
      expect(AnalyticsService.signupComplete, isNotEmpty);
      expect(AnalyticsService.signupOtpSent, isNotEmpty);
    });

    test('subscription constants', () {
      expect(AnalyticsService.planView, isNotEmpty);
      expect(AnalyticsService.planSelected, isNotEmpty);
      expect(AnalyticsService.checkoutBegin, isNotEmpty);
      expect(AnalyticsService.paymentSuccess, isNotEmpty);
      expect(AnalyticsService.paymentFailed, isNotEmpty);
    });

    test('instance should be singleton', () {
      expect(identical(AnalyticsService.instance, AnalyticsService.instance), true);
    });

    test('logEvent should not crash when firebaseReady is false', () {
      // firebaseReady is false in test env — should no-op
      AnalyticsService.instance.logEvent('test_event');
      AnalyticsService.instance.logEvent('test_event', {'key': 'value'});
    });

    test('setUserProperty should not crash when firebaseReady is false', () {
      AnalyticsService.instance.setUserProperty('prop', 'value');
    });

    test('helper methods should not crash', () {
      AnalyticsService.instance.logLoginStart();
      AnalyticsService.instance.logLoginPasskeyAttempt();
    });
  });

  // ===== web_utils_stub =====
  group('web_utils_stub', () {
    test('getWebUserAgent should return empty string', () {
      expect(web_stub.getWebUserAgent(), '');
    });

    test('isTouchDevice should return false', () {
      expect(web_stub.isTouchDevice(), false);
    });
  });

  // ===== BiometricService =====
  group('BiometricService', () {
    test('BiometricResult enum should have 3 values', () {
      expect(BiometricResult.values, hasLength(3));
      expect(BiometricResult.values, contains(BiometricResult.success));
      expect(BiometricResult.values, contains(BiometricResult.failed));
      expect(BiometricResult.values, contains(BiometricResult.hardwareUnavailable));
    });
  });

  // ===== SessionRefreshMutex expanded =====
  group('SessionRefreshMutex', () {
    setUp(() {
      SessionRefreshMutex.isLoggedOut = false;
      SessionRefreshMutex.passkeyFlowInProgress = false;
      SessionRefreshMutex.isRefreshing = false;
    });

    test('guardedRefreshIfNeeded should skip when logged out', () async {
      SessionRefreshMutex.isLoggedOut = true;
      await SessionRefreshMutex.guardedRefreshIfNeeded();
      // Should return without error
    });

    test('guardedRefreshIfNeeded should skip during passkey flow', () async {
      SessionRefreshMutex.passkeyFlowInProgress = true;
      await SessionRefreshMutex.guardedRefreshIfNeeded();
    });

    test('isRefreshing should track refresh state', () {
      SessionRefreshMutex.isRefreshing = true;
      expect(SessionRefreshMutex.isRefreshing, true);
      SessionRefreshMutex.isRefreshing = false;
      expect(SessionRefreshMutex.isRefreshing, false);
    });
  });

  // ===== ToastManager =====
  group('ToastManager', () {
    test('overlayStateOrNull returns null in test env', () {
      expect(ToastManager.overlayStateOrNull, isNull);
    });
  });
}
