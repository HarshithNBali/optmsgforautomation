import 'package:optmsg/common/responsive/responsive.dart';
import 'package:optmsg/constant/auth_styles.dart';
import 'package:optmsg/screens/auth/userNameSuccess/widgets/success_content_widget.dart';
import 'package:optmsg/services/common_service.dart';
import 'package:optmsg/widgets/logo.dart';
import 'package:optmsg/widgets/web_background.dart';
import 'package:optmsg/widgets/web_container.dart';
import 'package:flutter/material.dart';

class SuccessDesktopLayout extends StatelessWidget {
  final VoidCallback onBackToLogin;

  const SuccessDesktopLayout({
    super.key,
    required this.onBackToLogin,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = AppBreakpoints.screenHeight(context);
    final screenWidth = AppBreakpoints.screenWidth(context);

    return WebBackground(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: screenHeight * 0.030),
              LogoWithSlogan(sloganStyle: AuthStyles.authSlogan(context)),
              SizedBox(height: screenHeight * 0.050),
              TransparentContainer(
                height: 420,
                width: screenWidth * 0.250,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: SuccessContentWidget(onBackToLogin: onBackToLogin),
                  ),
                ),
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    CommonService().getCopyrightNotice(),
                    style: AuthStyles.copyright(context),
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.020),
            ],
          ),
        ],
      ),
    );
  }
}
