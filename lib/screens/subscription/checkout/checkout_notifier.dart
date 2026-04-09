import 'dart:async';
import 'dart:convert';

import 'package:optmsg/common/app_manger/app_cache.dart';
import 'package:optmsg/common/utilites/logger.dart';
import 'package:optmsg/common/utilites/stripe_url_validator.dart';
import 'package:optmsg/main.dart';
import 'package:optmsg/screens/subscription/checkout/checkout_state.dart';
import 'package:optmsg/services/api_service.dart';
import 'package:optmsg/services/common_service.dart';
import 'package:optmsg/services/socket_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:optmsg/screens/auth/auth_riverpod/auth_notifier.dart';
import 'package:go_router/go_router.dart';
import 'package:optmsg/screens/auth/login_post_processor.dart';
import 'package:optmsg/webPackerHandler/mobile_check_out.dart'
    if (dart.library.js_interop) 'package:optmsg/webPackerHandler/web_check_out.dart';
import '../../../constant/app_config.dart' as app_urls;
import '../../../model/profile_model.dart';
import '../../../router/app_routes.dart';
import '../../../services/analytics_service.dart';
import '../../../services/storage_service.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';

const String _stripeRedirectTag = 'makePayment STRIPE REDIRECT';

final checkoutProvider = NotifierProvider.autoDispose<CheckoutNotifier, CheckoutState>(
  CheckoutNotifier.new,
);

class CheckoutNotifier extends Notifier<CheckoutState> {
  final AnalyticsService _analytics = AnalyticsService.instance;
  bool _disposed = false;
  bool _paymentHandled = false;
  bool _paymentInitiated = false;

  late final SecureStorageService storage;
  late final ApiService api;
  late final SocketService _socket;

  @override
  CheckoutState build() {
    storage = ref.read(storageServiceProvider);
    api = ref.read(apiServiceProvider);
    _socket = ref.read(socketServiceProvider);
    _disposed = false;
    _paymentHandled = false;
    _paymentInitiated = false;
    ref.onDispose(() {
      _disposed = true;
      _paymentSub?.cancel();
      _socketErrorSub?.cancel();
      _socketDisconnectSub?.cancel();
      _paymentTimeout?.cancel();
      _progressTimer30s?.cancel();
      _progressTimer120s?.cancel();
    });
    return const CheckoutState();
  }

  StreamSubscription? _paymentSub;
  StreamSubscription? _socketErrorSub;
  StreamSubscription? _socketDisconnectSub;
  Timer? _paymentTimeout;
  Timer? _progressTimer30s;
  Timer? _progressTimer120s;

  // ✅ INIT CHECKOUT
  Future<void> initCheckout() async {
    state = state.copyWith(isLoading: true);

    try {
      // Primary: read from secure storage. On web, the WebCrypto key lives in
      // IndexedDB; if it is lost (private browsing, cleared site data), the
      // read returns null. Fall back to the SharedPreferences copy written by
      // select_plan.dart so the checkout can still recover.
      Map<String, dynamic>? plan = await storage.readObjectData('selected_plan');
      if (plan == null && kIsWeb) {
        final prefs = await SharedPreferences.getInstance();
        final raw = prefs.getString('selected_plan_json');
        if (raw != null) {
          plan = json.decode(raw) as Map<String, dynamic>?;
        }
      }
      final page = await storage.readData('subscriptionPage');
      final user = ref.read(authProvider).userData;

      final charge = plan?['charge'];
      final originalCharge = charge is num
          ? charge.toDouble()
          : double.tryParse(charge?.toString() ?? '') ?? 0.0;

      state = state.copyWith(
        isLoading: false,
        selectedPlan: plan,
        subscriptionPage: page ?? '',
        originalCharge: originalCharge,
        grandTotal: originalCharge,
        token: user?['token'] ?? '',
        planType: plan?['type'] == "annual" ? "yr" : "mo",
      );

      _analytics.logCheckoutBegin(
        plan?['title'] as String? ?? '',
        plan?['type'] as String? ?? '',
        originalCharge,
      );

      await storage.writeData('isCheckout', 'true');
      AppCache().setIsCheckout('true');

      // M-12: register listener BEFORE connecting so no paymentStatus events
      // are dropped during the connection handshake window.
      _setupSocket();

      await _socket.initSocket(
        app_urls.socketUrl,
        state.token,
        user?['id'] ?? 0,
      );
    } catch (e) {
      printLog('initCheckout error', e);
      if (!_disposed) state = state.copyWith(isLoading: false);
    }
  }

