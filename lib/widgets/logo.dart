import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:optmsg/router/app_routes.dart';
import 'package:optmsg/constant/img_path.dart';
import 'package:optmsg/constant/string_constant.dart';
import 'package:optmsg/constant/app_typography.dart';
import 'package:optmsg/common/responsive/breakpoints.dart';

class LogoWithSlogan extends StatelessWidget {
  final TextStyle? sloganStyle;
  final String? testId;

  const LogoWithSlogan({super.key, this.sloganStyle, this.testId});

  @override

  /// A widget that displays the logo with a slogan, and navigates to the web
  /// login page when tapped.
  Widget build(BuildContext context) {
    // Use minimum sizes to prevent logo from becoming too small
    final screenHeight = AppBreakpoints.screenHeight(context);
    final screenWidth = AppBreakpoints.screenWidth(context);

    final logoHeight = (screenHeight * 0.040).clamp(28.0, 48.0);
    final logoWidth = (screenWidth * 0.144).clamp(100.0, 200.0);
    final spacing = (screenHeight * 0.005).clamp(4.0, 8.0);

    return GestureDetector(
      key: testId != null ? Key(testId!) : null,
      onTap: () {
        context.go(AppRoutes.login);
      },
      child: Column(
        children: [
          SvgPicture.asset(
            svgWebLogo,
            height: logoHeight,
            width: logoWidth,
          ),
          SizedBox(
            height: spacing,
          ),
          Text(
            slogan,
            style: sloganStyle ?? AppTypography.appBarTitle1(context),
          ),
        ],
      ),
    );
  }
}
