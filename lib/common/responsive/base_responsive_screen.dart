library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'breakpoints.dart';

class ResponsiveScreenConfig {
  /// Whether to show floating action button
  final bool showFab;

  /// Whether to show reading pane (desktop only)
  final bool showReadingPane;

  /// Whether to show sidebar navigation
  final bool showSidebar;

  /// Whether to show action bar
  final bool showActionBar;

  /// Flex ratio for list pane in split view
  final int listPaneFlex;

  /// Flex ratio for reading pane in split view
  final int readingPaneFlex;

  const ResponsiveScreenConfig({
    this.showFab = false,
    this.showReadingPane = false,
    this.showSidebar = false,
    this.showActionBar = true,
    this.listPaneFlex = 1,
    this.readingPaneFlex = 2,
  });

  /// Default mobile configuration
  static const mobile = ResponsiveScreenConfig(
    showFab: true,
    showReadingPane: false,
    showSidebar: false,
    showActionBar: false,
  );

  /// Default tablet configuration
  static const tablet = ResponsiveScreenConfig(
    showFab: false,
    showReadingPane: false,
    showSidebar: false,
    showActionBar: true,
  );

  /// Default desktop configuration (without reading pane)
  static const desktop = ResponsiveScreenConfig(
    showFab: false,
    showReadingPane: false,
    showSidebar: true,
    showActionBar: true,
  );

  /// Desktop configuration with reading pane
  static const desktopWithReadingPane = ResponsiveScreenConfig(
    showFab: false,
    showReadingPane: true,
    showSidebar: true,
    showActionBar: true,
    listPaneFlex: 1,
    readingPaneFlex: 2,
  );

  /// Get config based on device type and reading pane preference
  static ResponsiveScreenConfig forDevice(
    DeviceType deviceType, {
    bool readingPaneEnabled = false,
  }) {
    switch (deviceType) {
      case DeviceType.mobile:
        return mobile;
      case DeviceType.tablet:
        return tablet;
      case DeviceType.desktop:
        return readingPaneEnabled ? desktopWithReadingPane : desktop;
    }
  }

  /// Copy with modified values
  ResponsiveScreenConfig copyWith({
    bool? showFab,
    bool? showReadingPane,
    bool? showSidebar,
    bool? showActionBar,
    int? listPaneFlex,
    int? readingPaneFlex,
  }) {
    return ResponsiveScreenConfig(
      showFab: showFab ?? this.showFab,
      showReadingPane: showReadingPane ?? this.showReadingPane,
      showSidebar: showSidebar ?? this.showSidebar,
      showActionBar: showActionBar ?? this.showActionBar,
      listPaneFlex: listPaneFlex ?? this.listPaneFlex,
      readingPaneFlex: readingPaneFlex ?? this.readingPaneFlex,
    );
  }
}

/// Mixin for responsive screen state management.
///
/// Add this mixin to your screen's State class to get responsive
/// utilities and lifecycle hooks.
mixin ResponsiveScreenMixin<T extends StatefulWidget> on State<T> {
  /// Current device type based on screen width
  DeviceType get deviceType => AppBreakpoints.deviceType(context);

  /// Screen width
  double get screenWidth => AppBreakpoints.screenWidth(context);

  /// Screen height
  double get screenHeight => AppBreakpoints.screenHeight(context);

  /// Check if current layout is mobile
  bool get isMobile => deviceType == DeviceType.mobile;

  /// Check if current layout is tablet
  bool get isTablet => deviceType == DeviceType.tablet;

  /// Check if current layout is desktop
  bool get isDesktop => deviceType == DeviceType.desktop;

  /// Check if running on web platform
  bool get isWeb => kIsWeb;

  /// Check if sidebar should be visible (desktop web only)
  bool get isSidebarVisible => isWeb && isDesktop;

  /// Check if reading pane can be shown based on screen width
  bool get canShowReadingPane => AppBreakpoints.canShowReadingPane(screenWidth);

  /// Get responsive config for current device
  ResponsiveScreenConfig getConfig({bool readingPaneEnabled = false}) {
    return ResponsiveScreenConfig.forDevice(
      deviceType,
      readingPaneEnabled: readingPaneEnabled && canShowReadingPane,
    );
  }

  /// Determine FAB visibility based on platform and layout
  bool shouldShowFab({bool longPressMode = true}) {
    // Show FAB on native mobile OR web mobile view
    final isMobileView = screenWidth < AppBreakpoints.mobile;
    return (!isWeb || isMobileView) && longPressMode;
  }
}

abstract class BaseScreenController extends ChangeNotifier {
  bool _isLoading = false;
  bool _isDisposed = false;

  /// Whether the screen is currently loading data
  bool get isLoading => _isLoading;

  /// Whether the controller has been disposed
  bool get isDisposed => _isDisposed;

  /// Set loading state
  @protected
  void setLoading(bool value) {
    if (_isDisposed) return;
    _isLoading = value;
    notifyListeners();
  }

  /// Initialize the controller (call in initState)
  @mustCallSuper
  Future<void> init() async {
    setLoading(true);
  }

  /// Refresh data
  Future<void> refresh();

  /// Safely notify listeners (checks if disposed)
  @override
  void notifyListeners() {
    if (!_isDisposed) {
      super.notifyListeners();
    }
  }

  @override
  @mustCallSuper
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
