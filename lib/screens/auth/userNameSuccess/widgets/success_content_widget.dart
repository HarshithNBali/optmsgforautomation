import 'package:optmsg/common/responsive/responsive.dart';
import 'package:optmsg/constant/img_path.dart';
import 'package:optmsg/constant/string_constant.dart';
import 'package:optmsg/constant/auth_styles.dart';
import 'package:optmsg/widgets/button_form_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SuccessContentWidget extends StatelessWidget {
  final VoidCallback onBackToLogin;

  const SuccessContentWidget({
    super.key,
    required this.onBackToLogin,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = AppBreakpoints.screenHeight(context);
    final screenWidth = AppBreakpoints.screenWidth(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SvgPicture.asset(
          svgSuccess,
          height: screenHeight * 0.140,
          width: screenWidth * 0.140,
        ),
        SizedBox(height: screenHeight * 0.015),
        Text(userNameSent, style: AuthStyles.heroTitle(context)),
        SizedBox(height: screenHeight * 0.015),
        Text(
          userNameText,
          style: AuthStyles.subTitle(context),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: screenHeight * 0.030),
        CustomGradientButton(
          testId: 'username_success_login_button',
          onPressed: onBackToLogin,
          text: backToLogin,
          textStyle: AuthStyles.authButtonText(context),
        ),
      ],
    );
  }
}
