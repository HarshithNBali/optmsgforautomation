import 'package:optmsg/common/responsive/responsive.dart';
import 'package:optmsg/constant/app_config.dart';
import 'package:optmsg/constant/img_path.dart';
import 'package:optmsg/constant/string_constant.dart';
import 'package:optmsg/constant/auth_styles.dart';
import 'package:optmsg/services/form_validation.dart';
import 'package:optmsg/widgets/button_form_field.dart';
import 'package:optmsg/widgets/country_picker.dart';
import 'package:optmsg/widgets/text_form_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:optmsg/router/app_routes.dart';

class CreateAccountFormWidget extends StatelessWidget {
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
  final double? spacing;
  final bool isLoading;

  const CreateAccountFormWidget({
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
    this.spacing,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = AppBreakpoints.screenWidth(context);
    final gap = spacing ?? 20.0;

    return Form(
      key: formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildUsernameField(context),
          SizedBox(height: gap),
          _buildPhoneField(context, screenWidth),
          SizedBox(height: gap),
          _buildTermsCheckbox(context),
          SizedBox(height: gap),
          _buildConditionCheckbox(context),
          SizedBox(height: gap * 1.5),
          CustomGradientButton(
            onPressed: isLoading ? null : onSubmit,
            text: 'Get Started',
            textStyle: AuthStyles.authButtonText(context),
          ),
          SizedBox(height: gap * 1.5),
          ClickableText(
            firstText: haveAccount,
            firstTextColor: AuthStyles.textPrimary,
            secondText: ' $login',
            secondTextColor: AuthStyles.textAccent,
            onTap: onLogin,
          ),
        ],
      ),
    );
  }

  Widget _buildUsernameField(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: CustomTextFormField(
            inputAction: TextInputAction.next,
            onChange: onUserNameChanged,
            inputFormatter: FilteringTextInputFormatter.allow(
              RegExp(r'^[a-zA-Z0-9_.-]*$'),
            ),
            showRightIcon: true,
            rightIcon: isUserNameAvailable ? svgTick : svgCloseRed,
            controller: userNameController,
            labelText: userName,
            validator: formValidation.validateUserNameWeb,
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.newUsername],
            fillColor: AuthStyles.inputFill,
            borderColor: AuthStyles.inputBorder,
            style: AuthStyles.inputText(context),
            hintStyle: AuthStyles.hintText(context),
          ),
        ),
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 35.0),
              child: Text(
                ' $emailExtension',
                style: AuthStyles.inputText(context),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPhoneField(BuildContext context, double screenWidth) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CountryPicker(),
        SizedBox(width: screenWidth * 0.005),
        Expanded(
          child: CustomTextFormField(
            inputAction: TextInputAction.done,
            inputFormatter: FilteringTextInputFormatter.allow(
              RegExp(r'^[0-9]+$'),
            ),
            controller: phoneController,
            labelText: phoneNo,
            validator: formValidation.validatePhoneNumber,
            keyboardType: TextInputType.phone,
            autofillHints: const [AutofillHints.telephoneNumber],
            fillColor: AuthStyles.inputFill,
            borderColor: AuthStyles.inputBorder,
            style: AuthStyles.inputText(context),
            hintStyle: AuthStyles.hintText(context),
          ),
        ),
      ],
    );
  }

  Widget _buildTermsCheckbox(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Checkbox(
          value: acceptTerms,
          onChanged: onAcceptTermsChanged,
          side: BorderSide(color: AuthStyles.textPrimary.withValues(alpha: 0.5), width: 1),
          activeColor: context.appColors.toggleGreen,
          checkColor: const Color(0xFF243A8F),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: ClickableText(
            firstText: 'I have read and agree to the OptMsg',
            firstTextColor: AuthStyles.textPrimary,
            secondText: " Privacy Policy",
            secondTextColor: AuthStyles.textAccent,
            onTap: () => context
                .push(AppRoutes.staticPagePath('privacy_policy', 'signup')),
            thirdText: ' and',
            thirdTextColor: AuthStyles.textPrimary,
            fourthText: " Terms of Service",
            fourthTextColor: AuthStyles.textAccent,
            onTap2: () => context
                .push(AppRoutes.staticPagePath('terms_conditions', 'signup')),
          ),
        ),
      ],
    );
  }

  Widget _buildConditionCheckbox(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Checkbox(
          value: acceptCondition,
          onChanged: onAcceptConditionChanged,
          side: BorderSide(color: AuthStyles.textPrimary.withValues(alpha: 0.5), width: 1),
          activeColor: context.appColors.toggleGreen,
          checkColor: const Color(0xFF243A8F),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: ClickableText(
            firstText: condition,
            firstTextColor: AuthStyles.textPrimary,
            secondText: "",
            secondTextColor: AuthStyles.textPrimary,
            onTap: () {},
            thirdText: "",
            thirdTextColor: AuthStyles.textPrimary,
            fourthText: "",
            fourthTextColor: AuthStyles.textPrimary,
            onTap2: () {},
          ),
        ),
      ],
    );
  }
}
