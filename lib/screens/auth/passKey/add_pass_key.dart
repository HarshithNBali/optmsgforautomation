import 'package:optmsg/common/utilites/logger.dart';
import 'package:optmsg/constant/img_path.dart';
import 'package:optmsg/constant/string_constant.dart';
import 'package:optmsg/constant/styles.dart';
import 'package:optmsg/constant/auth_styles.dart';
import 'package:optmsg/services/adaptive_service.dart';
import 'package:optmsg/services/common_service.dart';
import 'package:optmsg/widgets/button_form_field.dart';
import 'package:optmsg/widgets/logo.dart';
import 'package:optmsg/widgets/web_background.dart';
import 'package:optmsg/widgets/web_container.dart';
import 'package:go_router/go_router.dart';
import 'package:optmsg/router/app_routes.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:optmsg/screens/auth/passKey/passkey_notifier.dart';

import '../../../common/app_manger/app_cache.dart';

class AddPassKey extends ConsumerStatefulWidget {
  final String? pageKey;
  const AddPassKey({super.key, this.pageKey = ''});

  @override
  ConsumerState<AddPassKey> createState() => _AddPassKeyState();
}

class _AddPassKeyState extends ConsumerState<AddPassKey> {
  final ScrollController _scrollController = ScrollController();


  @override
  void initState() {
    super.initState();
    // M-17: Set cache synchronously so the redirect guard sees the value
    // immediately, then persist to SharedPreferences in the background.
    _setPasskeyPageOpen(true);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _setPasskeyPageOpen(false);
    super.dispose();
  }

  /// Set flag to track when passkey page is open.
  /// AppCache is updated synchronously; SharedPreferences is persisted
  /// in the background so initState/dispose don't race with the redirect.
  void _setPasskeyPageOpen(bool isOpen) {
    AppCache().setIsPasskeyPageOpen(isOpen);
    _persistPasskeyFlag(isOpen);
  }

  Future<void> _persistPasskeyFlag(bool isOpen) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isPasskeyPageOpen', isOpen);
      await prefs.setBool('isPasskeyPageOpenStatus', isOpen);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final isMobileWeb = CommonService().getPlatform() == "web" &&
        AdaptiveService.isMobileLayout(context);
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (keyboardHeight > 0.0 && _scrollController.hasClients) {
        Future.delayed(const Duration(milliseconds: 100), () {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          }
        });
      }
    });

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: WebBackground(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: isMobileWeb
                              ? (isPortrait
                                  ? AdaptiveService.screenHeight(context) *
                                      0.020
                                  : AdaptiveService.screenHeight(context) *
                                      0.010)
                              : AdaptiveService.screenHeight(context) * 0.030,
                        ),
                        LogoWithSlogan(sloganStyle: AuthStyles.authSlogan(context)),
                        SizedBox(
                          height: isMobileWeb
                              ? (isPortrait
                                  ? AdaptiveService.screenHeight(context) *
                                      0.020
                                  : AdaptiveService.screenHeight(context) *
                                      0.010)
                              : AdaptiveService.screenHeight(context) * 0.050,
                        ),
                        TransparentContainer(
                          height: isMobileWeb
                              ? (isPortrait
                                  ? 480
                                  : (keyboardHeight > 0 ? 400 : 450))
                              : 498,
                          width: isMobileWeb
                              ? AdaptiveService.screenWidth(context) * 0.95
                              : 533,
                          child: SingleChildScrollView(
                            child: Padding(
                              padding: EdgeInsets.all(isMobileWeb ? 8.0 : 10.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SvgPicture.asset(
                                    svgAddPassKey,
                                    height:
                                        isMobileWeb && !isPortrait ? 100 : 128,
                                    width:
                                        isMobileWeb && !isPortrait ? 150 : 198,
                                  ),
                                  const SizedBox(height: AppStyles.space4),
                                  _buildInfoTile(
                                    svgNoPassword,
                                    noPassword,
                                    noPasswordDesc,
                                    isMobileWeb && !isPortrait,
                                  ),
                                  _buildInfoTile(
                                    svgDeviceCompatibility,
                                    deviceCompatibility,
                                    deviceCompatibilityDesc,
                                    isMobileWeb && !isPortrait,
                                  ),
                                  _buildInfoTile(
                                    svgSecuredSafe,
                                    securedSafe,
                                    securedSafeDesc,
                                    isMobileWeb && !isPortrait,
                                  ),
                                  const SizedBox(height: AppStyles.space8),
                                  Consumer(
                                    builder: (context, ref, _) {
                                      final passkeyState =
                                          ref.watch(passkeyProvider);
                                      final isDisabled =
                                          passkeyState.isLoading ||
                                              passkeyState.isEnabling;
                                      return Opacity(
                                        opacity: isDisabled ? 0.5 : 1.0,
                                        child: CustomGradientButton(
                                          onPressed: () async {
                                            if (isDisabled) return;
                                            final success = await ref
                                                .read(passkeyProvider.notifier)
                                                .enablePasskey();
                                            _handleNavigation(success);
                                          },
                                          text: passkeyState.isLoading
                                              ? 'Loading...'
                                              : passkeyState.isEnabling
                                                  ? 'Enabling...'
                                                  : enablePasskey,
                                          textStyle: AuthStyles.authButtonText(context),
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(height: AppStyles.space8),
                                  CustomGradientButton(
                                    onPressed: () {
                                      ref.read(passkeyProvider.notifier).skip();
                                      _handleNavigation(false);
                                    },
                                    text: noThanks,
                                    textStyle: AuthStyles.authButtonText(context),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (kIsWeb &&
                  (AdaptiveService.isDesktopLayout(context) ||
                      (!isMobileWeb && !isPortrait)))
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    CommonService().getCopyrightNotice(),
                    style: AuthStyles.copyright(context),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoTile(
      String icon, String title, String subtitle, bool isCompact) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(
        horizontal: isCompact ? 8.0 : 16.0,
        vertical: isCompact ? 4.0 : 0.0,
      ),
      leading: SvgPicture.asset(
        icon,
        height: isCompact ? 30 : 41,
        width: isCompact ? 30 : 40,
      ),
      title: Text(
        title,
        style: AuthStyles.copyright(context).copyWith(
          fontSize: isCompact ? 14 : 15,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        maxLines: 3,
        style: AuthStyles.hintText(context).copyWith(
          fontSize: isCompact ? 12 : 13,
        ),
      ),
    );
  }

  void _handleNavigation(bool webauthn) {
    final passkeyState = ref.read(passkeyProvider);
    final userData = passkeyState.userData;
    String boardingStatus =
        userData?['user']?['boardingSteps'] ?? 'notification';

    printLog("pageKey", widget.pageKey);

    if (widget.pageKey == 'paymentSuccess') {
      if (!kIsWeb) {
        AppCache().setTabName('');
        context.go(AppRoutes.inbox);
      } else {
        context.go(
          AppRoutes.paymentSuccess,
          extra: {'webauthn': webauthn},
        );
      }
    } else {
      // Skip onboarding if already completed on this device (survives logout)
      if (kIsWeb ||
          boardingStatus == 'notification' ||
          passkeyState.hasCompletedOnboarding) {
        AppCache().setTabName('');
        context.go(AppRoutes.inbox);
      } else {
        context.go(AppRoutes.onboarding, extra: {'status': boardingStatus});
      }
    }
  }
}
