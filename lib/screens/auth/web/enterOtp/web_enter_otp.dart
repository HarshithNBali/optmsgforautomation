import 'package:optmsg/constant/img_path.dart';
import 'package:optmsg/screens/auth/web/enterOtp/web_enter_otp_notifier.dart';
import 'package:optmsg/widgets/logo.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:optmsg/common/responsive/responsive.dart';
import 'package:optmsg/widgets/button_form_field.dart';
import 'package:optmsg/widgets/text_form_field.dart';
import 'package:optmsg/widgets/web_background.dart';
import 'package:optmsg/widgets/web_container.dart';
import 'package:optmsg/constant/string_constant.dart';
import 'package:optmsg/constant/styles.dart';
import 'package:optmsg/constant/auth_styles.dart';
import 'package:pinput/pinput.dart';


class WebEnterOtp extends ConsumerStatefulWidget {
  final String pageKey;
  final String loginId;
  final String userName;

  const WebEnterOtp({
    super.key,
    required this.pageKey,
    required this.loginId,
    required this.userName,
  });

  @override
  ConsumerState<WebEnterOtp> createState() => _WebEnterOtpState();
}

class _WebEnterOtpState extends ConsumerState<WebEnterOtp> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref.invalidate(webEnterOtpProvider);
      ref.read(webEnterOtpProvider.notifier).initialize(widget.loginId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(webEnterOtpProvider);
    final notifier = ref.read(webEnterOtpProvider.notifier);

    return Scaffold(
      body: WebBackground(
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            children: [
              const SizedBox(height: AppStyles.space8),
              LogoWithSlogan(sloganStyle: AuthStyles.authSlogan(context)),
              const SizedBox(height: AppStyles.space8),
              _buildBackButton(context),
              TransparentContainer(
                height: 450,
                width: AppBreakpoints.authFormWidthWide,
                child: Form(
                  key: notifier.formKey,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SvgPicture.asset(svgAccount),
                        const SizedBox(height: 20),
                        Text(
                          verifyAccount,
                          style: AuthStyles.heroTitle(context),
                        ),
                        Text(
                          state.formattedPhoneNumber,
                          style: AuthStyles.subTitle(context),
                        ),
                        const SizedBox(height: AppStyles.space8),
                        Pinput(
                          controller: notifier.otpController,
                          keyboardType: TextInputType.number,
                          length: 6,
                          defaultPinTheme: PinTheme(
                            width: AppBreakpoints.isMobileLayout(context)
                                ? AppBreakpoints.screenWidth(context) * 0.12
                                : 56,
                            height: 48,
                            textStyle: AuthStyles.pinDigit(context),
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AuthStyles.textPrimary.withValues(alpha: 0.5)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // L-01: Show cooldown timer on resend button.
                        ClickableText(
                            firstText: notReceived,
                            secondText: state.resendCooldownSeconds > 0
                                ? ' Resend in ${state.resendCooldownSeconds}s'
                                : ' $requestAgain',
                            firstTextColor: AuthStyles.textSecondary,
                            secondTextColor: state.resendCooldownSeconds > 0
                                ? AuthStyles.textSecondary
                                : AuthStyles.textAccent,
                            onTap: () => notifier.resendOtp(
                                  pageKey: widget.pageKey,
                                  userName: widget.userName,
                                  isLogin: widget.pageKey == 'login',
                                )),
                        const SizedBox(height: AppStyles.space8),
                        CustomGradientButton(
                          onPressed: () {
                            if (!state.isLoading) {
                              if (widget.pageKey == 'login') {
                                notifier.submitOtp(
                                  userName: widget.userName,
                                );
                              } else {
                                notifier.verifyOtp(
                                  pageKey: widget.pageKey,
                                  userName: widget.userName,
                                );
                              }
                            }
                          },
                          text: state.isLoading ? "Please wait..." : submit,
                          textStyle: AuthStyles.authButtonText(context),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return SizedBox(
      width: AppBreakpoints.screenWidth(context) > 540
          ? 540
          : AppBreakpoints.screenWidth(context),
      child: InkWell(
        onTap: () => context.pop(),
        child: Row(
          children: [
            Icon(Icons.arrow_back, color: context.colors.onPrimary),
            const SizedBox(width: 6),
            Text('Back', style: AuthStyles.inputText(context)),
          ],
        ),
      ),
    );
  }
}
