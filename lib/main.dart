import 'dart:async';
import 'dart:io';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:optmsg/common/utilites/logger.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/foundation.dart'
    show PlatformDispatcher, defaultTargetPlatform, kDebugMode, kIsWeb, kReleaseMode;
import 'package:optmsg/constant/app_config.dart';
import 'package:optmsg/constant/string_constant.dart'
    show headingFontFamily, bodyFontFamily;
import 'package:optmsg/firebase_options.dart';
import 'package:optmsg/services/common_service.dart';
import 'package:optmsg/router/app_router.dart';
import 'package:optmsg/router/app_routes.dart';
import 'package:app_links/app_links.dart';
import 'package:descope/descope.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:optmsg/constant/app_colors_extension.dart';
import 'package:optmsg/constant/styles.dart';
import 'package:optmsg/services/biometric_lock_controller.dart';
import 'package:optmsg/services/biometric_service.dart';
import 'package:optmsg/widgets/logo.dart';
import 'package:optmsg/services/session_expiry_manager.dart';
import 'package:optmsg/services/session_refresh_mutex.dart';
import 'package:optmsg/services/storage_service.dart';
import 'package:optmsg/screens/email/inbox_riverpod/inbox_notifier.dart';
import 'package:optmsg/screens/auth/auth_riverpod/auth_notifier.dart'
    show authProvider;
import 'package:optmsg/screens/settings/setting_riverpod/settings_notifier.dart'
    show settingsProvider;
import 'package:optmsg/model/auth/auth_state.dart' show AuthState;
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:optmsg/services/storage/platform_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:media_store_plus/media_store_plus.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:optmsg/services/notification_service.dart';
import 'package:optmsg/services/socket_service.dart';
import 'package:optmsg/webPackerHandler/mobile_check_out.dart'
    if (dart.library.js_interop) 'package:optmsg/webPackerHandler/web_check_out.dart';
import 'common/app_manger/app_cache.dart';
import 'common/app_manger/app_environment.dart';
import 'package:optmsg/common/responsive/responsive.dart';
import 'common/utilites/url_strategy_noop.dart'
    if (dart.library.js_util) 'common/utilites/url_strategy_web.dart';


final CheckOutImp checkOutImp = CheckOutImp(); // Instance for web utilities

late final GoRouter appRouter;

/// Read environment from --dart-define
const String appEnv = String.fromEnvironment('ENV', defaultValue: 'stage');

// Global provider container for services without context
final ProviderContainer providerContainer = ProviderContainer();

/// Whether Firebase was successfully initialized (guarded globally).
bool firebaseReady = false;

