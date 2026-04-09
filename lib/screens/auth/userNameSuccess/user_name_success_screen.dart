import 'package:optmsg/common/responsive/responsive.dart';
import 'package:optmsg/router/app_routes.dart';
import 'package:go_router/go_router.dart';
import 'package:optmsg/screens/auth/userNameSuccess/widgets/success_desktop_layout.dart';
import 'package:optmsg/screens/auth/userNameSuccess/widgets/success_mobile_layout.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter/material.dart';

class UserNameSuccessScreen extends ConsumerWidget {
  const UserNameSuccessScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: ResponsiveLayoutBuilder(
        mobile: (ctx, deviceType, width) => SuccessMobileLayout(
          onBackToLogin: () => _navigateToLogin(context),
        ),
        desktop: (ctx, deviceType, width) => SuccessDesktopLayout(
          onBackToLogin: () => _navigateToLogin(context),
        ),
      ),
    );
  }

  void _navigateToLogin(BuildContext context) {
    context.go(AppRoutes.login);
  }
}
