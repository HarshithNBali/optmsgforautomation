import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:optmsg/main.dart';
import 'package:optmsg/router/app_routes.dart';
import 'package:optmsg/screens/auth/auth_riverpod/auth_notifier.dart'
    show authProvider;
import 'package:optmsg/services/api_service.dart';
import 'package:optmsg/services/common_service.dart';
import 'package:optmsg/services/storage_service.dart';
import 'package:optmsg/common/utilites/logger.dart';
import 'package:optmsg/webPackerHandler/mobile_check_out.dart'
    if (dart.library.js_interop) 'package:optmsg/webPackerHandler/web_check_out.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:app_badge_plus/app_badge_plus.dart';
import 'package:media_store_plus/media_store_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class PushNotificationService {
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  final GlobalKey<NavigatorState> navigatorKey;
  final SecureStorageService secureStorageService = SecureStorageService();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // H-12: stored so they can be cancelled before re-subscribing
  StreamSubscription<RemoteMessage>? _onMessageSub;
  StreamSubscription<RemoteMessage>? _onMessageOpenedAppSub;
  // M-14: track token refresh subscription so it isn't registered twice on re-init
  StreamSubscription<String>? _tokenRefreshSub;

  PushNotificationService(this.navigatorKey);

  static const AndroidNotificationChannel _androidChannel =
      AndroidNotificationChannel(
        'high_importance_channel',
        'High Importance Notifications',
        description: 'Used for important notifications',
        importance: Importance.high,
      );

  // ================= INITIALIZATION =================

  Future<void> initialize() async {
    // NOTE: onBackgroundMessage is now registered in main() before runApp()
    // so the callback handle is available to background isolates immediately.

    if (!kIsWeb) {
      firebaseMessaging.getInitialMessage().then((message) async {
        if (Platform.isIOS && message != null) {
          await handleNotification(message);
        }
        if (Platform.isAndroid) {
          MediaStore.appFolder = "MediaStorePlugin";
        }
      });
    }

    // H-12: cancel before re-subscribing to prevent duplicate listeners on re-init
    await _onMessageSub?.cancel();
    await _onMessageOpenedAppSub?.cancel();
    _onMessageSub = FirebaseMessaging.onMessage.listen(showNotification);
    _onMessageOpenedAppSub = FirebaseMessaging.onMessageOpenedApp.listen(
      handleNotification,
    );

    // M-11: persist refreshed token while the app is running (incl. background).
    // Without this, a token rotation while backgrounded is silently dropped and
    // the stored/server token becomes stale until the next cold start.
    await _tokenRefreshSub?.cancel();
    _tokenRefreshSub = FirebaseMessaging.instance.onTokenRefresh.listen((
      newToken,
    ) async {
      if (newToken.isNotEmpty) {
        await _updateTokenOnServer(newToken);
      }
    });

    await initializeLocalNotifications();
    await _saveFcmToken();

    // S-15: Synchronize the current token with the server on every app start
    // if the user is already authenticated. Without this, a persistent session
    // (no login needed) would keep using a stale token if the app was
    // re-installed or the token changed while the app was off.
    final currentToken = await secureStorageService.readData('deviceToken');
    if (currentToken != null && currentToken.isNotEmpty) {
      final isAuthenticated = providerContainer.read(authProvider).isAuthenticated;
      if (isAuthenticated) {
        unawaited(_updateTokenOnServer(currentToken));
      }
    }

    await _requestPermissions();
  }

  /// Internal helper to push the device token to the backend.
  Future<void> _updateTokenOnServer(String token) async {
    await secureStorageService.writeData('deviceToken', token);
    try {
      final isAuthenticated = providerContainer.read(authProvider).isAuthenticated;
      if (!isAuthenticated) return;

      // H-02: Use the centralized ApiService for the update request.
      // NOTE: We are hitting a 404 on 'user/update-device-token' in the staging
      // environment. Monitoring logs to confirm if the path is correct for iOS.
      final response = await ApiService().post('user/update-device-token', {
        'deviceToken': token,
      });

      if (kDebugMode) {
        final status = response['statusCode'] ?? 200;
        printLog('[PUSH] Token update server response', 'status=$status');
        if (status == 404) {
          debugPrint("❌ [PUSH_DEBUG] 404 NOT FOUND on 'user/update-device-token'. THIS ENDPOINT IS WRONG ON STAGING.");
        }
      }
    } catch (e) {
      if (kDebugMode) {
        printLog('[PUSH] Token update exception', e.toString());
      }
    }
  }

  // ================= LOCAL NOTIFICATIONS =================

  Future<void> initializeLocalNotifications() async {
    const initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('appicon'),
      iOS: DarwinInitializationSettings(
        // Permission is requested separately via _requestPermissions() using
        // Firebase Messaging. Setting these to true causes a duplicate prompt.
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    );

    await flutterLocalNotificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: _handleNotificationPayload,
    );

    if (CommonService().getPlatform() == 'android') {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(_androidChannel);
    }
  }

  // ================= NOTIFICATION HANDLING =================

  Future<void> handleNotification(RemoteMessage message) async {
    try {
      final pathData = _parsePath(message.data['PATH']);

      final badgeCount = int.tryParse(message.data['badge'] ?? '') ?? 0;

      if (!kIsWeb && await AppBadgePlus.isSupported()) {
        try {
          await AppBadgePlus.updateBadge(badgeCount);
        } catch (_) {}
      }

      // H-PERF-03: Wait for auth to initialize (cold-start case) instead of
      // an unconditional 2-second sleep. Resolves instantly when app is warm.
      await _waitForAuthReady();

      await _navigateFromNotification(
        type: pathData['type'],
        emailId: pathData['emailId'],
      );
    } catch (_) {
      CommonService.animatedToast('Invalid notification data', 'error');
    }
  }

  Future<void> _handleNotificationPayload(NotificationResponse response) async {
    try {
      final pathData = _parsePath(response.payload ?? '');

      await _navigateFromNotification(
        type: pathData['type'],
        emailId: pathData['emailId'],
      );
    } catch (_) {
      CommonService.animatedToast('Something went wrong', 'error');
    }
  }

  Future<void> showNotification(RemoteMessage message) async {
    // W-2/W-3: On web, flutter_local_notifications is not supported.
    // Use FCM's onMessage stream — the Firebase JS SDK surfaces foreground
    // messages automatically. For visual banners while the tab is active,
    // we call the browser Notification API directly.
    if (kIsWeb) {
      // W-3/H-01: On web, flutter_local_notifications is not supported.
      // Call the browser's native Notification API via JS interop to show
      // a banner while the tab is active.
      //
      // Search in notification payload first, then fall back to data payload
      // (common for data-only messages sent by some backends).
      final title =
          message.notification?.title ?? message.data['title'] ?? 'New Message';
      final body =
          message.notification?.body ??
          message.data['body'] ??
          'You have a new message';

      checkOutImp.showWebNotification(title, body, icon: 'favicon.png');
      return;
    }

    const androidDetails = AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      channelDescription: 'Used for important notifications',
      importance: Importance.max,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await flutterLocalNotificationsPlugin.show(
      id: 0,
      title: message.notification?.title ?? 'No Title',
      body: message.notification?.body ?? 'No Body',
      notificationDetails: platformDetails,
      payload: message.data['PATH'],
    );
  }

  // ================= NAVIGATION =================

  Future<void> _navigateFromNotification({
    required String type,
    required int emailId,
  }) async {
    // Use the in-memory Riverpod state as the single source of truth.
    // Reading from secure storage is stale during the window between
    // setAuthenticated(false) and clearAllData() completing.
    final isAuthenticated = providerContainer
        .read(authProvider)
        .isAuthenticated;

    if (isAuthenticated) {
      if (type == 'newEmailInbox') {
        appRouter.go(AppRoutes.inbox);
        await Future.microtask(
          () => appRouter.push(
            AppRoutes.viewEmailPath(emailId.toString()),
            extra: {'emailType': 'Inbox'},
          ),
        );
      } else if (type == 'newEmailCommunity') {
        await secureStorageService.writeData(
          'newEmailCommunityNotification',
          emailId.toString(),
        );

        appRouter.go(AppRoutes.trash);
      } else {
        appRouter.go(AppRoutes.notifications);
      }
    } else {
      appRouter.go(AppRoutes.login);
    }
  }

  /// H-PERF-03: Waits for auth to be initialized before navigating.
  /// Returns immediately when the app is already warm. On cold-start,
  /// polls every 100ms up to 3 seconds (same safety window as the old
  /// unconditional delay, but typically resolves much faster).
  Future<void> _waitForAuthReady() async {
    const pollInterval = Duration(milliseconds: 100);
    const maxWait = Duration(seconds: 3);
    final deadline = DateTime.now().add(maxWait);

    while (!providerContainer.read(authProvider).isInitialized &&
        DateTime.now().isBefore(deadline)) {
      await Future.delayed(pollInterval);
    }
  }

  /// W-3: Waits for the Firebase service worker to reach 'activated' state
  /// before calling getToken().  On first-ever page load the SW goes through
  /// installing → waiting → activated, and getToken() throws
  /// "Cannot read properties of undefined (reading 'pushManager')" if called
  /// before the SW is active.
  ///
  /// Moving the SW registration script before flutter_bootstrap.js (W-2) is
  /// the primary fix.  This 1.5 s guard is a belt-and-suspenders safety net
  /// for the ~500 ms install→activate window on first load.
  Future<void> _waitForServiceWorkerReady() async {
    if (!kIsWeb) return;
    await Future.delayed(const Duration(milliseconds: 1500));
  }

  // ================= HELPERS =================

  Map<String, dynamic> _parsePath(String rawPath) {
    final data = jsonDecode(rawPath);
    return {'type': data['type'] ?? '', 'emailId': data['emailId'] ?? 0};
  }

  Future<void> _saveFcmToken() async {
    try {
      if (kIsWeb) {
        // W-3: Wait for the service worker to be active before calling
        // getToken(). Even though the SW registration is now placed before
        // flutter_bootstrap.js, the SW may still be in 'installing' state on
        // the very first page load.  This guard ensures pushManager is defined.
        await _waitForServiceWorkerReady();
      }

      // W-7: VAPID key from Firebase Console → optmsg-staging → Project Settings
      // → Cloud Messaging → Web Push certificates.
      // This is the staging key. For production, override via:
      //   --dart-define=VAPID_KEY=<prod-vapid-key>
      // VAPID public keys are safe to embed in source.
      const vapidKey = String.fromEnvironment(
        'VAPID_KEY',
        defaultValue:
            'BIoEW6sMflExxg2LDJZIMMlerPJFP9RnLi2THz4S0QbyJRVrI2douP7M7rcWJanreu2OLpRQ5-Ri_6EBJoSS6D4',
      );

      final token = isSafari()
          ? 'NOT SUPPORTED'
          : await firebaseMessaging.getToken(
              vapidKey: kIsWeb ? vapidKey : null,
            );

      // H-11: only persist a real token; skip write on null to avoid
      // storing a placeholder that gets sent to the server as a device token
      if (token != null && token.isNotEmpty) {
        debugPrint("🚀 [PUSH_TOKEN] -> $token"); // LOG FOR MANUAL TESTING
        await secureStorageService.writeData('deviceToken', token);
      }
    } catch (_) {
      // Token unavailable — leave any previously stored token intact
    }
  }

  Future<void> _requestPermissions() async {
    if (kIsWeb) {
      await firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      return;
    }
    if (Platform.isAndroid) {
      // H-14: POST_NOTIFICATIONS is a runtime permission on Android 13+ (API 33).
      // permission_handler's isDenied can return false on first launch on some devices,
      // so check SDK level explicitly to guarantee the dialog is shown on first run.
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      if (androidInfo.version.sdkInt >= 33) {
        await Permission.notification.request();
      }
    } else {
      await firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

  bool isSafari() {
    return CheckOutImp().webWindowNavigatorUserAgentContains();
  }
}
