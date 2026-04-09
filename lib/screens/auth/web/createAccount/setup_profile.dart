import 'package:optmsg/widgets/logo.dart';
import 'package:flutter/material.dart';
import 'package:optmsg/services/common_service.dart';
import 'package:optmsg/constant/string_constant.dart';
import 'package:optmsg/constant/styles.dart';
import 'package:optmsg/constant/auth_styles.dart';
import 'package:optmsg/common/responsive/responsive.dart';
import 'package:optmsg/services/adaptive_service.dart';
import 'package:go_router/go_router.dart';
import 'package:optmsg/router/app_routes.dart';
import 'package:optmsg/services/form_validation.dart';
import 'package:optmsg/services/storage_service.dart';
import 'package:optmsg/widgets/button_form_field.dart';
import 'package:optmsg/widgets/date_picker.dart';
import 'package:optmsg/widgets/text_form_field.dart';
import 'package:optmsg/widgets/web_background.dart';
import 'package:optmsg/widgets/web_container.dart';
import 'package:optmsg/widgets/web_login_content.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:optmsg/screens/auth/auth_riverpod/auth_notifier.dart';
import 'package:intl/intl.dart';

class SetupProfile extends ConsumerStatefulWidget {
  final String userName;
  const SetupProfile({super.key, required this.userName});

  @override
  ConsumerState<SetupProfile> createState() => _SetupProfileState();
}

