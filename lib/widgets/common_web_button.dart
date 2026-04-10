import 'package:optmsg/constant/styles.dart';
import 'package:optmsg/constant/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Reusable icon + text button for web primary actions.
class CommonWebButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String? iconAsset;
  final IconData? iconData;
  final EdgeInsetsGeometry padding;
  final double iconSize;
  final double spacing;
  final TextStyle? textStyle;
  final Color backgroundColor;
  final BorderRadius borderRadius;
  final Color iconColor;
  final String? testId;

  const CommonWebButton({
    super.key,
    required this.onPressed,
    this.iconAsset,
    this.iconData,
    required this.label,
    this.onHoverStart,
    this.onHoverEnd,
    this.padding = const EdgeInsets.all(12.0),
    this.iconSize = 20,
    this.spacing = 6,
    this.textStyle,
    this.backgroundColor = AppStyles.clickableTextColor,
    this.borderRadius = const BorderRadius.all(Radius.circular(6)),
    this.iconColor = Colors.white,
    this.testId,
  }) : assert(iconAsset != null || iconData != null,
            'Either iconAsset or iconData must be provided.');

  @override
  Widget build(BuildContext context) {
    final icon = iconData != null
        ? Icon(
            iconData,
            size: iconSize,
            color: iconColor,
          )
        : SvgPicture.asset(
            iconAsset!,
            height: iconSize,
            width: iconSize,
            colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
          );

    final button = ElevatedButton(
      key: testId != null ? Key(testId!) : null,
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all<Color>(backgroundColor),
        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: borderRadius,
          ),
        ),
        padding: WidgetStateProperty.all<EdgeInsetsGeometry>(padding),
      ),
      onPressed: onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon,
          SizedBox(width: spacing),
          Text(label, style: textStyle ?? AppTypography.minMed14White(context).copyWith(color: Colors.white)),
        ],
      ),
    );

    if (onHoverStart == null && onHoverEnd == null) {
      return button;
    }

    return MouseRegion(
      onEnter: onHoverStart == null ? null : (_) => onHoverStart!(),
      onExit: onHoverEnd == null ? null : (_) => onHoverEnd!(),
      child: button,
    );
  }
}
