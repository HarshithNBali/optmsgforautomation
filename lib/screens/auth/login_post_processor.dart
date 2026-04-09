import 'package:descope/descope.dart';
import 'package:optmsg/main.dart';
import 'package:optmsg/model/login_model.dart';
import 'package:optmsg/router/app_routes.dart';
import 'package:optmsg/screens/auth/auth_riverpod/auth_notifier.dart';
import 'package:optmsg/services/storage_service.dart';

/// Shared post-auth navigation logic: post-login flow and passkey enrollment
/// gating used by auth, OTP, and payment screens.
class LoginPostProcessor {
  const LoginPostProcessor._();

  /// After a successful `userLogin()`, navigate to passkey setup (if supported
  /// and not already enrolled) or directly to inbox/plans based on subscription.
  static Future<void> navigateAfterLogin(Map<String, dynamic> userData) async {
    await goToAddPassKeyIfNeeded(
      pageKey: 'login',
      fallback: () async => _navigateBySubscription(userData),
    );
  }

  /// Navigate to passkey setup only if the device supports passkeys AND the
  /// user has not already enrolled one. Otherwise calls [fallback] to continue.
  static Future<void> goToAddPassKeyIfNeeded({
    String pageKey = '',
    required Future<void> Function() fallback,
  }) async {
    try {
      // 1. Check enrollment (in-memory auth state first, then storage)
      final authState = providerContainer.read(authProvider);
      if (authState.userData?['user']?['webauthn'] == true) {
        await fallback();
        return;
      }
      final flag = await SecureStorageService().readData('hasPasskeyEnrolled');
      if (flag == 'true') {
        await fallback();
        return;
      }

      // 2. Check device support
      if (!await Descope.passkey.isSupported()) {
        await fallback();
        return;
      }

      // 3. Both conditions met — show AddPassKey
      appRouter.go(AppRoutes.addPassKey, extra: {'pageKey': pageKey});
    } catch (_) {
      // If anything throws, skip passkey gracefully
      await fallback();
    }
  }

  static void _navigateBySubscription(Map<String, dynamic> userData) {
    final login = LoginModel.fromJson({
      'success': true,
      'data': userData,
      'message': '',
    });

    if (isSubscriptionValid(login)) {
      appRouter.go(AppRoutes.inbox);
    } else {
      appRouter.go(AppRoutes.plans);
    }
  }
}
