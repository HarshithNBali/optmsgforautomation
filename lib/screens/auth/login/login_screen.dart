import 'package:optmsg/common/utilites/logger.dart';
import 'package:optmsg/common/responsive/responsive.dart';
import 'package:optmsg/constant/app_config.dart';
import 'package:optmsg/model/auth/auth_state.dart';
import 'package:optmsg/router/app_routes.dart';
import 'package:optmsg/screens/auth/auth_riverpod/auth_notifier.dart';
import 'package:optmsg/screens/auth/login/widgets/login_desktop_layout.dart';
import 'package:optmsg/screens/auth/login/widgets/login_mobile_layout.dart';
import 'package:optmsg/services/common_service.dart';
import 'package:optmsg/services/form_validation.dart';
import 'package:optmsg/widgets/load_container/load_container.dart';
import 'package:optmsg/widgets/load_container/loader_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../services/storage_service.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _loginFormKey = GlobalKey<FormState>();
  final _userNameController = TextEditingController();
  final _formValidation = FormValidationService();

  bool _isHovered = false;

  static const String _upgradePopupKey = 'upgradePopupShownAfterLogin';

  @override
  void dispose() {
    _userNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authProvider.select((s) => s.isLoading));

    ref.listen(authProvider, (previous, next) {
      if (next.status == AuthStatus.awaitingOtp &&
          (previous == null || previous.status != AuthStatus.awaitingOtp)) {
        _handleAwaitingOtp(next);
      }
      if (next.status == AuthStatus.error &&
          (previous == null || previous.status != AuthStatus.error)) {
        _stopLoader();
        // auth_notifier already shows a CustomToast for the error
      }
      if (next.status == AuthStatus.authenticated &&
          (previous == null || previous.status != AuthStatus.authenticated)) {
        _stopLoader();
      }
    });

    return Scaffold(
      key: const Key('login_screen'),
      resizeToAvoidBottomInset: false,
      body: LoaderContainer(
        child: ResponsiveLayoutBuilder(
          mobile: (_, _, _) => LoginMobileLayout(
            formKey: _loginFormKey,
            userNameController: _userNameController,
            formValidation: _formValidation,
            onLogin: _handleLogin,
            onForgot: _handleForgot,
            onRegister: _handleRegister,
            isLoading: isLoading,
          ),
          tablet: (_, _, _) => LoginDesktopLayout(
            formKey: _loginFormKey,
            userNameController: _userNameController,
            formValidation: _formValidation,
            onLogin: _handleLogin,
            onForgot: _handleForgot,
            onRegister: _handleRegister,
            isHovered: _isHovered,
            onHoverChanged: (hover) => setState(() => _isHovered = hover),
            isLoading: isLoading,
          ),
          desktop: (_, _, _) => LoginDesktopLayout(
            formKey: _loginFormKey,
            userNameController: _userNameController,
            formValidation: _formValidation,
            onLogin: _handleLogin,
            onForgot: _handleForgot,
            onRegister: _handleRegister,
            isHovered: _isHovered,
            onHoverChanged: (hover) => setState(() => _isHovered = hover),
            isLoading: isLoading,
          ),
        ),
      ),
    );
  }

  // ================= AUTH LISTENER =================

  void _handleAwaitingOtp(AuthState state) {
    printLog("LoginScreen",
        "_handleAwaitingOtp: verifyUser is ${state.verifyUser != null}");
    if (state.verifyUser == null) {
      printLog(
          "LoginScreen", "_handleAwaitingOtp: verifyUser is NULL, returning");
      return;
    }
    printLog("LoginScreen",
        "_handleAwaitingOtp: stopping loader and pushing OTP screen");
    _stopLoader(); // Ensure loader is stopped before navigation

    final response = state.verifyUser!['data'] ?? {};
    final isDescopeLogin = state.isDescopeLogin ?? false;

    printLog(
        "LoginScreen", "Navigating to OTP with loginId: ${response['mobile']}");

    if (kIsWeb) {
      context.push(
        AppRoutes.webOtpToken,
        extra: {
          'userName': _userNameController.text,
          'pageKey': 'login',
          'webAuthn': isDescopeLogin,
          'loginId': response['mobile'] ?? '',
        },
      );
    } else {
      context.push(
        AppRoutes.enterOtp,
        extra: {
          'userName': _userNameController.text,
          'pageKey': 'login',
          'webAuthn': isDescopeLogin,
          'loginId': response['mobile'],
        },
      );
    }
  }

  // ================= ACTIONS =================

  Future<void> _handleLogin() async {
    if (!_loginFormKey.currentState!.validate()) return;

    await _markUpgradePopupAsHidden();

    _startLoader();
    ref.read(authProvider.notifier).userVerify(_userNameController.text);
  }

  void _handleForgot() {
    context.push(AppRoutes.forgotUsername);
  }

  Future<void> _handleRegister() async {
    if (CommonService().getPlatform() == 'web') {
      context.push(AppRoutes.signup);
      return;
    }

    final uri = Uri.parse(webAppSignUp);
    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    }
  }

  // ================= HELPERS =================

  Future<void> _markUpgradePopupAsHidden() async {
    if (kIsWeb) {
      await SecureStorageService().writeData(_upgradePopupKey, 'false');
    } else {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_upgradePopupKey, false);
    }
  }

  void _startLoader() {
    ref.read(loaderProvider.notifier).set(true);
  }

  void _stopLoader() {
    ref.read(loaderProvider.notifier).set(false);
  }

}
