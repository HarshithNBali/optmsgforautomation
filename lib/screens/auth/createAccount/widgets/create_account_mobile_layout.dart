import 'package:optmsg/constant/img_path.dart';
import 'package:optmsg/constant/string_constant.dart';
import 'package:optmsg/constant/styles.dart';
import 'package:optmsg/constant/auth_styles.dart';
import 'package:optmsg/services/common_service.dart';
import 'package:optmsg/screens/auth/createAccount/widgets/create_account_form_widget.dart';
import 'package:optmsg/services/form_validation.dart';
import 'package:optmsg/widgets/gradient_background.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CreateAccountMobileLayout extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController userNameController;
  final TextEditingController phoneController;
  final FormValidationService formValidation;
  final bool isUserNameAvailable;
  final bool acceptTerms;
  final bool acceptCondition;
  final VoidCallback onSubmit;
  final VoidCallback onLogin;
  final VoidCallback onBack;
  final VoidCallback onUserNameChanged;
  final ValueChanged<bool?> onAcceptTermsChanged;
  final ValueChanged<bool?> onAcceptConditionChanged;
  final bool isLoading;

  const CreateAccountMobileLayout({
    super.key,
    required this.formKey,
    required this.userNameController,
    required this.phoneController,
    required this.formValidation,
    required this.isUserNameAvailable,
    required this.acceptTerms,
    required this.acceptCondition,
    required this.onSubmit,
    required this.onLogin,
    required this.onBack,
    required this.onUserNameChanged,
    required this.onAcceptTermsChanged,
    required this.onAcceptConditionChanged,
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
            _buildHeader(context),
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 40.0, vertical: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(svgIcon, height: 40),
                          const SizedBox(height: 8),
                          _buildTitle(context),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppStyles.space32),
                    Expanded(
                      flex: 1,
                      child: SingleChildScrollView(
                        child: CreateAccountFormWidget(
                          formKey: formKey,
                          userNameController: userNameController,
                          phoneController: phoneController,
                          formValidation: formValidation,
                          isUserNameAvailable: isUserNameAvailable,
                          acceptTerms: acceptTerms,
                          acceptCondition: acceptCondition,
                          onSubmit: onSubmit,
                          onLogin: onLogin,
                          onUserNameChanged: onUserNameChanged,
                          onAcceptTermsChanged: onAcceptTermsChanged,
                          onAcceptConditionChanged: onAcceptConditionChanged,
                          isLoading: isLoading,
                        ),
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
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final availableHeight = constraints.maxHeight;
                  final iconSize = (availableHeight * 0.06).clamp(30.0, 60.0);
                  final spacing = (availableHeight * 0.012).clamp(6.0, 12.0);

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        SvgPicture.asset(svgIcon, height: iconSize),
                        _buildTitle(context),
                        CreateAccountFormWidget(
                          formKey: formKey,
                          userNameController: userNameController,
                          phoneController: phoneController,
                          formValidation: formValidation,
                          isUserNameAvailable: isUserNameAvailable,
                          acceptTerms: acceptTerms,
                          acceptCondition: acceptCondition,
                          onSubmit: onSubmit,
                          onLogin: onLogin,
                          onUserNameChanged: onUserNameChanged,
                          onAcceptTermsChanged: onAcceptTermsChanged,
                          onAcceptConditionChanged: onAcceptConditionChanged,
                          spacing: spacing,
                          isLoading: isLoading,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            _buildCopyright(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppStyles.space16),
      child: TextButton.icon(
        onPressed: onBack,
        icon: SvgPicture.asset(svgArrowBack, height: 30, width: 32),
        label: Text(back, style: AuthStyles.inputText(context)),
        style: TextButton.styleFrom(
          minimumSize: const Size(0, 48),
          padding: EdgeInsets.zero,
        ),
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Column(
      children: [
        Text(signUp, style: AuthStyles.heroTitle(context)),
        const SizedBox(height: AppStyles.space4),
        Text(signUpText,
            style: AuthStyles.subTitle(context), textAlign: TextAlign.center),
      ],
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
