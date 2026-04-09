import 'package:optmsg/common/responsive/responsive.dart';
import 'package:optmsg/constant/img_path.dart';
import 'package:optmsg/constant/string_constant.dart';
import 'package:optmsg/constant/styles.dart';
import 'package:optmsg/constant/auth_styles.dart';
import 'package:optmsg/screens/auth/enterOtp/widgets/otp_form_widget.dart';
import 'package:optmsg/services/common_service.dart';
import 'package:optmsg/widgets/logo.dart';
import 'package:optmsg/widgets/web_background.dart';
import 'package:optmsg/widgets/web_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class OtpDesktopLayout extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController otpController;
  final FocusNode focusNode;
  final String formattedPhone;
  final VoidCallback onSubmit;
  final VoidCallback onResend;
  final VoidCallback onBack;
  final ValueChanged<String>? onOtpChanged;
  final ScrollController? scrollController;
  final bool isLoading;
  final int resendCooldownSeconds;

  const OtpDesktopLayout({
    super.key,
    required this.formKey,
    required this.otpController,
    required this.focusNode,
    required this.formattedPhone,
    required this.onSubmit,
    required this.onResend,
    required this.onBack,
    this.onOtpChanged,
    this.scrollController,
    this.isLoading = false,
    this.resendCooldownSeconds = 0,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = AppBreakpoints.screenWidth(context);

    return WebBackground(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                child: Column(
                  children: [
                    const SizedBox(height: AppStyles.space8),
                    LogoWithSlogan(sloganStyle: AuthStyles.authSlogan(context)),
                    const SizedBox(height: AppStyles.space8),
                    _buildBackButton(context, screenWidth),
                    _buildOtpCard(context),
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
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackButton(BuildContext context, double screenWidth) {
    return SizedBox(
      width: screenWidth > 540 ? 540 : screenWidth,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            TextButton.icon(
              onPressed: onBack,
              icon: SvgPicture.asset(svgArrowBack, height: 30, width: 32),
              label: Text(back, style: AuthStyles.inputText(context)),
              style: TextButton.styleFrom(
                minimumSize: const Size(0, 48),
                padding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOtpCard(BuildContext context) {
    return TransparentContainer(
      height: 450,
      width: AppBreakpoints.authFormWidthWide,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: OtpFormWidget(
          formKey: formKey,
          otpController: otpController,
          focusNode: focusNode,
          formattedPhone: formattedPhone,
          onSubmit: onSubmit,
          onResend: onResend,
          onOtpChanged: onOtpChanged,
          showIcon: false,
          isLoading: isLoading,
          resendCooldownSeconds: resendCooldownSeconds,
        ),
      ),
    );
  }
}
