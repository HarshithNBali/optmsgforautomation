import 'package:optmsg/constant/string_constant.dart';
import 'package:optmsg/constant/auth_styles.dart';

import 'package:optmsg/services/form_validation.dart';
import 'package:optmsg/widgets/button_form_field.dart';
import 'package:optmsg/widgets/date_picker.dart';
import 'package:optmsg/widgets/text_form_field.dart';
import 'package:flutter/material.dart';

class SetupProfileFormWidget extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController dobController;
  final FormValidationService formValidation;
  final VoidCallback onSubmit;
  final VoidCallback onLogin;
  final double? spacing;
  final bool? readOnly;

  const SetupProfileFormWidget(
      {super.key,
      required this.formKey,
      required this.firstNameController,
      required this.lastNameController,
      required this.dobController,
      required this.formValidation,
      required this.onSubmit,
      required this.onLogin,
      this.spacing,
      this.readOnly});

  @override
  Widget build(BuildContext context) {
    final gap = spacing ?? 10.0;

    return Form(
      key: formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomTextFormField(
            testId: 'setup_profile_firstname_input',
            textCapitalization: TextCapitalization.sentences,
            inputAction: TextInputAction.next,
            controller: firstNameController,
            labelText: firstName,
            validator: formValidation.validateFirstName,
            keyboardType: TextInputType.text,
            readOnly: readOnly ?? false,
            autofillHints: const [AutofillHints.givenName],
            fillColor: AuthStyles.inputFill,
            borderColor: AuthStyles.inputBorder,
            style: AuthStyles.inputText(context),
            hintStyle: AuthStyles.hintText(context),
          ),
          SizedBox(height: gap),
          CustomTextFormField(
            testId: 'setup_profile_lastname_input',
            textCapitalization: TextCapitalization.sentences,
            inputAction: TextInputAction.next,
            controller: lastNameController,
            labelText: lastName,
            validator: formValidation.validateLastName,
            keyboardType: TextInputType.text,
            readOnly: readOnly ?? false,
            autofillHints: const [AutofillHints.familyName],
            fillColor: AuthStyles.inputFill,
            borderColor: AuthStyles.inputBorder,
            style: AuthStyles.inputText(context),
            hintStyle: AuthStyles.hintText(context),
          ),
          SizedBox(height: gap),
          DateOfBirthPicker(
            testId: 'setup_profile_dob_input',
            readOnly: readOnly ?? false,
            controller: dobController,
            labelText: dob,
            validator: formValidation.validateDob,
          ),
          SizedBox(height: gap),
          CustomGradientButton(
            testId: 'setup_profile_submit_button',
            onPressed: onSubmit,
            text: signUp,
            textStyle: AuthStyles.authButtonText(context),
          ),
          SizedBox(height: gap * 2),
          ClickableText(
            key: const Key('setup_profile_login_link'),
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
}
