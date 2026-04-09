import 'package:optmsg/common/responsive/responsive.dart';
import 'package:optmsg/constant/string_constant.dart';
import 'package:optmsg/constant/styles.dart';
import 'package:optmsg/constant/auth_styles.dart';
import 'package:optmsg/screens/auth/createAccount/widgets/create_account_form_widget.dart';
import 'package:optmsg/services/common_service.dart';
import 'package:optmsg/services/form_validation.dart';
import 'package:optmsg/widgets/logo.dart';
import 'package:optmsg/widgets/web_background.dart';
import 'package:optmsg/widgets/web_container.dart';
import 'package:optmsg/widgets/web_login_content.dart';
import 'package:flutter/material.dart';

class CreateAccountDesktopLayout extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController userNameController;
  final TextEditingController phoneController;
  final FormValidationService formValidation;
  final bool isUserNameAvailable;
  final bool acceptTerms;
  final bool acceptCondition;
  final VoidCallback onSubmit;
  final VoidCallback onLogin;
  final VoidCallback onUserNameChanged;
  final ValueChanged<bool?> onAcceptTermsChanged;
  final ValueChanged<bool?> onAcceptConditionChanged;
  final bool isLoading;

  const CreateAccountDesktopLayout({
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
    required this.onUserNameChanged,
    required this.onAcceptTermsChanged,
    required this.onAcceptConditionChanged,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = AppBreakpoints.screenWidth(context);
    final isDesktop = AppBreakpoints.isDesktopLayout(context);

    return WebBackground(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    const SizedBox(height: AppStyles.space32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [LogoWithSlogan(sloganStyle: AuthStyles.authSlogan(context)), const SizedBox(height: 50)],
                    ),
                    const SizedBox(height: 50),
                    Container(
                      constraints: const BoxConstraints(minHeight: 78),
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        children: [
                          if (isDesktop)
                            const Column(children: [StaticContentWidget()]),
                          if (isDesktop) SizedBox(width: screenWidth * 0.060),
                          _buildFormCard(context, screenWidth),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          _buildCopyright(context),
        ],
      ),
    );
  }

  Widget _buildFormCard(BuildContext context, double screenWidth) {
    return Column(
      children: [
        TransparentContainer(
          height: screenWidth < AppBreakpoints.authFormWidthNarrow ? 715 : 615,
          width: AppBreakpoints.authFormWidthNarrow,
          child: Padding(
            padding: const EdgeInsets.all(AppStyles.space32),
            child: Column(
              children: [
                _buildHeader(context),
                const SizedBox(height: AppStyles.space32),
                Expanded(
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
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(signUp,
                  style: AuthStyles.heroTitle(context), textAlign: TextAlign.left),
              const SizedBox(height: AppStyles.space4),
              Text(signUpText,
                  style: AuthStyles.subTitle(context), textAlign: TextAlign.left),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
          decoration: BoxDecoration(
            color: context.appColors.stepBadgeBg,
            borderRadius: BorderRadius.circular(AppStyles.radiusXXL),
          ),
          child: Text('Step 1/4', style: AuthStyles.copyright(context)),
        ),
      ],
    );
  }

  Widget _buildCopyright(BuildContext context) {
    return Padding(
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
    );
  }
}
