library;

import 'package:flutter/material.dart';
import 'package:optmsg/constant/app_colors_extension.dart';
import 'breakpoints.dart';

/// Signature for responsive layout builder functions.
typedef ResponsiveLayoutWidgetBuilder = Widget Function(
  BuildContext context,
  DeviceType deviceType,
  double screenWidth,
);

class ResponsiveLayoutBuilder extends StatelessWidget {
  /// Builder for mobile layout (< 600px)
  final ResponsiveLayoutWidgetBuilder mobile;

  /// Builder for tablet layout (600px - 1023px)
  /// Falls back to [mobile] if not provided
  final ResponsiveLayoutWidgetBuilder? tablet;

  /// Builder for desktop layout (>= 1024px)
  /// Falls back to [tablet] or [mobile] if not provided
  final ResponsiveLayoutWidgetBuilder? desktop;

  const ResponsiveLayoutBuilder({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = AppBreakpoints.screenWidth(context);
    final deviceType = AppBreakpoints.deviceType(context);

    switch (deviceType) {
      case DeviceType.mobile:
        return mobile(context, deviceType, screenWidth);
      case DeviceType.tablet:
        return (tablet ?? mobile)(context, deviceType, screenWidth);
      case DeviceType.desktop:
        return (desktop ?? tablet ?? mobile)(context, deviceType, screenWidth);
    }
  }
}

class ResponsiveValue<T> extends StatelessWidget {
  /// Value for mobile layout
  final T mobile;

  /// Value for tablet layout (falls back to mobile)
  final T? tablet;

  /// Value for desktop layout (falls back to tablet or mobile)
  final T? desktop;

  /// Builder that receives the responsive value
  final Widget Function(BuildContext context, T value) builder;

  const ResponsiveValue({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    final deviceType = AppBreakpoints.deviceType(context);
    final value = _getValue(deviceType);
    return builder(context, value);
  }

  T _getValue(DeviceType deviceType) {
    switch (deviceType) {
      case DeviceType.mobile:
        return mobile;
      case DeviceType.tablet:
        return tablet ?? mobile;
      case DeviceType.desktop:
        return desktop ?? tablet ?? mobile;
    }
  }
}

/// Extension on BuildContext for responsive utilities.
extension ResponsiveContext on BuildContext {
  /// Get screen width
  double get screenWidth => AppBreakpoints.screenWidth(this);

  /// Get screen height
  double get screenHeight => AppBreakpoints.screenHeight(this);

  /// Get shortest side (for device type detection)
  double get shortestSide => AppBreakpoints.shortestSide(this);

  /// Get current device type (based on shortest side)
  DeviceType get deviceType => AppBreakpoints.deviceType(this);

  /// Check if mobile layout (based on shortest side)
  bool get isMobile => AppBreakpoints.isMobileLayout(this);

  /// Check if tablet layout (based on shortest side)
  bool get isTablet => AppBreakpoints.isTabletLayout(this);

  /// Check if desktop layout (based on shortest side)
  bool get isDesktop => AppBreakpoints.isDesktopLayout(this);

  /// Check if reading pane can be shown
  bool get canShowReadingPane =>
      AppBreakpoints.canShowReadingPaneFromContext(this);

  /// Check if landscape orientation
  bool get isLandscape => AppBreakpoints.isLandscape(this);

  /// Check if keyboard is visible
  bool get isKeyboardVisible => AppBreakpoints.isKeyboardVisible(this);

  /// Get responsive value based on device type
  T responsive<T>({
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    switch (deviceType) {
      case DeviceType.mobile:
        return mobile;
      case DeviceType.tablet:
        return tablet ?? mobile;
      case DeviceType.desktop:
        return desktop ?? tablet ?? mobile;
    }
  }

  /// Shorthand for `Theme.of(context).colorScheme`.
  ColorScheme get colors => Theme.of(this).colorScheme;

  /// Shorthand for app-specific color tokens (status, accent, gradients).
  AppColorsExtension get appColors => Theme.of(this).extension<AppColorsExtension>()!;
}