class _SetupProfileState extends ConsumerState<SetupProfile> {
  String deviceToken = '';
  final _formValidationService = FormValidationService();
  final SecureStorageService secureStorageService = SecureStorageService();
  final GlobalKey<FormState> _setupProfileFormKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getDeviceToken();
  }

  Future<void> _getDeviceToken() async {
    deviceToken = (await secureStorageService.readData('deviceToken')) ?? "";
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isReadOnly =
        ref.watch(authProvider.select((s) => s.isReadOnly));

    return Scaffold(
        resizeToAvoidBottomInset: true,
        body: WebBackground(
            child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      SizedBox(
                        height: AdaptiveService.screenHeight(context) * 0.030,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          LogoWithSlogan(sloganStyle: AuthStyles.authSlogan(context)),
                          SizedBox(
                            height:
                                AdaptiveService.screenHeight(context) * 0.050,
                          ),
                        ],
                      ),
                      SizedBox(
                        height: AdaptiveService.screenHeight(context) * 0.050,
                      ),
                      Container(
                        constraints: BoxConstraints(
                          minHeight:
                              AdaptiveService.screenHeight(context) * 0.780,
                        ),
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          children: [
                            if (AdaptiveService.isDesktopLayout(context))
                              const Column(
                                children: [StaticContentWidget()],
                              ),
                            if (AdaptiveService.isDesktopLayout(context))
                              SizedBox(
                                width: AdaptiveService.screenWidth(context) *
                                    0.060,
                              ),
                            Column(
                              children: [
                                TransparentContainer(
                                  height: 510,
                                  width: AppBreakpoints.authFormWidthMedium,
                                  child: Padding(
                                    padding: const EdgeInsets.all(30),
                                    child: Column(children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  setupProfile,
                                                  style: AuthStyles.heroTitle(context),
                                                  textAlign: TextAlign.left,
                                                ),
                                                SizedBox(
                                                    height: AdaptiveService
                                                            .screenHeight(
                                                                context) *
                                                        0.010),
                                                Text(
                                                  setupProfileText,
                                                  style: AuthStyles.subTitle(context),
                                                  textAlign: TextAlign.left,
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 14.0,
                                                vertical: 8.0),
                                            decoration: BoxDecoration(
                                              color: context.appColors.stepBadgeBg,
                                              borderRadius:
                                                  BorderRadius.circular(AppStyles.radiusXXL),
                                            ),
                                            child: Text('Step 2/4',
                                                style: AuthStyles.copyright(context)),
                                          )
                                        ],
                                      ),
                                      SizedBox(
                                          height: AdaptiveService.screenHeight(
                                                  context) *
                                              0.030),
                                      Expanded(
                                        child: Form(
                                          key: _setupProfileFormKey,
                                          child: Column(
                                            children: [
                                              Expanded(
                                                child: SingleChildScrollView(
                                                  child: Column(
                                                    children: [
                                                      CustomTextFormField(
                                                        textCapitalization:
                                                            TextCapitalization
                                                                .sentences,
                                                        inputAction:
                                                            TextInputAction
                                                                .next,
                                                        controller:
                                                            _firstNameController,
                                                        labelText: firstName,
                                                        validator:
                                                            _formValidationService
                                                                .validateFirstName,
                                                        keyboardType:
                                                            TextInputType.text,
                                                        readOnly:
                                                            isReadOnly,
                                                        autofillHints: const [AutofillHints.givenName],
                                                        fillColor: AuthStyles.inputFill,
                                                        borderColor: AuthStyles.inputBorder,
                                                        style: AuthStyles.inputText(context),
                                                        hintStyle: AuthStyles.hintText(context),
                                                      ),
                                                      SizedBox(
                                                          height: AdaptiveService
                                                                  .screenHeight(
                                                                      context) *
                                                              0.010),
                                                      CustomTextFormField(
                                                        textCapitalization:
                                                            TextCapitalization
                                                                .sentences,
                                                        inputAction:
                                                            TextInputAction
                                                                .next,
                                                        controller:
                                                            _lastNameController,
                                                        labelText: lastName,
                                                        validator:
                                                            _formValidationService
                                                                .validateLastName,
                                                        keyboardType:
                                                            TextInputType.text,
                                                        readOnly:
                                                            isReadOnly,
                                                        autofillHints: const [AutofillHints.familyName],
                                                        fillColor: AuthStyles.inputFill,
                                                        borderColor: AuthStyles.inputBorder,
                                                        style: AuthStyles.inputText(context),
                                                        hintStyle: AuthStyles.hintText(context),
                                                      ),
                                                      SizedBox(
                                                          height: AdaptiveService
                                                                  .screenHeight(
                                                                      context) *
                                                              0.010),
                                                      DateOfBirthPicker(
                                                          readOnly:
                                                              isReadOnly,
                                                          controller:
                                                              _dobController,
                                                          labelText: dob,
                                                          validator:
                                                              _formValidationService
                                                                  .validateDob),
                                                      SizedBox(
                                                          height: AdaptiveService
                                                                  .screenHeight(
                                                                      context) *
                                                              0.010),
                                                      CustomGradientButton(
                                                        onPressed:
                                                            _submitProfile,
                                                        text: signUp,
                                                        textStyle: AuthStyles.authButtonText(context),
                                                      ),
                                                      SizedBox(
                                                          height: AdaptiveService
                                                                  .screenHeight(
                                                                      context) *
                                                              0.030),
                                                      ClickableText(
                                                        firstText: haveAccount,
                                                        firstTextColor:
                                                            AuthStyles.textPrimary,
                                                        secondText: ' $login',
                                                        secondTextColor:
                                                            AuthStyles.textAccent,
                                                        onTap: _webLogin,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ]),
                                  ),
                                )
                              ],
                            )
                          ],
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
                  ),
                ),
              ),
            ),
          ],
        )));
  }

  void _webLogin() {
    context.go(AppRoutes.login);
  }

  Future<void> _submitProfile() async {
    if (!_setupProfileFormKey.currentState!.validate()) return;

    final dobForAPI = _dateFormatForAPI(_dobController.text);

    await ref.read(authProvider.notifier).setupProfile(
          firstName: _firstNameController.text,
          lastName: _lastNameController.text,
          dob: dobForAPI,
          deviceToken: deviceToken,
          userName: widget.userName,
          onSuccess: () {
            if (mounted) {
              context.push(AppRoutes.plans);
            }
          },
        );
  }

  String _dateFormatForAPI(String inputDate) {
    DateTime parsedDate = DateFormat('MM/dd/yyyy').parse(inputDate);
    return DateFormat('yyyy-MM-dd').format(parsedDate);
  }
}
