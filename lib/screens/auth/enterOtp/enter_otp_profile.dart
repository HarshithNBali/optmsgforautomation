import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:optmsg/constant/common_constant.dart';
import 'package:optmsg/widgets/button_form_field.dart';
import 'package:optmsg/widgets/load_container/load_indicator.dart';
import 'package:optmsg/widgets/text_form_field.dart';
import 'package:optmsg/constant/img_path.dart';
import 'package:optmsg/constant/string_constant.dart';
import 'package:optmsg/constant/styles.dart';

import 'package:optmsg/constant/auth_styles.dart';
import 'package:optmsg/common/responsive/responsive.dart';
import 'package:optmsg/widgets/gradient_background.dart';
import 'package:optmsg/services/adaptive_service.dart';
import 'package:optmsg/services/common_service.dart';
import 'package:optmsg/services/storage_service.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';
import 'package:optmsg/router/app_routes.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:optmsg/screens/settings/profile_riverpod/profile_notifier.dart';

class EnterOtpProfile extends ConsumerStatefulWidget {
  const EnterOtpProfile({super.key});

  @override
  ConsumerState<EnterOtpProfile> createState() => _EnterOtpProfileState();
}

class _EnterOtpProfileState extends ConsumerState<EnterOtpProfile> {
  final SecureStorageService secureStorageService = SecureStorageService();
  final _otpProfileFormKey = GlobalKey<FormState>();
  Map<String, dynamic>? userData;
  final TextEditingController _otpController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String? countryCode;
  String? mobileNumber;
  String? formattedPhoneNumber;

