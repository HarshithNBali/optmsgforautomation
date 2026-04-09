import 'package:optmsg/common/responsive/responsive.dart';
import 'package:optmsg/constant/string_constant.dart';
import 'package:optmsg/constant/styles.dart';
import 'package:optmsg/constant/auth_styles.dart';
import 'package:optmsg/screens/auth/setupProfile/widgets/setup_profile_form_widget.dart';
import 'package:optmsg/services/common_service.dart';
import 'package:optmsg/services/form_validation.dart';
import 'package:optmsg/widgets/logo.dart';
import 'package:optmsg/widgets/web_background.dart';
import 'package:optmsg/widgets/web_container.dart';
import 'package:optmsg/widgets/web_login_content.dart';
import 'package:flutter/material.dart';

class SetupProfileDesktopLayout extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController dobController;
  final FormValidationService formValidation;
  final VoidCallback onSubmit;
  final VoidCallback onLogin;
  final bool? readOnly;

  const SetupProfileDesktopLayout(
      {super.key,
      required this.formKey,
      required this.firstNameController,
      required this.lastNameController,
      required this.dobController,
      required this.formValidation,
      required this.onSubmit,
      required this.onLogin,
      this.readOnly});

  @override
  Widget build(BuildContext context) {
    final screenHeight = AppBreakpoints.screenHeight(context);
    final screenWidth = AppBreakpoints.screenWidth(context);
    final isDesktop = AppBreakpoints.isDesktopLayout(context);

    return WebBackground(
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  children: [
                    _vSpace(screenHeight, 0.03),
                    _logoSection(context, screenHeight),
                    _vSpace(screenHeight, 0.05),
                    _contentSection(
                      context,
                      screenHeight,
                      screenWidth,
                      isDesktop,
                    ),
                    _copyright(context),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // -------------------- SECTIONS --------------------

  Widget _logoSection(BuildContext context, double screenHeight) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        LogoWithSlogan(sloganStyle: AuthStyles.authSlogan(context)),
        SizedBox(height: screenHeight * 0.05),
      ],
    );
  }

  Widget _contentSection(
    BuildContext context,
    double screenHeight,
    double screenWidth,
    bool isDesktop,
  ) {
    return Container(
      constraints: BoxConstraints(minHeight: screenHeight * 0.78),
      child: Wrap(
        alignment: WrapAlignment.center,
        children: [
          if (isDesktop) const StaticContentWidget(),
          if (isDesktop) SizedBox(width: screenWidth * 0.06),
          _formCard(context, screenHeight),
        ],
      ),
    );
  }

  Widget _formCard(BuildContext context, double screenHeight) {
    return TransparentContainer(
      height: 510,
      width: AppBreakpoints.authFormWidthMedium,
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          children: [
            _header(context, screenHeight),
            _vSpace(screenHeight, 0.03),
            Expanded(
              child: SetupProfileFormWidget(
                formKey: formKey,
                firstNameController: firstNameController,
                lastNameController: lastNameController,
                dobController: dobController,
                formValidation: formValidation,
                onSubmit: onSubmit,
                onLogin: onLogin,
                readOnly: readOnly ?? false,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -------------------- HEADER --------------------

  Widget _header(BuildContext context, double screenHeight) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                setupProfile,
                style: AuthStyles.heroTitle(context),
              ),
              _vSpace(screenHeight, 0.01),
              Text(
                setupProfileText,
                style: AuthStyles.subTitle(context),
              ),
            ],
          ),
        ),
        const _StepBadge(stepText: 'Step 2/4'),
      ],
    );
  }

  // -------------------- FOOTER --------------------

  Widget _copyright(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Wrap(
        alignment: WrapAlignment.center,
        children: [
          Text(
            CommonService().getCopyrightNotice(),
            textAlign: TextAlign.center,
            style: AuthStyles.copyright(context),
          ),
        ],
      ),
    );
  }

  // -------------------- HELPERS --------------------

  Widget _vSpace(double height, double factor) {
    return SizedBox(height: height * factor);
  }
}

// -------------------- SMALL REUSABLE WIDGETS --------------------

class _StepBadge extends StatelessWidget {
  final String stepText;

  const _StepBadge({required this.stepText});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: context.appColors.stepBadgeBg,
        borderRadius: BorderRadius.circular(AppStyles.radiusXXL),
      ),
      child: Text(stepText, style: AuthStyles.copyright(context)),
    );
  }
}
