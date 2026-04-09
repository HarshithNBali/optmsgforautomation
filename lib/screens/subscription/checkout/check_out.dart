import 'dart:async';

import 'package:intl/intl.dart';
import 'package:optmsg/common/responsive/breakpoints.dart';
import 'package:optmsg/common/responsive/responsive.dart';
import 'package:optmsg/constant/img_path.dart';
import 'package:optmsg/constant/string_constant.dart';
import 'package:optmsg/constant/styles.dart';
import 'package:optmsg/constant/app_typography.dart';
import 'package:optmsg/screens/subscription/checkout/checkout_notifier.dart';
import 'package:optmsg/webPackerHandler/mobile_check_out.dart'
    if (dart.library.js_interop) 'package:optmsg/webPackerHandler/web_check_out.dart';
import 'package:go_router/go_router.dart';
import 'package:optmsg/router/app_routes.dart';
import 'package:optmsg/services/adaptive_service.dart';
import 'package:optmsg/services/common_service.dart';
import 'package:optmsg/widgets/promo_code_text_field.dart';
import 'package:optmsg/widgets/web_background.dart';
import 'package:optmsg/widgets/web_container.dart';

import 'package:optmsg/widgets/button_form_field.dart';
import 'package:optmsg/widgets/load_container/delayed_loading_overlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:optmsg/widgets/dash_border.dart';
import 'package:optmsg/common/app_manger/app_cache.dart';
import 'package:optmsg/services/storage_service.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';


class CheckOutRiverpod extends ConsumerStatefulWidget {
  final String page;
  const CheckOutRiverpod({super.key, required this.page});

  @override
  ConsumerState<CheckOutRiverpod> createState() => _CheckOutRiverpodState();
}

