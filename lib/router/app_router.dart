import 'package:optmsg/common/app_manger/app_cache.dart';
import 'package:optmsg/model/tags_list_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:optmsg/router/app_routes.dart';
import 'package:optmsg/router/responsive_route_wrappers.dart';
import 'package:optmsg/screens/compose/compose_riverpod/compose_state.dart';
import 'package:optmsg/screens/auth/enterOtp/otp_screen.dart';
import 'package:optmsg/screens/auth/enterOtp/enter_otp_profile.dart';
import 'package:optmsg/screens/auth/login/login_screen.dart';
import 'package:optmsg/screens/auth/web/enterOtp/web_enter_otp.dart';
import 'package:optmsg/screens/auth/web/paymentSuccess/payment_success.dart';
import 'package:optmsg/screens/auth/passKey/add_pass_key.dart';
import 'package:optmsg/screens/auth/enterOtp/success_otp.dart';
import 'package:optmsg/screens/auth/userNameSuccess/user_name_success_screen.dart';
import 'package:optmsg/screens/auth/forgotUserName/forgot_user_name.dart';
import 'package:optmsg/widgets/onboarding.dart';
import 'package:optmsg/screens/auth/setupProfile/setup_profile_screen.dart';
import 'package:optmsg/webPackerHandler/mobile_check_out.dart'
    if (dart.library.js_interop) 'package:optmsg/webPackerHandler/web_check_out.dart';
import 'package:optmsg/widgets/shell_layout.dart';
import 'package:optmsg/router/route_extras.dart';
import 'package:optmsg/router/route_page_transitions.dart';
import 'package:optmsg/router/route_observer_service.dart';
import 'package:optmsg/services/storage_service.dart';
import 'package:optmsg/constant/app_config.dart';
import 'package:descope/descope.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:optmsg/screens/auth/auth_riverpod/auth_notifier.dart';
import 'package:optmsg/model/auth/auth_state.dart';

import '../common/utilites/logger.dart';
import '../screens/auth/createAccount/create_account_screen.dart';
import '../screens/subscription/checkout/processing_payment.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();

/// GR-4: Encapsulates mutable redirect state so it resets cleanly when
/// [createRouter] is called (e.g. hot restart, test harness).
class _RedirectState {
  /// Whether we have already routed to ProcessingPaymentScreen for the
  /// current Stripe redirect. Without this, `Uri.base` (which never changes
  /// on web) causes the redirect guard to fire repeatedly.
  bool stripeParamsConsumed = false;

  /// Redirect-loop protection.
  String? lastRedirectTarget;
  int redirectCount = 0;
  DateTime redirectWindowStart = DateTime.now();

  static const int maxRedirectDepth = 5;
  static const int redirectWindowMs = 3000;

  void reset() {
    stripeParamsConsumed = false;
    lastRedirectTarget = null;
    redirectCount = 0;
    redirectWindowStart = DateTime.now();
  }
}

_RedirectState _rs = _RedirectState();

/// GR-5: Const set of public routes for O(1) lookup. Evaluated once, not on
/// every redirect call.
const _publicRoutes = {
  AppRoutes.login,
  AppRoutes.signup,
  AppRoutes.forgotUsername,
  AppRoutes.usernameSuccess,
  AppRoutes.enterOtp,
  AppRoutes.setupProfile,
  AppRoutes.plans,
  AppRoutes.checkout,
  AppRoutes.paymentSuccess,
  AppRoutes.webOtpToken,
  AppRoutes.addPassKey,
  AppRoutes.processingPayment,
  AppRoutes.helpCenter, // GR-15: /help must be accessible without auth
  AppRoutes.faq, // GR-15: /help/faq must be accessible without auth
};

/// Prefixes that are public (e.g. /signup/ sub-pages, /help/ static pages).
const _publicPrefixes = ['/signup/', '/help/'];

/// The refresh listenable created by [createRouter]. Exposed so the owner
/// (e.g. `_MyAppState.dispose()`) can call `dispose()` on it — GoRouter only
/// removes its own listener but never disposes the listenable itself (C-08).
_RiverpodRefreshListenable? routerRefreshListenable;

/// Temporarily suppress GoRouter refresh so auth state changes don't
/// flatten the navigation stack (used during signup → plans transition).
void muteRouterRefresh() => routerRefreshListenable?.mute();
void unmuteRouterRefresh() => routerRefreshListenable?.unmute();