  // ✅ SOCKET LISTENER (duplicate safe)
  void _setupSocket() {
    if (_paymentSub != null) return;

    printLog("SOCKET", "Listening paymentStatus");

    // S-01: Handle socket errors/disconnects during payment flow
    _socketErrorSub ??=
        _socket.onEvent('socketError').listen((_) {
      if (_disposed || !_paymentInitiated || _paymentHandled) return;
      printLog("SOCKET", "Error during payment — polling immediately");
      CommonService.animatedToast(
          'Connection error. Verifying payment...', 'warning');
      _pollPaymentStatusDirectly();
    });

    _socketDisconnectSub ??=
        _socket.onEvent('socketDisconnect').listen((_) {
      if (_disposed || !_paymentInitiated || _paymentHandled) return;
      printLog("SOCKET", "Disconnected during payment — polling immediately");
      _pollPaymentStatusDirectly();
    });

    _paymentSub =
        _socket.onEvent('paymentStatus').listen((newMessage) async {
      if (newMessage == null || _disposed || _paymentHandled) return;

      if (newMessage['paymentStatus'] == 'success' &&
          newMessage['token'] == state.token) {
        _paymentHandled = true;
        _paymentTimeout?.cancel();
        _paymentTimeout = null;
        _cancelProgressTimers();
        CheckOutImp().closeWebWindow();
        AppCache().setQueryParms(newMessage);
        bool ok = false;
        try {
          ok = await verifyPayment();
        } catch (_) {
          if (_disposed) return;
          _clearPromo();
          state = state.copyWith(isLoading: false);
          CommonService.animatedToast('Please try again.', 'error');
          return;
        }
        if (_disposed) return;

        if (ok) {
          _analytics.logPaymentSuccess(
            state.selectedPlan?['title'] as String? ?? '',
            state.selectedPlan?['type'] as String? ?? '',
            state.grandTotal,
            state.isPromoApplied ? state.promoCode : null,
          );
          await storage.writeData('isAuthenticated', 'true');
          await storage.writeData('signupInProgress', 'false');
          AppCache().setSignupInProgress('false');
          await _clearIsCheckout();
          state = state.copyWith(isLoading: false);
          final ctx = NavigationService.navigatorKey.currentContext;
          if (ctx != null) {
            await LoginPostProcessor.goToAddPassKeyIfNeeded(
              pageKey: 'paymentSuccess',
              fallback: () async {
                ctx.go(AppRoutes.paymentSuccess, extra: {'webauthn': false});
              },
            );
          }
        } else {
          _clearPromo();
          state = state.copyWith(isLoading: false);
          CommonService.animatedToast('Please try again.', 'error');
        }
      } else {
        _analytics.logPaymentFailed(
          state.selectedPlan?['title'] as String? ?? '',
          'payment_status_not_success',
        );
        _clearPromo();
        state = state.copyWith(isLoading: false);
        CommonService.animatedToast(
            'Something went wrong please try again.', 'error');
      }
    });
  }

