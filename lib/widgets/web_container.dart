import 'package:flutter/material.dart';
import 'package:optmsg/constant/app_colors_extension.dart';
import 'package:optmsg/constant/styles.dart';

class TransparentContainer extends StatelessWidget {
  final double? height;
  final double width;
  final Widget child;

  const TransparentContainer({super.key, this.height, required this.width, required this.child});

  @override

  /// Builds a widget that displays a semi-transparent container with a
  /// rounded corners, a faint grey border and a white child.
  ///
  /// The [height] and [width] parameters control the size of the container.
  /// The [child] parameter is the widget that will be displayed inside the
  /// container.
  ///
  /// This widget is typically used to display a widget with a slight
  /// background color and a border, such as a text field or a button.
  ///
  /// The default border color is grey and the default border width is 0.3.
  /// You can change these values if needed.
  ///
  /// The default background color is white, but you can change it if needed.
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppStyles.radiusS),
        color: Theme.of(context).extension<AppColorsExtension>()?.semiTransparentSurface ?? const Color.fromRGBO(255, 255, 255, 0.1),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
          width: 0.3,
        ),
      ),
      // You can change the color if needed
      child: child,
    );
  }
}