void main() async {
  runZonedGuarded(() async {
    WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

    if (!kIsWeb) {
      FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
      if (Platform.isAndroid) {
        await MediaStore.ensureInitialized();
      }
    }
    configureUrl();
    // H-03: Track init success so Crashlytics is only used when Firebase is ready.
    firebaseReady = Firebase.apps.isNotEmpty;
    if (!firebaseReady) {
      try {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
        firebaseReady = true;
      } catch (e) {
        printLog("Firebase initialization error: ", "$e");
      }
    }

    if (firebaseReady) {
      // Register the background message handler BEFORE runApp() so the
      // callback handle is available when Android spawns a background isolate
      // for incoming push notifications. Previously this was called inside
      // MyApp.initState() → notificationIni(), which is too late — background
      // isolates spawned before initState() can't find the handler.
      if (!kIsWeb) {
        FirebaseMessaging.onBackgroundMessage(
            firebaseMessagingBackgroundHandler);
      }
      if (!kIsWeb) {
        await FirebasePerformance.instance
            .setPerformanceCollectionEnabled(kReleaseMode);
        await FirebaseCrashlytics.instance
            .setCrashlyticsCollectionEnabled(kReleaseMode);
        FirebaseCrashlytics.instance.setCustomKey('app_env', appEnv);
      }
      // P1-1: Only collect analytics in release builds to keep dev/debug
      // traffic out of production GA4 reports.
      // P1-2: Attach platform and environment to every event so GA4 reports
      // can be segmented without custom dimensions.
      // CS-3: Fire-and-forget — analytics setup doesn't need to complete
      // before runApp(). Previously awaited with 5s timeouts each, adding
      // up to 10s of blocking on slow Android devices.
      unawaited(Future(() async {
        try {
          await FirebaseAnalytics.instance
              .setAnalyticsCollectionEnabled(kReleaseMode)
              .timeout(const Duration(seconds: 5));
          if (!kIsWeb) {
            await FirebaseAnalytics.instance.setDefaultEventParameters({
              'platform': defaultTargetPlatform.name,
              'app_env': appEnv,
            }).timeout(const Duration(seconds: 5));
          }
        } catch (e) {
          printLog("Firebase Analytics init", "$e");
        }
      }));
    }

    await clearSecureStorageOnReinstall();

    // STAB-01: Replace red error screen with user-friendly message in release.
    if (kReleaseMode) {
      ErrorWidget.builder = (FlutterErrorDetails details) => const Scaffold(
            body: Center(
              child: Text('Something went wrong. Please restart the app.'),
            ),
          );
    }

    if (firebaseReady && kReleaseMode && !kIsWeb) {
      FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
      PlatformDispatcher.instance.onError = (error, stack) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: false);
        return true;
      };
    }

    if (kIsWeb) {
      await AppEnvironment.instance.currentWebEnv(appEnv);
    } else {
      await AppEnvironment.instance.currentEnv();
    }
    // ✅ Initialize Descope before routing so session is ready after Stripe redirect
    if (kDebugMode) {
      debugPrint('[ENV] env=$env, projectId=$projectId, baseUrl=$defaultBaseUrl');
    }
    Descope.setup(projectId);
    await Descope.sessionManager.loadSession();
    // CS-1: Session refresh is handled by AuthNotifier._initialize() (which
    // checks sessionToken.isExpired) and by the pre-request refresh in
    // ApiService/_guardedRefreshIfNeeded(). Refreshing here was redundant and
    // added up to 15s of blocking on cold start when the JWT was expired.
    // loadSession() is sufficient — it puts the session in memory for
    // _initialize() to evaluate.

    // GR-2: Pre-load redirect-critical storage values into memory so the
    // GoRouter redirect callback can read them synchronously (no I/O per nav).
    await AppCache().loadRedirectCache();

    appRouter = createRouter(AppRoutes.home, providerContainer);

    // Initialize device info cache for physical tablet detection
    // This allows accurate detection of native tablets for layout decisions
    GoRouter.optionURLReflectsImperativeAPIs = true;

    // CS-6: Deferred to post-first-frame — device info isn't needed for
    // initial routing or auth init. Was blocking runApp() by 100-200ms.
    unawaited(AppBreakpoints.initializeDeviceInfo());
    if (!kIsWeb) {
      // H-13: Remove splash only after auth initialization completes, not on a
      // fixed timer. A 1-second timer could remove the splash before the router
      // has determined the auth state, causing a white flash on slow devices.
      // NOTE: This MUST be inside runZonedGuarded, after Descope.setup(), so
      // that listening to authProvider (which triggers AuthNotifier._initialize)
      // doesn't race ahead of Descope initialization.
      ProviderSubscription<AuthState>? splashSub;
      splashSub = providerContainer.listen<AuthState>(
        authProvider,
        (_, next) {
          if (next.isInitialized) {
            FlutterNativeSplash.remove();
            splashSub?.close();
          }
        },
        fireImmediately: true,
      );
    }

    runApp(
      UncontrolledProviderScope(
        container: providerContainer,
        child: const MyApp(),
      ),
    );
  }, (error, stack) {
    if (firebaseReady && !kIsWeb) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: false);
    }
  });
}

