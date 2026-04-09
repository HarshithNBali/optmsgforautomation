import 'package:optmsg/constant/img_path.dart';
import 'package:optmsg/constant/string_constant.dart';
import 'package:optmsg/constant/styles.dart';
import 'package:optmsg/constant/auth_styles.dart';
import 'package:optmsg/services/common_service.dart';

import 'package:optmsg/screens/auth/login/widgets/login_form_widget.dart';
import 'package:optmsg/services/form_validation.dart';
import 'package:optmsg/widgets/gradient_background.dart';
import 'package:optmsg/widgets/text_form_field.dart' show ClickableText;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LoginMobileLayout extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController userNameController;
  final FormValidationService formValidation;
  final VoidCallback onLogin;
  final VoidCallback onForgot;
  final VoidCallback onRegister;
  final bool isLoading;

  const LoginMobileLayout({
    super.key,
    required this.formKey,
    required this.userNameController,
    required this.formValidation,
    required this.onLogin,
    required this.onForgot,
    required this.onRegister,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;
    final isLandscape = orientation == Orientation.landscape;
    final screenHeight = MediaQuery.of(context).size.height;

    if (isLandscape) {
      return _buildLandscapeLayout(context);
    }
    return _buildPortraitLayout(context, screenHeight);
  }

  Widget _buildLandscapeLayout(BuildContext context) {
    return GradientBackground(
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(svgIcon, height: 50),
                          const SizedBox(height: 8),
                          Text(loginToOptMsg, style: AuthStyles.heroTitle(context)),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppStyles.space32),
                    Expanded(
                      flex: 1,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          LoginFormWidget(
                            formKey: formKey,
                            userNameController: userNameController,
                            formValidation: formValidation,
                            onLogin: onLogin,
                            onForgot: onForgot,
                            spacing: 8.0,
                            isLoading: isLoading,
                          ),
                          const SizedBox(height: AppStyles.space8),
                          ClickableText(
                            firstText: noAccount,
                            firstTextColor: AuthStyles.textSecondary,
                            secondText: " $clickHere",
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
            _buildCopyright(context),
          ],
        ),
      ),
    );
  }

  Widget _buildPortraitLayout(BuildContext context, double screenHeight) {
    return GradientBackground(
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final availableHeight = constraints.maxHeight;
            final iconSize = (availableHeight * 0.1).clamp(40.0, 80.0);
            final spacing = (availableHeight * 0.02).clamp(8.0, 20.0);

            return Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 30.0,
                      vertical: spacing,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        SvgPicture.asset(svgIcon, height: iconSize),
                        Text(loginToOptMsg, style: AuthStyles.heroTitle(context)),
                        LoginFormWidget(
                          formKey: formKey,
                          userNameController: userNameController,
                          formValidation: formValidation,
                          onLogin: onLogin,
                          onForgot: onForgot,
                          spacing: spacing,
                          isLoading: isLoading,
                        ),
                        ClickableText(
                          firstText: noAccount,
                          firstTextColor: AuthStyles.textSecondary,
                          secondText: " $clickHere",
                          secondTextColor: AuthStyles.textAccent,
                          onTap: onRegister,
                        ),
                      ],
                    ),
                  ),
                ),
                _buildCopyright(context),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildCopyright(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        CommonService().getCopyrightNotice(),
        textAlign: TextAlign.center,
        style: AuthStyles.copyright(context),
      ),
    );
  }
}
