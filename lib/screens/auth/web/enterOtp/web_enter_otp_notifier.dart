import 'dart:async';

import 'package:optmsg/common/app_manger/app_cache.dart';
import 'package:optmsg/screens/auth/auth_riverpod/auth_notifier.dart';
import 'package:optmsg/screens/auth/login_post_processor.dart';
import 'package:optmsg/screens/auth/web/enterOtp/web_enter_otp_state.dart';
import 'package:optmsg/services/storage_service.dart';
import 'package:descope/descope.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../router/app_router.dart' show rootNavigatorKey;
import '../../../../router/app_routes.dart';
import '../../../../services/analytics_service.dart';
import '../../../../services/api_service.dart';
import '../../../../services/common_service.dart';
import '../../../../services/descope_error_mapper.dart';

final webEnterOtpProvider =
    NotifierProvider<WebEnterOtpNotifier, WebEnterOtpState>(
        WebEnterOtpNotifier.new);

class WebEnterOtpNotifier extends Notifier<WebEnterOtpState> {
  final AnalyticsService _analytics = AnalyticsService.instance;
  final SecureStorageService secureStorageService = SecureStorageService();
  bool _disposed = false;

  // H-16: Recreated in build() to avoid use-after-dispose on invalidation
  late TextEditingController otpController;
  Timer? _resendCooldownTimer;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  WebEnterOtpState build() {
    _disposed = false;
    otpController = TextEditingController();
    ref.onDispose(() {
      _disposed = true;
      otpController.dispose();
      _resendCooldownTimer?.cancel();
    });
    return const WebEnterOtpState();
  }

  /// L-01: Start a 30-second cooldown after sending an OTP.
  void _startResendCooldown() {
    _resendCooldownTimer?.cancel();
    state = state.copyWith(resendCooldownSeconds: 30);
    _resendCooldownTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) {
        final remaining = state.resendCooldownSeconds - 1;
        if (remaining <= 0) {
          _resendCooldownTimer?.cancel();
          state = state.copyWith(resendCooldownSeconds: 0);
        } else {
          state = state.copyWith(resendCooldownSeconds: remaining);
        }
      },
    );
  }

  // ================= INITIALIZE =================

  Future<void> initialize(String loginId) async {
    otpController.clear();

    final userData = ref.read(authProvider).userData;

    final deviceToken =
        await secureStorageService.readData('deviceToken') ?? '';

    final countryCode =
        await secureStorageService.readData('countryCode') ?? '+1';

    final formatted = CommonService().formatPhoneNumber(countryCode, loginId);

    state = state.copyWith(
      userData: userData,
      deviceToken: deviceToken,
      countryCode: countryCode,
      formattedPhoneNumber: formatted,
    );
  }

  // ================= VALIDATION =================

  bool _validateOtp() {
    if (!formKey.currentState!.validate()) return false;

    if (otpController.text.isEmpty) {
      CommonService.animatedToast('Please enter OTP', 'error');
      return false;
    }
    return true;
  }

  void clearOtp() => otpController.clear();

  // ================= DESCOPE VERIFY =================

  Future<void> _verifyDescopeOtp(String userName) async {
    final authResponse = await Descope.otp.verify(
      method: DeliveryMethod.sms,
      loginId: userName,
      code: otpController.text,
    );

    final session = DescopeSession.fromAuthenticationResponse(authResponse);

    Descope.sessionManager.manageSession(session);
  }

  // ================= SUBMIT LOGIN OTP =================

  Future<void> submitOtp({
    required String userName,
  }) async {
    if (!_validateOtp()) return;

    try {
      state = state.copyWith(isLoading: true);

      await _verifyDescopeOtp(userName);
      if (_disposed) return;
      _analytics.logLoginOtpVerified();

      // H-01 fix: delegate to the canonical AuthNotifier.userLogin() instead
      // of duplicating its API call, subscription validation, and storage writes.
      final authState = await ref
          .read(authProvider.notifier)
          .userLogin(state.deviceToken);
      if (_disposed) return;

      if (authState.isAuthenticated && authState.userData != null) {
        await _navigateAfterLogin(authState.userData!);
      }
    } on DescopeException catch (e) {
      _analytics.logLoginOtpFailed(e.desc);
      CommonService.animatedToast(mapDescopeError(e), 'error');
      clearOtp();
    } finally {
      if (!_disposed) state = state.copyWith(isLoading: false);
    }
  }

  // ================= POST-LOGIN NAVIGATION =================

  Future<void> _navigateAfterLogin(Map<String, dynamic> userData) =>
      LoginPostProcessor.navigateAfterLogin(userData);

  // ================= RESEND OTP =================

  Future<void> resendOtp({
    required String pageKey,
    required String userName,
    required bool isLogin,
  }) async {
    // L-01: Prevent rapid-fire resend taps.
    if (state.resendCooldownSeconds > 0) return;

    try {
      clearOtp();

      if (pageKey == 'webForgotUserName') {
        final response = await ApiService().post(
          'auth/resend-otp',
          {"id": state.userData!['id']},
        );
        if (_disposed) return;

        CommonService.animatedToast(
          response['message'],
          response['success'] ? 'success' : 'error',
        );
        _startResendCooldown();
        return;
      }

      if (isLogin) {
        await Descope.otp.signIn(
          method: DeliveryMethod.sms,
          loginId: userName,
        );
      } else {
        // Normalise to E.164: keep leading '+', strip all non-digit characters.
        final e164 =
            '+${state.formattedPhoneNumber.replaceAll(RegExp(r'[^\d]'), '')}';
        await Descope.otp.signUp(
          method: DeliveryMethod.sms,
          loginId: userName,
          details: SignUpDetails(
            phone: e164,
          ),
        );
      }
      if (_disposed) return;

      CommonService.animatedToast('Otp sent', 'success');
      _startResendCooldown();
    } on DescopeException catch (e) {
      CommonService.animatedToast(mapDescopeError(e), 'error');
    }
  }

  // ================= VERIFY NON-LOGIN OTP =================

  Future<void> verifyOtp({
    required String pageKey,
    required String userName,
  }) async {
    if (!_validateOtp()) return;

    try {
      state = state.copyWith(isLoading: true);

      if (pageKey == 'webForgotUserName') {
        final response = await ApiService().post(
          'auth/verify-otp',
          {"id": state.userData!['id'], "otp": otpController.text},
        );
        if (_disposed) return;

        if (!response['success']) {
          clearOtp();
          CommonService.animatedToast(response['message'], 'error');
          return;
        }

        rootNavigatorKey.currentContext?.go(AppRoutes.usernameSuccess);
      } else {
        await _verifyDescopeOtp(userName);
        if (_disposed) return;
        // SP-01 (web): Set signupInProgress before navigating so the router's
        // setup-profile guard allows access while auth state is still
        // 'authenticating' (setAuthenticated is not called until setupProfile
        // is submitted).
        AppCache().setSignupInProgress('true');
        await secureStorageService.writeData('signupInProgress', 'true');
        if (_disposed) return;
        _analytics.logSignupOtpVerified();

        rootNavigatorKey.currentContext?.pushReplacement(
          AppRoutes.setupProfile,
          extra: {'userName': userName},
        );
      }
    } on DescopeException catch (e) {
      CommonService.animatedToast(mapDescopeError(e), 'error');
    } finally {
      if (!_disposed) state = state.copyWith(isLoading: false);
    }
  }
}
