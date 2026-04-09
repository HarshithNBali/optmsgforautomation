import 'package:optmsg/services/common_service.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:optmsg/constant/img_path.dart';
import 'package:optmsg/constant/styles.dart';
import 'package:optmsg/services/form_validation.dart';
import 'package:optmsg/widgets/button_form_field.dart';
import 'package:optmsg/widgets/text_form_field.dart';
import 'package:optmsg/widgets/country_picker.dart';
import 'package:optmsg/widgets/gradient_background.dart';
import 'package:optmsg/constant/string_constant.dart';
import 'package:optmsg/constant/auth_styles.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:optmsg/screens/auth/auth_riverpod/auth_notifier.dart';
import 'package:optmsg/router/app_routes.dart';

class ForgotUserNameMobile extends ConsumerStatefulWidget {
  const ForgotUserNameMobile({super.key});

  @override
  ConsumerState<ForgotUserNameMobile> createState() =>
      _ForgotUserNameMobileState();
}

class _ForgotUserNameMobileState extends ConsumerState<ForgotUserNameMobile> {
  final _forgotUserNameFormKey = GlobalKey<FormState>();
  final TextEditingController _phoneController = TextEditingController();
  final _formValidationService = FormValidationService();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: CommonService().getPlatform() == 'ios' ? false : true,
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: GradientBackground(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppStyles.space16),
                  child: TextButton.icon(
                    onPressed: () {
                      context.pop();
                    },
                    icon: SvgPicture.asset(
                      svgArrowBack,
                      height: 30,
                      width: 32,
                    ),
                    label: Text(
                      back,
                      style: AuthStyles.inputText(context),
                    ),
                    style: TextButton.styleFrom(
                      minimumSize: const Size(0, 48),
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(AppStyles.space32),
                        child: Form(
                          key: _forgotUserNameFormKey,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SvgPicture.asset(
                                svgIcon,
                              ),
                              const SizedBox(height: AppStyles.space16),
                              Text(
                                forgotUserName,
                                style: AuthStyles.heroTitle(context),
                              ),
                              const SizedBox(height: AppStyles.space16),
                              Text(
                                forgotText,
                                textAlign: TextAlign.center,
                                style: AuthStyles.subTitle(context),
                              ),
                              const SizedBox(height: AppStyles.space32),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const CountryPicker(),
                                  const SizedBox(width: AppStyles.space8),
                                  Expanded(
                                    child: CustomTextFormField(
                                      inputAction: TextInputAction.done,
                                      inputFormatter:
                                          FilteringTextInputFormatter.allow(
                                              RegExp(r'^[0-9]+$')),
                                      controller: _phoneController,
                                      labelText: phoneNo,
                                      validator: _formValidationService
                                          .validatePhoneNumber,
                                      autofillHints: const [AutofillHints.telephoneNumber],
                                      keyboardType: TextInputType.phone,
                                      fillColor: AuthStyles.inputFill,
                                      borderColor: AuthStyles.inputBorder,
                                      style: AuthStyles.inputText(context),
                                      hintStyle: AuthStyles.hintText(context),
                                    ),
                                  )
                                ],
                              ),
                              const SizedBox(height: AppStyles.space32),
                              CustomGradientButton(
                                onPressed: onPressed,
                                text: submit,
                                textStyle: AuthStyles.authButtonText(context),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    CommonService().getCopyrightNotice(),
                    textAlign: TextAlign.center,
                    style: AuthStyles.copyright(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void onPressed() async {
    if (!_forgotUserNameFormKey.currentState!.validate()) return;

    final success = await ref
        .read(authProvider.notifier)
        .forgotUserName(_phoneController.text);

    if (success && mounted) {
      await context.push(
        AppRoutes.enterOtp,
        extra: {
          'userName': '',
          'pageKey': 'forgotUserName',
          'loginId': _phoneController.text,
          'webAuthn': false,
        },
      );
    }
  }
}
