import 'package:flutter/material.dart';
import 'package:optmsg/constant/app_typography.dart';

class FooterButton extends StatelessWidget {
  final Color button1Color;
  final Color button1TextColor;
  final Color button1BorderColor;
  final Color button2Color;
  final Color button2TextColor;
  final Color button2BorderColor;
  final double borderRadius;
  final double buttonHeight;
  final double spaceBetweenButtons;
  final VoidCallback onPressedButton1;
  final VoidCallback onPressedButton2;
  final String textButton1;
  final String textButton2;
  final String? testId;

  const FooterButton({
    super.key,
    required this.button1Color,
    required this.button1TextColor,
    required this.button1BorderColor,
    required this.button2Color,
    required this.button2TextColor,
    required this.button2BorderColor,
    this.borderRadius = 12.0,
    this.buttonHeight = 40.0, // Customize button height
    this.spaceBetweenButtons = 20.0, // Add space between buttons
    required this.onPressedButton1,
    required this.onPressedButton2,
    required this.textButton1,
    required this.textButton2,
    this.testId,
  });

  @override

  /// Builds a row containing two customizable buttons.
  ///
  /// This widget creates a row with two buttons that have customizable colors,
  /// text, borders, and actions. Each button is wrapped in a [GestureDetector]
  /// to handle tap events and is styled with a [Container] using the specified
  /// colors and border radius. The buttons are separated by a [SizedBox] to add
  /// space between them.
  ///
  /// The parameters [button1Color], [button1TextColor], [button1BorderColor],
  /// [button2Color], [button2TextColor], [button2BorderColor], [borderRadius],
  /// [buttonHeight], [spaceBetweenButtons], [onPressedButton1], [onPressedButton2],
  /// [textButton1], and [textButton2] are used to customize the appearance and
  /// behavior of the buttons.
  ///
  /// The [onPressedButton1] and [onPressedButton2] callbacks are triggered when
  /// the respective buttons are tapped.

  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          key: testId != null ? Key('${testId}_button1') : null,
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: onPressedButton1,
              child: Container(
                height: buttonHeight,
                decoration: BoxDecoration(
                  color: button1Color,
                  border: Border.all(color: button1BorderColor),
                  borderRadius: BorderRadius.circular(borderRadius),
                ),
                child: Center(
                  child: Text(
                    textButton1,
                    style: AppTypography.button(context).copyWith(color: button1TextColor),
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: spaceBetweenButtons), // Add space between buttons
        Flexible(
          key: testId != null ? Key('${testId}_button2') : null,
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: onPressedButton2,
              child: Container(
                height: buttonHeight,
                decoration: BoxDecoration(
                  color: button2Color,
                  border: Border.all(color: button2BorderColor),
                  borderRadius: BorderRadius.circular(borderRadius),
                ),
                child: Center(
                  child: Text(
                    textButton2,
                    style: AppTypography.button(context).copyWith(color: button2TextColor),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
