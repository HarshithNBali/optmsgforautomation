import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// BuildContext extension for in-widget navigation via GoRouter.
/// Services and notifiers without BuildContext should use [appRouter] directly
/// (from main.dart) or static helpers in [LoginPostProcessor].
extension NavigationContext on BuildContext {
  /// Navigate using GoRouter go
  void goTo(String path, {Object? extra}) =>
      GoRouter.of(this).go(path, extra: extra);

  /// Navigate using GoRouter push
  void pushTo(String path, {Object? extra}) =>
      GoRouter.of(this).push(path, extra: extra);

  /// Navigate using GoRouter replace
  void replaceTo(String path, {Object? extra}) =>
      GoRouter.of(this).replace(path, extra: extra);

  /// Pop current route
  void goBack<T extends Object?>([T? result]) => GoRouter.of(this).pop(result);

  /// Check if can go back
  bool get canGoBack => GoRouter.of(this).canPop();
}