/// Async portion of the GoRouter redirect logic. Separated so that the
/// synchronous Stripe-params check in the main redirect callback can return
/// a plain [String] (not a [Future]), which GoRouter processes immediately
/// — before rendering any widget.
Future<String?> _asyncRedirect(
  GoRouterState goState,
  ProviderContainer container,
  SecureStorageService storage,
  CheckOutImp checkOutImp,
) async {
  try {
    printLog("redirect", goState.uri);

    // P0-A: Track every navigation attempt.
    logScreenView(goState.uri.path);

    final authState = container.read(authProvider);
    final currentPath = goState.matchedLocation;

    // Helper: guard against redirect loops before returning a target.
    String? guardedRedirect(String target) {
      if (target == currentPath) return null;
      final now = DateTime.now();
      if (target == _rs.lastRedirectTarget &&
          now.difference(_rs.redirectWindowStart).inMilliseconds <
              _RedirectState.redirectWindowMs) {
        _rs.redirectCount++;
        if (_rs.redirectCount >= _RedirectState.maxRedirectDepth) {
          printLog(
            "redirect_loop_break",
            "Breaking loop after ${_rs.redirectCount} redirects to $target within ${_RedirectState.redirectWindowMs}ms",
          );
          _rs.lastRedirectTarget = null;
          _rs.redirectCount = 0;
          return null;
        }
      } else {
        _rs.lastRedirectTarget = target;
        _rs.redirectCount = 1;
        _rs.redirectWindowStart = now;
      }
      return target;
    }

    final isAuthenticated = authState.isAuthenticated;
    final isInitialized = authState.isInitialized;

    /// Prevent redirect before auth restore (fix login flicker on refresh)
    if (!isInitialized) return null;

    /// GR-5: Use top-level const set + prefix list for O(1) lookup.
    final isPublicRoute =
        _publicRoutes.contains(currentPath) ||
        _publicPrefixes.any((p) => currentPath.startsWith(p));

    // GR-2: Read from in-memory cache instead of secure storage.
    // M-08: Removed SharedPreferences fallback — AppCache is primed at startup
    // via loadRedirectCache(), so the in-memory value is always current.
    final isCheckout = AppCache().isCheckout;

    /// =========================================================
    /// STRIPE WEB REDIRECT HANDLING (async fallback path)
    /// =========================================================
    if (kIsWeb) {
      // Already on the processing screen — let it render and handle
      // the full payment flow (verify, setAuthenticated, navigate).
      if (currentPath == AppRoutes.processingPayment) return null;

      // Deferred Stripe param detection (runs if synchronous check missed)
      if (!_rs.stripeParamsConsumed) {
        final uri = Uri.base;
        final goUri = goState.uri;
        Map<String, String> queryParams = checkOutImp.getQueryParams();

        if (queryParams.isEmpty) {
          queryParams = uri.queryParameters;
        }
        if (queryParams.isEmpty) {
          queryParams = goUri.queryParameters;
        }
        if (queryParams.isEmpty) {
          final cached = await AppCache().getQueryParms();
          if (cached != null) {
            queryParams = cached.map((k, v) => MapEntry(k, v.toString()));
          }
        }

        printLog(
          '_guardRoute STRIPE REDIRECT CHECK',
          'isCheckout: $isCheckout | finalParams: $queryParams | path: $currentPath',
        );

        final isSuccess =
            queryParams['success'] == 'true' ||
            queryParams['paymentStatus'] == 'success';
        final isFailure =
            queryParams['success'] == 'false' ||
            queryParams['paymentStatus'] == 'failed';

        if (isSuccess || isFailure) {
          _rs.stripeParamsConsumed = true;
          AppCache().setQueryParms({});
          final queryString = queryParams.entries
              .map(
                (e) =>
                    '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}',
              )
              .join('&');
          return '${AppRoutes.processingPayment}?$queryString';
        }

        // Safari/ITP recovery — only trigger on the home/login route
        // (initial page load after cross-origin Stripe redirect), never when
        // the user is already on a post-payment page like /payment-success.
        if (isCheckout == 'true' &&
            (currentPath == AppRoutes.home || currentPath == AppRoutes.login)) {
          printLog(
            '_guardRoute STRIPE RECOVERY',
            'No URL params but isCheckout=true. Forcing Processing Payment recovery.',
          );
          _rs.stripeParamsConsumed = true;
          // H-02: Do NOT assume success — ProcessingPaymentScreen will verify
          // with the backend to determine actual payment status.
          return '${AppRoutes.processingPayment}?recovered=true';
        }

        // R-01: Mark the Stripe/ITP check as consumed for this session even
        // when nothing fires. _rs resets on every createRouter call (fresh page
        // load), so this only suppresses re-checks during in-session backward
        // navigation (e.g. user presses browser back through '/' or '/login'
        // after visiting /checkout). Without this, the ITP recovery fires on
        // any backward navigation that lands on '/' or '/login' while
        // isCheckout is still 'true' in AppCache.
        _rs.stripeParamsConsumed = true;
      }
    }

    /// FAST PATH: unauthenticated user on a protected route → login
    if (!isAuthenticated && !isPublicRoute) {
      return AppRoutes.login;
    }

    final subscriptionPage = AppCache().subscriptionPage;

    /// =========================================================
    /// HOME ROUTE GUARD
    /// =========================================================
    if (currentPath == AppRoutes.home) {
      if (kIsWeb) {
        final browserPath = Uri.base.path;
        final browserQuery = Uri.base.query;

        final fullBrowserPath = browserQuery.isNotEmpty
            ? '$browserPath?$browserQuery'
            : browserPath;

        if (browserPath.isNotEmpty && browserPath != '/') {
          // GR-17: Use exact match for public routes (consistent with line 147),
          // only use startsWith for prefix patterns like /signup/.
          final isBrowserPathPublic =
              _publicRoutes.contains(browserPath) ||
              _publicPrefixes.any((p) => browserPath.startsWith(p));

          if (fullBrowserPath != currentPath &&
              (isBrowserPathPublic || isAuthenticated)) {
            return fullBrowserPath;
          }
        }
      }

      if (isAuthenticated) {
        final pendingMailto = AppCache().mailto;
        if (pendingMailto != null && pendingMailto.isNotEmpty) {
          AppCache().setMailto(null);
          // Fire-and-forget: clear from persistent storage too.
          storage.deleteData('mailto');
          return AppRoutes.composeWithTo(pendingMailto);
        }
        // R-02: During signup, route to /plans instead of /inbox so that an
        // authenticated user who refreshes at '/' mid-signup (before selecting
        // a plan) lands on the correct step rather than /inbox, which would
        // show errors due to the missing subscription.
        if (AppCache().signupInProgress == 'true') {
          return AppRoutes.plans;
        }
        return AppRoutes.inbox;
      }

      return AppRoutes.login;
    }

    /// =========================================================
    /// SETUP-PROFILE ACCESS GUARD
    /// =========================================================
    if (currentPath == AppRoutes.setupProfile) {
      final signupInProgress = AppCache().signupInProgress;

      // G-01: Truly unauthenticated with no active signup → /signup.
      //       Exception: signupInProgress='true' means the user just completed
      //       OTP (Descope session established, but Riverpod auth state is still
      //       'authenticating', not yet 'authenticated'). Allow through.
      if (!isAuthenticated && signupInProgress != 'true') {
        return guardedRedirect(AppRoutes.signup);
      }
      // G-02: Already submitted setup-profile — prevent back-navigation.
      //       First name/last name/DOB are already saved to the Descope user.
      if (subscriptionPage == 'selectPlan') {
        return guardedRedirect(AppRoutes.plans);
      }
      // G-03: Authenticated non-signup user who somehow reached /setup-profile.
      if (isAuthenticated && signupInProgress != 'true') {
        return guardedRedirect(AppRoutes.inbox);
      }
      // Allow:
      //  • isAuthenticated + signupInProgress='true' → first-time form fill ✓
      //  • !isAuthenticated + signupInProgress='true' → just completed OTP ✓
    }

    /// =========================================================
    /// PREVENT BACK NAVIGATION TO AUTH SCREENS
    /// =========================================================
    if (isAuthenticated) {
      final signupInProgress = AppCache().signupInProgress;

      final authRoutes = [
        AppRoutes.login,
        AppRoutes.signup,
        AppRoutes.enterOtp,
        AppRoutes.webOtpToken,
      ];

      final signupExemptRoutes = [AppRoutes.enterOtpProfile];

      if (authRoutes.any(
        (route) =>
            currentPath.startsWith(route) &&
            !signupExemptRoutes.contains(currentPath),
      )) {
        // GR-16: Read from in-memory cache instead of awaiting SharedPreferences.
        final isPasskeyPageOpen = AppCache().isPasskeyPageOpen;
        // G-04: Mid-signup but setup-profile not yet submitted. Route to
        //       /setup-profile so the user completes their profile, not to
        //       inbox/passkey (which would fail without a subscription).
        if (signupInProgress == 'true' && subscriptionPage != 'selectPlan') {
          return guardedRedirect(AppRoutes.setupProfile);
        }
        if (subscriptionPage == 'selectPlan') {
          return guardedRedirect(AppRoutes.plans);
        }
        if (isPasskeyPageOpen) return guardedRedirect(AppRoutes.inbox);

        final hasEnrolledPasskey =
            authState.userData?['user']?['webauthn'] == true ||
            AppCache().hasPasskeyEnrolled;
        if (hasEnrolledPasskey) return guardedRedirect(AppRoutes.inbox);

        bool passkeySupported = false;
        try {
          passkeySupported = await Descope.passkey.isSupported();
        } catch (_) {}

        if (passkeySupported) {
          return guardedRedirect(AppRoutes.addPassKey);
        }

        // Check onboarding status before defaulting to inbox
        final hasCompletedOnboarding = AppCache().hasCompletedOnboarding;
        if (!hasCompletedOnboarding && !kIsWeb) {
          // userData is already in AuthState — no storage read needed.
          final boardingStatus =
              authState.userData?['user']?['boardingSteps'] ?? 'notification';
          if (boardingStatus != 'notification') {
            return guardedRedirect(AppRoutes.onboarding);
          }
        }
        return guardedRedirect(AppRoutes.inbox);
      }
    }

    // No redirect needed — reset loop counter.
    _rs.lastRedirectTarget = null;
    _rs.redirectCount = 0;
    return null;
  } catch (e) {
    printLog("router_redirect_error", e);
    return null;
  }
}

