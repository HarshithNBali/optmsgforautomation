import 'package:optmsg/common/responsive/responsive.dart';
import 'package:optmsg/constant/string_constant.dart';
import 'package:optmsg/constant/auth_styles.dart';
import 'package:optmsg/screens/auth/login/widgets/login_form_widget.dart';
import 'package:optmsg/services/common_service.dart';
import 'package:optmsg/services/form_validation.dart';
import 'package:optmsg/widgets/logo.dart';
import 'package:optmsg/widgets/text_form_field.dart' show ClickableText;
import 'package:optmsg/widgets/web_background.dart';
import 'package:optmsg/widgets/web_container.dart';
import 'package:optmsg/widgets/web_login_content.dart';
import 'package:flutter/material.dart';

class LoginDesktopLayout extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController userNameController;
  final FormValidationService formValidation;
  final VoidCallback onLogin;
  final VoidCallback onForgot;
  final VoidCallback onRegister;
  final bool isHovered;
  final ValueChanged<bool> onHoverChanged;
  final bool isLoading;

  const LoginDesktopLayout({
    super.key,
    required this.formKey,
    required this.userNameController,
    required this.formValidation,
    required this.onLogin,
    required this.onForgot,
    required this.onRegister,
    required this.isHovered,
    required this.onHoverChanged,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = AppBreakpoints.screenHeight(context);
    final screenWidth = AppBreakpoints.screenWidth(context);
    final isDesktop = AppBreakpoints.isDesktopLayout(context);

    return WebBackground(
      child: Padding(
        padding: const EdgeInsets.all(3.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.only(top: 30.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [LogoWithSlogan(sloganStyle: AuthStyles.authSlogan(context))],
                      ),
                      SizedBox(height: screenHeight * 0.050),
                      Wrap(
                        alignment: WrapAlignment.center,
                        children: [
                          if (isDesktop)
                            const Column(
                              children: [StaticContentWidget()],
                            ),
                          if (isDesktop) SizedBox(width: screenWidth * 0.080),
                          _buildLoginCard(context, screenHeight),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Wrap(
                alignment: WrapAlignment.center,
                children: [
                  Text(
                    textAlign: TextAlign.center,
                    CommonService().getCopyrightNotice(),
                    style: AuthStyles.copyright(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginCard(BuildContext context, double screenHeight) {
    return Column(
      children: [
        TransparentContainer(
          height: 430,
          width: AppBreakpoints.authFormWidthWide,
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              children: [
                Text(
                  login,
                  style: AuthStyles.heroTitle(context),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: screenHeight * 0.010),
                Text(
                  loginText,
                  style: AuthStyles.subTitle(context),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: screenHeight * 0.030),
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          child: LoginFormWidget(
                            formKey: formKey,
                            userNameController: userNameController,
                            formValidation: formValidation,
                            onLogin: onLogin,
                            onForgot: onForgot,
                            spacing: screenHeight * 0.015,
                            showHoverEffect: true,
                            isHovered: isHovered,
                            onHoverChanged: onHoverChanged,
                            isLoading: isLoading,
                          ),
                        ),
                      ),
                      ClickableText(
                        firstText: noAccount,
                        firstTextColor: AuthStyles.textSecondary,
                        secondText: " Create Account",
                        secondTextColor: AuthStyles.textAccent,
                        onTap: onRegister,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
