import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:optmsg/main.dart' show firebaseReady;

/// Centralised Firebase Analytics wrapper.
///
/// All custom event names are defined as constants to prevent typos and make
/// it easy to search for usages. The class guards every call behind
/// [firebaseReady] and swallows exceptions so callers never need try/catch.
class AnalyticsService {
  AnalyticsService._();
  static final AnalyticsService instance = AnalyticsService._();

  FirebaseAnalytics get _analytics => FirebaseAnalytics.instance;

  // ─── Event name constants ──────────────────────────────────────────────

  // Login flow
  static const loginStart = 'login_start';
  static const loginPasskeyAttempt = 'login_passkey_attempt';
  static const loginPasskeySuccess = 'login_passkey_success';
  static const loginPasskeyFail = 'login_passkey_fail';
  static const loginOtpSent = 'login_otp_sent';
  static const loginOtpVerified = 'login_otp_verified';
  static const loginOtpFailed = 'login_otp_failed';
  static const loginSuccess = 'login_success';
  static const loginFailed = 'login_failed';

  // Passkey enrollment
  static const passkeyEnrollStart = 'passkey_enroll_start';
  static const passkeyEnrollSuccess = 'passkey_enroll_success';
  static const passkeyEnrollSkip = 'passkey_enroll_skip';
  static const passkeyEnrollFail = 'passkey_enroll_fail';

  // Signup flow
  static const signupStart = 'signup_start';
  static const signupUsernameCheck = 'signup_username_check';
  static const signupOtpSent = 'signup_otp_sent';
  static const signupOtpVerified = 'signup_otp_verified';
  static const signupProfileSubmit = 'signup_profile_submit';
  static const signupComplete = 'signup_complete';

  // Subscription / checkout
  static const planView = 'plan_view';
  static const planSelected = 'plan_selected';
  static const freePlanSelected = 'free_plan_selected';
  static const checkoutBegin = 'checkout_begin';
  static const promoCodeApplied = 'promo_code_applied';
  static const promoCodeFailed = 'promo_code_failed';
  static const promoCodeRemoved = 'promo_code_removed';
  static const paymentStart = 'payment_start';
  static const paymentRedirectStripe = 'payment_redirect_stripe';
  static const paymentSuccess = 'payment_success';
  static const paymentFailed = 'payment_failed';
  static const subscriptionCancelled = 'subscription_cancelled';
  static const subscriptionChangeStart = 'subscription_change_start';

  // ─── Core logging ──────────────────────────────────────────────────────

  void logEvent(String name, [Map<String, Object>? params]) {
    if (!firebaseReady) return;
    try {
      _analytics.logEvent(name: name, parameters: params);
    } catch (_) {}
  }

  void setUserProperty(String name, String? value) {
    if (!firebaseReady) return;
    try {
      _analytics.setUserProperty(name: name, value: value);
    } catch (_) {}
  }

  // ─── Login flow helpers ────────────────────────────────────────────────

  void logLoginStart() => logEvent(loginStart);

  void logLoginPasskeyAttempt() => logEvent(loginPasskeyAttempt);

  void logLoginPasskeySuccess() {
    logEvent(loginPasskeySuccess);
    setUserProperty('login_method', 'passkey');
  }

  void logLoginPasskeyFail(String error) =>
      logEvent(loginPasskeyFail, {'error': _truncate(error)});

  void logLoginOtpSent({bool isFallback = false}) =>
      logEvent(loginOtpSent, {'is_fallback': isFallback.toString()});

  void logLoginOtpVerified() => logEvent(loginOtpVerified);

  void logLoginOtpFailed(String error) =>
      logEvent(loginOtpFailed, {'error': _truncate(error)});

  void logLoginSuccess(String method) {
    logEvent(loginSuccess, {'method': method});
    setUserProperty('login_method', method);
  }

  void logLoginFailed(String errorType) =>
      logEvent(loginFailed, {'error_type': errorType});

  // ─── Passkey enrollment helpers ────────────────────────────────────────

  void logPasskeyEnrollStart() => logEvent(passkeyEnrollStart);

  void logPasskeyEnrollSuccess() {
    logEvent(passkeyEnrollSuccess);
    setUserProperty('has_passkey', 'true');
  }

  void logPasskeyEnrollSkip() {
    logEvent(passkeyEnrollSkip);
    setUserProperty('has_passkey', 'false');
  }

  void logPasskeyEnrollFail(String error) =>
      logEvent(passkeyEnrollFail, {'error': _truncate(error)});

  // ─── Signup flow helpers ───────────────────────────────────────────────

  void logSignupStart() {
    logEvent(signupStart);
    setUserProperty('signup_source', kIsWeb ? 'web' : 'mobile');
  }

  void logSignupUsernameCheck(bool available) =>
      logEvent(signupUsernameCheck, {'available': available.toString()});

  void logSignupOtpSent() => logEvent(signupOtpSent);

  void logSignupOtpVerified() => logEvent(signupOtpVerified);

  void logSignupProfileSubmit() => logEvent(signupProfileSubmit);

  void logSignupComplete() => logEvent(signupComplete);

  // ─── Subscription / checkout helpers ───────────────────────────────────

  void logPlanView() => logEvent(planView);

  void logPlanSelected(String planName, String planType, double price) =>
      logEvent(planSelected, {
        'plan_name': planName,
        'plan_type': planType,
        'price': price,
      });

  void logFreePlanSelected(String planName) =>
      logEvent(freePlanSelected, {'plan_name': planName});

  void logCheckoutBegin(String planName, String planType, double price) =>
      logEvent(checkoutBegin, {
        'plan_name': planName,
        'plan_type': planType,
        'price': price,
      });

  void logPromoCodeApplied(
          String promoCode, String discountType, double discountAmount) =>
      logEvent(promoCodeApplied, {
        'promo_code': promoCode,
        'discount_type': discountType,
        'discount_amount': discountAmount,
      });

  void logPromoCodeFailed(String promoCode, String error) =>
      logEvent(promoCodeFailed, {
        'promo_code': promoCode,
        'error': _truncate(error),
      });

  void logPromoCodeRemoved() => logEvent(promoCodeRemoved);

  void logPaymentStart(String planName, double price, bool hasPromo) =>
      logEvent(paymentStart, {
        'plan_name': planName,
        'price': price,
        'has_promo': hasPromo.toString(),
      });

  void logPaymentRedirectStripe(String planName) =>
      logEvent(paymentRedirectStripe, {'plan_name': planName});

  void logPaymentSuccess(
          String planName, String planType, double price, String? promoCode) =>
      logEvent(paymentSuccess, {
        'plan_name': planName,
        'plan_type': planType,
        'price': price,
        if (promoCode != null && promoCode.isNotEmpty) 'promo_code': promoCode,
      });

  void logPaymentFailed(String planName, String error) =>
      logEvent(paymentFailed, {
        'plan_name': planName,
        'error': _truncate(error),
      });

  void logSubscriptionCancelled() => logEvent(subscriptionCancelled);

  void logSubscriptionChangeStart(String fromPlan, String toPlan) =>
      logEvent(subscriptionChangeStart, {
        'from_plan': fromPlan,
        'to_plan': toPlan,
      });

  // ─── Util ──────────────────────────────────────────────────────────────

  /// Firebase Analytics truncates parameter values at 100 chars.
  String _truncate(String value) =>
      value.length > 100 ? value.substring(0, 100) : value;
}
