import 'package:optmsg/common/responsive/responsive.dart';
import 'package:optmsg/constant/img_path.dart';
import 'package:optmsg/constant/string_constant.dart';
import 'package:optmsg/constant/styles.dart';
import 'package:optmsg/constant/auth_styles.dart';
import 'package:optmsg/widgets/button_form_field.dart';
import 'package:optmsg/widgets/text_form_field.dart' show ClickableText;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pinput/pinput.dart';

class OtpFormWidget extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController otpController;
  final FocusNode focusNode;
  final String formattedPhone;
  final VoidCallback onSubmit;
  final VoidCallback onResend;
  final ValueChanged<String>? onOtpChanged;
  final bool showIcon;
  final bool isLoading;
  final int resendCooldownSeconds;

  const OtpFormWidget({
    super.key,
    required this.formKey,
    required this.otpController,
    required this.focusNode,
    required this.formattedPhone,
    required this.onSubmit,
    required this.onResend,
    this.onOtpChanged,
    this.showIcon = true,
    this.isLoading = false,
    this.resendCooldownSeconds = 0,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final orientation = MediaQuery.of(context).orientation;
    final isLandscape = orientation == Orientation.landscape;
    final isMobile = AppBreakpoints.isMobile(screenSize.width);
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;
    final spacing = (screenHeight * 0.015).clamp(8.0, 15.0);

    return Form(
      key: formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            SvgPicture.asset(svgIcon,
                height: (screenHeight * 0.08).clamp(40.0, 70.0)),
            SizedBox(height: spacing),
          ],
          Text(verifyAccount, style: AuthStyles.heroTitle(context)),
          SizedBox(height: spacing),
          Text(
            verifyText,
            textAlign: TextAlign.center,
            style: AuthStyles.subTitle(context),
          ),
          SizedBox(height: spacing * 0.3),
          Text(
            formattedPhone,
            style: AuthStyles.subTitle(context),
          ),
          SizedBox(height: spacing * 1.5),
          _buildPinInput(context, isMobile, screenWidth, isLandscape),
          SizedBox(height: spacing * 1.5),
          ClickableText(
            firstText: notReceived,
            firstTextColor: AuthStyles.textSecondary,
            secondText: resendCooldownSeconds > 0
                ? ' Resend in ${resendCooldownSeconds}s'
                : ' $requestAgain',
            secondTextColor: resendCooldownSeconds > 0
                ? AuthStyles.textSecondary
                : AuthStyles.textPrimary,
            onTap: resendCooldownSeconds > 0 ? () {} : onResend,
          ),
          SizedBox(height: spacing * 2),
          CustomGradientButton(
            text: submit,
            onPressed: isLoading ? null : onSubmit,
            textStyle: AuthStyles.authButtonText(context),
          ),
        ],
      ),
    );
  }

  Widget _buildPinInput(BuildContext context, bool isMobile, double screenWidth, bool isLandscape) {
    // Calculate available width considering container padding
    // In landscape mobile, container is typically 50-60% of screen width
    final containerWidth = isLandscape && isMobile
        ? screenWidth * 0.5 - 48 // Account for container padding
        : screenWidth - 48;

    // Calculate pin width based on available space
    // 6 pins + 5 gaps (8px each) = need to fit in containerWidth
    const int pinCount = 6;
    const double gapWidth = 8.0;
    const double totalGaps = (pinCount - 1) * gapWidth;

    double pinWidth;
    if (isMobile) {
      if (isLandscape) {
        // In landscape, calculate based on available container width
        pinWidth = ((containerWidth - totalGaps) / pinCount).clamp(36.0, 48.0);
      } else {
        pinWidth = screenWidth * 0.12;
      }
    } else {
      pinWidth = 56.0;
    }

    final pinHeight = isLandscape && isMobile ? 42.0 : 48.0;
    final fontSize = isLandscape && isMobile ? 16.0 : 18.0;

    return Pinput(
      controller: otpController,
      length: 6,
      focusNode: focusNode,
      autofocus: true,
      onChanged: onOtpChanged,
      onCompleted: (pin) {
        if (!isLoading && pin.length == 6 && RegExp(r'^\d{6}$').hasMatch(pin)) {
          onSubmit();
        }
      },
      separatorBuilder: (index) => const SizedBox(width: gapWidth),
      defaultPinTheme: PinTheme(
        width: pinWidth,
        height: pinHeight,
        textStyle: AuthStyles.pinDigit(context).copyWith(fontSize: fontSize),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(AppStyles.radiusM),
          border: Border.all(color: AuthStyles.textPrimary.withValues(alpha: 0.5)),
        ),
      ),
      mainAxisAlignment: MainAxisAlignment.center,
      pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
      showCursor: true,
    );
  }
}
