import 'package:optmsg/services/api_service.dart';
import 'package:optmsg/constant/img_path.dart';
import 'package:optmsg/constant/string_constant.dart';
import 'package:optmsg/constant/styles.dart';
import 'package:optmsg/constant/auth_styles.dart';
import 'package:optmsg/services/adaptive_service.dart';
import 'package:optmsg/services/common_service.dart';
import 'package:optmsg/services/storage_service.dart';
import 'package:optmsg/widgets/button_form_field.dart';
import 'package:optmsg/widgets/logo.dart';
import 'package:optmsg/widgets/web_background.dart';
import 'package:optmsg/widgets/web_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:go_router/go_router.dart';
import 'package:optmsg/router/app_routes.dart';
import 'package:optmsg/screens/auth/auth_riverpod/auth_notifier.dart'
    show authProvider;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import '../../../../common/app_manger/app_cache.dart';

class PaymentSuccess extends ConsumerStatefulWidget {
  final bool webauthn;
  const PaymentSuccess({super.key, required this.webauthn});

  @override
  ConsumerState<PaymentSuccess> createState() => _PaymentSuccessState();
}

class _PaymentSuccessState extends ConsumerState<PaymentSuccess> {
  final ApiService apiService = ApiService();
  final SecureStorageService secureStorageService = SecureStorageService();
  late Map<String, dynamic> userData;
  bool _isDataReady = false;
  bool _isNavigating = false;
  late final YoutubePlayerController _ytController;

  @override
  void initState() {
    super.initState();
    _ytController = YoutubePlayerController.fromVideoId(
      videoId: 'p5G7wt1DksY',
      params: const YoutubePlayerParams(
        showControls: true,
        showFullscreenButton: false,
        enableCaption: false,
      ),
    );
    // Reset to start when video ends (user clicks play to watch again)
    _ytController.listen((event) {
      if (event.playerState == PlayerState.ended) {
        _ytController.seekTo(seconds: 0);
        _ytController.pauseVideo();
      }
    });
    fetchData();
  }

  @override
  void dispose() {
    _ytController.close();
    super.dispose();
  }

  @override

  /// Builds the payment success page.
  ///
  /// This page is shown when a user successfully makes a payment.
  /// It displays a success message and a button to go to the home page.
  /// Additionally, it displays a QR code that can be used to download the app.
  /// The page is wrapped in a [WebBackground] widget which provides a background image.
  ///
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    // Wide: video + QR side-by-side | Medium: stacked, QR horizontal | Narrow: all vertical
    final isWide = screenWidth >= 850;
    final isNarrow = screenWidth < 500;

    // Video container scales up on wide screens
    final videoWidth = isWide
        ? (screenWidth * 0.55).clamp(400.0, 640.0)
        : (screenWidth * 0.9).clamp(280.0, 560.0);

