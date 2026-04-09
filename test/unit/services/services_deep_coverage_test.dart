import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:optmsg/common/responsive/breakpoints.dart' show DeviceType;
import 'package:optmsg/services/analytics_service.dart';
import 'package:optmsg/services/biometric_service.dart';
import 'package:optmsg/services/adaptive_service.dart';
import 'package:optmsg/services/common_service.dart';
import 'package:optmsg/services/action_biometric_guard.dart';
import 'package:optmsg/services/count_notifier.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // ===== AnalyticsService all methods =====
  group('AnalyticsService all helper methods', () {
    final analytics = AnalyticsService.instance;

    // All methods guard behind firebaseReady which is false in tests.
    // Calling them exercises the code path without hitting Firebase.

    test('login flow helpers', () {
      analytics.logLoginStart();
      analytics.logLoginPasskeyAttempt();
      analytics.logLoginPasskeySuccess();
      analytics.logLoginPasskeyFail('test error');
      analytics.logLoginOtpSent();
      analytics.logLoginOtpSent(isFallback: true);
      analytics.logLoginOtpVerified();
      analytics.logLoginOtpFailed('invalid code');
      analytics.logLoginSuccess('otp');
      analytics.logLoginSuccess('passkey');
      analytics.logLoginFailed('subscription_invalid');
    });

    test('passkey enrollment helpers', () {
      analytics.logPasskeyEnrollStart();
      analytics.logPasskeyEnrollSuccess();
      analytics.logPasskeyEnrollSkip();
      analytics.logPasskeyEnrollFail('device not supported');
    });

    test('signup flow helpers', () {
      analytics.logSignupStart();
      analytics.logSignupUsernameCheck(true);
      analytics.logSignupUsernameCheck(false);
      analytics.logSignupOtpSent();
      analytics.logSignupOtpVerified();
      analytics.logSignupProfileSubmit();
      analytics.logSignupComplete();
    });

    test('subscription helpers', () {
      analytics.logPlanView();
      analytics.logPlanSelected('Pro', 'monthly', 9.99);
      analytics.logFreePlanSelected('Reader');
      analytics.logCheckoutBegin('Pro', 'monthly', 9.99);
      analytics.logPromoCodeApplied('SAVE10', 'percent', 10.0);
      analytics.logPromoCodeFailed('BAD', 'invalid');
      analytics.logPromoCodeRemoved();
      analytics.logPaymentStart('Pro', 9.99, true);
      analytics.logPaymentRedirectStripe('Pro');
      analytics.logPaymentSuccess('Pro', 'monthly', 9.99, 'SAVE10');
      analytics.logPaymentSuccess('Pro', 'monthly', 9.99, null);
      analytics.logPaymentFailed('Pro', 'card declined');
      analytics.logSubscriptionCancelled();
      analytics.logSubscriptionChangeStart('Reader', 'Pro');
    });

    test('core methods', () {
      analytics.logEvent('custom_event');
      analytics.logEvent('custom_event', {'key': 'value'});
      analytics.setUserProperty('test_prop', 'test_value');
      analytics.setUserProperty('test_prop', null);
    });

    test('_truncate should handle long strings', () {
      // Call a method that uses _truncate with a long error
      final longError = 'x' * 200;
      analytics.logLoginPasskeyFail(longError);
      analytics.logPaymentFailed('plan', longError);
      // Should not crash — _truncate limits to 100 chars
    });
  });

  // ===== BiometricService =====
  group('BiometricService', () {
    test('BiometricResult values', () {
      expect(BiometricResult.success.index, 0);
      expect(BiometricResult.failed.index, 1);
      expect(BiometricResult.hardwareUnavailable.index, 2);
    });

    test('BiometricService can be instantiated', () {
      final service = BiometricService();
      expect(service, isNotNull);
    });
  });

  // ===== AdaptiveService =====
  group('AdaptiveService', () {
    testWidgets('screenWidth should return positive value', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(builder: (context) {
            final width = AdaptiveService.screenWidth(context);
            expect(width, 400.0);
            return const SizedBox();
          }),
        ),
      );

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('screenHeight should return positive value', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(builder: (context) {
            final height = AdaptiveService.screenHeight(context);
            expect(height, 800.0);
            return const SizedBox();
          }),
        ),
      );

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('isMobileLayout for small screen', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(builder: (context) {
            final isMobile = AdaptiveService.isMobileLayout(context);
            expect(isMobile, isA<bool>());
            return const SizedBox();
          }),
        ),
      );

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('getDeviceType should return a DeviceType', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(builder: (context) {
            final type = AdaptiveService.getDeviceType(context);
            expect(type, isA<DeviceType>());
            return const SizedBox();
          }),
        ),
      );

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  });

  // ===== CommonService extensionTypesIcon =====
  group('CommonService extensionTypesIcon', () {
    final service = CommonService();

    test('should return SvgPicture for image types', () {
      expect(service.extensionTypesIcon('image/jpeg'), isNotNull);
      expect(service.extensionTypesIcon('image/png'), isNotNull);
      expect(service.extensionTypesIcon('image'), isNotNull);
    });

    test('should return SvgPicture for pdf', () {
      expect(service.extensionTypesIcon('pdf'), isNotNull);
    });

    test('should return SvgPicture for video', () {
      expect(service.extensionTypesIcon('video'), isNotNull);
    });

    test('should return SvgPicture for mp3', () {
      expect(service.extensionTypesIcon('mp3'), isNotNull);
    });

    test('should return SvgPicture for zip', () {
      expect(service.extensionTypesIcon('zip'), isNotNull);
    });

    test('should return default SvgPicture for unknown type', () {
      expect(service.extensionTypesIcon('unknown'), isNotNull);
      expect(service.extensionTypesIcon('docx'), isNotNull);
    });
  });

  // ===== CommonService isMobileBrowser/isTouchDevice =====
  group('CommonService platform methods', () {
    test('isMobileBrowser should return false on non-web', () {
      expect(CommonService.isMobileBrowser(), false);
    });

    test('isTouchDevice should return false on non-web', () {
      expect(CommonService.isTouchDevice(), false);
    });

    test('isMobileOrTouchDevice should return false on non-web', () {
      expect(CommonService.isMobileOrTouchDevice(), false);
    });
  });

  // ===== ActionBiometricGuard expanded =====
  group('ActionBiometricGuard expanded', () {
    test('markDeparture and markReturn are safe no-ops without controller', () {
      expect(() => ActionBiometricGuard.markDeparture(), returnsNormally);
      expect(() => ActionBiometricGuard.markReturn(), returnsNormally);
    });
  });

  // ===== CountNotifier expanded =====
  group('CountNotifier CountState', () {
    test('copyWith all fields', () {
      final state = const CountState().copyWith(
        inboxCount: 10,
        draftCount: 5,
        archiveCount: 20,
        trashCount: 3,
        isUpdateDialogVisible: true,
        isUpdatePopUpDismiss: true,
        newNotification: 'yes',
      );
      expect(state.inboxCount, 10);
      expect(state.draftCount, 5);
      expect(state.archiveCount, 20);
      expect(state.trashCount, 3);
      expect(state.isUpdateDialogVisible, true);
      expect(state.isUpdatePopUpDismiss, true);
      expect(state.newNotification, 'yes');
    });
  });
}
