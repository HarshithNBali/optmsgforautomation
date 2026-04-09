library;

import 'dart:io' show Platform;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform;
import 'package:flutter/material.dart';

enum DeviceType {
  mobile,

  tablet,

  desktop,
}

class AppBreakpoints {
  AppBreakpoints._();

  // Cache for physical tablet detection (initialized once at app startup)
  static bool? _isPhysicalTabletCached;
  static bool _cacheInitialized = false;

  static Future<void> initializeDeviceInfo() async {
    if (kIsWeb) {
      _isPhysicalTabletCached = false;
      _cacheInitialized = true;
      return;
    }

    try {
      final deviceInfo = DeviceInfoPlugin();

      if (Platform.isAndroid) {
        // M-13: Use shortestSide from the first view to distinguish tablets
        // from phones in landscape. Phones have shortestSide < 600dp.
        final view = WidgetsBinding.instance.platformDispatcher.views.first;
        final shortestSideDp =
            view.physicalSize.shortestSide / view.devicePixelRatio;
        _isPhysicalTabletCached = shortestSideDp >= 600.0;
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        // iPad detection via model name - reliable for iOS
        _isPhysicalTabletCached = iosInfo.model.toLowerCase().contains('ipad');
      } else {
        _isPhysicalTabletCached = false;
      }
    } catch (e) {
      // Fallback to null for runtime detection
      _isPhysicalTabletCached = null;
    }

    _cacheInitialized = true;
  }

  static bool isPhysicalTabletFromContext(BuildContext context) {
    if (kIsWeb) return false;

    // iOS: Use cached result (model-based detection)
    if (Platform.isIOS) {
      return _isPhysicalTabletCached ?? false;
    }

    final shortest = shortestSide(context);
    return shortest >= 600.0;
  }

  static bool get isPhysicalTablet {
    if (!_cacheInitialized || kIsWeb) return false;
    return _isPhysicalTabletCached ?? false;
  }

  static const double mobile = 600.0;

  static const double tablet = 600.0;

  static const double desktop = 1024.0;

  static const double readingPane =
      600.0; // Allow reading pane on tablets (medium screens)

  static const double minHeightForReadingPane =
      500.0; // Minimum height to show reading pane

  static const double largeDesktop = 1440.0;

  // ── UI Layout Constants ──────────────────────────────────────────────────

  /// Auth form card widths (desktop centred cards)
  static const double authFormWidthNarrow = 450.0; // create account
  static const double authFormWidthMedium = 500.0; // setup profile, forgot username
  static const double authFormWidthWide = 533.0; // login, enter OTP

  /// Generic content form widths (contacts, settings)
  static const double formWidthDesktop = 600.0;
  static const double formWidthTablet = 500.0;

  /// Split-pane (master/detail) constraints
  static const double splitPaneMinWidth = 280.0;
  static const double splitPaneMaxWidth = 600.0;

  /// Dropdown / overlay menus
  static const double overlayMenuWidth = 200.0;

  /// Popup & action sheet max-widths
  static const double popupMaxWidth = 500.0;
  static const double actionSheetMaxWidth = 400.0;

  /// Web login form width
  static const double webLoginFormWidth = 420.0;

  /// Credit card display dimensions
  static const double creditCardWidth = 323.0;
  static const double creditCardHeight = 181.0;

  /// Skeleton loader placeholder widths
  static const double skeletonWidthSm = 200.0;
  static const double skeletonWidthMd = 250.0;
  static const double skeletonWidthLg = 300.0;

  // ────────────────────────────────────────────────────────────────────────

  static const int emailListFlex = 1;

  static const int readingPaneFlex = 2;

  /// Check if width is in mobile range (< 600px)
  static bool isMobile(double width) => width < mobile;

  /// Check if width is in tablet range (600px - 1023px)
  static bool isTablet(double width) => width >= tablet && width < desktop;

  /// Check if width is in desktop range (>= 1024px)
  static bool isDesktop(double width) => width >= desktop;

  /// Check if width is in large desktop range (>= 1440px)
  static bool isLargeDesktop(double width) => width >= largeDesktop;

  static bool canShowReadingPane(double width) => width >= readingPane;

  /// Check if reading pane can be shown for device
  /// Uses canShowReadingPaneFromContext which checks both width and height
  static bool canShowReadingPaneForDevice(BuildContext context) {
    return canShowReadingPaneFromContext(context);
  }

  /// Get device type from width
  static DeviceType getDeviceType(double width) {
    if (width < mobile) return DeviceType.mobile;
    if (width < desktop) return DeviceType.tablet;
    return DeviceType.desktop;
  }

  static double screenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  /// Get screen height from context
  static double screenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  /// Get shortest side of screen (works correctly in both orientations)
  static double shortestSide(BuildContext context) {
    return MediaQuery.of(context).size.shortestSide;
  }

  /// Check if device is iPad (iOS with tablet-sized screen)
  static bool isIPad(BuildContext context) {
    if (kIsWeb) return false;
    if (defaultTargetPlatform != TargetPlatform.iOS) return false;

    // iPad typically has shortest side >= 600px
    final shortest = shortestSide(context);
    return shortest >= 600.0;
  }

  static bool isTabletDevice(BuildContext context) {
    if (kIsWeb) return false;
    final shortest = shortestSide(context);
    return shortest >= 600.0;
  }