    final qrColumn = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildQrBox(
          asset: "assets/img/qriOS.png",
          badge: svgAppStore,
          url: 'https://apps.apple.com/us/app/optmsg/id6742815057',
        ),
        const SizedBox(height: 8),
        _buildQrBox(
          asset: "assets/img/qrAndroid.png",
          badge: svgPlayStore,
          url: 'https://play.google.com/store/apps/details?id=com.optmsg.stag',
        ),
      ],
    );

    final videoBox = TransparentContainer(
      width: videoWidth,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              welcome,
              style: AuthStyles.heroTitle(context),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppStyles.radiusS),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: YoutubePlayer(
                  controller: _ytController,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(subscription,
                style: AuthStyles.subTitle(context), textAlign: TextAlign.center),
            const SizedBox(height: AppStyles.space8),
            CustomGradientButton(
              onPressed: () {
                if (!_isDataReady || _isNavigating) return;
                setState(() {
                  _isNavigating = true;
                });
                context.go(AppRoutes.inbox);
              },
              text: _isNavigating
                  ? 'Loading...'
                  : (_isDataReady ? home : 'Please wait...'),
              textStyle: AuthStyles.authButtonText(context),
            ),
          ],
        ),
      ),
    );

    return Scaffold(
      body: WebBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(8.0),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height - 16,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // --- Main content ---
                Column(
                  children: [
                    SizedBox(
                      height: AdaptiveService.screenHeight(context) * 0.030,
                    ),
                    LogoWithSlogan(sloganStyle: AuthStyles.authSlogan(context)),
                    SizedBox(
                      height: AdaptiveService.screenHeight(context) * 0.050,
                    ),
                    // Wide: video left, QR stacked right
                    if (isWide)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          videoBox,
                          const SizedBox(width: 12),
                          qrColumn,
                        ],
                      )
                    // Medium: video on top, QR side-by-side below
                    else if (!isNarrow) ...[
                      videoBox,
                      const SizedBox(height: AppStyles.space8),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 10,
                        runSpacing: 8,
                        children: [
                          _buildQrBox(
                            asset: "assets/img/qriOS.png",
                            badge: svgAppStore,
                            url: 'https://apps.apple.com/us/app/optmsg/id6742815057',
                          ),
                          _buildQrBox(
                            asset: "assets/img/qrAndroid.png",
                            badge: svgPlayStore,
                            url: 'https://play.google.com/store/apps/details?id=com.optmsg.stag',
                          ),
                        ],
                      ),
                    ]
                    // Narrow: all stacked vertically
                    else ...[
                      videoBox,
                      const SizedBox(height: AppStyles.space8),
                      qrColumn,
                    ],
                  ],
                ),
                // --- Copyright pinned to bottom, scrolls with content ---
                Padding(
                  padding: const EdgeInsets.only(top: 16, bottom: 8),
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
      ),
    );
  }

  /// Fetches the user's profile data from the server and updates storage.
  ///
  /// This method makes an API call to retrieve the user's profile data. Upon
  /// successful retrieval, it updates the authentication status and user data
  /// in the secure storage. The method also ensures that the `webauthn` status
  /// is updated in the stored user data. If the API call fails, it displays an
  /// error toast message.

  Future<void> fetchData() async {
    AppCache().setQueryParms({});
    try {
      Map<String, dynamic> profileData =
          await apiService.get('user/get-profile');

      if (profileData['success']) {
        await secureStorageService.writeData('isAuthenticated', 'true');
        // Build fresh userData from profile response
        final currentData = ref.read(authProvider).userData;
        userData = currentData != null
            ? Map<String, dynamic>.from(currentData)
            : <String, dynamic>{};
        userData['user'] = profileData['data'];
        // Persist and sync to authProvider in one step
        await ref.read(authProvider.notifier).persistUserData(userData);
        await ref.read(authProvider.notifier).updateUserField('webauthn', widget.webauthn);
        userData = ref.read(authProvider).userData ?? userData;

        // Refresh AuthNotifier to sync in-memory auth state with storage
        ref
            .read(authProvider.notifier)
            .setAuthenticated(true, userData: userData);

        // Mark data as ready so user can navigate
        if (mounted) {
          setState(() {
            _isDataReady = true;
          });
        }
      } else {
        CommonService.animatedToast(catchError, 'error');
        // Still allow navigation on error to prevent user getting stuck
        if (mounted) {
          setState(() {
            _isDataReady = true;
          });
        }
      }
    } catch (error) {
      if (error is! NoInternetException) {
        CommonService.animatedToast(catchError, 'error');
      }
      // Still allow navigation on error to prevent user getting stuck
      if (mounted) {
        setState(() {
          _isDataReady = true;
        });
      }
    }
  }

  Widget _buildQrBox({
    required String asset,
    required String badge,
    required String url,
    double boxWidth = 180,
    double boxHeight = 200,
    double imageSize = 125,
  }) {
    return TransparentContainer(
      height: boxHeight,
      width: boxWidth,
      child: InkWell(
        onTap: () => openStore(url),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(asset, height: imageSize, width: imageSize),
            const SizedBox(height: AppStyles.space8),
            SvgPicture.asset(badge),
          ],
        ),
      ),
    );
  }

  Future<void> openStore(String url) async {
    final openUrl = Uri.parse(url);
    if (await canLaunchUrl(openUrl)) {
      await launchUrl(openUrl, mode: LaunchMode.externalApplication);
    }
  }
}
