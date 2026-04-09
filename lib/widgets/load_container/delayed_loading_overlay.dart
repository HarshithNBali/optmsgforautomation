import 'dart:async';

import 'package:flutter/material.dart';
import 'package:optmsg/constant/app_colors_extension.dart';
import 'package:optmsg/constant/common_constant.dart';

import 'load_indicator.dart';

/// Overlay spinner that only appears after a [delay] (default 600ms) to prevent
/// the spinner from flashing on-screen for fast operations.
///
/// Usage:
/// ```dart
/// DelayedLoadingOverlay(
///   isLoading: state.isLoading,
///   child: actualContent,
/// )
/// ```
class DelayedLoadingOverlay extends StatefulWidget {
  final bool isLoading;
  final Widget child;
  final Duration delay;

  const DelayedLoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.delay = const Duration(milliseconds: duration),
  });

  @override
  State<DelayedLoadingOverlay> createState() => _DelayedLoadingOverlayState();
}

class _DelayedLoadingOverlayState extends State<DelayedLoadingOverlay> {
  Timer? _timer;
  bool _showSpinner = false;

  @override
  void initState() {
    super.initState();
    if (widget.isLoading) {
      _timer = Timer(widget.delay, () {
        if (mounted) setState(() => _showSpinner = true);
      });
    }
  }

  @override
  void didUpdateWidget(DelayedLoadingOverlay old) {
    super.didUpdateWidget(old);
    if (widget.isLoading && !old.isLoading) {
      _timer?.cancel();
      _timer = Timer(widget.delay, () {
        if (mounted) setState(() => _showSpinner = true);
      });
    } else if (!widget.isLoading && old.isLoading) {
      _timer?.cancel();
      if (_showSpinner) setState(() => _showSpinner = false);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_showSpinner) ...[
          ModalBarrier(dismissible: false, color: Theme.of(context).extension<AppColorsExtension>()?.overlayBarrier ?? const Color(0x80FFFFFF)),
          const Center(child: LoaderIndicator()),
        ],
      ],
    );
  }
}
