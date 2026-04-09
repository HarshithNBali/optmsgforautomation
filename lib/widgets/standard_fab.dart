import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:optmsg/constant/styles.dart';
import 'package:optmsg/services/fab_toast_coordinator.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

/// Standardized floating action button used across the app.
///
/// Renders a 40x40 rounded-square button with a white SVG icon on the
/// primary theme color. Automatically animates upward when a toast is
/// visible to avoid being covered.
///
/// Use [StandardFab] inside a [Stack] (list screens with bottom nav).
/// Use [StandardFab.button] as a Scaffold [floatingActionButton] (pushed
/// screens without bottom nav) — Scaffold handles safe-area positioning.
class StandardFab extends StatelessWidget {
  final String iconAsset;
  final VoidCallback onPressed;
  final String heroTag;
  final bool visible;

  const StandardFab({
    super.key,
    required this.iconAsset,
    required this.onPressed,
    required this.heroTag,
    this.visible = true,
  });

  /// Builds just the visual button — no positioning.
  ///
  /// Use this as `Scaffold.floatingActionButton` on pushed screens where
  /// the Scaffold handles bottom-safe-area placement automatically.
  static Widget button({
    required String iconAsset,
    required VoidCallback onPressed,
  }) {
    return _FabButton(iconAsset: iconAsset, onPressed: onPressed);
  }

  /// Toast height (~48px) + gap (12px) to push FAB above a visible toast.
  static const double _toastOffset = 60.0;

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();

    return ValueListenableBuilder<bool>(
      valueListenable: FabToastCoordinator.isToastVisible,
      builder: (context, toastShowing, child) {
        return AnimatedPositioned(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          right: AppStyles.fabInset,
          bottom: toastShowing
              ? AppStyles.fabInset + _toastOffset
              : AppStyles.fabInset,
          child: child!,
        );
      },
      child: _FabButton(iconAsset: iconAsset, onPressed: onPressed),
    );
  }
}

class _FabButton extends StatelessWidget {
  final String iconAsset;
  final VoidCallback onPressed;

  const _FabButton({required this.iconAsset, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final button = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppStyles.fabRadius),
        child: Container(
          width: AppStyles.fabSize,
          height: AppStyles.fabSize,
          decoration: BoxDecoration(
            color: cs.primary,
            borderRadius: BorderRadius.circular(AppStyles.fabRadius),
            boxShadow: [
              BoxShadow(
                color: cs.shadow.withValues(alpha: isDark ? 0.30 : 0.15),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
              BoxShadow(
                color: cs.shadow.withValues(alpha: isDark ? 0.20 : 0.10),
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Center(
            child: SvgPicture.asset(
              iconAsset,
              height: AppStyles.fabIconSize,
              width: AppStyles.fabIconSize,
              colorFilter:
                  ColorFilter.mode(cs.onPrimary, BlendMode.srcIn),
            ),
          ),
        ),
      ),
    );

    if (kIsWeb || (!kIsWeb && Platform.isAndroid)) {
      return PointerInterceptor(child: button);
    }
    return button;
  }
}
