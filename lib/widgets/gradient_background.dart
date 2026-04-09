import 'package:flutter/material.dart';
import 'package:optmsg/common/responsive/responsive.dart';
import 'package:optmsg/constant/styles.dart';

class GradientBackground extends StatelessWidget {
  final Widget child;
  final bool? bottomSafeArea;
  const GradientBackground({super.key, required this.child, this.bottomSafeArea});

  @override
  Widget build(BuildContext context) {
    final gradient = context.appColors.appBarGradient ?? AppStyles.appBarGradient;
    return Container(
      decoration: BoxDecoration(gradient: gradient),
      child: SafeArea(
        bottom: bottomSafeArea != null ? false : true,
        child: child,
      ),
    );
  }
}
