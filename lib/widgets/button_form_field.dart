import 'package:flutter/material.dart';
import 'package:optmsg/constant/styles.dart';
import 'package:optmsg/constant/app_typography.dart';
import 'package:optmsg/common/responsive/responsive.dart';

class CustomGradientButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Widget? leadingIcon;
  final bool isLoading;
  final TextStyle? textStyle;

  const CustomGradientButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.leadingIcon,
    this.isLoading = false,
    this.textStyle,
  });

  @override

  /// Builds a full width button with a gradient background.
  ///
  /// The button is a [ClipRRect] with a [BorderRadius.circular] of 12.0.
  /// The child of the [ClipRRect] is a [Container] with a [LinearGradient] decoration.
  /// The gradient is defined by two colors: [Color(0xFFFC976D)] and [Color(0xFFFD5D1A)].
  /// The button is an [ElevatedButton] with a transparent background and elevation of 0.
  /// The shape of the button is a [RoundedRectangleBorder] with a [BorderRadius.circular] of 2.0.
  /// The child of the button is a [Container] with a black text.
  ///
  /// The [onPressed] callback is called when the button is tapped.
  /// The [text] is the text of the button.
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 1.0,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppStyles.radiusXXL),
        child: Container(
          decoration: BoxDecoration(
            gradient: context.appColors.accentGradient,
          ),
          child: ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppStyles.radiusXXL),
              ),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: Center(
                // child: Text(
                //   text,
                //   style: AppTypography.button(context),
                // ),
                child: isLoading
                    ? SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      )
                    : leadingIcon == null
                    ? Text(
                        text,
                        style: textStyle ?? AppTypography.button(context),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: leadingIcon!,
                          ),
                          Flexible(
                            child: Text(
                              text,
                              style: textStyle ?? AppTypography.button(context),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override

  /// Builds a full width button with a gradient background.
  ///
  /// The button is a [ClipRRect] with a [BorderRadius.circular] of 5.0.
  /// The child of the [ClipRRect] is a [Container] with a [LinearGradient] decoration.
  /// The gradient is defined by two colors: [Color(0xFFE3E7E9)] and [Color(0xFFE3E7E9)].
  /// The button is an [ElevatedButton] with a transparent background and elevation of 0.
  /// The shape of the button is a [RoundedRectangleBorder] with a [BorderRadius.circular] of 2.0.
  /// The child of the button is a [Container] with a black text.
  ///
  /// The [onPressed] callback is called when the button is tapped.
  /// The [text] is the text of the button.
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 1.0,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppStyles.radiusS),
        child: Container(
          decoration: BoxDecoration(
            gradient: context.appColors.disabledGradient,
          ),
          child: ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppStyles.radiusXS),
              ),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 15.0),
              child: Center(
                child: Text(
                  text,
                  style: AppTypography.titleLarge(context).copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
