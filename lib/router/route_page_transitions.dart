import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:go_router/go_router.dart';

/// Builds a [CustomTransitionPage] with a platform-aware push transition.
///
/// - iOS/Android: [CupertinoPageTransition] (slide from right, 300 ms)
/// - Web: fade + subtle horizontal slide (200 ms)
///
/// Use as the `pageBuilder` for hierarchical/detail routes inside the
/// ShellRoute. The ShellLayout (AppBar, sidebar, bottom nav) stays static —
/// only the body content animates.
CustomTransitionPage<void> buildPushTransitionPage({
  required LocalKey key,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: key,
    child: child,
    transitionDuration: kIsWeb
        ? const Duration(milliseconds: 200)
        : const Duration(milliseconds: 300),
    reverseTransitionDuration: kIsWeb
        ? const Duration(milliseconds: 200)
        : const Duration(milliseconds: 300),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      if (kIsWeb) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.05, 0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOut,
            )),
            child: child,
          ),
        );
      }
      return CupertinoPageTransition(
        primaryRouteAnimation: animation,
        secondaryRouteAnimation: secondaryAnimation,
        linearTransition: false,
        child: child,
      );
    },
  );
}

/// Convenience: wraps a route [builder] so it produces a
/// [CustomTransitionPage] with the standard push transition.
///
/// Use in place of `builder:` on a GoRoute:
/// ```dart
/// GoRoute(
///   path: AppRoutes.emailView,
///   pageBuilder: pushPageBuilder((context, goState) {
///     return MyWidget(...);
///   }),
/// )
/// ```
Page<void> Function(BuildContext, GoRouterState) pushPageBuilder(
  Widget Function(BuildContext, GoRouterState) builder,
) {
  return (context, state) => buildPushTransitionPage(
        key: state.pageKey,
        child: builder(context, state),
      );
}