  static DeviceType deviceType(BuildContext context) {
    final width = screenWidth(context);
    final height = screenHeight(context);
    final isLandscape = width > height;
    final shortest = shortestSide(context);
    final isTabletSized = shortest >= tablet;

    // PHONE CHECK (native only): If shortestSide < 600, it's a phone — always mobile layout.
    // This handles phone landscape where width > 600 but it's still a phone.
    // On web, only width matters — a short browser window should not force mobile.
    if (!kIsWeb && shortest < tablet) {
      return DeviceType.mobile;
    }

    // NATIVE TABLET: Check physical tablet FIRST (before width-based desktop check)
    // This ensures large iPads (like Pro 12.9" with 1024px portrait width) are handled correctly
    if (!kIsWeb && isTabletSized && isPhysicalTabletFromContext(context)) {
      // Physical tablet portrait → Mobile layout
      // Physical tablet landscape → Tablet layout
      return isLandscape ? DeviceType.tablet : DeviceType.mobile;
    }

    // Desktop check based on width (>= 1024px)
    if (width >= desktop) return DeviceType.desktop;

    // Tablet layout for width in tablet range (600-1023px) - both web and native
    if (width >= tablet) {
      return DeviceType.tablet;
    }

    // Phone (width < 600px)
    return DeviceType.mobile;
  }

  static bool isMobileLayout(BuildContext context) {
    final width = screenWidth(context);
    final height = screenHeight(context);
    final isLandscape = width > height;
    final shortest = shortestSide(context);
    final isTabletSized = shortest >= tablet;

    // PHONE CHECK (native only): If shortestSide < 600, it's a phone — always mobile layout.
    // On web, only width matters — a short browser window should not force mobile.
    if (!kIsWeb && shortest < tablet) {
      return true;
    }

    // NATIVE TABLET: Check physical tablet FIRST (before width-based desktop check)
    // This ensures large iPads (like Pro 12.9" with 1024px portrait width) are handled correctly
    if (!kIsWeb && isTabletSized && isPhysicalTabletFromContext(context)) {
      // Physical tablet portrait → mobile layout
      // Physical tablet landscape → NOT mobile (shows tablet layout)
      return !isLandscape;
    }

    // Desktop is never mobile (>= 1024px)
    if (width >= desktop) return false;

    // Tablet range (600-1023px) is not mobile - both web and native
    if (width >= tablet) {
      return false;
    }

    // Phone - always mobile (width < 600px)
    return true;
  }

  static bool isTabletLayout(BuildContext context) {
    final width = screenWidth(context);
    final height = screenHeight(context);
    final isLandscape = width > height;
    final shortest = shortestSide(context);
    final isTabletSized = shortest >= tablet;

    // PHONE CHECK (native only): If shortestSide < 600, it's a phone — never tablet layout.
    // On web, only width matters — a short browser window should not force mobile.
    if (!kIsWeb && shortest < tablet) {
      return false;
    }

    if (!kIsWeb && isTabletSized && isPhysicalTabletFromContext(context)) {
      return isLandscape;
    }

    // Desktop is never tablet (>= 1024px)
    if (width >= desktop) return false;

    // Tablet layout for width in tablet range (600-1023px) - both web and native
    if (width >= tablet) {
      return true;
    }

    return false;
  }

  /// Check if context is desktop layout.
  /// Respects physical tablet detection — a physical tablet in portrait
  /// should NOT return true even if width >= 1024 (e.g. iPad Pro 12.9").
  static bool isDesktopLayout(BuildContext context) {
    final width = screenWidth(context);
    if (width < desktop) return false;

    // Physical tablet portrait should not be desktop layout
    if (!kIsWeb) {
      final shortest = shortestSide(context);
      final isTabletSized = shortest >= tablet;
      if (isTabletSized && isPhysicalTabletFromContext(context)) {
        return false; // Physical tablets use mobile/tablet layouts, never desktop
      }
    }

    return true;
  }

  /// Check if reading pane can be shown from context
  /// Requires both sufficient width AND height to be usable
  static bool canShowReadingPaneFromContext(BuildContext context) {
    final width = screenWidth(context);
    final height = screenHeight(context);

    // Need both sufficient width and height for reading pane to be usable
    // A landscape phone might have width > 600 but height < 500, making it unusable
    return width >= readingPane && height >= minHeightForReadingPane;
  }

  /// Check if the device is in landscape orientation.
  static bool isLandscape(BuildContext context) {
    return screenWidth(context) > screenHeight(context);
  }

  /// Check if native tablet in landscape (sidebar + content layout).
  static bool isNativeTabletLandscape(BuildContext context) {
    return !kIsWeb && isTabletLayout(context) && isLandscape(context);
  }

  /// Check if the software keyboard is currently visible.
  static bool isKeyboardVisible(BuildContext context) {
    return MediaQuery.of(context).viewInsets.bottom > 0;
  }

  /// Get the current keyboard height in logical pixels.
  static double keyboardHeight(BuildContext context) {
    return MediaQuery.of(context).viewInsets.bottom;
  }

  /// Check if device is a phone (shortestSide < 600px)
  /// Phones should never show reading pane or panel layouts
  static bool isPhone(BuildContext context) {
    if (kIsWeb) return false;
    final shortest = shortestSide(context);
    return shortest < 600.0;
  }

  /// Check if device is a phone in landscape orientation
  /// Phone landscape should use single-column layout, not panel layout
  static bool isPhoneLandscape(BuildContext context) {
    if (kIsWeb) return false;
    final width = screenWidth(context);
    final height = screenHeight(context);
    final shortest = shortestSide(context);
    final isLandscape = width > height;

    // Phone (shortestSide < 600) in landscape
    return shortest < 600.0 && isLandscape;
  }
}