Future<void> clearSecureStorageOnReinstall() async {
  if (kIsWeb) return; // SecureStorage.deleteAll() not supported on web
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String key = 'hasRunBefore';
  if (prefs.getBool(key) == null || !(prefs.getBool(key) ?? false)) {
    final storage = createPlatformSecureStorage();
    await storage.deleteAll();
    await prefs.setBool(key, true);
  }
}

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    // H-02: Use a single instance so initializeLocalNotifications() and
    // showNotification() share the same plugin state (was creating two).
    final service = PushNotificationService(NavigationService.navigatorKey);
    await service.initializeLocalNotifications();
    await service.showNotification(message);
  } catch (e) {
    if (kDebugMode) {
      printLog("Background message error: ", "$e");
    }
  }
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  /// Global accessor for the biometric lock controller.
  /// Used by ActionBiometricGuard and DraftResponsive to check action state.
  static BiometricLockController? lockController;

  /// Called by settings notifier after writing the biometric preference.
  static void notifyBiometricSettingChanged() {
    if (lockController == null) return;
    // Re-read from storage to get the latest value.
    SecureStorageService().readData('isBiometricEnable').then((val) {
      lockController!.onBiometricSettingChanged(val == 'true');
    });
  }

  /// Whether an action departure (link, print, download) is active.
  /// Used by DraftResponsive to suppress draft refresh during action departures.
  static bool get isActionDepartureActive =>
      lockController?.isActionDepartureActive ?? false;

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> with WidgetsBindingObserver {
  final SecureStorageService secureStorageService = SecureStorageService();
  late AppLinks _appLinks;
  StreamSubscription<Uri>? _sub;

  // ✅ Biometric lock — all state lives in the controller.
  late final BiometricLockController _lockController;

  // 30-second periodic timer that keeps the Descope session JWT fresh while
  // the app is in the foreground. The SDK's own `startTimer()` is still
  // unimplemented (v0.9.18), so we supply the timer ourselves.
  Timer? _sessionRefreshTimer;
  static const _refreshInterval = Duration(seconds: 30);

  static const platform = MethodChannel('com.optmsg/intent');
  static const _privacyChannel = MethodChannel('com.optmsg.mail/privacy');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Initialize biometric lock controller.
    _lockController = BiometricLockController(
      privacyChannel: _privacyChannel,
      biometricService: BiometricService(),
      navigatorKey: NavigationService.navigatorKey,
      performLogout: () async {
        if (!mounted) return;
        await ref.read(authProvider.notifier).logout();
        appRouter.go(AppRoutes.login);
      },
    );
    MyApp.lockController = _lockController;
    notificationIni();
    if (!kIsWeb) {
      _lockController.initialize(
        hasSession: Descope.sessionManager.session != null,
      );
    }
    if (!kIsWeb) {
      _appLinks = AppLinks();
      if (Platform.isAndroid) {
        _retrieveInitialEmail();
        // Optionally, set up a listener for new intents.
        platform.setMethodCallHandler((call) async {
          if (call.method == "newIntent") {
            final String? email = call.arguments;
            if (email != null) {
              _processEmailUri(Uri.parse("mailto:$email"));
            }
          }
        });
      }
      _handleIncomingLinks();

      // if (widget.initialMessage != null) {
      //   WidgetsBinding.instance.addPostFrameCallback((_) {
      //
      //     widget.pushNotificationService.handleNotification(widget.initialMessage!);
      //   });
      // }
    }
    if (kIsWeb) {
      // Web has no FCM push token. Use empty string so the backend can
      // distinguish "no push support" from a real token. A hardcoded value
      // like '1234' would collide across all web users.
      secureStorageService.writeData('deviceToken', '');
    }
    // M-13: kOfficeIpAddresses is always empty — IP lookup always returned '+1'.
    // Removed the dead checkIp() call; write '+1' directly.
    secureStorageService.writeData('countryCode', '+1');
    if (!kIsWeb) {
      monitorInternetConnection();
    }
    printLog("initState", "message");
  }

  // ✅ App lifecycle — delegates biometric logic to controller
  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState appState) async {
    printLog("didChangeAppLifecycleState", appState);
    final isAuth = providerContainer.read(authProvider).isAuthenticated;

    if (appState == AppLifecycleState.inactive) {
      _lockController.onLifecycleInactive(isAuth);
    } else if (appState == AppLifecycleState.hidden) {
      _stopSessionRefreshTimer();
    } else if (appState == AppLifecycleState.paused) {
      _lockController.onLifecyclePaused(isAuth);
      _stopSessionRefreshTimer();
    } else if (appState == AppLifecycleState.resumed) {
      if (Descope.sessionManager.session != null) {
        _startSessionRefreshTimer();
      }
      if (kIsWeb) {
        try {
          await _refreshSessionOnResume();
        } catch (e) {
          debugPrint('[Session] Unexpected error in _refreshSessionOnResume: $e');
        }
        SocketService().reconnectIfNeeded();
      } else {
        // Biometric check FIRST — doesn't need a valid JWT.
        await _lockController.onLifecycleResumed(isAuth);
        // THEN refresh session and reconnect socket.
        try {
          await _refreshSessionOnResume();
        } catch (e) {
          debugPrint('[Session] Unexpected error in _refreshSessionOnResume: $e');
        }
        SocketService().reconnectIfNeeded();
      }
    }
  }

  void _startSessionRefreshTimer() {
    _sessionRefreshTimer?.cancel();
    _sessionRefreshTimer = Timer.periodic(_refreshInterval, (_) async {
      final session = Descope.sessionManager.session;
      if (session == null) return;
      try {
        await SessionRefreshMutex.guardedRefreshIfNeeded();
      } catch (e) {
        debugPrint('[SessionTimer] Refresh failed: $e');
        var currentSession = Descope.sessionManager.session;
        if (currentSession == null) {
          try {
            await Descope.sessionManager.loadSession();
            currentSession = Descope.sessionManager.session;
          } catch (_) {}
          if (currentSession != null && !currentSession.refreshToken.isExpired) {
            return;
          }
        }
        if (currentSession == null || currentSession.refreshToken.isExpired || e is DescopeException) {
          // Don't force-logout while the biometric dialog is active.
          if (_lockController.state.value == BiometricLockState.authenticating) {
            printLog('[SessionTimer] Terminal but biometric in progress — deferring', '');
            return;
          }
          unawaited(SessionExpiryManager.handleExpiry());
        }
      }
    });
  }

  void _stopSessionRefreshTimer() {
    _sessionRefreshTimer?.cancel();
    _sessionRefreshTimer = null;
  }

  Future<void> _refreshSessionOnResume() async {
    final session = Descope.sessionManager.session;
    final biometricActive =
        _lockController.state.value == BiometricLockState.authenticating;
    if (session == null) {
      if (providerContainer.read(authProvider).isAuthenticated) {
        var loadSucceeded = false;
        try {
          await Descope.sessionManager.loadSession();
          loadSucceeded = true;
        } catch (e) {
          debugPrint('[Session] loadSession() threw on resume — '
              'treating as transient storage error, skipping logout ($e)');
        }
        if (!loadSucceeded) return;
        if (Descope.sessionManager.session == null) {
          if (biometricActive) {
            printLog('[Session] No session but biometric active — deferring logout', '');
            return;
          }
          if (SessionRefreshMutex.isLoggedOut) return;
          unawaited(SessionExpiryManager.handleExpiry());
        } else {
          _startSessionRefreshTimer();
        }
      }
      return;
    }
    if (!providerContainer.read(authProvider).isAuthenticated) return;
    try {
      await SessionRefreshMutex.guardedRefreshIfNeeded();
    } catch (e) {
      debugPrint('[Session] Refresh failed on resume: $e');
      final currentSession = Descope.sessionManager.session;
      if ((currentSession != null && currentSession.refreshToken.isExpired) || e is DescopeException) {
        if (biometricActive) {
          printLog('[Session] Terminal session but biometric active — deferring logout', '');
          return;
        }
        if (SessionRefreshMutex.isLoggedOut) return;
        unawaited(SessionExpiryManager.handleExpiry());
      }
    }
  }

  Future<void> notificationIni() async {
    PushNotificationService notificationService = PushNotificationService(
      NavigationService.navigatorKey,
    );
    await notificationService.initialize();
  }

  StreamSubscription<List<ConnectivityResult>>? subscription;
  Timer? _showSnackbarTimer;
  Future<void> monitorInternetConnection() async {
    subscription = Connectivity().onConnectivityChanged.listen((
      List<ConnectivityResult> connectivityResult,
    ) {
      if (connectivityResult.contains(ConnectivityResult.none)) {
        _showSnackbarTimer = Timer(const Duration(seconds: 2), () {
          CommonService.showConnectivityBanner();
        });
      } else {
        _showSnackbarTimer?.cancel();
        CommonService.hideConnectivityBanner();
        // Auto-retry: refresh inbox data after connectivity restores.
        // AN-5: Guard against firing while a session refresh is in flight —
        // the inbox API call would queue behind the mutex and add latency.
        final auth = providerContainer.read(authProvider);
        if (auth.isAuthenticated && !SessionRefreshMutex.isRefreshing) {
          Future.delayed(const Duration(seconds: 1), () {
            if (!SessionRefreshMutex.isRefreshing) {
              providerContainer.read(inboxProvider.notifier).getAllEmails('');
            }
          });
        }
      }
    });
  }

  void _handleIncomingLinks() async {
    Uri? initialUri = await _appLinks.getInitialLink();
    if (initialUri != null && initialUri.scheme == 'mailto') {
      _processEmailUri(initialUri);
    }
    _sub = _appLinks.uriLinkStream.listen((Uri uri) {
      if (uri.scheme == 'mailto') {
        _processEmailUri(uri);
      }
    }, onError: (err) {});
  }

  Future<void> _retrieveInitialEmail() async {
    try {
      final String? email = await platform.invokeMethod('getInitialEmail');
      if (email != null) {
        _processEmailUri(Uri.parse("mailto:$email"));
      }
    } on PlatformException catch (e) {
      if (kDebugMode) {
        printLog("Failed to get initial email: ", "${e.message}");
      }
    }
  }

  Future<void> _processEmailUri(Uri uri) async {
    String email = uri.path;
    if (CommonService.isValidEmail(email)) {
      final authState = providerContainer.read(authProvider);
      if (authState.isAuthenticated) {
        // Already logged in — navigate to compose immediately.
        appRouter.go(AppRoutes.composeWithTo(email));
      } else {
        // Not yet authenticated — store for post-login navigation.
        await secureStorageService.writeData('mailto', email);
        AppCache().setMailto(email);
      }
    }
  }

  /*
  Future<void> handleRedirection(BuildContext context) async {
    Map<String, dynamic>? userData  = await secureStorageService.readObjectData('userProfileData');
    bool isAuthenticated = await secureStorageService.readData('isAuthenticated') == 'true';
    final platform = CommonService().getPlatform();
    final isMobileApp = platform == 'android' || platform == 'ios';

    if (kIsWeb) {
      final currentPath = checkOutImp.getCurrentPath();
      final queryParams = checkOutImp.getQueryParams();
      printLog("handleRedirection", queryParams);
     // final isCheckout = await secureStorageService.readData('isCheckout');
      final prefs = await SharedPreferences.getInstance();
      final isCheckout = prefs.getString('isCheckout');
      if (currentPath == AppRoutes.signup) {
        if (context.mounted) {
          context.go(AppRoutes.signup);
        }
        return;
      }
      if (isCheckout == 'true') {
        if (context.mounted) {
          await checkPaymentStatus(context, queryParams, isCheckout);
        }
        return;
      }
    }

    if (userData != null && isAuthenticated == 'true') {
      await secureStorageService.writeData('isAuthenticated', 'true');
      await socketService.initSocket(
          socketUrl, userData['token'], userData['user']['id']);
      final isBiometricEnabled =
          await secureStorageService.readData('isBiometricEnable');
      final biometricService = BiometricService();

      if (isMobileApp && isBiometricEnabled == 'true') {
        final authenticated = await biometricService.authenticate();
        if (authenticated) {
          String boardingStatus = userData['user']['boardingSteps'];
          // socketService.initSocket(socketUrl, userData['token'], userData['user']['id']);
          if (boardingStatus == 'notification') {
            if (context.mounted) {
              context.go(AppRoutes.inbox);
            }
          } else {
            if (context.mounted) {
              context
                  .go(AppRoutes.onboarding, extra: {'status': boardingStatus});
            }
          }
        } else {
          if (context.mounted) {
            context.go(AppRoutes.login);
          }
        }
      } else {
        // socketService.initSocket(socketUrl, userData['token'], userData['user']['id']);
        if (context.mounted) {
          context.go(AppRoutes.inbox);
        }
      }
    } else {
      await secureStorageService.writeData('isAuthenticated', 'false');
      socketService.disconnect();
      if (context.mounted) {
        context.go(AppRoutes.login);
      }
    }
  }
*/

  /*  Future<void> checkPaymentStatus(
      BuildContext context, Map<String, String> queryParams, isCheckout) async {
    if (!kIsWeb) return;

    if (queryParams.isNotEmpty && queryParams['success'] == 'true') {
      await secureStorageService.writeData('isAuthenticated', 'true');
      await secureStorageService.writeData('isCheckout', 'false');

      // Clear the URL query parameters after processing
      checkOutImp.clearUrlParams();

      String page =
          await secureStorageService.readData('subscriptionPage') ?? '';
      try {
        if (await Descope.passkey.isSupported()) {
          if (page == 'subscription') {
            if (context.mounted) {
              context.go(AppRoutes.paymentSuccess,
                  extra: {'webauthn': userData['user']['webauthn']});
            }
          } else {
            if (context.mounted) {
              context.go(AppRoutes.addPassKey);
            }
          }
        } else {
          if (context.mounted) {
            context.go(AppRoutes.paymentSuccess,
                extra: {'webauthn': userData['user']['webauthn']});
          }
        }
      } catch (e) {
        if (context.mounted) {
          context.go(AppRoutes.paymentSuccess,
              extra: {'webauthn': userData['user']['webauthn']});
        }
      }
    } else if ((queryParams.isEmpty || queryParams['success'] == 'false') &&
        isCheckout == 'true') {
      // Clear the URL query parameters
      checkOutImp.clearUrlParams();
      if (context.mounted) {
        context.go(AppRoutes.plans);
      }
    } else {
      if (context.mounted) {
        context.go(AppRoutes.login);
      }
    }
  }*/

  @override
  Widget build(BuildContext context) {
    // Auth state changes — delegate to biometric lock controller.
    ref.listen(authProvider, (previous, next) {
      if (!kIsWeb) {
        // Auth initialized to unauthenticated — show login page.
        if (next.isInitialized &&
            !(previous?.isInitialized ?? false) &&
            !next.isAuthenticated) {
          _lockController.onUnauthenticated();
        }

        // Fresh login — dismiss overlays, user just proved identity.
        if (next.isAuthenticated &&
            !(previous?.isAuthenticated ?? false)) {
          _lockController.onAuthenticated();
        }
      }
      // Start/stop the background session refresh timer based on auth state.
      if (next.isAuthenticated) {
        _startSessionRefreshTimer();
      } else {
        _stopSessionRefreshTimer();
      }
    });

    return MaterialApp.router(
      title: appInfo['name'],
      theme: _lightTheme,
      darkTheme: _darkTheme,
      themeMode: switch (ref.watch(settingsProvider.select((s) => s.themeModePref))) {
        'dark' => ThemeMode.dark,
        'light' => ThemeMode.light,
        _ => ThemeMode.system,
      },
      routerConfig: appRouter,
      builder: (context, child) {
        // S3.6: Cap text scale at 1.5x to prevent layout overflow while
        // preserving accessibility. Industry standard for email apps.
        // Use TextScaler.linear() instead of .clamp() to avoid assertion
        // failures when Material widgets call .clamp() again downstream.
        final mediaQuery = MediaQuery.of(context);
        final clampedFactor = mediaQuery.textScaler.scale(1.0).clamp(1.0, 1.5);
        final scaledChild = DefaultTextHeightBehavior(
          textHeightBehavior: const TextHeightBehavior(
            leadingDistribution: TextLeadingDistribution.even,
          ),
          child: MediaQuery(
            data: mediaQuery.copyWith(textScaler: TextScaler.linear(clampedFactor)),
            child: child!,
          ),
        );

        // Apply responsive breakpoints to the original widget
        Widget content = ResponsiveBreakpoints.builder(
          child: scaledChild,
          breakpoints: [
            const Breakpoint(start: 0, end: 450, name: MOBILE),
            const Breakpoint(start: 451, end: 800, name: TABLET),
            const Breakpoint(start: 801, end: 1920, name: DESKTOP),
            const Breakpoint(start: 1921, end: double.infinity, name: '4K'),
          ],
        );

        if (!kIsWeb) {
          // Mobile platform-specific SafeArea handling
          content = Platform.isAndroid
              ? SafeArea(
                  top: false,
                  bottom: true,
                  left: false,
                  right: false,
                  child: content,
                )
              : content;

          // ✅ Biometric lock — single overlay driven by controller state
          content = ValueListenableBuilder<BiometricLockState>(
            valueListenable: _lockController.state,
            builder: (ctx, lockState, wrappedChild) {
              switch (lockState) {
                case BiometricLockState.unlocked:
                  return wrappedChild!;
                case BiometricLockState.privacyShield:
                  return Scaffold(
                    backgroundColor: Theme.of(ctx).colorScheme.surface,
                    body: Image.asset(
                      'assets/splash/splash.png',
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  );
                case BiometricLockState.locked:
                case BiometricLockState.authenticating:
                  return Scaffold(
                    backgroundColor: AppStyles.blueBackground,
                    body: SafeArea(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const IgnorePointer(child: LogoWithSlogan()),
                            const SizedBox(height: 36),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).colorScheme.surface,
                                foregroundColor: Theme.of(context).colorScheme.primary,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 28,
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(AppStyles.radiusXXL),
                                ),
                              ),
                              onPressed: _lockController.triggerUnlock,
                              icon: const Icon(Icons.fingerprint, size: 22),
                              label: const Text(
                                'Unlock',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontFamily: headingFontFamily,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
              }
            },
            child: content,
          );
        }

        return content;
      },
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Theme builders
  // ─────────────────────────────────────────────────────────────────────────

  // Aligned with AppTypography tablet-breakpoint values (the middle tier).
  // Widgets should prefer AppTypography.*() for responsive sizing; this
  // TextTheme serves as the Material default fallback.
  static TextTheme _buildTextTheme() => const TextTheme(
        displayLarge: TextStyle(
            fontSize: 36, fontWeight: FontWeight.w800, height: 1.15, letterSpacing: -0.25),
        displayMedium: TextStyle(
            fontSize: 27, fontWeight: FontWeight.w700, height: 1.15, letterSpacing: -0.25),
        displaySmall: TextStyle(
            fontSize: 24, fontWeight: FontWeight.w700, height: 1.15, letterSpacing: -0.25),
        headlineLarge: TextStyle(
            fontSize: 24, fontWeight: FontWeight.w700, height: 1.15, letterSpacing: -0.25),
        headlineMedium:
            TextStyle(fontSize: 18, fontWeight: FontWeight.w700, height: 1.2),
        headlineSmall:
            TextStyle(fontSize: 16, fontWeight: FontWeight.w600, height: 1.2),
        titleLarge:
            TextStyle(fontSize: 16.5, fontWeight: FontWeight.w600, height: 1.2),
        titleMedium:
            TextStyle(fontSize: 15, fontWeight: FontWeight.w600, height: 1.25),
        titleSmall:
            TextStyle(fontSize: 14, fontWeight: FontWeight.w600, height: 1.2),
        bodyLarge: TextStyle(
            fontFamily: bodyFontFamily,
            fontFamilyFallback: ['NotoColorEmoji'],
            fontSize: 15.5,
            fontWeight: FontWeight.w400,
            height: 1.4),
        bodyMedium: TextStyle(
            fontFamily: bodyFontFamily,
            fontFamilyFallback: ['NotoColorEmoji'],
            fontSize: 15,
            fontWeight: FontWeight.w400,
            height: 1.35),
        bodySmall: TextStyle(
            fontFamily: bodyFontFamily,
            fontFamilyFallback: ['NotoColorEmoji'],
            fontSize: 14,
            fontWeight: FontWeight.w400,
            height: 1.3),
        labelLarge: TextStyle(
            fontSize: 14.5, fontWeight: FontWeight.w500, height: 1.2, letterSpacing: 0.1),
        labelMedium: TextStyle(
            fontSize: 13, fontWeight: FontWeight.w500, height: 1.2, letterSpacing: 0.1),
        labelSmall: TextStyle(
            fontSize: 12, fontWeight: FontWeight.w500, height: 1.2, letterSpacing: 0.1),
      ).apply(
        fontFamily: headingFontFamily,
        fontFamilyFallback: ['NotoColorEmoji'],
      );

  // S1.13: Theme-level transitions are disabled so folder/tab switches are
  // instant (no header movement). Hierarchical detail routes (email detail,
  // contacts, compose, etc.) use per-route push transitions via GoRouter
  // pageBuilder overrides in route_page_transitions.dart.
  static PageTransitionsTheme _buildPageTransitions() => const PageTransitionsTheme(
        builders: {
          TargetPlatform.macOS: NoAnimationPageTransitionsBuilder(),
          TargetPlatform.windows: NoAnimationPageTransitionsBuilder(),
          TargetPlatform.android: NoAnimationPageTransitionsBuilder(),
          TargetPlatform.iOS: NoAnimationPageTransitionsBuilder(),
          TargetPlatform.linux: NoAnimationPageTransitionsBuilder(),
        },
      );

  // Cache ThemeData so the same object is reused across rebuilds.
  // Without caching, every build() creates a new ThemeData instance,
  // and since ThemeData doesn't implement ==, Flutter treats it as a
  // theme change — cascading rebuilds to every Theme.of(context) user.
  static final ThemeData _lightTheme = _buildLightTheme();
  static final ThemeData _darkTheme = _buildDarkTheme();

  static ThemeData _buildLightTheme() {
    const colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: AppStyles.primaryColor,
      onPrimary: AppStyles.onPrimary,
      secondary: AppStyles.secondaryColor,
      onSecondary: AppStyles.onPrimary,
      error: AppStyles.textError,
      onError: AppStyles.onPrimary,
      surface: Colors.white,
      onSurface: Color(0xFF1A1C1E),
      outline: AppStyles.grey,                    // #747474
      outlineVariant: AppStyles.stroke,            // #F1F1F1
      onSurfaceVariant: AppStyles.grey,            // #747474
      surfaceContainerHighest: Color(0xFFF5F5F5),
      surfaceContainerLow: Color(0xFFFAFAFA),
      shadow: Colors.black,
    );

    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppStyles.radiusM),
      borderSide: BorderSide(color: colorScheme.outlineVariant, width: 1),
    );

    return ThemeData(
      useMaterial3: true,
      fontFamily: headingFontFamily,
      colorScheme: colorScheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppStyles.primaryColor,
        foregroundColor: AppStyles.onPrimary,
        elevation: 0,
        scrolledUnderElevation: 4,
        shadowColor: Colors.black38,
        surfaceTintColor: Colors.transparent,
        shape: Border(
          bottom: BorderSide(color: Color(0x26FFFFFF), width: 1),
        ),
        centerTitle: false,
        iconTheme: IconThemeData(color: AppStyles.onPrimary),
        actionsIconTheme: IconThemeData(color: AppStyles.onPrimary),
        titleTextStyle: TextStyle(
          color: AppStyles.onPrimary,
          fontSize: 18.0,
          fontWeight: FontWeight.w700,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        border: inputBorder,
        enabledBorder: inputBorder,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppStyles.radiusM),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppStyles.radiusM),
          borderSide: BorderSide(color: colorScheme.error, width: 1),
        ),
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.15),
        hintStyle: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 14),
        errorStyle: const TextStyle(color: AppStyles.clickableTextColor),
        errorMaxLines: 2,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppStyles.clickableTextColor,
          foregroundColor: colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppStyles.radiusS),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          elevation: 0,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppStyles.radiusS),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          side: BorderSide(color: colorScheme.outlineVariant),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppStyles.radiusS),
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: colorScheme.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppStyles.radiusM),
          side: BorderSide(color: colorScheme.outlineVariant, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppStyles.radiusXL),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppStyles.radiusXL)),
        ),
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: AppStyles.primaryColor,
        selectionColor: Color(0x40243A8F), // primary at 25% opacity
        selectionHandleColor: AppStyles.primaryColor,
      ),
      dividerTheme: const DividerThemeData(
        color: AppStyles.stroke,
        thickness: 1,
        space: 1,
      ),
      scaffoldBackgroundColor: Colors.white,
      textTheme: _buildTextTheme(),
      pageTransitionsTheme: _buildPageTransitions(),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppStyles.clickableTextColor;
            }
            return Colors.transparent;
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return Colors.white;
            }
            return colorScheme.onSurfaceVariant;
          }),
          side: WidgetStatePropertyAll(
            BorderSide(color: colorScheme.outlineVariant),
          ),
        ),
      ),
      drawerTheme: DrawerThemeData(
        backgroundColor: colorScheme.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        indicatorColor: Colors.transparent,
        overlayColor: WidgetStateProperty.all(Colors.transparent),
        surfaceTintColor: Colors.transparent,
        height: 64,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppStyles.primaryVariant, size: 24);
          }
          return IconThemeData(color: colorScheme.onSurfaceVariant, size: 24);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppStyles.primaryVariant);
          }
          return TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: colorScheme.onSurfaceVariant);
        }),
      ),
      extensions: const [AppColorsExtension.light],
    );
  }

  static ThemeData _buildDarkTheme() {
    const colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: AppStyles.secondaryColor,          // #B3CCFF — lighter blue for dark surfaces
      onPrimary: Color(0xFF0A1A3E),               // dark text on light-blue buttons
      secondary: AppStyles.clickableTextColor,
      onSecondary: AppStyles.onPrimary,
      error: Color(0xFFFFB4AB),
      onError: Color(0xFF690005),
      surface: AppStyles.surfaceDark,              // #0E1530
      onSurface: AppStyles.onSurfaceDark,          // #E8ECFF
      outline: AppStyles.onSurfaceVarDark,         // #B3BBDD
      outlineVariant: Color(0xFF3A3A3A),              // visible border on dark surfaces
      onSurfaceVariant: AppStyles.onSurfaceVarDark, // #B3BBDD
      surfaceContainerHighest: AppStyles.surfaceHighDark, // #1C2660
      surfaceContainerLow: AppStyles.surfaceContDark,     // #161E45
      shadow: Colors.black,
    );

    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppStyles.radiusM),
      borderSide: BorderSide(color: colorScheme.outlineVariant, width: 1),
    );

    return ThemeData(
      useMaterial3: true,
      fontFamily: headingFontFamily,
      colorScheme: colorScheme,
      // Dark AppBar: elevated surface, NOT brand primary — distinguishes from light mode
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surfaceContainerHighest, // #1C2660 elevated navy
        foregroundColor: colorScheme.onSurface,               // #E8ECFF light text
        elevation: 0,
        scrolledUnderElevation: 2,
        shadowColor: Colors.black87,
        surfaceTintColor: Colors.transparent,
        shape: Border(
          bottom: BorderSide(color: colorScheme.outlineVariant, width: 1),
        ),
        centerTitle: false,
        iconTheme: IconThemeData(color: colorScheme.onSurface),
        actionsIconTheme: IconThemeData(color: colorScheme.onSurface),
        titleTextStyle: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 18.0,
          fontWeight: FontWeight.w700,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        border: inputBorder,
        enabledBorder: inputBorder,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppStyles.radiusM),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppStyles.radiusM),
          borderSide: BorderSide(color: colorScheme.error, width: 1),
        ),
        filled: true,
        fillColor: colorScheme.surfaceContainerLow,
        hintStyle: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 14),
        errorStyle: TextStyle(color: colorScheme.error),
        errorMaxLines: 2,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppStyles.clickableTextColor,
          foregroundColor: AppStyles.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppStyles.radiusS),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          elevation: 0,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppStyles.radiusS),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          side: BorderSide(color: colorScheme.outlineVariant),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppStyles.radiusS),
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: colorScheme.surfaceContainerLow,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppStyles.radiusM),
          side: BorderSide(color: colorScheme.outlineVariant, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colorScheme.surfaceContainerHighest,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppStyles.radiusXL),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colorScheme.surfaceContainerHighest,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppStyles.radiusXL)),
        ),
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: AppStyles.secondaryColor,
        selectionColor: Color(0x40B3CCFF),
        selectionHandleColor: AppStyles.secondaryColor,
      ),
      dividerTheme: const DividerThemeData(
        color: AppStyles.surfaceContDark,
        thickness: 1,
        space: 1,
      ),
      scaffoldBackgroundColor: AppStyles.surfaceDark,
      textTheme: _buildTextTheme(),
      pageTransitionsTheme: _buildPageTransitions(),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppStyles.clickableTextColor;
            }
            return Colors.transparent;
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return Colors.white;
            }
            return colorScheme.onSurfaceVariant;
          }),
          side: WidgetStatePropertyAll(
            BorderSide(color: colorScheme.outlineVariant),
          ),
        ),
      ),
      drawerTheme: const DrawerThemeData(
        backgroundColor: AppStyles.surfaceDark,
        surfaceTintColor: Colors.transparent,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colorScheme.surfaceContainerLow,
        indicatorColor: Colors.transparent,
        overlayColor: WidgetStateProperty.all(Colors.transparent),
        surfaceTintColor: Colors.transparent,
        height: 64,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: colorScheme.primary, size: 24);
          }
          return IconThemeData(color: colorScheme.onSurfaceVariant, size: 24);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: colorScheme.primary);
          }
          return TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: colorScheme.onSurfaceVariant);
        }),
      ),
      extensions: const [AppColorsExtension.dark],
    );
  }

  @override
  void dispose() {
    MyApp.lockController = null;
    _lockController.dispose();
    _stopSessionRefreshTimer();
    WidgetsBinding.instance.removeObserver(this);
    _sub?.cancel();
    subscription?.cancel();
    _showSnackbarTimer?.cancel();
    routerRefreshListenable?.dispose();
    appRouter.dispose();
    super.dispose();
  }
}

class NavigationService {
  static GlobalKey<NavigatorState> get navigatorKey => rootNavigatorKey;
}

class NoAnimationPageTransitionsBuilder extends PageTransitionsBuilder {
  const NoAnimationPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return child;
  }
}