class _CheckOutRiverpodState extends ConsumerState<CheckOutRiverpod> {
  final TextEditingController _promoController = TextEditingController();
  final FocusNode _promoFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await ref.read(checkoutProvider.notifier).initCheckout();
    });
  }

  @override
  void dispose() {
    _promoController.dispose();
    _promoFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(checkoutProvider);
    final notifier = ref.read(checkoutProvider.notifier);

    double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = AppBreakpoints.isMobileLayout(context);
    final isTablet = AppBreakpoints.isTabletLayout(context);

    final double containerWidth = isMobile
        ? screenWidth - 40
        : isTablet
            ? 450
            : 500;

    final double buttonWidth = isMobile
        ? screenWidth - 60
        : isTablet
            ? 400
            : 450;
    final Map<String, dynamic> plan = state.selectedPlan ?? {};
    final String planTitle = (plan['title'] ?? '').toString();
    final String planCharge = (plan['charge'] ?? '').toString();
    final String planDate = () {
      final raw = (plan['nextPaymentDate'] ?? '').toString();
      if (raw.isEmpty) return '-';
      try {
        final dt = DateTime.parse(raw);
        return DateFormat('MMM d, yyyy').format(dt);
      } catch (_) {
        return raw;
      }
    }();

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: WebBackground(
        child: DelayedLoadingOverlay(
          isLoading: state.isLoading,
          child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    if (state.subscriptionPage == 'selectPlan')
                      SvgPicture.asset(
                        svgWebLogo,
                        height: AdaptiveService.screenHeight(context) * 0.040,
                        width: AdaptiveService.screenWidth(context) * 0.144,
                      ),
                    if (state.subscriptionPage == 'selectPlan')
                      const SizedBox(height: 20),

                    /// BACK + STEP
                    if (state.subscriptionPage == 'selectPlan')
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InkWell(
                            onTap: () async {
                              await SecureStorageService()
                                  .writeData('isCheckout', 'false');
                              AppCache().setIsCheckout('false');
                              if (kIsWeb) {
                                final prefs =
                                    await SharedPreferences.getInstance();
                                await prefs.setString('isCheckout', 'false');
                              }
                              if (context.mounted) {
                                if (GoRouter.of(context).canPop()) {
                                  context.pop();
                                } else {
                                  context.go(AppRoutes.plans);
                                }
                              }
                            },
                            child: SizedBox(
                              height: 48,
                              child: Row(
                                children: [
                                  SvgPicture.asset(svgArrowBack),
                                  Text('  $back',
                                      style: AppTypography.appBarTitle1(context)),
                                  const Spacer(),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.primary,
                                      borderRadius: BorderRadius.circular(AppStyles.radiusXXL),
                                    ),
                                    child: Text('Step 4/4',
                                        style: AppTypography.copyright(context)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: AppStyles.space32),
                        ],
                      ),

                    /// BODY
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            Text(orderSummary,
                                style: AppTypography.checkOutTitle(context)),

                            const SizedBox(height: AppStyles.space8),

                            /// ORDER SUMMARY
                            TransparentContainer(
                              height: state.isPromoApplied ? 310 : 253,
                              width: containerWidth,
                              child: SingleChildScrollView(
                                child: Column(
                                  children: [
                                    _row("Plan", planTitle),
                                    _row("Price", '\$$planCharge'),
                                    _row("Next Billing Date", planDate),
                                    _row("Total Amount", '\$$planCharge'),
                                    if (state.isPromoApplied)
                                      _row("Promo applied",
                                          '-\$${state.discount}'),
                                    Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: DashedBorder(
                                        height: 1,
                                        width: double.infinity,
                                        color: Theme.of(context).colorScheme.surface,
                                      ),
                                    ),
                                    _row("Grand Total", '\$${state.grandTotal}',
                                        bold: true),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 8),

                            /// PROMO
                            TransparentContainer(
                              width: containerWidth,
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: PromoCodeTextField(
                                  controller: _promoController,
                                  focusNode: _promoFocusNode,
                                  isEnabled: true,
                                  rightText:
                                      state.isPromoApplied ? "Remove" : "Apply",
                                  showRightText: true,
                                  onSuffixTap: () {
                                    if (state.selectedPlan == null) {
                                      CommonService.animatedToast(
                                          'Plan data still loading, please wait.', 'error');
                                      return;
                                    }
                                    if (state.isPromoApplied) {
                                      _promoController.clear();
                                      notifier.removePromo();
                                    } else {
                                      notifier.applyPromo(_promoController.text);
                                    }
                                    // Re-focus the field so the user can
                                    // continue editing without tapping again.
                                    _promoFocusNode.requestFocus();
                                  },
                                  labelText: 'Add Promo Code',
                                ),
                              ),
                            ),

                            const SizedBox(height: AppStyles.space8),

                            SizedBox(
                              width: buttonWidth,
                              child: CustomGradientButton(
                                text: 'Pay Now',
                                onPressed: () {
                                  // Bug 20: Pre-open tab synchronously within
                                  // user gesture so Safari doesn't block it.
                                  if (kIsWeb) CheckOutImp().preOpenTab();
                                  notifier.makePayment();
                                },
                              ),
                            ),

                            const SizedBox(height: 50),

                            AnimatedContainer(
                              height: keyboardHeight > 0 ? keyboardHeight : 0,
                              duration: const Duration(milliseconds: 300),
                            ),
                          ],
                        ),
                      ),
                    ),

                    if (AdaptiveService.isDesktopLayout(context))
                      Text(CommonService().getCopyrightNotice(),
                          style: AppTypography.copyright(context)),
                  ],
                ),
              ),
            ),
      ),
    );
  }

  Widget _row(String title, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          Text(title,
              style: bold
                  ? AppTypography.loginContent(context)
                  : AppTypography.checkOutSummary(context)),
          const Spacer(),
          Text(value,
              style: bold
                  ? AppTypography.loginContent(context)
                  : AppTypography.checkOutSummary(context)),
        ],
      ),
    );
  }
}
