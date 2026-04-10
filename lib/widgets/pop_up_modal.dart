import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:optmsg/widgets/text_form_field.dart';
import 'package:optmsg/constant/styles.dart';
import 'package:optmsg/constant/app_typography.dart';
import 'package:optmsg/common/responsive/responsive.dart';
import 'package:optmsg/widgets/footer_button.dart';

class CustomPopupModal extends StatelessWidget {
  final String? icon;
  final String title;
  final String subtitle;
  final VoidCallback onPressedButton1;
  final VoidCallback onPressedButton2;
  final String textButton1;
  final String textButton2;
  final SimpleTextFormField? formField1;
  final String? testId;

  const CustomPopupModal({
    super.key,
    this.icon,
    this.title = "",
    this.subtitle = "",
    required this.onPressedButton1,
    required this.onPressedButton2,
    required this.textButton1,
    required this.textButton2,
    this.formField1,
    this.testId,
  });

  @override

  /// Returns a [Dialog] widget with a rounded rectangle shape and transparent
  /// background. The child of the [Dialog] is a [contentBox] widget.
  ///
  /// The [contentBox] widget is the content of the dialog. It is a widget that
  /// displays a title, a subtitle, a text field, and two buttons.
  ///
  Widget build(BuildContext context) {
    return Dialog(
      key: testId != null ? Key(testId!) : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppStyles.radiusXXL),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: contentBox(context),
    );
  }

  /// Returns a [Center] widget with a [Container] child that contains all the elements
  /// of the popup dialog. The width of the container is constrained to be 600px or
  /// 90% of the screen width, whichever is smaller. The container has a rounded
  /// rectangle shape, a white background, and a shadow. The child of the container
  /// is a [SingleChildScrollView] that contains a [Column] of widgets. The column
  /// includes an optional icon, an optional title, an optional subtitle, an optional
  /// text field, and two buttons. The text field is the provided [SimpleTextFormField].
  /// The buttons are wrapped in a [FooterButton] widget.
  Widget contentBox(BuildContext context) {
    final double screenWidth = AppBreakpoints.screenWidth(context);
    final double dialogWidth =
        AppBreakpoints.isMobile(screenWidth) ? screenWidth * 0.9 : 600;

    return Center(
      child: Container(
        width: dialogWidth,
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(top: 30),
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(AppStyles.radiusXXL),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.26),
              offset: const Offset(0, 10),
              blurRadius: 10,
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (icon != null)
                SvgPicture.asset(
                  icon!,
                  width: screenWidth * 0.12,
                  height: AppBreakpoints.screenHeight(context) * 0.12,
                ),
              SizedBox(height: AppBreakpoints.screenHeight(context) * 0.03),
              if (title.isNotEmpty)
                Text(
                  title,
                  style: AppTypography.popUpTitle(context),
                  textAlign: TextAlign.center,
                ),
              if (subtitle.isNotEmpty)
                SizedBox(height: AppBreakpoints.screenHeight(context) * 0.02),
              if (subtitle.isNotEmpty)
                Text(
                  subtitle,
                  style: AppTypography.slogan(context),
                  textAlign: TextAlign.center,
                ),
              if (formField1 != null)
                SizedBox(
                    height: AppBreakpoints.screenHeight(context) *
                        0.02), // Add some space
              ?formField1,
              // Include the provided TextFormField
              SizedBox(height: AppBreakpoints.screenHeight(context) * 0.03),
              FooterButton(
                  testId: testId != null ? '${testId}_footer' : null,
                  button1Color: context.colors.surface,
                  button1TextColor: context.colors.onSurface,
                  button1BorderColor: context.colors.outlineVariant,
                  button2Color: context.appColors.accent,
                  button2TextColor: context.colors.onPrimary,
                  button2BorderColor: Colors.transparent,
                  onPressedButton1: onPressedButton1,
                  onPressedButton2: onPressedButton2,
                  textButton1: textButton1,
                  textButton2: textButton2)
            ],
          ),
        ),
      ),
    );
  }
}
