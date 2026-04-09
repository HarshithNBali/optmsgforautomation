import 'package:optmsg/constant/img_path.dart';
import 'package:optmsg/constant/string_constant.dart';
import 'package:optmsg/constant/styles.dart';
import 'package:optmsg/constant/auth_styles.dart';
import 'package:optmsg/services/common_service.dart';
import 'package:optmsg/screens/auth/enterOtp/widgets/otp_form_widget.dart';
import 'package:optmsg/widgets/gradient_background.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class OtpMobileLayout extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController otpController;
  final FocusNode focusNode;
  final String formattedPhone;
  final VoidCallback onSubmit;
  final VoidCallback onResend;
  final VoidCallback onBack;
  final ValueChanged<String>? onOtpChanged;
  final bool isLoading;
  final int resendCooldownSeconds;

  const OtpMobileLayout({
    super.key,
    required this.formKey,
    required this.otpController,
    required this.focusNode,
    required this.formattedPhone,
    required this.onSubmit,
    required this.onResend,
    required this.onBack,
    this.onOtpChanged,
    this.isLoading = false,
    this.resendCooldownSeconds = 0,
  });

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;
    final isLandscape = orientation == Orientation.landscape;

    if (isLandscape) {
      return _buildLandscapeLayout(context);
    }
    return _buildPortraitLayout(context);
  }

  Widget _buildLandscapeLayout(BuildContext context) {
    return GradientBackground(
      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 40.0, vertical: 8.0),
                child: Center(
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
              ),
            ),
            _buildCopyright(context),
          ],
        ),
      ),
    );
  }

  Widget _buildPortraitLayout(BuildContext context) {
    return GradientBackground(
      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Center(
                  child: OtpFormWidget(
                    formKey: formKey,
                    otpController: otpController,
                    focusNode: focusNode,
                    formattedPhone: formattedPhone,
                    onSubmit: onSubmit,
                    onResend: onResend,
                    onOtpChanged: onOtpChanged,
                    showIcon: true,
                    isLoading: isLoading,
                    resendCooldownSeconds: resendCooldownSeconds,
                  ),
                ),
              ),
            ),
            _buildCopyright(context),
          ],
        ),
      ),
    );
  }

  Widget _buildCopyright(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        CommonService().getCopyrightNotice(),
        textAlign: TextAlign.center,
        style: AuthStyles.copyright(context),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppStyles.space16),
      child: TextButton.icon(
        onPressed: onBack,
        icon: SvgPicture.asset(svgArrowBack, height: 30),
        label: Text(back, style: AuthStyles.inputText(context)),
        style: TextButton.styleFrom(
          minimumSize: const Size(0, 48),
          padding: EdgeInsets.zero,
        ),
      ),
    );
  }
}