  @override
  void initState() {
    super.initState();
    getUserData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_focusNode);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
          backgroundColor: Colors.transparent,
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: SvgPicture.asset(
                svgArrowBack,
                height: 24,
                width: 24,
                colorFilter: const ColorFilter.mode(
                  AuthStyles.textPrimary,
                  BlendMode.srcIn,
                ),
              ),
              onPressed: () => context.pop(),
            ),
            title: const Text(otp, style: TextStyle(color: AuthStyles.textPrimary)),
            actions: const [SizedBox.shrink()],
          ),
          body: GradientBackground(
            child: AdaptiveService.isDesktopLayout(context)
              ? Center(
                  child: SizedBox(
                    width: AppBreakpoints.formWidthDesktop,
                    child: Form(
                      key: _otpProfileFormKey,
                      child: ListView(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(AppStyles.space32),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                SvgPicture.asset(
                                  svgAccount,
                                  height: 60,
                                  width: 80,
                                ),
                                const SizedBox(height: AppStyles.space16),
                                Text(
                                  verifyAccount,
                                  style: AuthStyles.heroTitle(context),
                                ),
                                const SizedBox(height: AppStyles.space16),
                                Text(
                                  verifyText,
                                  textAlign: TextAlign.center,
                                  style: AuthStyles.subTitle(context),
                                ),
                                const SizedBox(height: AppStyles.space4),
                                if (countryCode != null && mobileNumber != null)
                                  Text(
                                    formattedPhoneNumber!,
                                    textAlign: TextAlign.center,
                                    style: AuthStyles.subTitle(context),
                                  ),
                                const SizedBox(height: AppStyles.space32),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 2.0,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.only(
                                          top: 5.0,
                                          bottom: 5.0,
                                        ),
                                        child: Pinput(
                                          controller: _otpController,
                                          closeKeyboardWhenCompleted: false,
                                          keyboardType: TextInputType.number,
                                          focusNode: _focusNode,
                                          length: 6,
                                          defaultPinTheme: PinTheme(
                                            width: 56,
                                            height: 48,
                                            textStyle: AuthStyles.inputText(context),
                                            decoration: BoxDecoration(
                                              color: Colors.transparent,
                                              borderRadius:
                                                  BorderRadius.circular(AppStyles.radiusM),
                                              border: Border.all(
                                                color: AuthStyles.textPrimary.withValues(alpha: 0.5),
                                              ),
                                            ),
                                          ),
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          pinputAutovalidateMode:
                                              PinputAutovalidateMode.onSubmit,
                                          showCursor: true,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: AppStyles.space32),
                                ClickableText(
                                  firstText: notReceived,
                                  firstTextColor: AuthStyles.textSecondary,
                                  secondText: " $requestAgain",
                                  secondTextColor: AuthStyles.textPrimary,
                                  onTap: resendOtp,
                                ),
                                const SizedBox(height: AppStyles.space32),
                                CustomGradientButton(
                                  onPressed: verifyOtp,
                                  text: submit,
                                  textStyle: AuthStyles.authButtonText(context),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : Form(
                  key: _otpProfileFormKey,
                  child: ListView(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(AppStyles.space20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SvgPicture.asset(svgAccount, height: 60, width: 80),
                            const SizedBox(height: AppStyles.space16),
                            Text(
                              verifyAccount,
                              style: AuthStyles.heroTitle(context),
                            ),
                            const SizedBox(height: AppStyles.space16),
                            Text(
                              verifyText,
                              textAlign: TextAlign.center,
                              style: AuthStyles.subTitle(context),
                            ),
                            const SizedBox(height: AppStyles.space4),
                            if (countryCode != null && mobileNumber != null)
                              Text(
                                formattedPhoneNumber!,
                                textAlign: TextAlign.center,
                                style: AuthStyles.subTitle(context),
                              ),
                            const SizedBox(height: 20),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 2.0,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.only(
                                      top: 5.0,
                                      bottom: 5.0,
                                    ),
                                    child: Pinput(
                                      controller: _otpController,
                                      closeKeyboardWhenCompleted: false,
                                      keyboardType: TextInputType.number,
                                      focusNode: _focusNode,
                                      length: 6,
                                      defaultPinTheme: PinTheme(
                                        width:
                                            AdaptiveService.isMobileLayout(
                                              context,
                                            )
                                            ? AdaptiveService.screenWidth(
                                                    context,
                                                  ) *
                                                  0.12
                                            : 56,
                                        height: 48,
                                        textStyle: AuthStyles.inputText(context),
                                        decoration: BoxDecoration(
                                          color: Colors.transparent,
                                          borderRadius: BorderRadius.circular(
                                            AppStyles.radiusM,
                                          ),
                                          border: Border.all(
                                            color: AuthStyles.textPrimary.withValues(alpha: 0.5),
                                          ),
                                        ),
                                      ),
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      pinputAutovalidateMode:
                                          PinputAutovalidateMode.onSubmit,
                                      showCursor: true,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: AppStyles.space20),
                            ClickableText(
                              firstText: notReceived,
                              firstTextColor: context.colors.onSurfaceVariant,
                              secondText: " $requestAgain",
                              secondTextColor: context.colors.onSurface,
                              onTap: resendOtp,
                            ),
                            const SizedBox(height: AppStyles.space32),
                            CustomGradientButton(
                              onPressed: verifyOtp,
                              text: submit,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
          ),
        ),
      ),
    );
  }

  Future<void> getUserData() async {
    userData = await secureStorageService.readObjectData('userProfileData');
    if (userData != null) {
      if (mounted) {
        setState(() {
          countryCode = userData!['countryCode'];
          mobileNumber = userData!['tempMobile'];
          formattedPhoneNumber = CommonService().formatPhoneNumber(
            countryCode!,
            mobileNumber!,
          );
        });
      }
    }
  }

  Future<void> resendOtp() async {
    FocusScope.of(context).unfocus();
    _focusNode.unfocus();
    final notifier = ref.read(profileProvider.notifier);
    final otpId = userData?['tempOtpId'];

    if (otpId == null) return;

    bool dialogShown = false;
    final dlgTimer = Timer(const Duration(milliseconds: duration), () {
      if (mounted) {
        dialogShown = true;
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => const Center(
            child: LoaderIndicator(),
          ),
        );
      }
    });

    final success = await notifier.resendOtp(otpId);
    dlgTimer.cancel();

    if (mounted) {
      if (dialogShown) context.pop();
      if (success) {
        _otpController.clear();
      }
    }
  }

  Future<void> verifyOtp() async {
    FocusScope.of(context).unfocus();
    _focusNode.unfocus();
    if (!_otpProfileFormKey.currentState!.validate()) {
      return;
    }

    String otpStr = _otpController.text;

    if (otpStr.isEmpty || otpStr.length < 6) {
      CommonService.animatedToast('Please enter OTP', 'error');
      return;
    }

    final notifier = ref.read(profileProvider.notifier);

    bool dialogShown = false;
    final dlgTimer = Timer(const Duration(milliseconds: duration), () {
      if (mounted) {
        dialogShown = true;
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => const Center(
            child: LoaderIndicator(),
          ),
        );
      }
    });

    final success = await notifier.verifyNewMobile(otpStr);
    dlgTimer.cancel();

    if (mounted) {
      if (dialogShown) context.pop();
      if (success) {
        context.push(AppRoutes.profile);
      } else {
        _otpController.clear();
      }
    }
  }
}
