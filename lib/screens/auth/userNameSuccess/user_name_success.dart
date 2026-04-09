import 'package:optmsg/router/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:optmsg/constant/img_path.dart';
import 'package:optmsg/constant/styles.dart';
import 'package:optmsg/constant/auth_styles.dart';
import 'package:optmsg/widgets/button_form_field.dart';
import 'package:optmsg/widgets/gradient_background.dart';
import 'package:optmsg/constant/string_constant.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserNameSuccess extends ConsumerWidget {
  const UserNameSuccess({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: GradientBackground(
          child: Padding(
            padding: const EdgeInsets.all(AppStyles.space32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  svgSuccess,
                  height: 140,
                  width: 140,
                ),
                const SizedBox(height: AppStyles.space16),
                Text(
                  userNameSent,
                  style: AuthStyles.heroTitle(context),
                ),
                const SizedBox(height: AppStyles.space16),
                Text(userNameText,
                    style: AuthStyles.subTitle(context), textAlign: TextAlign.center),
                const SizedBox(height: AppStyles.space32),
                CustomGradientButton(
                  onPressed: () => _onPressed(context),
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

  void _onPressed(BuildContext context) {
    context.go(AppRoutes.login);
  }
}