  // ✅ APPLY PROMO
  Future<void> applyPromo(String promoCode) async {
    promoCode = promoCode.trim();
    if (promoCode.isEmpty) {
      CommonService.animatedToast('Enter Promo Code', 'error');
      return;
    }
    if (!RegExp(r'^[A-Z0-9\-]{3,30}$', caseSensitive: false).hasMatch(promoCode)) {
      CommonService.animatedToast('Invalid promo code format', 'error');
      return;
    }

    state = state.copyWith(isLoading: true);

    try {
      final resp = await api.post('plan/check-promo',
          {"planId": state.selectedPlan!['id'], "promo": promoCode});

      if (!resp['success']) {
        _analytics.logPromoCodeFailed(promoCode, resp['message'] ?? 'invalid');
        state = state.copyWith(isLoading: false);
        CommonService.animatedToast(resp['message'], 'error');
        return;
      }

      final type = resp['data']['discountType'];
      final dis = (resp['data']['discount'] as num).toDouble();

      // L-15: Round discount to 2 decimals (consistent with subscription_notifier)
      double discount = type == "flat" ? dis : (state.originalCharge * dis) / 100;
      discount = double.parse(discount.toStringAsFixed(2));

      final total = double.parse(
          (state.originalCharge - discount).clamp(0.0, double.infinity).toStringAsFixed(2));

      state = state.copyWith(
        isLoading: false,
        isPromoApplied: true,
        promoCode: promoCode,
        discount: discount,
        discountType: type,
        grandTotal: total,
      );

      _analytics.logPromoCodeApplied(promoCode, type as String, discount);
      CommonService.animatedToast('Promo code applied', 'success');
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  void removePromo() {
    _analytics.logPromoCodeRemoved();
    _clearPromo();
  }

  void _clearPromo() {
    state = state.copyWith(
      isPromoApplied: false,
      promoCode: '',
      discount: 0,
      grandTotal: state.originalCharge,
    );
  }

  /// Clears isCheckout from all storage layers after payment is fully resolved.
  Future<void> _clearIsCheckout() async {
    await storage.writeData('isCheckout', 'false');
    AppCache().setIsCheckout('false');
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('isCheckout');
      await prefs.remove('selected_plan_json');
    }
  }

  // ✅ MAKE PAYMENT
  Future<void> makePayment() async {
    _paymentInitiated = true;
    _analytics.logPaymentStart(
      state.selectedPlan?['title'] as String? ?? '',
      state.grandTotal,
      state.isPromoApplied,
    );
    state = state.copyWith(isLoading: true);

    try {
      Map<String, dynamic> data = {"planId": state.selectedPlan!['id']};

      if (state.isPromoApplied) {
        data["promo"] = state.promoCode;
      }

      Map<String, dynamic> resp = await api.post('plan/select-plan', data);

      if (!resp['success']) {
        _clearPromo();
        state = state.copyWith(isLoading: false);
        CommonService.animatedToast(resp['message'], 'error');
        return;
      }

      if (state.selectedPlan!['charge'] > 0) {
        final url = resp['data']['url'] as String?;
        if (!isValidStripeUrl(url)) {
          state = state.copyWith(isLoading: false);
          CommonService.animatedToast('Something went wrong', 'error');
          printLog(_stripeRedirectTag, 'Rejected invalid URL: $url');
          return;
        }

        // ✅ listener already attached before this
        printLog(_stripeRedirectTag, 'Attempting to launch URL');
        printLog(_stripeRedirectTag,
            'Using navigateToUrl (same tab) as requested');

        // Persist critical state before page unloads
        await storage.writeData('subscriptionPage', state.subscriptionPage);
        AppCache().setSubscriptionPage(state.subscriptionPage);
        await storage.writeData('isCheckout', 'true');
        AppCache().setIsCheckout('true');

        // WEB FALLBACK: SecureStorage uses sessionStorage on web which is
        // cleared when navigating to a different origin (Stripe). Write to
        // SharedPreferences (localStorage) as a backup that survives the
        // cross-origin redirect.
        if (kIsWeb) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('isCheckout', 'true');
          await prefs.setString('subscriptionPage', state.subscriptionPage);
        }

        // Bug 20: Use new-tab checkout so the app stays loaded and the
        // socket-based payment confirmation (line 151-200) works on web.
        // Falls back to same-tab navigation if popup was blocked.
        CheckOutImp().openStripeCheckout(url!);
        _analytics.logPaymentRedirectStripe(
          state.selectedPlan?['title'] as String? ?? '',
        );

        // S-02: Start intermediate progress feedback timers
        _startProgressFeedbackTimers();

        // Start 5-minute fallback — if socket never fires, poll the API once
        _paymentTimeout?.cancel();
        _paymentTimeout = Timer(const Duration(minutes: 5), () async {
          _paymentTimeout = null;
          _cancelProgressTimers();
          if (_disposed || _paymentHandled) return;
          _paymentHandled = true;
          bool ok = false;
          try {
            ok = await verifyPayment();
          } catch (_) {
            if (_disposed) return;
            state = state.copyWith(isLoading: false);
            CommonService.animatedToast('Payment confirmation timed out. Please try again.', 'error');
            return;
          }
          if (_disposed) return;
          final ctx = NavigationService.navigatorKey.currentContext;
          if (ok) {
            await storage.writeData('isAuthenticated', 'true');
            await storage.writeData('signupInProgress', 'false');
            AppCache().setSignupInProgress('false');
            await _clearIsCheckout();
            state = state.copyWith(isLoading: false);
            if (ctx != null) ctx.go(AppRoutes.paymentSuccess);
          } else {
            await _clearIsCheckout();
            state = state.copyWith(isLoading: false);
            CommonService.animatedToast('Payment confirmation timed out. Please try again.', 'error');
            if (ctx != null) ctx.go(AppRoutes.plans);
          }
        });

        state = state.copyWith(isLoading: true);
      } else {
        final ctx = NavigationService.navigatorKey.currentContext;
        if (ctx != null) {
          await LoginPostProcessor.goToAddPassKeyIfNeeded(
            pageKey: 'paymentSuccess',
            fallback: () async {
              ctx.go(AppRoutes.paymentSuccess, extra: {'webauthn': false});
            },
          );
        }
      }
    } catch (error) {
      _clearPromo();
      state = state.copyWith(isLoading: false);

      if (error is! NoInternetException) {
        CommonService.animatedToast('Something went wrong', 'error');
      }
    }
  }

