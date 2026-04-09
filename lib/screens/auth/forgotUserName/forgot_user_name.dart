import 'package:optmsg/common/responsive/responsive.dart';
import 'package:optmsg/screens/auth/forgotUserName/forgot_user_name_mobile.dart';
import 'package:optmsg/screens/auth/web/forgotUserName/web_forgot_user_name.dart';
import 'package:flutter/material.dart';

class ForgotUserName extends StatelessWidget {
  const ForgotUserName({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayoutBuilder(
      mobile: (_, _, _) => const ForgotUserNameMobile(),
      tablet: (_, _, _) => const WebForgotUserName(),
      desktop: (_, _, _) => const WebForgotUserName(),
    );
  }
}
