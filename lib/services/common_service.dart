import 'dart:async';
import 'dart:io';

import 'package:optmsg/common/responsive/breakpoints.dart';
import 'package:optmsg/services/fab_toast_coordinator.dart';
import 'package:optmsg/services/overlay_manager.dart';
import 'package:optmsg/services/storage_service.dart';
import 'package:optmsg/constant/app_config.dart';
import 'package:optmsg/constant/img_path.dart';
import 'package:optmsg/constant/string_constant.dart';
import 'package:optmsg/constant/styles.dart';
import 'package:optmsg/main.dart';
import 'package:optmsg/services/action_biometric_guard.dart';
import 'package:optmsg/model/contact_list_model.dart';

import 'package:optmsg/services/api_service.dart';
import 'package:optmsg/services/session_refresh_mutex.dart';
import 'package:optmsg/services/socket_service.dart';
import 'package:optmsg/widgets/add_email_modal.dart';
import 'package:optmsg/widgets/toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:app_badge_plus/app_badge_plus.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:optmsg/router/app_routes.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart';
import 'package:optmsg/services/web_utils.dart' as web_utils;

import 'update_provider.dart';
import 'global_variable_notifier.dart';

class CommonService {
  final SecureStorageService secureStorageService = SecureStorageService();
  final SocketService socketService = SocketService();

  /// Returns the copyright notice string for the current year.
  ///
  /// The copyright notice string is in the format: "  [year] [app name] ".
  String getCopyrightNotice() {
    int currentYear = DateTime.now().year;
    return '$copyright © $currentYear ${appInfo["name"]}$rights';
  }

  static void dismissToast() {
    _removeOverlay();
  }

  /// Displays a toast message on the screen with animation.
  ///
  /// The [message] is the text to be displayed in the toast.
  ///
  /// The [type] determines the appearance of the toast.
  /// If [type] is 'err', the toast will be shown with a red background.
  /// Otherwise, it will be shown with a green background.
  ///
  /// The [undoMethod] is an optional callback that is called when the user
  /// presses the undo button on the toast.
  ///
  /// The [checkMainScreen] flag is used to position the toast at a different
  /// location when the app is running on the main screen.
  ///
  static OverlayEntry? overlayEntry;
  static Timer? _toastDismissTimer;
  static void animatedToast(
    String message,
    String type, [
    VoidCallback? undoMethod,
    bool checkMainScreen = false,
  ]) {
    // RC-5: Suppress ALL error toasts during logout. SessionExpiryManager already
    // showed "Session expired" and navigation to /login is underway. Any error
    // toasts from in-flight requests on still-mounted screens (inbox, archive,
    // contacts, etc.) would produce confusing double-toasts.
    // The "Session expired" toast itself is NOT suppressed because it fires
    // BEFORE isLoggedOut is set (line 103 before line 105 in session_expiry_manager).
    if (SessionRefreshMutex.isLoggedOut && type == 'error') return;

    // Centralized guard: suppress connectivity toasts — the persistent overlay
    // banner handles these. If the banner was dismissed, re-show it so the user
    // sees the connectivity status on every failed action.
    final lower = message.toLowerCase();
    if (lower.contains('no internet')) {
      showConnectivityBanner();
      return;
    }

    // Remove any existing toast
    if (overlayEntry != null && overlayEntry!.mounted) {
      overlayEntry!.remove();
    }
    overlayEntry = null;

    bool toastUndoFlag = false;

    late OverlayEntry currentOverlay;

    currentOverlay = OverlayEntry(
      builder: (context) => Positioned(
        bottom: checkMainScreen
            ? AppBreakpoints.screenHeight(context) *
                  (CommonService().getPlatform() == 'ios' ? 0.11 : 0.08)
            : 20,
        left: 0,
        right: 0,
        child: Align(
          alignment: Alignment.center,
          child: CustomToast(
            message: message,
            type: type,

            /// ✅ UNDO BUTTON
            undoMethod: () {
              try {
                toastUndoFlag = true;
                undoMethod?.call();
              } catch (e, st) {
                debugPrint('Toast undo error: $e\n$st');
              } finally {
                if (currentOverlay.mounted) {
                  currentOverlay.remove();
                }
                if (overlayEntry == currentOverlay) {
                  overlayEntry = null;
                }
                FabToastCoordinator.isToastVisible.value = false;
              }
            },

            /// ✅ CLOSE BUTTON (FIXED)
            closeIcon: () {
              try {
                toastUndoFlag = true;
              } catch (e, st) {
                debugPrint('Toast close error: $e\n$st');
              } finally {
                if (currentOverlay.mounted) {
                  currentOverlay.remove();
                }
                if (overlayEntry == currentOverlay) {
                  overlayEntry = null;
                }
                FabToastCoordinator.isToastVisible.value = false;
              }
            },
          ),
        ),
      ),
    );

    overlayEntry = currentOverlay;

    // Initialize ToastManager if needed
    final overlayState = ToastManager.overlayStateOrNull;
    if (overlayState == null) {
      final navState = NavigationService.navigatorKey.currentState;
      if (navState != null && navState.overlay != null) {
        ToastManager.overlayState = navState.overlay;
      } else {
        final ctx = NavigationService.navigatorKey.currentContext;
        if (ctx != null) {
          ToastManager.initialize(ctx);
        }
      }
    }

    final finalOverlayState = ToastManager.overlayStateOrNull;
    if (finalOverlayState != null && finalOverlayState.mounted) {
      finalOverlayState.insert(currentOverlay);
      FabToastCoordinator.isToastVisible.value = true;

      /// ✅ Auto dismiss after 3 seconds
      _toastDismissTimer?.cancel();
      _toastDismissTimer = Timer(const Duration(seconds: 3), () {
        if (!toastUndoFlag && currentOverlay.mounted) {
          currentOverlay.remove();
        }
        if (overlayEntry == currentOverlay) {
          overlayEntry = null;
        }
        FabToastCoordinator.isToastVisible.value = false;
      });
    } else {
      overlayEntry = null;
      debugPrint('Toast: $message ($type)');
    }
  }

