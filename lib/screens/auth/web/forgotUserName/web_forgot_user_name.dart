import 'package:optmsg/widgets/logo.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:optmsg/constant/img_path.dart';
import 'package:optmsg/constant/styles.dart';
import 'package:optmsg/common/responsive/responsive.dart';
import 'package:optmsg/services/adaptive_service.dart';
import 'package:optmsg/services/form_validation.dart';
import 'package:optmsg/services/common_service.dart';
import 'package:optmsg/widgets/button_form_field.dart';
import 'package:optmsg/widgets/text_form_field.dart';
import 'package:optmsg/widgets/country_picker.dart';
import 'package:optmsg/widgets/web_background.dart';
import 'package:optmsg/widgets/web_container.dart';
import 'package:optmsg/constant/string_constant.dart';
import 'package:optmsg/constant/auth_styles.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:optmsg/router/app_routes.dart';
import 'package:optmsg/screens/auth/auth_riverpod/auth_notifier.dart';

class WebForgotUserName extends ConsumerStatefulWidget {
  const WebForgotUserName({super.key});

  @override
  ConsumerState<WebForgotUserName> createState() => _WebForgotUserNameState();
}

class _WebForgotUserNameState extends ConsumerState<WebForgotUserName> {
  final _forgotUserNameFormKey = GlobalKey<FormState>();
  final TextEditingController _phoneController = TextEditingController();
  final _formValidationService = FormValidationService();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override

  /// Builds the web forgot username screen widget.
  ///
  /// The widget is a [Column] with two children: a [Row] with a [LogoWithSlogan],
  /// a [WebBackground] with a [SingleChildScrollView] containing the forgot username form,
  /// and a [Row] with a [Text] displaying the copyright notice.
  ///
  /// The [SingleChildScrollView] contains a [Column] with the forgot username form, which
  /// includes a [Form] with a [CountryPicker], a [CustomTextFormField] for the phone number,
  /// and a [CustomGradientButton] for submitting the form.
  ///
  /// The form elements are validated using the [_formValidationService] and the
  /// [_webForgotUserNameLogic] is used to check the availability of the user name.
  ///
  /// The user can navigate to the login screen by clicking on the "Have an account?"
  /// [ClickableText] at the bottom of the screen.
  ///
  /// The user can also navigate to the terms and conditions and privacy policy
  /// pages by clicking on the corresponding [ClickableText]s in the sign up form.
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: WebBackground(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    height: AdaptiveService.screenHeight(context) * 0.030,
                  ),
                  LogoWithSlogan(sloganStyle: AuthStyles.authSlogan(context)),
                  const SizedBox(
                    height: 50,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap: () {
                          context.pop();
                        },
                        child: SizedBox(
                          width: 80,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.asset(
                                svgArrowBack,
                                height: 30,
                                width: 32,
                              ),
                              Text(
                                '  $back',
                                style: AuthStyles.inputText(context),
                              ),
                            ],
                          ),
                        ),
                      ),
                      TransparentContainer(
                        height: 450,
                        width: AppBreakpoints.authFormWidthMedium,
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: SingleChildScrollView(
                            child: Form(
                              key: _forgotUserNameFormKey,
                              child: Column(children: [
                                Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      SvgPicture.asset(
                                        'assets/svg/userName.svg',
                                        height: 40,
                                        width: 40,
                                      ),
                                      const SizedBox(height: AppStyles.space8),
                                      Text(
                                        forgotUserName,
                                        style: AuthStyles.heroTitle(context),
                                      ),
                                      const SizedBox(height: AppStyles.space8),
                                      Text(
                                        forgotText,
                                        textAlign: TextAlign.center,
                                        style: AuthStyles.subTitle(context),
                                      ),
                                      const SizedBox(height: AppStyles.space8),
                                      Row(
                                        children: [
                                          const CountryPicker(),
                                          const SizedBox(width: AppStyles.space8),
                                          Expanded(
                                            child: CustomTextFormField(
                                              inputAction: TextInputAction.done,
                                              inputFormatter:
                                                  FilteringTextInputFormatter
                                                      .allow(
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
                                      const SizedBox(height: AppStyles.space8),
                                      CustomGradientButton(
                                        onPressed: onPressed,
                                        text: submit,
                                        textStyle: AuthStyles.authButtonText(context),
                                      ),
                                    ],
                                  ),
                                ),
                              ]),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: AppStyles.space8,
                      )
                    ],
                  ),
                ],
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
                )
              ],
            ),
          ),
        ],
      )),
    );
  }

  void onPressed() async {
    if (!_forgotUserNameFormKey.currentState!.validate()) return;

    final success = await ref
        .read(authProvider.notifier)
        .forgotUserName(_phoneController.text);

    if (success && mounted) {
      await context.push(
        AppRoutes.webOtpToken,
        extra: {
          'userName': '',
          'pageKey': 'webForgotUserName',
          'loginId': _phoneController.text,
          'webAuthn': false,
        },
      );
    }
  }
}