/// H-10: Error scaffold shown when a route builder throws an unexpected
/// exception. Provides a safe fallback rather than crashing to Flutter's
/// unhandled-error boundary.
class _RouteErrorScaffold extends StatelessWidget {
  const _RouteErrorScaffold();

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 12),
          const Text('Something went wrong loading this page.'),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => GoRouter.of(context).go('/'),
            child: const Text('Go Back'),
          ),
        ],
      ),
    ),
  );
}

/// H-10: Wraps a GoRoute builder in a try-catch so that widget-instantiation
/// errors don't propagate uncaught to Flutter's error boundary.
Widget Function(BuildContext, GoRouterState) safeRouteBuilder(
  Widget Function(BuildContext, GoRouterState) builder,
) => (context, state) {
  try {
    return builder(context, state);
  } catch (e, st) {
    printLog('route_builder_error', '$e\n$st');
    return const _RouteErrorScaffold();
  }
};

/// Generates a GoRoute for each folder's email detail view.
/// Route pattern: /{folder}/email?id=X  (query param keeps GA page paths stable)
/// The emailType is derived from the folder segment of the path.
List<GoRoute> _emailDetailRoutes() {
  const folders = {
    'inbox': 'Inbox',
    'archive': 'Archive',
    'sent': 'Sent',
    'drafts': 'Drafts',
    'trash': 'Trash',
    'spam': 'Spam',
  };
  return folders.entries.map((entry) {
    return GoRoute(
      path: '/${entry.key}/email',
      pageBuilder: pushPageBuilder(
        safeRouteBuilder((context, goState) {
          final id = int.tryParse(goState.uri.queryParameters['id'] ?? '') ?? 0;
          final extra = safeExtras(goState.extra);
          return ResponsiveViewEmailWrapper(
            emailId: id,
            emailType: extraString(extra, 'emailType', entry.value),
            allTagsList: extraTyped<TagsListModel>(extra, 'allTagsList'),
          );
        }),
      ),
    );
  }).toList();
}

