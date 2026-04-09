import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:optmsg/router/app_routes.dart';
import 'package:optmsg/services/common_service.dart';
import 'package:optmsg/services/storage_service.dart';
import 'package:optmsg/screens/auth/login_post_processor.dart';
import 'package:optmsg/screens/auth/auth_riverpod/auth_notifier.dart';
import 'package:optmsg/common/app_manger/app_cache.dart';
import 'package:optmsg/common/utilites/logger.dart';
import 'package:optmsg/constant/app_typography.dart';
import 'package:optmsg/webPackerHandler/mobile_check_out.dart'
    if (dart.library.js_interop) 'package:optmsg/webPackerHandler/web_check_out.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProcessingPaymentScreen extends ConsumerStatefulWidget {
  final Map<String, String> queryParams;

  const ProcessingPaymentScreen({super.key, required this.queryParams});

  @override
  ConsumerState<ProcessingPaymentScreen> createState() =>
      _ProcessingPaymentScreenState();
}

class _ProcessingPaymentScreenState
    extends ConsumerState<ProcessingPaymentScreen> {
  final SecureStorageService storage = SecureStorageService();

  @override
  void initState() {
    super.initState();
    // Use addPostFrameCallback to ensure the widget is fully mounted before async navigation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _processPaymentRedirect();
    });
  }

  Future<void> _processPaymentRedirect() async {
    // 1. Poll until SecureStorage is ready (replaces fixed 500 ms delay).
    //    Each attempt waits 100 ms; give up after 20 attempts (~2 s total).
    //    M-11: Increased from 10 to 20 attempts for slow first reads.
    String? isCheckout;
    for (int attempt = 0; attempt < 20; attempt++) {
      if (!mounted) return;
      isCheckout = await storage.readData('isCheckout');
      if (isCheckout != null) break;
      await Future.delayed(const Duration(milliseconds: 100));
    }
    if (!mounted) return;

    // WEB FALLBACK: SecureStorage uses sessionStorage which is cleared after
    // cross-origin navigation (Stripe). Fall back to SharedPreferences
    // (localStorage) which persists.
    if (kIsWeb && isCheckout == null) {
      final prefs = await SharedPreferences.getInstance();
      if (!mounted) return;
      isCheckout = prefs.getString('isCheckout');
    }
    // Fallback: treat as checkout if we have success params but storage timed out
    isCheckout ??= (widget.queryParams['success'] == 'true' ||
            widget.queryParams['paymentStatus'] == 'success')
        ? 'true'
        : null;

    // 2. NOW we can safely read the remaining SecureStorage values
    String subscriptionPage = await storage.readData('subscriptionPage') ?? '';
    if (!mounted) return;
    if (kIsWeb && subscriptionPage.isEmpty) {
      final prefs = await SharedPreferences.getInstance();
      if (!mounted) return;
      subscriptionPage = prefs.getString('subscriptionPage') ?? '';
    }

    // 3. Evaluate the Stripe payload
    final isRecovered = widget.queryParams['recovered'] == 'true';
    final isSuccess = widget.queryParams['success'] == 'true' ||
        widget.queryParams['paymentStatus'] == 'success';
    final isFailure = widget.queryParams['success'] == 'false' ||
        widget.queryParams['paymentStatus'] == 'failed';

    try {
      printLog("ProcessingPaymentScreen",
          "Check: isCheckout=$isCheckout, isSuccess=$isSuccess, isFailure=$isFailure, isRecovered=$isRecovered");

      // R-06: For "recovered" sessions where no success param is present, the
      // user pressed Back on Stripe without completing payment. Skip the backend
      // verification entirely — making an API call here can trigger spurious
      // "session expired" errors on cold-start before the JWT has been refreshed.
      // Route directly to /checkout so the user can review their order and retry.
      if (isCheckout == 'true' && isRecovered && !isSuccess) {
        printLog("ProcessingPaymentScreen",
            "Recovered session (user pressed Back). Returning to checkout without verification.");
        await _clearCheckoutState();
        if (!mounted) return;
        CheckOutImp().clearUrlParams();
        if (mounted) context.go(AppRoutes.checkout);
        return;
      }

      // PP-01: For successful payments, wait for _initialize() to complete before
      // proceeding. After Stripe cross-origin redirect, SecureStorage (sessionStorage)
      // is cleared. _initialize() Branch 2 re-fetches userData via user/get-profile
      // and sets AuthState.authenticated(userData). We must wait for this before
      // reading userData or checking auth state.
      if (isCheckout == 'true' && isSuccess) {
        for (int attempt = 0; attempt < 40; attempt++) {
          if (!mounted) return;
          if (ref.read(authProvider).isInitialized) break;
          await Future.delayed(const Duration(milliseconds: 100));
        }
        if (!mounted) return;

        // Security check: _initialize() restored auth from the Descope session.
        // If it could not (no valid session = Branch 3), treat as unverified.
        // Trust: isCheckout='true' (our localStorage flag) + Stripe's success URL.
        final authState = ref.read(authProvider);
        if (!authState.isAuthenticated) {
          await _clearCheckoutState();
          if (!mounted) return;
          CheckOutImp().clearUrlParams();
          printLog("ProcessingPaymentScreen",
              "Auth not restored after init. Routing to plans.");
          CommonService.animatedToast(
            'Payment could not be confirmed. Please log in and try again.',
            'error',
          );
          if (mounted) context.go(AppRoutes.plans);
          return;
        }

        await storage.writeData('isAuthenticated', 'true');
        await storage.writeData('signupInProgress', 'false');
        AppCache().setSignupInProgress('false');
        if (!mounted) return;
        await _clearCheckoutState();
        if (!mounted) return;

        // userData is guaranteed non-null: isAuthenticated=true means
        // AuthState.authenticated(userData) was set by _initialize().
        final userData = authState.userData!;
        ref
            .read(authProvider.notifier)
            .setAuthenticated(true, userData: userData);

        // CLEAR URL before GoRouter attempts to evaluate the next route!
        // Otherwise, it gets stuck in an infinite loop intercepting "success=true"
        CheckOutImp().clearUrlParams();

        if (subscriptionPage == 'subscription') {
          // Existing subscribers upgrading — skip passkey setup
          if (mounted) context.go(AppRoutes.paymentSuccess);
          return;
        }

        await LoginPostProcessor.goToAddPassKeyIfNeeded(
          pageKey: 'paymentSuccess',
          fallback: () async {
            if (mounted) context.go(AppRoutes.paymentSuccess);
          },
        );
        return;
      }

      if (isCheckout == 'true' && isFailure) {
        await _clearCheckoutState();
        if (!mounted) return;
        CheckOutImp().clearUrlParams();
        if (mounted) context.go(AppRoutes.plans);
        return;
      }

      printLog("ProcessingPaymentScreen",
          "Missing conditions. Routing to plans as fallback.");
      CheckOutImp().clearUrlParams();
      // Fallback if somehow missing — use /plans (public route) not /inbox
      if (mounted) context.go(AppRoutes.plans);
    } catch (e) {
      printLog("ProcessingPaymentScreen", "Error caught: $e");
      if (mounted) context.go(AppRoutes.plans);
    }
  }

  /// Clears the isCheckout flag from all storage layers.
  Future<void> _clearCheckoutState() async {
    await storage.writeData('isCheckout', 'false');
    AppCache().setIsCheckout('false');
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('isCheckout');
      await prefs.remove('selected_plan_json');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 24),
            Text(
              'Confirming Payment...',
              style: AppTypography.inboxTitle(context),
            ),
            const SizedBox(height: 8),
            Text(
              'Please do not close this window.',
              style: AppTypography.slogan(context),
            ),
          ],
        ),
      ),
    );
  }
}
