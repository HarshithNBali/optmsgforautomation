import 'package:optmsg/constant/app_config.dart';
import 'package:optmsg/constant/string_constant.dart';
import 'package:optmsg/constant/auth_styles.dart';
import 'package:optmsg/services/form_validation.dart';
import 'package:optmsg/widgets/button_form_field.dart';
import 'package:optmsg/widgets/text_form_field.dart' show CustomTextFormField;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LoginFormWidget extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController userNameController;
  final FormValidationService formValidation;
  final VoidCallback onLogin;
  final VoidCallback onForgot;
  final double spacing;
  final bool showHoverEffect;
  final bool isHovered;
  final ValueChanged<bool>? onHoverChanged;
  final bool isLoading;

  const LoginFormWidget({
    super.key,
    required this.formKey,
    required this.userNameController,
    required this.formValidation,
    required this.onLogin,
    required this.onForgot,
    this.spacing = 20,
    this.showHoverEffect = false,
    this.isHovered = false,
    this.onHoverChanged,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildUserNameField(context),
          SizedBox(height: spacing),
          CustomGradientButton(
            onPressed: isLoading ? null : onLogin,
            text: login,
            textStyle: AuthStyles.authButtonText(context),
          ),
          SizedBox(height: spacing),
          _buildForgotLink(context),
        ],
      ),
    );
  }

  Widget _buildUserNameField(BuildContext context) {
    // ignore: deprecated_member_use
    final Pattern usernamePattern = RegExp(r'[a-zA-Z0-9_.-]');

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: CustomTextFormField(
            inputAction: TextInputAction.done,
            inputFormatter: FilteringTextInputFormatter.allow(usernamePattern),
            controller: userNameController,
            labelText: userName,
            validator: formValidation.validateUserNameWeb,
            keyboardType: TextInputType.emailAddress,
            name: 'username',
            autofillHints: const [],
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

  Widget _buildForgotLink(BuildContext context) {
    if (showHoverEffect) {
      return MouseRegion(
        onEnter: (_) => onHoverChanged?.call(true),
        onExit: (_) => onHoverChanged?.call(false),
        child: GestureDetector(
          onTap: onForgot,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
            child: Text(
              forgotUserNameClick,
              style: isHovered
                  ? AuthStyles.actionLink(context).copyWith(
                      decoration: TextDecoration.underline,
                    )
                  : AuthStyles.actionLink(context),
            ),
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: onForgot,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        child: Text(
          forgotUserNameClick,
          style: AuthStyles.actionLink(context),
        ),
      ),
    );
  }
}
