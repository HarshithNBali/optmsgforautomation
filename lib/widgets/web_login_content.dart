import 'package:optmsg/constant/img_path.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:optmsg/constant/string_constant.dart';
import 'package:optmsg/constant/auth_styles.dart';
import 'package:optmsg/common/responsive/breakpoints.dart';

class StaticContentWidget extends StatelessWidget {
  const StaticContentWidget({super.key});

  @override

  /// Builds a static content widget for the login screen.
  ///
  /// This widget consists of a container with a fixed width and padding,
  /// containing a column with SVG images and descriptive text. It displays
  /// three sections, each consisting of an image, a line, and corresponding
  /// text. The text describes the attributes "secure", "private", and "simple",
  /// each with a heading and a description. The layout is responsive based on
  /// the screen height.

  Widget build(BuildContext context) {
    return Container(
      width: AppBreakpoints.webLoginFormWidth,
      padding: const EdgeInsets.all(16.0),
      color: Colors.transparent,
      child: Column(
        children: [
          SizedBox(height: AppBreakpoints.screenHeight(context) * 0.012),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                children: [
                  SvgPicture.asset(svgLoginImgPlaceHolder),
                  const SizedBox(height: 9),
                  SvgPicture.asset('assets/svg/loginStaticLine.svg'),
                  const SizedBox(height: 9),
                  SvgPicture.asset(svgLoginImgPlaceHolder),
                  const SizedBox(height: 9),
                  SvgPicture.asset('assets/svg/loginStaticLine.svg'),
                  const SizedBox(height: 9),
                  SvgPicture.asset(svgLoginImgPlaceHolder),
                ],
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          secure,
                          style: AuthStyles.loginStaticHeading(context),
                          textAlign: TextAlign.left,
                        ),
                        const SizedBox(height: 0.8),
                        Text(secureText,
                            softWrap: true,
                            style: AuthStyles.hintText(context),
                            textAlign: TextAlign.left),
                        const SizedBox(height: 68),
                        Text(
                          private,
                          style: AuthStyles.loginStaticHeading(context),
                          textAlign: TextAlign.left,
                        ),
                        const SizedBox(height: 0.8),
                        Text(
                          privateText,
                          softWrap: true,
                          style: AuthStyles.hintText(context),
                          textAlign: TextAlign.left,
                        ),
                        const SizedBox(height: 52),
                        Text(simple,
                            style: AuthStyles.loginStaticHeading(context),
                            textAlign: TextAlign.left),
                        const SizedBox(height: 0.8),
                        Text(simpleText,
                            softWrap: true,
                            style: AuthStyles.hintText(context),
                            textAlign: TextAlign.left),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
