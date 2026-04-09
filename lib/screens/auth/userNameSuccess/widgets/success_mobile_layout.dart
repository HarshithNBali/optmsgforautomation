import 'package:optmsg/common/responsive/responsive.dart';
import 'package:optmsg/constant/img_path.dart';
import 'package:optmsg/constant/styles.dart';
import 'package:optmsg/screens/auth/userNameSuccess/widgets/success_content_widget.dart';
import 'package:optmsg/widgets/gradient_background.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SuccessMobileLayout extends StatelessWidget {
  final VoidCallback onBackToLogin;

  const SuccessMobileLayout({
    super.key,
    required this.onBackToLogin,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = AppBreakpoints.screenHeight(context);
    final screenWidth = AppBreakpoints.screenWidth(context);
    final isLandscape = screenWidth > screenHeight;

    if (isLandscape) {
      return _buildLandscapeLayout(context);
    }
    return _buildPortraitLayout(context, screenHeight);
  }

  Widget _buildLandscapeLayout(BuildContext context) {
    return GradientBackground(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 8.0),
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: Center(
                  child: SvgPicture.asset(svgIcon, height: 50),
                ),
              ),
              const SizedBox(width: AppStyles.space32),
              Expanded(
                flex: 1,
                child: Center(
                  child: SuccessContentWidget(onBackToLogin: onBackToLogin),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPortraitLayout(BuildContext context, double screenHeight) {
    return GradientBackground(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppStyles.space32),
          child: Column(
            children: [
              SizedBox(height: screenHeight * 0.05),
              SvgPicture.asset(svgIcon),
              SizedBox(height: screenHeight * 0.05),
              SuccessContentWidget(onBackToLogin: onBackToLogin),
            ],
          ),
        ),
      ),
    );
  }
}