  // S-01: Immediately poll payment status when socket fails
  Future<void> _pollPaymentStatusDirectly() async {
    if (_disposed || _paymentHandled) return;
    _paymentHandled = true;
    _paymentTimeout?.cancel();
    _progressTimer30s?.cancel();
    _progressTimer120s?.cancel();

    bool ok = false;
    try {
      ok = await verifyPayment();
    } catch (_) {
      // Payment not confirmed yet — reset flag so socket/timer can still handle it
      _paymentHandled = false;
      return;
    }
    if (_disposed) return;

    if (ok) {
      _analytics.logPaymentSuccess(
        state.selectedPlan?['title'] as String? ?? '',
        state.selectedPlan?['type'] as String? ?? '',
        state.grandTotal,
        state.isPromoApplied ? state.promoCode : null,
      );
      await storage.writeData('isAuthenticated', 'true');
      await storage.writeData('signupInProgress', 'false');
      AppCache().setSignupInProgress('false');
      await _clearIsCheckout();
      state = state.copyWith(isLoading: false);
      final ctx = NavigationService.navigatorKey.currentContext;
      if (ctx != null) {
        await LoginPostProcessor.goToAddPassKeyIfNeeded(
          pageKey: 'paymentSuccess',
          fallback: () async {
            ctx.go(AppRoutes.paymentSuccess, extra: {'webauthn': false});
          },
        );
      }
    } else {
      // Not confirmed yet — reset so socket/timer can still pick it up
      _paymentHandled = false;
    }
  }

  // S-02: Start intermediate progress feedback timers
  void _startProgressFeedbackTimers() {
    _progressTimer30s?.cancel();
    _progressTimer120s?.cancel();

    _progressTimer30s = Timer(const Duration(seconds: 30), () {
      if (_disposed || _paymentHandled) return;
      CommonService.animatedToast(
          'Still confirming your payment\u2026', 'info');
    });

    _progressTimer120s = Timer(const Duration(seconds: 120), () {
      if (_disposed || _paymentHandled) return;
      CommonService.animatedToast(
          'This is taking longer than expected. We\u2019ll send you an email once confirmed.',
          'info');
    });
  }

  // S-02: Cancel progress feedback timers
  void _cancelProgressTimers() {
    _progressTimer30s?.cancel();
    _progressTimer30s = null;
    _progressTimer120s?.cancel();
    _progressTimer120s = null;
  }

  /// Manually trigger payment verification (e.g. from a "Check Again" button).
  Future<void> manualVerifyPayment() async {
    if (_disposed || _paymentHandled) return;
    await _pollPaymentStatusDirectly();
  }

  // ✅ VERIFY PAYMENT
  Future<bool> verifyPayment() async {
    final profileData = await api.get('user/get-profile');
    if (_disposed) return false;

    // Guard: API may return an error map (e.g. 401) without a 'data' key.
    if (profileData['success'] != true || profileData['data'] == null) {
      return false;
    }

    final profile = MyProfile.fromJson(profileData);
    state = state.copyWith(profile: profile);

    return profile.data.isSubscribed;
  }
}
