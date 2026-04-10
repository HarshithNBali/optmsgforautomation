import 'package:optmsg/common/responsive/responsive.dart';
import 'package:optmsg/screens/auth/createAccount/widgets/create_account_desktop_layout.dart';
import 'package:optmsg/screens/auth/createAccount/widgets/create_account_mobile_layout.dart';
import 'package:optmsg/screens/auth/auth_riverpod/auth_notifier.dart';
import 'package:optmsg/services/form_validation.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:optmsg/router/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:optmsg/services/common_service.dart';

class CreateAccountScreen extends ConsumerStatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  ConsumerState<CreateAccountScreen> createState() =>
      _CreateAccountScreenState();
}

class _CreateAccountScreenState extends ConsumerState<CreateAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _userNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _formValidation = FormValidationService();

  bool _acceptTerms = false;
  bool _acceptCondition = false;

  @override
  void dispose() {
    _userNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isUserNameAvailable =
        ref.watch(authProvider.select((s) => s.isUserNameAvailable));
    final isLoading = ref.watch(authProvider.select((s) => s.isLoading));

    return Scaffold(
      key: const Key('signup_screen'),
      resizeToAvoidBottomInset: true,
      body: ResponsiveLayoutBuilder(
        mobile: (ctx, deviceType, width) => CreateAccountMobileLayout(
          formKey: _formKey,
          userNameController: _userNameController,
          phoneController: _phoneController,
          formValidation: _formValidation,
          isUserNameAvailable: isUserNameAvailable,
          acceptTerms: _acceptTerms,
          acceptCondition: _acceptCondition,
          onSubmit: _handleSubmit,
          onLogin: _handleLogin,
          onBack: () => context.pop(),
          onUserNameChanged: () => ref
              .read(authProvider.notifier)
              .checkUserName(_userNameController.text),
          onAcceptTermsChanged: (v) =>
              setState(() => _acceptTerms = v ?? false),
          onAcceptConditionChanged: (v) =>
              setState(() => _acceptCondition = v ?? false),
          isLoading: isLoading,
        ),
        tablet: (ctx, deviceType, width) => CreateAccountDesktopLayout(
          formKey: _formKey,
          userNameController: _userNameController,
          phoneController: _phoneController,
          formValidation: _formValidation,
          isUserNameAvailable: isUserNameAvailable,
          acceptTerms: _acceptTerms,
          acceptCondition: _acceptCondition,
          onSubmit: _handleSubmit,
          onLogin: _handleLogin,
          onUserNameChanged: () => ref
              .read(authProvider.notifier)
              .checkUserName(_userNameController.text),
          onAcceptTermsChanged: (v) =>
              setState(() => _acceptTerms = v ?? false),
          onAcceptConditionChanged: (v) =>
              setState(() => _acceptCondition = v ?? false),
          isLoading: isLoading,
        ),
        desktop: (ctx, deviceType, width) => CreateAccountDesktopLayout(
          formKey: _formKey,
          userNameController: _userNameController,
          phoneController: _phoneController,
          formValidation: _formValidation,
          isUserNameAvailable: isUserNameAvailable,
          acceptTerms: _acceptTerms,
          acceptCondition: _acceptCondition,
          onSubmit: _handleSubmit,
          onLogin: _handleLogin,
          onUserNameChanged: () => ref
              .read(authProvider.notifier)
              .checkUserName(_userNameController.text),
          onAcceptTermsChanged: (v) =>
              setState(() => _acceptTerms = v ?? false),
          onAcceptConditionChanged: (v) =>
              setState(() => _acceptCondition = v ?? false),
          isLoading: isLoading,
        ),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_acceptTerms) {
      CommonService.animatedToast(
          'Please Accept Terms and Conditions and Privacy Policy', 'error');
      return;
    }

    if (!_acceptCondition) {
      CommonService.animatedToast(
          'Please Accept Consent to receive SMS messages', 'error');
      return;
    }

    final success = await ref.read(authProvider.notifier).signUp(
          _userNameController.text,
          _phoneController.text,
        );

    if (success && mounted) {
      if (kIsWeb) {
        await context.push(
          AppRoutes.webOtpToken,
          extra: {
            'userName': _userNameController.text,
            'pageKey': 'signup',
            'loginId': _phoneController.text,
          },
        );
      } else {
        await context.push(
          AppRoutes.enterOtp,
          extra: {
            'userName': _userNameController.text,
            'pageKey': 'signup',
            'loginId': _phoneController.text,
          },
        );
      }
    }
  }

  void _handleLogin() {
    context.go(AppRoutes.login);
  }
}