GoRouter createRouter(String initialLocation, ProviderContainer container) {
  // GR-4: Reset mutable redirect state so hot restarts / test harnesses
  // don't inherit stale values from a previous router instance.
  _rs.reset();

  final storage = SecureStorageService();
  final checkOutImp = CheckOutImp();
  printLog("createRouter", initialLocation);
  routerRefreshListenable = _RiverpodRefreshListenable(container, authProvider);
  final router = GoRouter(
    initialLocation: initialLocation,
    navigatorKey: rootNavigatorKey,
    refreshListenable: routerRefreshListenable,
    redirect: (context, goState) {
      // ✅ STRIPE WEB REDIRECT — SYNCHRONOUS, runs before any widget renders.
      // The redirect function must NOT be async for this check because async
      // functions always return a Future, and GoRouter renders the initial
      // route (LoginScreen) while waiting for the Future to resolve.
      if (kIsWeb && !_rs.stripeParamsConsumed) {
        Map<String, String> earlyParams = checkOutImp.getQueryParams();
        if (earlyParams.isEmpty) {
          earlyParams = Uri.base.queryParameters;
        }
        final hasStripeParams =
            earlyParams['success'] != null ||
            earlyParams['paymentStatus'] != null;
        if (hasStripeParams) {
          _rs.stripeParamsConsumed = true;
          final queryString = earlyParams.entries
              .map(
                (e) =>
                    '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}',
              )
              .join('&');
          printLog('STRIPE_SYNC', 'Routing to /processing-payment');
          return '${AppRoutes.processingPayment}?$queryString';
        }
      }

      // All other redirect logic is async — delegate to helper.
      return _asyncRedirect(goState, container, storage, checkOutImp);
    },
    errorBuilder: (context, state) {
      // GR-1: Redirect unknown routes instead of showing GoRouter's default
      // error page (plain white screen with red text).
      // BS-1: Previously returned a blank Scaffold and did a single
      // post-frame callback that silently failed if context was null,
      // leaving the user on a blank screen permanently. Now retries
      // up to 3 times and shows a spinner + fallback button.
      final authState = container.read(authProvider);
      final target = authState.isAuthenticated
          ? AppRoutes.inbox
          : AppRoutes.login;
      void tryRedirect([int attempt = 0]) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (rootNavigatorKey.currentContext != null) {
            GoRouter.of(rootNavigatorKey.currentContext!).go(target);
          } else if (attempt < 3) {
            // Context not ready — retry after a brief delay.
            Future.delayed(
              const Duration(milliseconds: 100),
              () => tryRedirect(attempt + 1),
            );
          }
        });
      }

      tryRedirect();
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  if (rootNavigatorKey.currentContext != null) {
                    GoRouter.of(
                      rootNavigatorKey.currentContext!,
                    ).go(AppRoutes.login);
                  }
                },
                child: const Text('Go to Login'),
              ),
            ],
          ),
        ),
      );
    },
    routes: [
      // '/' is handled entirely by the global redirect above (auth init guard,
      // web deep-link recovery, passkey flow). The builder here is a safety
      // fallback that renders only during the brief !isInitialized window; the
      // refreshListenable will immediately re-run the redirect once auth restores.
      // BS-5: Show a spinner instead of a blank scaffold so the user has
      // visual feedback during slow auth initialization (CS-1, CS-2).
      GoRoute(
        path: '/',
        builder: (_, _) =>
            const Scaffold(body: Center(child: CircularProgressIndicator())),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, goState) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.signup,
        builder: (context, goState) => const CreateAccountScreen(),
      ),
      GoRoute(
        path: AppRoutes.forgotUsername,
        builder: (context, goState) => const ForgotUserName(),
      ),
      GoRoute(
        path: AppRoutes.enterOtp,
        builder: safeRouteBuilder((context, goState) {
          final extra = safeExtras(goState.extra);
          return OtpScreen(
            userName: extraString(extra, 'userName'),
            pageKey: extraString(extra, 'pageKey', 'login'),
            webAuthn: extraBool(extra, 'webAuthn'),
            loginId: extraString(extra, 'loginId'),
          );
        }),
      ),
      GoRoute(
        path: AppRoutes.setupProfile,
        builder: safeRouteBuilder((context, goState) {
          final extra = safeExtras(goState.extra);
          return SetupProfileScreen(userName: extraString(extra, 'userName'));
        }),
      ),
      GoRoute(
        path: AppRoutes.addPassKey,
        builder: safeRouteBuilder((context, goState) {
          final extra = safeExtras(goState.extra);
          return AddPassKey(pageKey: extraString(extra, 'pageKey'));
        }),
      ),
      GoRoute(
        path: AppRoutes.successOtp,
        builder: (context, goState) => const SuccessOtp(),
      ),
      GoRoute(
        path: AppRoutes.enterOtpProfile,
        builder: (context, goState) => const EnterOtpProfile(),
      ),
      GoRoute(
        path: AppRoutes.usernameSuccess,
        builder: (context, goState) => const UserNameSuccessScreen(),
      ),
      GoRoute(
        path: AppRoutes.webOtpToken,
        redirect: (context, goState) {
          // GR-3: On page refresh, extra is lost — redirect to login.
          if (goState.extra == null) return AppRoutes.login;
          return null;
        },
        builder: safeRouteBuilder((context, goState) {
          final extra = safeExtras(goState.extra);
          return WebEnterOtp(
            userName: extraString(extra, 'userName'),
            pageKey: extraString(extra, 'pageKey', 'login'),
            loginId: extraString(extra, 'loginId'),
          );
        }),
      ),
      GoRoute(
        path: AppRoutes.checkout,
        builder: safeRouteBuilder((context, goState) {
          final extra = safeExtras(goState.extra);
          return ResponsiveCheckOutWrapper(page: extraString(extra, 'page'));
        }),
      ),
      GoRoute(
        path: AppRoutes.plans,
        builder: (context, goState) => const ResponsivePlansWrapper(),
      ),
      GoRoute(
        path: AppRoutes.paymentSuccess,
        builder: safeRouteBuilder((context, goState) {
          final extra = safeExtras(goState.extra);
          return PaymentSuccess(webauthn: extraBool(extra, 'webauthn'));
        }),
      ),
      GoRoute(
        path: AppRoutes.processingPayment,
        builder: safeRouteBuilder((context, goState) {
          return ProcessingPaymentScreen(
            queryParams: goState.uri.queryParameters,
          );
        }),
      ),
      ShellRoute(
        builder: (context, goState, child) =>
            ShellLayout(state: goState, child: child),
        routes: [
          GoRoute(
            path: AppRoutes.inbox,
            builder: safeRouteBuilder((context, goState) {
              final emailId = int.tryParse(
                goState.uri.queryParameters['email'] ?? '',
              );
              return ResponsiveInboxWrapper(selectedEmailId: emailId);
            }),
          ),
          GoRoute(
            path: AppRoutes.archive,
            builder: safeRouteBuilder((context, goState) {
              final emailId = int.tryParse(
                goState.uri.queryParameters['email'] ?? '',
              );
              return ResponsiveArchiveWrapper(selectedEmailId: emailId);
            }),
          ),
          GoRoute(
            path: AppRoutes.sent,
            builder: safeRouteBuilder((context, goState) {
              final emailId = int.tryParse(
                goState.uri.queryParameters['email'] ?? '',
              );
              return ResponsiveSentWrapper(selectedEmailId: emailId);
            }),
          ),
          GoRoute(
            path: AppRoutes.drafts,
            builder: safeRouteBuilder((context, goState) {
              final emailId = int.tryParse(
                goState.uri.queryParameters['email'] ?? '',
              );
              return ResponsiveDraftWrapper(selectedEmailId: emailId);
            }),
          ),
          GoRoute(
            path: AppRoutes.trash,
            builder: safeRouteBuilder((context, goState) {
              final emailId = int.tryParse(
                goState.uri.queryParameters['email'] ?? '',
              );
              return ResponsiveTrashWrapper(selectedEmailId: emailId);
            }),
          ),
          GoRoute(
            path: AppRoutes.contacts,
            builder: (context, goState) => const ResponsiveContactsWrapper(),
          ),
          GoRoute(
            path: AppRoutes.settings,
            builder: (context, goState) => const ResponsiveSettingsWrapper(),
            routes: [
              GoRoute(
                path: 'profile', // Matches /settings/profile
                builder: (context, state) => const ResponsiveProfileWrapper(),
              ),
              GoRoute(
                path: 'account', // Matches /settings/account
                builder: (context, state) => const ResponsiveAccountWrapper(),
                routes: [
                  GoRoute(
                    path: 'subscription',
                    builder: safeRouteBuilder((context, state) {
                      final extra = safeExtras(state.extra);
                      return ResponsiveSubscriptionWrapper(
                        listData:
                            extraTyped<Map<String, dynamic>>(
                              extra,
                              'listData',
                            ) ??
                            {},
                      );
                    }),
                    routes: [
                      GoRoute(
                        path: 'change_payment',
                        builder: (context, state) =>
                            const ResponsivePaymentMethodWrapper(),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: AppRoutes.notifications,
            pageBuilder: (context, goState) =>
                const NoTransitionPage(child: ResponsiveNotificationWrapper()),
          ),
          GoRoute(
            path: AppRoutes.tags,
            redirect: (context, goState) {
              final hasExtras = goState.extra != null;
              final hasQueryId = goState.uri.queryParameters['id'] != null;
              if (!hasExtras && !hasQueryId) return AppRoutes.inbox;
              return null;
            },
            builder: safeRouteBuilder((context, goState) {
              final extra = goState.extra != null
                  ? safeExtras(goState.extra)
                  : <String, dynamic>{};
              final queryId = goState.uri.queryParameters['id'];
              final tagId =
                  extra['data']?['tagId'] ?? int.tryParse(queryId ?? '');
              final tagName = extra['data']?['tagName'] ?? '';
              return ResponsiveTagsWrapper(
                key: ValueKey('tags-$tagId'),
                tagId: tagId,
                tagName: tagName is String ? tagName : '',
                tagsList: extra['tagsList'],
              );
            }),
          ),
          GoRoute(
            path: AppRoutes.helpCenter,
            builder: (context, goState) => const ResponsiveHelpCenterWrapper(),
          ),
          // Backwards compat: /email?id=X redirects to /inbox/email?id=X
          GoRoute(
            path: '/email',
            redirect: (context, goState) {
              final id = goState.uri.queryParameters['id'] ?? '0';
              return '/inbox/email?id=$id';
            },
          ),
          // Folder-specific email detail routes
          ..._emailDetailRoutes(),
          GoRoute(
            path: AppRoutes.spam,
            builder: (context, goState) => const ResponsiveSpamWrapper(),
          ),
          GoRoute(
            path: AppRoutes.viewContactriverpod,
            // GR-3: extras don't survive web refresh — redirect to contacts list.
            redirect: (context, goState) =>
                goState.extra == null ? AppRoutes.contacts : null,
            pageBuilder: pushPageBuilder(
              safeRouteBuilder((context, goState) {
                final extra = safeExtras(goState.extra);
                return ResponsiveViewContactriverpodWrapper(
                  contact: extra['contact'],
                  page: extra['page'],
                  onContactUpdated: extra['onContactUpdated'],
                  hideAppBar: extraBool(extra, 'hideAppBar'),
                );
              }),
            ),
          ),
          GoRoute(
            path: AppRoutes.editContactriverpod,
            redirect: (context, goState) =>
                goState.extra == null ? AppRoutes.contacts : null,
            pageBuilder: pushPageBuilder(
              safeRouteBuilder((context, goState) {
                final extra = safeExtras(goState.extra);
                return ResponsiveEditContactriverpodWrapper(
                  contact: extra['contact'],
                  contactData: extra['contactData'] ?? [],
                  isReadingPaneMode: extraBool(extra, 'isReadingPaneMode'),
                );
              }),
            ),
          ),
          // GR-12: Removed duplicate /contacts/add route — only /contacts/add-contact is used.
          GoRoute(
            path: AppRoutes.addContactriverpod,
            pageBuilder: pushPageBuilder(
              (context, goState) => const ResponsiveAddContactWrapper(),
            ),
          ),
          GoRoute(
            path: AppRoutes.addExistingContact,
            redirect: (context, goState) =>
                goState.extra == null ? AppRoutes.contacts : null,
            pageBuilder: pushPageBuilder(
              safeRouteBuilder((context, goState) {
                final extra = safeExtras(goState.extra);
                return ResponsiveAddExistingContactWrapper(
                  prevEmail: extra['prevEmail'],
                  type: extra['type'],
                  multipleEmails: extra['multipleEmails'],
                );
              }),
            ),
          ),
          GoRoute(
            path: AppRoutes.changeSubscription,
            pageBuilder: pushPageBuilder(
              (context, goState) => const ResponsiveChangeSubscriptionWrapper(),
            ),
          ),
          GoRoute(
            path: AppRoutes.faq,
            builder: (context, goState) => const ResponsiveFaqWrapper(),
          ),
          GoRoute(
            path: AppRoutes.compose,
            pageBuilder: pushPageBuilder(
              safeRouteBuilder((context, goState) {
                final extra = safeExtras(goState.extra);
                final uri = goState.uri;
                final to = uri.queryParameters['to'];

                // Feature flag: native Flutter compose
                if (useNativeCompose) {
                  return ResponsiveComposeWrapper(
                    params: ComposeParams(
                      mode: ComposeMode.fromString(
                        extra['type'] as String? ?? 'compose',
                      ),
                      emailId: extra['emailId'] as int?,
                      toEmail: to ?? extra['email'] as String?,
                      sourcePage: extra['sourcePage'] as String?,
                    ),
                  );
                }

                // Legacy WebView compose
                var url = extra['url'] as String?;
                if (url == null && to != null) {
                  final pageId = DateTime.now().microsecondsSinceEpoch;
                  final offsetInMinutes =
                      DateTime.now().timeZoneOffset.inMinutes;
                  url =
                      '${defaultBaseUrl}email/compose?pageId=$pageId&toEmail=$to&timeZone=$offsetInMinutes';
                }

                return ResponsiveWebComposeWrapper(
                  type: extra['type'] as String? ?? 'compose',
                  url: url,
                  token: extra['token'] as String?,
                  pageId: extra['pageId'],
                  emailId: extra['emailId'] as int?,
                  email: to ?? extra['email'],
                  sourcePage: extra['sourcePage'],
                );
              }),
            ),
          ),
          GoRoute(
            path: AppRoutes.reply,
            // GR-3c: extras don't survive web refresh — redirect to inbox.
            redirect: (context, goState) =>
                goState.extra == null ? AppRoutes.inbox : null,
            pageBuilder: pushPageBuilder(
              safeRouteBuilder((context, goState) {
                final extra = safeExtras(goState.extra);
                final id = int.tryParse(goState.pathParameters['id'] ?? '');

                if (useNativeCompose) {
                  return ResponsiveComposeWrapper(
                    params: ComposeParams(
                      mode: ComposeMode.reply,
                      emailId: id,
                      sourcePage: extra['sourcePage'] as String?,
                    ),
                  );
                }

                return ResponsiveWebComposeWrapper(
                  type: 'reply',
                  url: extra['url'],
                  token: extra['token'] as String?,
                  pageId: extra['pageId'],
                  emailId: id,
                  sourcePage: extra['sourcePage'],
                );
              }),
            ),
          ),
          GoRoute(
            path: AppRoutes.forward,
            // GR-3c: extras don't survive web refresh — redirect to inbox.
            redirect: (context, goState) =>
                goState.extra == null ? AppRoutes.inbox : null,
            pageBuilder: pushPageBuilder(
              safeRouteBuilder((context, goState) {
                final extra = safeExtras(goState.extra);
                final id = int.tryParse(goState.pathParameters['id'] ?? '');

                if (useNativeCompose) {
                  return ResponsiveComposeWrapper(
                    params: ComposeParams(
                      mode: ComposeMode.forward,
                      emailId: id,
                      sourcePage: extra['sourcePage'] as String?,
                    ),
                  );
                }

                return ResponsiveWebComposeWrapper(
                  type: 'forward',
                  url: extra['url'],
                  token: extra['token'] as String?,
                  pageId: extra['pageId'],
                  emailId: id,
                  sourcePage: extra['sourcePage'],
                );
              }),
            ),
          ),
          // GR-6: Explicit routes for static pages instead of a catch-all
          // `/:module/:slug` that could swallow valid routes added later.
          GoRoute(
            path: AppRoutes.helpStaticPage,
            builder: safeRouteBuilder((context, goState) {
              final slug = goState.pathParameters['slug'] ?? '';
              return ResponsiveStaticPagesWrapper(pageKey: slug);
            }),
          ),
        ],
      ),
      // Signup static pages (privacy policy, terms) are OUTSIDE ShellRoute
      // because the user is not logged in during signup — no sidebar/drawer needed.
      GoRoute(
        path: AppRoutes.signupStaticPage,
        builder: safeRouteBuilder((context, goState) {
          final slug = goState.pathParameters['slug'] ?? '';
          return ResponsiveStaticPagesWrapper(
            pageKey: slug,
            isSignupFlow: true,
          );
        }),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: safeRouteBuilder((context, goState) {
          final extra = safeExtras(goState.extra);
          return OnboardingScreen(status: extraString(extra, 'status'));
        }),
      ),
    ],
  );
  trackRouteChanges(router);
  return router;
}

class _RiverpodRefreshListenable extends ChangeNotifier {
  // GR-11: Typed parameter instead of dynamic for compile-time safety.
  _RiverpodRefreshListenable(
    ProviderContainer container,
    NotifierProvider<AuthNotifier, AuthState> provider,
  ) {
    _subscription = container.listen(provider, (_, _) {
      if (!_muted) notifyListeners();
    });
  }

  late final ProviderSubscription _subscription;
  bool _muted = false;

  /// Temporarily suppress GoRouter refresh notifications.
  /// Used during signup flow to prevent the auth state change from
  /// flattening the navigation stack before onSuccess() navigates.
  void mute() => _muted = true;
  void unmute() => _muted = false;

  @override
  void dispose() {
    _subscription.close();
    super.dispose();
  }
}
