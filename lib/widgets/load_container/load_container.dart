import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:optmsg/constant/common_constant.dart';

import 'load_indicator.dart';
import 'loader_provider.dart';

class LoaderContainer extends ConsumerStatefulWidget {
  final Widget child;

  const LoaderContainer({
    super.key,
    required this.child,
  });

  @override
  ConsumerState<LoaderContainer> createState() => _LoaderContainerState();
}

class _LoaderContainerState extends ConsumerState<LoaderContainer> {
  Timer? _timer;
  bool _showSpinner = false;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<bool>(loaderProvider, (prev, next) {
      if (next && !(prev ?? false)) {
        _timer?.cancel();
        _timer = Timer(const Duration(milliseconds: duration), () {
          if (mounted) setState(() => _showSpinner = true);
        });
      } else if (!next) {
        _timer?.cancel();
        if (_showSpinner) setState(() => _showSpinner = false);
      }
    });

    return Stack(
      children: [
        widget.child,
        if (_showSpinner) ...[
          Positioned.fill(
            child: Container(
              color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.5),
              child: const Center(child: LoaderIndicator()),
            ),
          ),
        ]
      ],
    );
  }
}