  static void _removeOverlay() {
    if (overlayEntry != null) {
      if (overlayEntry!.mounted) {
        overlayEntry!.remove();
      }
      overlayEntry = null;
    }
    FabToastCoordinator.isToastVisible.value = false;
  }

  // ─── CONNECTIVITY BANNER (overlay-based, persists across navigation) ───

  static OverlayEntry? _connectivityOverlay;
  static bool _isOffline = false;

  /// Whether the device is currently offline. Used by ShellLayout to
  /// re-show the banner on navigation after the user dismisses it.
  static bool get isOffline => _isOffline;

  /// Show persistent connectivity banner using CustomToast styling.
  /// Uses the same overlay system as animatedToast() for reliable
  /// cross-navigation persistence. Stays until dismissed by user or
  /// internet restores via [hideConnectivityBanner].
  ///
  /// Suppressed during active token refresh — a 401 is an auth issue, not
  /// a connectivity issue. The banner would otherwise appear as a false
  /// positive when the session JWT expires and recovery is in progress.
  static void showConnectivityBanner() {
    if (SessionRefreshMutex.isRefreshing) return;
    _isOffline = true;
    // Don't show duplicate
    if (_connectivityOverlay != null && _connectivityOverlay!.mounted) return;

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 20,
        left: 0,
        right: 0,
        child: Align(
          alignment: Alignment.center,
          child: CustomToast(
            message: 'Internet disconnected',
            type: 'error',
            closeIcon: () {
              // Dismiss overlay but keep _isOffline = true so it
              // re-shows on next navigation or action.
              if (entry.mounted) entry.remove();
              _connectivityOverlay = null;
            },
            undoMethod: () {},
          ),
        ),
      ),
    );

    _connectivityOverlay = entry;

    final overlayState = ToastManager.overlayStateOrNull;
    if (overlayState != null && overlayState.mounted) {
      overlayState.insert(entry);
    } else {
      final navState = NavigationService.navigatorKey.currentState;
      if (navState?.overlay != null) {
        navState!.overlay!.insert(entry);
      }
    }
  }

  /// Hide the connectivity banner AND clear the offline flag.
  /// Called when internet actually restores (from main.dart listener).
  static void hideConnectivityBanner() {
    _isOffline = false;
    if (_connectivityOverlay != null && _connectivityOverlay!.mounted) {
      _connectivityOverlay!.remove();
    }
    _connectivityOverlay = null;
  }

  /// Returns a new string with the first character of [input] capitalized.
  ///
  /// If [input] is empty, an empty string is returned.
  ///
  /// Example:
  ///
  String capitalize(String input) {
    if (input.isEmpty) {
      return input;
    }
    return input[0].toUpperCase() + input.substring(1);
  }

  /// Formats a given date string into a string that displays the date
  /// information in a human-readable format.
  ///
  /// If the [dateString] is null or empty, an empty string is returned.
  ///
  /// If the given date is today, the time is returned in 'h:mm a' format.
  ///
  /// If the given date is yesterday, 'Yesterday' is returned.
  ///
  /// If the given date is within the last week, the day of the week is returned.
  ///
  /// If the given date is more than a week ago, the date is returned in
  /// 'dd MMM, yyyy' format.
  ///
  /// The [type] parameter allows to specify the format of the returned string.
  /// If [type] is 'full', the returned string will be in the format
  /// 'EEEE, MMMM d, y \'at\' h:mma'.
  /// If [type] is 'onlyDate', the returned string will be in the format
  /// 'MMMM d, y'.
  /// Otherwise, the returned string will be in the format
  /// 'MMMM d, y \'at\' h:mma'.
  ///
  static String formatDateString(String? dateString, {String? type}) {
    // Check if dateString is null or empty
    if (dateString == null || dateString.isEmpty) {
      return ''; // Return an empty string as fallback value
    }

    // Parse the date string into a DateTime object
    DateTime dateTime = DateTime.parse(
      dateString,
    ).toLocal(); // Convert UTC to local time

    // Get the current date (stripped of time)
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);
    DateTime givenDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    // Calculate the difference in days
    int differenceInDays = today.difference(givenDate).inDays;

    if (differenceInDays == 0) {
      // If the date is today, return time in 'h:mm a' format
      return DateFormat('h:mm a').format(dateTime);
    } else if (differenceInDays == 1) {
      // If the date is yesterday, return 'Yesterday'
      return 'Yesterday';
    } else if (differenceInDays < 7) {
      // If the date is within the last week, return the day of the week
      return DateFormat('EEEE').format(dateTime);
    } else {
      // If the date is more than a week ago, return formatted date
      return type == 'full'
          ? DateFormat('EEEE, MMMM d, y \'at\' h:mma').format(dateTime)
          : (type == 'onlyDate'
                ? DateFormat('MMMM d, y').format(dateTime)
                : DateFormat('MMMM d, y \'at\' h:mma').format(dateTime));
    }
  }

  /// Converts a date string into a human-readable full date-time format.
  ///
  /// The input [dateString] should be in a valid date-time format. If
  /// [dateString] is null or empty, an empty string is returned.
  ///
  /// The returned string will be in the format 'EEEE, MMMM d, y at h:mma',
  /// where 'EEEE' is the full name of the day of the week, 'MMMM' is the full
  /// name of the month, 'd' is the day of the month, 'y' is the year, and
  /// 'h:mma' is the time in 12-hour format with AM/PM.
  ///
  /// The function also converts the date string from UTC to local time before
  /// formatting.

  static String fullDateTime(String? dateString) {
    // Check if dateString is null or empty
    if (dateString == null || dateString.isEmpty) {
      return ''; // Return an empty string as fallback value
    }
    // Parse the date string into a DateTime object
    DateTime dateTime = DateTime.parse(
      dateString,
    ).toLocal(); // Convert UTC to local time

    return DateFormat('EEEE, MMMM d, y \'at\' h:mma').format(dateTime);
  }

  /// Converts a date-time string into a human-readable format.
  ///
  /// If the date is today, the returned string is 'Today, `<time>`', where
  /// `<time>` is the time in 12-hour format with AM/PM.
  ///
  /// If the date is not today, the returned string is '`<date>` `<time>`', where
  /// `<date>` is the date in 'yMMMd' format, and `<time>` is the time in 12-hour
  /// format with AM/PM.
  String formatDateTime(String dateTimeString) {
    DateTime dateTime = DateTime.parse(
      dateTimeString,
    ).toLocal(); // Convert to local time
    DateTime now = DateTime.now();

    if (dateTime.year == now.year &&
        dateTime.month == now.month &&
        dateTime.day == now.day) {
      // Today
      return 'Today, ${DateFormat.jm().format(dateTime)}';
    } else {
      // Other dates
      return DateFormat.yMMMd().add_jm().format(
        dateTime,
      ); // Format the date as desired
    }
  }

  /// extensionTypesIcon function returns image based on the provided extension type.
  SvgPicture extensionTypesIcon(String type) {
    switch (type) {
      case 'image/jpeg':
      case 'image/png':
      case 'image/jpg':
        return SvgPicture.asset(svgimage, width: 30, height: 30);
      case 'image':
        return SvgPicture.asset(svgimage, width: 30, height: 30);
      case 'pdf':
        return SvgPicture.asset(
          svgpdf,
          colorFilter: const ColorFilter.mode(
            AppStyles.blueBackground,
            BlendMode.srcIn,
          ),
          width: 30,
          height: 30,
        );
      case 'video':
        return SvgPicture.asset(
          svgmp4,
          colorFilter: const ColorFilter.mode(
            AppStyles.blueBackground,
            BlendMode.srcIn,
          ),
          width: 30,
          height: 30,
        );
      case 'mp3':
        return SvgPicture.asset(
          svgmp3,
          colorFilter: const ColorFilter.mode(
            AppStyles.blueBackground,
            BlendMode.srcIn,
          ),
          width: 30,
          height: 30,
        );
      case 'zip':
        return SvgPicture.asset(
          svgmp3,
          colorFilter: const ColorFilter.mode(
            AppStyles.blueBackground,
            BlendMode.srcIn,
          ),
          width: 30,
          height: 30,
        );
      default:
        return SvgPicture.asset(
          svgdoc,
          colorFilter: const ColorFilter.mode(
            AppStyles.blueBackground,
            BlendMode.srcIn,
          ),
          width: 30,
          height: 30,
        );
    }
  }

  /// getFileName function returns the file name from the provided file path.
  String getFileName(String filePath) {
    if (filePath != '') {
      int lastIndex = filePath.lastIndexOf('/');
      String fileName = filePath.substring(lastIndex + 1);
      return fileName.toString();
    }
    return '';
  }

  /// Returns the current platform as a string. The returned value is one of the
  /// following:
  ///
  /// * "web" for web platform
  /// * "android" for Android platform
  /// * "ios" for iOS platform
  /// * "web" for other platforms
  ///
  /// This function is used to determine which platform the app is running on.
  String getPlatform() {
    if (kIsWeb) {
      return "web"; // Web platform
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      return "android"; // Android platform
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return "ios"; // iOS platform
    } else {
      return "web"; // Other platforms
    }
  }

  static bool isMobileBrowser() {
    if (!kIsWeb) return false;

    final userAgent = web_utils.getWebUserAgent().toLowerCase();
    return userAgent.contains('mobile') ||
        userAgent.contains('android') ||
        userAgent.contains('iphone') ||
        userAgent.contains('ipad') ||
        userAgent.contains('ipod');
  }

  static bool isTouchDevice() {
    if (!kIsWeb) return false;
    return web_utils.isTouchDevice();
  }

  static bool isMobileOrTouchDevice() {
    return isMobileBrowser() || isTouchDevice();
  }

  /// Returns a double value for flex size based on the current platform.
  ///
  /// On Android and iOS platforms, the returned value is the product of the
  /// [flexSize] parameter and the screen width.
  ///
  /// On web and desktop platforms, the returned value is the product of the
  /// [flexSize] parameter and the screen width, minus an adjustment value.
  /// The adjustment value is 10% of the screen width on web and desktop
  /// platforms.
  ///
  /// This function is used to provide a different layout for web and desktop
  /// platforms.
  double getFlexByPlatform(BuildContext context, double flexSize) {
    bool isDesktopLayout = AppBreakpoints.isDesktopLayout(context);
    double adaptiveSize = AppBreakpoints.screenWidth(context) * flexSize;

    // Adjust for Web/Desktop platforms
    double desktopAdjustment = isDesktopLayout
        ? AppBreakpoints.screenWidth(context) * 0.1
        : 0.0;

    if (defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS) {
      return adaptiveSize;
    } else if (kIsWeb) {
      return adaptiveSize - desktopAdjustment;
    } else {
      return adaptiveSize - desktopAdjustment; // For other platforms
    }
  }

  /// Downloads a file from the given URL.
  ///
  /// The file is downloaded by launching the given URL in an external
  /// application.
  ///
  /// If the launch fails, an exception is thrown.
  ///
  /// This function is used in the [FileViewer] widget to download the file
  /// when the download button is clicked.
  Future<void> downloadFile(String url) async {
    try {
      final Uri url0 = Uri.parse(s3BaseUrl + url);
      ActionBiometricGuard.markDeparture();
      if (!await launchUrl(url0, mode: LaunchMode.externalApplication)) {
        throw Exception('Could not launch $url0');
      }
    } catch (e) {
      CommonService.animatedToast(catchError, 'error');
    }
  }

  /// Logs out of the application.
  Future<void> logOut() async {
    await secureStorageService.clearAllData();
    if (!kIsWeb && await AppBadgePlus.isSupported()) {
      try {
        await AppBadgePlus.updateBadge(0);
      } catch (_) {}
    }
    // final refreshJwt = Descope.sessionManager.session?.refreshJwt;
    // if (refreshJwt != null) {
    //   await Descope.auth.revokeSessions(RevokeType.currentSession, refreshJwt);
    //   Descope.sessionManager.clearSession();
    // }
    // NavigationService.navigatorKey.currentState!.push(
    //   MaterialPageRoute(
    //     builder: (context) => AdaptiveService.isMobileLayout(context) ?  Login() : const WebLogin(),
    //   ),
    // );
    //providerContainer.read(authProvider.notifier).logout();
    final ctx = NavigationService.navigatorKey.currentContext;
    if (ctx != null && ctx.mounted) {
      ctx.go(AppRoutes.login);
    }
  }

  /// Converts a given timestamp in milliseconds to a string in the format "d MMM, yyyy".
  ///
  /// For example, the timestamp 1643723400 would be converted to "24 Jan, 2022".
  ///
  /// The timestamp is assumed to be in milliseconds since the Unix epoch (January 1, 1970).
  String formatTimestamp(int timestamp) {
    final DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final DateFormat formatter = DateFormat('d MMM, yyyy');
    return formatter.format(dateTime);
  }

  /// Converts a Unix timestamp to a formatted date string.
  String formatUnixTimestamp(int timestamp, String format) {
    // Convert Unix timestamp to milliseconds
    var dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);

    // Format the date as "day month year" (e.g., "29 April 2024")
    return DateFormat(format).format(dateTime);

    // exp:- formatUnixTimestamp(1745923852,'dd MMM yyyy')
  }

  /// Converts a file size in bytes to a human-readable format.
  ///
  /// This function automatically chooses the appropriate unit (Bytes, KB, MB, GB)
  /// and formats the value with one decimal place.
  String formatFileSize(int bytes) {
    double sizeInKB = bytes / 1024;

    if (sizeInKB >= 1024) {
      double sizeInMB = sizeInKB / 1024;
      return '${sizeInMB.toStringAsFixed(1)} MB';
    } else {
      return '${sizeInKB.toStringAsFixed(1)} KB';
    }
  }

  /// Converts a file size in bytes to a human-readable format.
  ///
  /// If the file size is 1 MB or larger, it is converted to a
  /// size in MB with two decimal places. Otherwise, the size is
  /// returned as a string with the unit "KB" and two decimal places.
  String composeFormatFileSize(int sizeInBytes) {
    if (sizeInBytes >= 1024 * 1024) {
      double sizeInMB = sizeInBytes / (1024 * 1024);
      return '${sizeInMB.toStringAsFixed(2)} MB';
    } else {
      double sizeInKB = sizeInBytes / 1024;
      return '${sizeInKB.toStringAsFixed(2)} KB';
    }
  }

  /// Checks whether a given email is valid.
  static bool isValidEmail(String email) {
    email = email.trim();
    const pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
    return RegExp(pattern).hasMatch(email);
  }

  /// Truncates a given text to a specified maximum length and appends an ellipsis if necessary.
  ///
  /// If the length of [text] is less than or equal to [maxLength], the original text is returned.
  /// Otherwise, the text is truncated to [maxLength] characters, and "..." is appended to indicate
  /// that the text has been truncated.
  ///
  /// [maxLength] specifies the maximum length of the returned string, including the ellipsis.
  /// [text] is the input string to be truncated.
  ///
  /// Returns a string that is either the original text or a truncated version with an ellipsis.

  String truncateWithEllipsis(int maxLength, String text) {
    return (text.length <= maxLength)
        ? "$text  "
        : '${text.substring(0, maxLength)}...  ';
  }

  /// Navigates to the "Add Recipient" screen for a given email address.
  Future<void> gotoAddRecipient(
    String email, {
    BuildContext? context,
    String? senderDisplayName,
  }) async {
    try {
      Map<String, dynamic> resp = await ApiService().post(
        'contact/check-email',
        {"email": email},
      );
      if (resp['success']) {
        resp['data']['status']
            ? viewContact(Contacts.fromJson(resp['data']['contact']))
            : optInMenu(
                email,
                context: null,
                senderDisplayName: senderDisplayName,
              );
      } else {
        CommonService.animatedToast(resp['message'], 'error');
      }
    } catch (error) {
      if (error is! NoInternetException) {
        CommonService.animatedToast('Error processing request', 'error');
      }
    }
  }

  /// Navigates to the contact view page for the specified contact.
  ///
  /// Determines the platform layout (desktop or non-desktop) and uses the
  /// appropriate navigator key to push the contact view page route onto the
  /// navigator stack.
  ///
  /// [contact] the contact object to be viewed.

  Future<void> viewContact(Contacts contact) async {
    // final isDesktop = AppBreakpoints.isDesktopLayout(
    //   NavigationService.navigatorKey.currentContext as BuildContext,
    // );

    // final navigatorKey = isDesktop ? webNavigatorKey : NavigationService.navigatorKey;

    await NavigationService.navigatorKey.currentContext!.push(
      AppRoutes.viewContactriverpodPath(contact.id),
      extra: {'contact': contact, 'page': 'list'},
    );
  }

  void optInMenu(String email, {BuildContext? context, String? senderDisplayName}) {
    final ctx = context ?? NavigationService.navigatorKey.currentContext;
    if (ctx == null) {
      CommonService.animatedToast('Unable to show dialog', 'error');
      return;
    }
    showDialog(
      context: ctx,
      builder: (BuildContext dialogContext) {
        return AddEmailModal(
          title: addEmail,
          subtitleFirst: email,
          subtitle: addEmailcontact,
          type: 'optin',
          saveFlag: () async {},
          contact: null,
          senderDisplayName: senderDisplayName,
        );
      },
    );
  }

  /// Generates a string that indicates the status of an email based on whether it is deleted or not.
  String undoStatus(String status, [bool? isDeleted]) {
    if (isDeleted != null && isDeleted) {
      return "Permanently Delete";
    }
    return "Moving to $status";
  }

  /// Updates the badge count using the FlutterAppBadger plugin.
  Future updateBadge(int count) async {
    if (kIsWeb || !await AppBadgePlus.isSupported()) return;
    try {
      await AppBadgePlus.updateBadge(count);
    } catch (_) {}
  }

  /// Formats a phone number by removing non-digit characters and structuring it in a
  /// standard format.
  ///
  /// Takes in a [countryCode] and a [mobileNumber], removes any non-digit characters
  /// from the [mobileNumber], and returns a formatted string in the pattern:
  /// (countryCode) XXX-XXX-XXXX.
  ///
  String formatPhoneNumber(String countryCode, String mobileNumber) {
    String digits = mobileNumber.replaceAll(RegExp(r'\D+'), '');
    if (digits.length < 6) return '($countryCode) $digits';
    return '($countryCode) ${digits.substring(0, 3)}-${digits.substring(3, 6)}-${digits.substring(6)}';
  }

  /// get current date
  int getCurrentDate() {
    DateTime now = DateTime.now();
    return now.millisecondsSinceEpoch ~/ 1000;
  }

  /// Retrieves the current version of the app.
  ///
  /// This function uses the `PackageInfo` package to obtain the version
  /// information of the app running on the platform.
  ///
  /// Returns a `Future` that resolves to a `String` representing the app
  /// version.

  static String? _cachedAppVersion;

  Future<String> getAppVersion() async {
    if (_cachedAppVersion != null) return _cachedAppVersion!;
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    _cachedAppVersion = packageInfo.version;
    return _cachedAppVersion!;
  }

  /// Returns the bundle ID of the current app.
  ///
  /// The bundle ID is the unique identifier for an app in the app store. It is
  /// used to identify the app when making API calls to the app store.
  ///
  /// The function returns a `Future` that resolves to a `String` representing the
  /// bundle ID of the current app.
  static Future<String> getBundleId() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.packageName;
  }

  /// Shows an update dialog with the given [updateType] and [updateMessage].
  ///
  /// If [updateType] is 'hard', the dialog will be non-dismissible and will
  /// have a single 'Update Now' button. If [updateType] is 'soft', the dialog
  /// will be dismissible and will have a 'Cancel' button as well as an 'Update Now'
  /// button.
  ///
  /// The dialog will not be shown if an update dialog is already visible,
  /// or if an optional update has been dismissed.
  ///
  /// The [updateMessage] will be displayed in the dialog's content.
  ///
  /// The dialog will be configured to use the platform's default style for
  /// the platform it is currently running on.
  ///
  /// The dialog will be shown on the root navigator.
  ///
  /// The dialog will be closed when the user presses a button or dismisses
  /// the dialog.
  ///
  /// If the user presses the 'Update Now' button, the app will open the app's
  /// page on the app store.
  static Future<void> showUpdateDialog({
    required String updateType,
    required String updateMessage,
  }) async {
    final context = NavigationService.navigatorKey.currentState?.context;

    if (context == null) return;

    final updateState = providerContainer.read(updateProvider);

    if (updateState.isUpdateDialogVisible) return; // Prevent duplicate popups
    if (updateType == 'soft' && updateState.isOptionalUpdateDismissed) return;

    providerContainer
        .read(updateProvider.notifier)
        .setUpdateDialogVisible(true);

    await showCupertinoDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        bool isForcedUpdate = updateType == 'hard';

        return CupertinoAlertDialog(
          title: Text(isForcedUpdate ? 'Update Required' : 'Update Available'),
          content: Text(updateMessage),
          actions: [
            if (!isForcedUpdate)
              CupertinoDialogAction(
                onPressed: () {
                  providerContainer
                      .read(updateProvider.notifier)
                      .dismissOptionalUpdate(); // Mark as dismissed
                  providerContainer
                      .read(updateProvider.notifier)
                      .setUpdateDialogVisible(false);
                  if (!context.mounted) return;
                  context.pop();
                },
                child: const Text('Cancel'),
              ),
            CupertinoDialogAction(
              onPressed: () async {
                final bool isAndroid =
                    Theme.of(context).platform == TargetPlatform.android;

                final String storeUrl = isAndroid ? playStoreUrl : appStoreUrl;

                final String bundleId = isAndroid ? await getBundleId() : '';
                final Uri url = Uri.parse(
                  isAndroid ? '$storeUrl$bundleId' : storeUrl,
                );

                if (await canLaunchUrl(url)) {
                  ActionBiometricGuard.markDeparture();
                  await launchUrl(url);
                } else {
                  throw 'Could not launch $url';
                }
              },
              child: const Text('Update Now'),
            ),
          ],
        );
      },
    );
    providerContainer
        .read(updateProvider.notifier)
        .setUpdateDialogVisible(false);
  }

  // Simplify the file path for user display
  String simplifyPath(String fullPath) {
    if (Platform.isAndroid) {
      // On Android, simplify the path starting from "Download"
      if (fullPath.contains('/Download/')) {
        return fullPath.split('/Download/').last;
      } else if (fullPath.contains('/storage/emulated/0/')) {
        return fullPath.split('/storage/emulated/0/').last;
      }
    } else if (Platform.isIOS) {
      // On iOS, simplify to show just the filename or relative path
      return fullPath.split('/').last;
    }
    return fullPath; // Fallback to full path if platform-specific logic fails
  }

  static Future<bool> permissionRequest() async {
    PermissionStatus result;
    result = await Permission.storage.request();
    if (result.isGranted) {
      return true;
    } else {
      return false;
    }
  }

  void showComposeWarning(BuildContext context) {
    showCupertinoDialog(
      barrierDismissible: false,
      context: context,
      builder: (_) => PointerInterceptor(
        intercepting: kIsWeb || Platform.isAndroid ? true : false,
        child: CupertinoAlertDialog(
          title: const Text('Alert'),
          content: const Text(freeUserWarning),
          actions: [
            CupertinoDialogAction(
              child: const Text("OK"),
              onPressed: () {
                if (!context.mounted) return;
                context.pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<Map<String, dynamic>> getLastActivity(BuildContext context) async {
    final hasCalled = providerContainer
        .read(globalVariableProvider)
        .hasCalledLastActivity;
    if (hasCalled) {
      return {}; // Return empty map if already called
    }
    try {
      final response = await ApiService().get('user/update-last-activity');
      if (response['success']) {
        providerContainer
            .read(globalVariableProvider.notifier)
            .setLastActivityCalled();
      }
      return response; // Return API response
    } catch (e) {
      providerContainer
          .read(globalVariableProvider.notifier)
          .setLastActivityCalled(); // Mark as called even on error
      return {'error': e.toString()}; // Return error map
    }
  }

}
