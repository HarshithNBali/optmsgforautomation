import 'package:flutter_test/flutter_test.dart';
import 'package:optmsg/model/auth/enter_otp_state.dart';
import 'package:optmsg/model/auth/passkey_state.dart';
import 'package:optmsg/model/auth/biometric_accept_result.dart';
import 'package:optmsg/model/auth/biometric_denied_result.dart';

void main() {
  group('EnterOtpState', () {
    test('defaults should be sensible', () {
      const state = EnterOtpState();
      expect(state.loading, false);
      expect(state.formattedPhone, '');
      expect(state.mobile, '');
      expect(state.countryCode, '+1');
      expect(state.userData, isNull);
    });

    group('computed properties', () {
      test('isLoading should mirror loading field', () {
        const state = EnterOtpState(loading: true);
        expect(state.isLoading, true);
        expect(const EnterOtpState().isLoading, false);
      });

      test('hasUserData should check userData presence', () {
        expect(const EnterOtpState().hasUserData, false);
        const state = EnterOtpState(userData: {'user': {}});
        expect(state.hasUserData, true);
      });

      test('hasMobile should check mobile is not empty', () {
        expect(const EnterOtpState().hasMobile, false);
        const state = EnterOtpState(mobile: '5551234567');
        expect(state.hasMobile, true);
      });

      test('displayPhone should prefer formattedPhone over mobile', () {
        const withFormatted = EnterOtpState(
          formattedPhone: '+1 (555) 123-4567',
          mobile: '5551234567',
        );
        expect(withFormatted.displayPhone, '+1 (555) 123-4567');

        const withoutFormatted = EnterOtpState(mobile: '5551234567');
        expect(withoutFormatted.displayPhone, '5551234567');
      });

      test('isValid should require both mobile and userData', () {
        expect(const EnterOtpState().isValid, false);
        expect(
          const EnterOtpState(mobile: '555').isValid,
          false,
        );
        expect(
          const EnterOtpState(userData: {'user': {}}).isValid,
          false,
        );
        const valid = EnterOtpState(
          mobile: '5551234567',
          userData: {'user': {}},
        );
        expect(valid.isValid, true);
      });

      test('fullPhone should concatenate countryCode and mobile', () {
        const state = EnterOtpState(countryCode: '+44', mobile: '7700900000');
        expect(state.fullPhone, '+447700900000');
      });
    });

    test('copyWith should produce modified copy', () {
      const original = EnterOtpState();
      final modified = original.copyWith(
        loading: true,
        mobile: '555',
        countryCode: '+44',
      );
      expect(modified.loading, true);
      expect(modified.mobile, '555');
      expect(modified.countryCode, '+44');
      expect(modified.formattedPhone, '');
    });
  });

  group('PasskeyState', () {
    test('defaults should be sensible', () {
      const state = PasskeyState();
      expect(state.isLoading, false);
      expect(state.isEnabling, false);
      expect(state.isEnabled, false);
      expect(state.passkeySupported, false);
      expect(state.hasCompletedOnboarding, false);
      expect(state.userData, isNull);
      expect(state.errorMessage, isNull);
    });

    group('computed properties', () {
      test('hasUserData', () {
        expect(const PasskeyState().hasUserData, false);
        const state = PasskeyState(userData: {'user': {}});
        expect(state.hasUserData, true);
      });

      test('hasError', () {
        expect(const PasskeyState().hasError, false);
        const state = PasskeyState(errorMessage: 'oops');
        expect(state.hasError, true);
      });

      test('canEnable requires !isLoading, !isEnabled, hasUserData', () {
        expect(const PasskeyState().canEnable, false); // no userData

        const loading = PasskeyState(
          isLoading: true,
          userData: {'user': {}},
        );
        expect(loading.canEnable, false);

        const alreadyEnabled = PasskeyState(
          isEnabled: true,
          userData: {'user': {}},
        );
        expect(alreadyEnabled.canEnable, false);

        const ready = PasskeyState(userData: {'user': {}});
        expect(ready.canEnable, true);
      });

      test('userName should join first and last name', () {
        const state = PasskeyState(
          userData: {
            'user': {'firstName': 'Jane', 'lastName': 'Doe'}
          },
        );
        expect(state.userName, 'Jane Doe');
      });

      test('userName should handle missing fields', () {
        const state = PasskeyState(userData: {'user': {}});
        expect(state.userName, '');
      });

      test('userEmail and loginId should extract userName', () {
        const state = PasskeyState(
          userData: {
            'user': {'userName': 'janedoe'}
          },
        );
        expect(state.userEmail, 'janedoe');
        expect(state.loginId, 'janedoe');
      });

      test('boardingStatus should extract boardingSteps', () {
        const state = PasskeyState(
          userData: {
            'user': {'boardingSteps': 'completed'}
          },
        );
        expect(state.boardingStatus, 'completed');
      });

      test('boardingStatus defaults to empty string', () {
        const state = PasskeyState();
        expect(state.boardingStatus, '');
      });
    });

    test('copyWith should produce modified copy', () {
      const original = PasskeyState();
      final modified = original.copyWith(
        isLoading: true,
        passkeySupported: true,
        errorMessage: 'fail',
      );
      expect(modified.isLoading, true);
      expect(modified.passkeySupported, true);
      expect(modified.errorMessage, 'fail');
    });
  });

  group('BiometricAcceptResult', () {
    test('should store all fields', () {
      final result = BiometricAcceptResult(
        authenticated: true,
        passkeySupported: true,
        boardingStatus: 'completed',
        webAuthn: true,
        isMobileLayout: false,
      );
      expect(result.authenticated, true);
      expect(result.passkeySupported, true);
      expect(result.boardingStatus, 'completed');
      expect(result.webAuthn, true);
      expect(result.isMobileLayout, false);
    });

    test('should handle false values', () {
      final result = BiometricAcceptResult(
        authenticated: false,
        passkeySupported: false,
        boardingStatus: '',
        webAuthn: false,
        isMobileLayout: true,
      );
      expect(result.authenticated, false);
      expect(result.passkeySupported, false);
    });
  });

  group('BiometricDeniedResult', () {
    test('should store all fields', () {
      final result = BiometricDeniedResult(
        webAuthn: true,
        boardingStatus: 'notification',
        passkeySupported: false,
      );
      expect(result.webAuthn, true);
      expect(result.boardingStatus, 'notification');
      expect(result.passkeySupported, false);
    });
  });
}
