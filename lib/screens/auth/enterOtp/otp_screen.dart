import 'dart:async';
import 'package:optmsg/common/responsive/responsive.dart';
import 'package:optmsg/model/login_model.dart';
import 'package:optmsg/model/otp_verify_model.dart';
import 'package:optmsg/model/auth/auth_state.dart';
import 'package:optmsg/screens/auth/auth_riverpod/auth_notifier.dart';
import 'package:optmsg/screens/auth/enterOtp/widgets/otp_desktop_layout.dart';
import 'package:optmsg/screens/auth/enterOtp/widgets/otp_mobile_layout.dart';

import 'package:optmsg/services/analytics_service.dart';
import 'package:optmsg/services/common_service.dart';
import 'package:optmsg/services/storage_service.dart';
import 'package:optmsg/common/app_manger/app_cache.dart';
import 'package:optmsg/widgets/load_container/load_container.dart';
import 'package:optmsg/widgets/load_container/loader_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:optmsg/router/app_routes.dart';
import 'package:optmsg/screens/auth/login_post_processor.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OtpScreen extends ConsumerStatefulWidget {
  final String pageKey;
  final bool webAuthn;
  final String loginId;
  final String userName;

  const OtpScreen({
    super.key,
    required this.pageKey,
    required this.webAuthn,
    required this.loginId,
    required this.userName,
  });

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final _otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _focusNode = FocusNode();
  final _scrollController = ScrollController();
  final secureStorageService = SecureStorageService();

  // A-10: Client-side resend cooldown (mirrors web_enter_otp.dart pattern).
  int _resendCooldownSeconds = 0;
  Timer? _resendTimer;

  @override
  void initState() {
    super.initState();
    _otpController.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authProvider.notifier).otpInit(widget.loginId);
      FocusScope.of(context).requestFocus(_focusNode);
    });
  }

  @override
  void dispose() {
    _otpController.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    _resendTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formattedPhone =
        ref.watch(authProvider.select((s) => s.formattedPhone));
    final isLoading = ref.watch(authProvider.select((s) => s.isLoading));

    ref.listen(authProvider, (prev, next) {
      ref.read(loaderProvider.notifier).set(next.isLoading);
      if (next.status == AuthStatus.error && prev?.status != AuthStatus.error) {
        _otpController.clear();
      }
    });

    return Scaffold(
      key: const Key('otp_screen'),
      resizeToAvoidBottomInset: false,
      body: LoaderContainer(
        child: ResponsiveLayoutBuilder(
          mobile: (ctx, deviceType, width) => OtpMobileLayout(
            formKey: _formKey,
            otpController: _otpController,
            focusNode: _focusNode,
            formattedPhone: formattedPhone ?? '',
            onSubmit: _handleSubmit,
            onResend: _handleResend,
            onBack: () => context.pop(),
            isLoading: isLoading,
            resendCooldownSeconds: _resendCooldownSeconds,
          ),
          tablet: (ctx, deviceType, width) => OtpDesktopLayout(
            formKey: _formKey,
            otpController: _otpController,
            focusNode: _focusNode,
            formattedPhone: formattedPhone ?? '',
            onSubmit: _handleSubmit,
            onResend: _handleResend,
            onBack: () => context.pop(),
            scrollController: _scrollController,
            isLoading: isLoading,
            resendCooldownSeconds: _resendCooldownSeconds,
          ),
          desktop: (ctx, deviceType, width) => OtpDesktopLayout(
            formKey: _formKey,
            otpController: _otpController,
            focusNode: _focusNode,
            formattedPhone: formattedPhone ?? '',
            onSubmit: _handleSubmit,
            onResend: _handleResend,
            onBack: () => context.pop(),
            scrollController: _scrollController,
            isLoading: isLoading,
            resendCooldownSeconds: _resendCooldownSeconds,
          ),
        ),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    FocusScope.of(context).unfocus();
    _focusNode.unfocus();

    if (!_formKey.currentState!.validate()) return;
    if (_otpController.text.isEmpty) {
      CommonService.animatedToast('Please enter OTP', 'error');
      return;
    }

    try {
      if (widget.pageKey == 'login') {
        await ref
            .read(authProvider.notifier)
            .verifyDescopeOtp(widget.userName, _otpController.text);
        if (!mounted) return;

        final deviceToken =
            await secureStorageService.readData('deviceToken') ?? '';
        if (!mounted) return;
        await ref.read(authProvider.notifier).userLogin(deviceToken);
        if (!mounted) return;

        final finalState = ref.read(authProvider);
        if (finalState.isAuthenticated && finalState.userData != null) {
          await _validateResponse(finalState.userData!);
        }
      } else if (widget.pageKey == 'signup') {
        // H-02 fix: signup OTP uses Descope verification, then navigates
        // to setup profile — not the legacy OTP path.
        await ref
            .read(authProvider.notifier)
            .verifyDescopeOtp(widget.userName, _otpController.text);
        if (!mounted) return;
        // SP-01: Set signupInProgress before navigating so the router's
        // setup-profile guard allows access while auth state is still
        // 'authenticating' (setAuthenticated is not called until setupProfile
        // is submitted).
        AppCache().setSignupInProgress('true');
        await SecureStorageService().writeData('signupInProgress', 'true');
        if (!mounted) return;
        AnalyticsService.instance.logSignupOtpVerified();
        context.pushReplacement(
          AppRoutes.setupProfile,
          extra: {'userName': widget.userName},
        );
      } else {
        final response = await ref
            .read(authProvider.notifier)
            .verifyLegacyOtp(_otpController.text);
        if (!mounted) return;
        if (response['success']) {
          OtpVerify otpVerify = OtpVerify.fromJson(response);
          CommonService.animatedToast(otpVerify.message, 'success');
          if (!mounted) return;
          context.pushReplacement(AppRoutes.successOtp);
        } else {
          _otpController.clear();
        }
      }
    } catch (e) {
      // Handled in notifier
    }
  }

  void _handleResend() {
    if (_resendCooldownSeconds > 0) return;
    FocusScope.of(context).unfocus();
    _focusNode.unfocus();
    _otpController.clear();

    ref.read(authProvider.notifier).resendOtp(
          widget.userName,
          isLogin: widget.pageKey == 'login',
          loginId: widget.loginId,
        );
    _startResendCooldown();
  }

  void _startResendCooldown() {
    _resendTimer?.cancel();
    setState(() => _resendCooldownSeconds = 30);
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _resendCooldownSeconds--;
        if (_resendCooldownSeconds <= 0) timer.cancel();
      });
    });
  }

  Future<void> _validateResponse(Map<String, dynamic> loginResponse) async {
    // Note: AuthNotifier has already validated the response and set the state.
    // This method handles the post-login UI redirection and biometrics.

    LoginModel login = LoginModel.fromJson(loginResponse);
    final bool isValid = isSubscriptionValid(login);

    if (isValid) {
      if (mounted) {
        context.pop();
      }

      // If the user just authenticated via passkey (webAuthn), skip the
      // biometric prompt — they already proved their identity. Proceed
      // directly to the post-login navigation.
      if (widget.webAuthn) {
        await _onBiometricDenied();
        return;
      }

      final isBiometricEnable =
          await secureStorageService.readData('isBiometricEnable');

      if (isBiometricEnable == 'true') {
        await _onBiometricAccept();
      } else {
        await _onBiometricDenied();
      }
    } else {
      CommonService.animatedToast(
          'Invalid User or Subscription Expired', 'error');
      _otpController.clear();
    }
  }

  Future<void> _onBiometricAccept() async {
    await ref.read(authProvider.notifier).biometricAccept(
          context.isMobile,
        );

    if (!mounted) return;
    await LoginPostProcessor.goToAddPassKeyIfNeeded(
      pageKey: widget.pageKey,
      fallback: () async => _navigateAfterLogin(),
    );
  }

  Future<void> _onBiometricDenied() async {
    await ref.read(authProvider.notifier).biometricDenied(widget.webAuthn);

    if (!mounted) return;
    await LoginPostProcessor.goToAddPassKeyIfNeeded(
      pageKey: widget.pageKey,
      fallback: () async => _navigateAfterLogin(),
    );
  }

  /// Routes to onboarding or inbox based on the user's boarding status.
  Future<void> _navigateAfterLogin() async {
    final storage = SecureStorageService();
    final hasCompleted =
        await storage.readData('hasCompletedOnboarding') == 'true';

    if (hasCompleted || kIsWeb) {
      if (!mounted) return;
      context.go(AppRoutes.inbox);
      return;
    }

    final userData = ref.read(authProvider).userData;
    final boardingStatus =
        userData?['user']?['boardingSteps'] ?? 'notification';

    if (!mounted) return;
    if (boardingStatus == 'notification') {
      context.go(AppRoutes.inbox);
    } else {
      context.go(AppRoutes.onboarding, extra: {'status': boardingStatus});
    }
  }
}
