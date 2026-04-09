import 'package:go_router/go_router.dart';
import 'package:optmsg/router/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:optmsg/services/adaptive_service.dart';
import 'package:optmsg/widgets/button_form_field.dart';
import 'package:optmsg/widgets/gradient_background.dart';
import 'package:optmsg/constant/img_path.dart';
import 'package:optmsg/constant/string_constant.dart';
import 'package:optmsg/constant/auth_styles.dart';

class SuccessOtp extends ConsumerWidget {
  const SuccessOtp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: GradientBackground(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: AdaptiveService.screenHeight(context) * 0.040,
                  width: AdaptiveService.screenWidth(context) * 1,
                ),
                SvgPicture.asset(
                  svgSuccess,
                  height: AdaptiveService.screenHeight(context) * 0.170,
                  width: AdaptiveService.screenWidth(context) * 0.170,
                ),
                SizedBox(
                  height: AdaptiveService.screenHeight(context) * 0.030,
                ),
                Text(
                  userNameSent,
                  style: AuthStyles.heroTitle(context),
                ),
                SizedBox(
                  height: AdaptiveService.screenHeight(context) * 0.020,
                ),
                Text(
                  otpSuccessMsg,
                  textAlign: TextAlign.center,
                  style: AuthStyles.subTitle(context),
                ),
                SizedBox(
                  height: AdaptiveService.screenHeight(context) * 0.030,
                ),
                CustomGradientButton(
                  onPressed: () {
                    context.go(AppRoutes.login);
                  },
                  text: backToLogin,
                  textStyle: AuthStyles.authButtonText(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
