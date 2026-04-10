import 'package:descope/descope.dart';
import 'package:optmsg/common/responsive/responsive.dart';
import 'package:optmsg/screens/auth/setupProfile/widgets/setup_profile_desktop_layout.dart';
import 'package:optmsg/screens/auth/setupProfile/widgets/setup_profile_mobile_layout.dart';
import 'package:optmsg/services/form_validation.dart';
import 'package:optmsg/common/app_manger/app_cache.dart';
import 'package:optmsg/common/utilites/logger.dart';
import 'package:optmsg/services/storage_service.dart';
import 'package:go_router/go_router.dart';
import 'package:optmsg/router/app_routes.dart';
import 'package:optmsg/router/app_router.dart' show unmuteRouterRefresh;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:optmsg/screens/auth/auth_riverpod/auth_notifier.dart';
import 'package:intl/intl.dart';

class SetupProfileScreen extends ConsumerStatefulWidget {
  final String userName;

  const SetupProfileScreen({super.key, required this.userName});

  @override
  ConsumerState<SetupProfileScreen> createState() => _SetupProfileScreenState();
}

class _SetupProfileScreenState extends ConsumerState<SetupProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _dobController = TextEditingController();
  final _formValidation = FormValidationService();
  final _secureStorage = SecureStorageService();

  String _deviceToken = '';
  late final String _resolvedUserName;

  @override
  void initState() {
    super.initState();
    // M-02: Fallback to Descope session loginId when extras are lost on web
    // page refresh. This prevents a malformed email (e.g. "@optmsg.com").
    _resolvedUserName = widget.userName.isNotEmpty
        ? widget.userName
        : _userNameFromDescope();
    if (_resolvedUserName.isEmpty) {
      printLog('SetupProfileScreen',
          'WARNING: userName is empty and no Descope session fallback available');
    }
    _getDeviceToken();
  }

  String _userNameFromDescope() {
    try {
      final loginIds = Descope.sessionManager.session?.user.loginIds;
      if (loginIds != null && loginIds.isNotEmpty) {
        return loginIds.first;
      }
    } catch (_) {}
    return '';
  }

  Future<void> _getDeviceToken() async {
    _deviceToken = (await _secureStorage.readData('deviceToken')) ?? "";
    setState(() {});
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isReadOnly =
        ref.watch(authProvider.select((s) => s.isReadOnly));
    return Scaffold(
      key: const Key('setup_profile_screen'),
      resizeToAvoidBottomInset: true,
      body: ResponsiveLayoutBuilder(
        mobile: (ctx, deviceType, width) => SetupProfileMobileLayout(
          formKey: _formKey,
          firstNameController: _firstNameController,
          lastNameController: _lastNameController,
          dobController: _dobController,
          formValidation: _formValidation,
          onSubmit: _handleSubmit,
          onLogin: _handleLogin,
          readOnly: isReadOnly,
        ),
        tablet: (ctx, deviceType, width) => SetupProfileDesktopLayout(
          formKey: _formKey,
          firstNameController: _firstNameController,
          lastNameController: _lastNameController,
          dobController: _dobController,
          formValidation: _formValidation,
          onSubmit: _handleSubmit,
          onLogin: _handleLogin,
          readOnly: isReadOnly,
        ),
        desktop: (ctx, deviceType, width) => SetupProfileDesktopLayout(
          formKey: _formKey,
          firstNameController: _firstNameController,
          lastNameController: _lastNameController,
          dobController: _dobController,
          formValidation: _formValidation,
          onSubmit: _handleSubmit,
          onLogin: _handleLogin,
          readOnly: isReadOnly,
        ),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final dobForAPI = _dateFormatForAPI(_dobController.text);

    await ref.read(authProvider.notifier).setupProfile(
          firstName: _firstNameController.text,
          lastName: _lastNameController.text,
          dob: dobForAPI,
          deviceToken: _deviceToken,
          userName: _resolvedUserName, // M-02: use resolved name
          onSuccess: () async {
            // M-03: Wrap in try/finally so unmuteRouterRefresh() always runs.
            // If it doesn't, GoRouter stops responding to auth state changes
            // (logout, session expiry) for the rest of the session.
            try {
              if (mounted) {
                await SecureStorageService()
                    .writeData('subscriptionPage', 'selectPlan');
                AppCache().setSubscriptionPage('selectPlan');
                await SecureStorageService()
                    .setString('subscriptionPage', 'selectPlan');
                // R-04: Use push (not go) so /setup-profile stays in the
                // browser history. go() replaces the history entry, causing
                // back-navigation from /plans to skip /setup-profile and land
                // on /login, which then redirects to /plans in a loop.
                context.push(AppRoutes.plans);
              }
            } finally {
              // Re-enable GoRouter refresh now that navigation is done.
              // Must run even if !mounted so future auth changes work.
              unmuteRouterRefresh();
            }
          },
        );
  }

  void _handleLogin() {
    context.go(AppRoutes.login);
  }

  String _dateFormatForAPI(String inputDate) {
    DateTime parsedDate = DateFormat('MM/dd/yyyy').parse(inputDate);
    return DateFormat('yyyy-MM-dd').format(parsedDate);
  }
}
