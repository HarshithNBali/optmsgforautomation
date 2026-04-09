import 'package:flutter/material.dart';

class DashedBorder extends StatelessWidget {
  final double height;
  final double width;
  final Color? color;

  const DashedBorder({
    super.key,
    required this.height,
    required this.width,
    this.color,
  });

  @override

  /// Builds a dashed border with a specified height and width.
  ///
  /// The border is a [CustomPaint] widget that uses a [DashedBorderPainter] to
  /// draw the dashed border. The color of the border is specified by the [color]
  /// parameter.
  ///
  /// The height and width of the border are specified by the [height] and [width]
  /// parameters, respectively.
  Widget build(BuildContext context) {
    final resolvedColor = color ?? Theme.of(context).colorScheme.outlineVariant;
    return SizedBox(
      height: height,
      width: width,
      child: CustomPaint(
        painter: DashedBorderPainter(color: resolvedColor),
      ),
    );
  }
}

class DashedBorderPainter extends CustomPainter {
  final Color color;

  DashedBorderPainter({required this.color});

  @override

  /// Paints a dashed line along the horizontal center of the [canvas].
  ///
  /// The line is drawn with the specified [color] and has a stroke width of 1.0.
  ///
  /// The dashes are drawn every [dashWidth] pixels, with a space of [dashSpace]
  /// pixels between each dash. The dashed line is drawn from the left edge of the
  /// [canvas] to the right edge.
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    const double dashWidth = 5.0;
    const double dashSpace = 5.0;
    double startX = 0.0;

    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, size.height / 2),
        Offset(startX + dashWidth, size.height / 2),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override

  /// Determines whether the [paint] method should be called again
  /// due to changes in the state of the [CustomPainter].
  ///
  /// Returns `true` if the new instance of the painter should repaint,
  /// otherwise returns `false`. This implementation always returns `false`
  /// since there are no dynamic properties that affect the painting logic.

  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
