import 'package:flutter/widgets.dart';
import 'package:optmsg/common/responsive/responsive.dart';

/// Adaptive service for responsive layout detection.
///
/// This class delegates to [AppBreakpoints] for consistent breakpoint
/// values across the application. Prefer using [AppBreakpoints] directly
/// or the [ResponsiveContext] extension for new code.
///
/// @deprecated Use [AppBreakpoints] or [ResponsiveContext] extension instead.
class AdaptiveService {
  /// Returns the width of the screen in logical pixels.
  static double screenWidth(BuildContext context) {
    return AppBreakpoints.screenWidth(context);
  }

  /// Returns the height of the screen in logical pixels.
  static double screenHeight(BuildContext context) {
    return AppBreakpoints.screenHeight(context);
  }

  /// Determines if the current layout is suitable for mobile devices.
  /// Mobile: width < 600px
  static bool isMobileLayout(BuildContext context) {
    return AppBreakpoints.isMobileLayout(context);
  }

  /// Determines if the current layout is suitable for tablet devices.
  /// Tablet: 600px <= width < 1024px
  static bool isTabletLayout(BuildContext context) {
    return AppBreakpoints.isTabletLayout(context);
  }

  /// Determines if the current layout is suitable for desktop devices.
  /// Desktop: width >= 1024px
  static bool isDesktopLayout(BuildContext context) {
    return AppBreakpoints.isDesktopLayout(context);
  }

  /// Check if reading pane can be shown.
  /// Reading pane: width >= 1024px
  static bool canShowReadingPane(BuildContext context) {
    return AppBreakpoints.canShowReadingPaneFromContext(context);
  }

  /// Get device type from context.
  static DeviceType getDeviceType(BuildContext context) {
    return AppBreakpoints.deviceType(context);
  }
}
