import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:optmsg/screens/subscription/plans/plans_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:optmsg/router/app_routes.dart';
import 'package:optmsg/services/common_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:optmsg/constant/img_path.dart';
import 'package:optmsg/constant/string_constant.dart';
import 'package:optmsg/constant/styles.dart';
import 'package:optmsg/common/responsive/responsive.dart';
import 'package:optmsg/constant/app_typography.dart';
import 'package:optmsg/screens/auth/login_post_processor.dart';
import 'package:optmsg/common/responsive/breakpoints.dart';
import 'package:optmsg/widgets/email_plans.dart';
import 'package:optmsg/widgets/load_container/delayed_loading_overlay.dart';
import 'package:optmsg/widgets/web_background.dart';
import 'package:optmsg/common/app_manger/app_cache.dart';
import 'package:optmsg/services/storage_service.dart';

import '../../../services/analytics_service.dart';
import '../../../services/api_service.dart';

class Plans extends ConsumerStatefulWidget {
  const Plans({super.key});

  @override
  ConsumerState<Plans> createState() => _PlansState();
}

class _PlansState extends ConsumerState<Plans> {
  final SecureStorageService secureStorageService = SecureStorageService();
  final AnalyticsService _analytics = AnalyticsService.instance;
  String _subscriptionPage = AppCache().subscriptionPage;

  @override
  void initState() {
    super.initState();
    _analytics.logPlanView();
    _loadSubscriptionPage();
  }

  Future<void> _loadSubscriptionPage() async {
    final page = await secureStorageService.readData('subscriptionPage');
    if (mounted) {
      setState(() {
        _subscriptionPage = page ?? '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final plansAsync = ref.watch(plansProvider);

    final isMobile = AppBreakpoints.isMobileLayout(context);
    final isTablet = AppBreakpoints.isTabletLayout(context);
    final screenHeight = AppBreakpoints.screenHeight(context);
    final screenWidth = AppBreakpoints.screenWidth(context);

    final bool isSignupFlow = _subscriptionPage == 'selectPlan';

    // M-05: During signup, canPop() is false after page refresh. Don't
    // navigate to /login (creates a redirect loop back to /plans).
    final canGoBack = isSignupFlow && GoRouter.of(context).canPop();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (!isSignupFlow) return;
        if (canGoBack) {
          context.pop();
        }
        // If can't pop, do nothing — profile is already submitted,
        // user must pick a plan to continue.
      },
      child: Scaffold(
      body: WebBackground(
        child: plansAsync.when(
          loading: () => const DelayedLoadingOverlay(
            isLoading: true,
            child: SizedBox.expand(),
          ),
          error: (e, _) {
            return const Center(child: Text('Something went wrong'));
          },
          data: (planList) {
            final plans = planList.data.plans;

            return Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      ref.invalidate(plansProvider);
                    },
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.all(isMobile ? 12 : 8),
                        child: Column(
                          children: [
                            // M-05: Only show back button if there's
                            // somewhere to go back to. After page refresh in
                            // signup flow, canPop() is false and going to
                            // /login creates a redirect loop.
                            if (canGoBack)
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: TextButton.icon(
                                    onPressed: () => context.pop(),
                                    icon: SvgPicture.asset(svgArrowBack),
                                    label: Text(back,
                                        style: AppTypography.appBarTitle1(context)),
                                    style: TextButton.styleFrom(
                                      minimumSize: const Size(0, 48),
                                      padding: EdgeInsets.zero,
                                    ),
                                  ),
                                ),
                              ),
                            SvgPicture.asset(
                              svgWebLogo,
                              height: screenHeight * (isMobile ? 0.035 : 0.040),
                              width: screenWidth * (isMobile ? 0.3 : 0.144),
                            ),
                            SizedBox(height: screenHeight * 0.02),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                borderRadius: BorderRadius.circular(AppStyles.radiusXXL),
                              ),
                              child: Text(
                                'Step 3/4',
                                style: AppTypography.copyright(context),
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.025),
                            Text(
                              platTitle,
                              textAlign: TextAlign.center,
                              style: isMobile
                                  ? AppTypography.userNameTitle(context)
                                      .copyWith(fontSize: 22)
                                  : AppTypography.userNameTitle(context),
                            ),
                            SizedBox(height: screenHeight * 0.005),
                            Text(
                              planSubTitle,
                              textAlign: TextAlign.center,
                              style: isMobile
                                  ? AppTypography.planSubTitle(context)
                                      .copyWith(fontSize: 14)
                                  : AppTypography.planSubTitle(context),
                            ),
                            SizedBox(height: screenHeight * 0.02),
                            _buildPlansLayout(
                              plans,
                              isMobile: isMobile,
                              isTablet: isTablet,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    CommonService().getCopyrightNotice(),
                    textAlign: TextAlign.center,
                    style: AppTypography.copyright(context),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    ),
    );
  }

  Widget _buildPlansLayout(
    List plans, {
    required bool isMobile,
    required bool isTablet,
  }) {
    final selectedType = ref.watch(selectedPlanTypeProvider);
    final selectedIndex = plans.indexWhere((e) => e.type == selectedType);

    final children = plans.asMap().entries.map((entry) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Plan(
          page: 'plans',
          borderCheck: false,
          title: entry.value.title,
          subtitle: entry.value.description,
          price: entry.value.charge > 0 ? '\$${entry.value.charge}' : '\$0.00',
          features: entry.value.features,
          isSelected: entry.key == selectedIndex,
          onSelected: (_) {
            ref.read(selectedPlanTypeProvider.notifier).set(entry.value.type);
          },
          onPressed: () => _handlePlanAction(entry.value),
        ),
      );
    }).toList();

    if (isMobile) return Column(children: children);

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: isTablet ? 12 : 16,
      runSpacing: isTablet ? 12 : 16,
      children: children,
    );
  }

  Future<void> _handlePlanAction(dynamic plan) async {
    try {
      _analytics.logPlanSelected(
        plan.title as String,
        plan.type as String,
        (plan.charge as num).toDouble(),
      );
      if (plan.charge > 0) {
        await secureStorageService.writeObjectData(
          'selected_plan',
          plan.toJson(),
        );
        // Web fallback: if WebCrypto key is lost (private browsing / cleared
        // IndexedDB), checkout_notifier can recover the plan from here.
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('selected_plan_json', jsonEncode(plan.toJson()));
        await SecureStorageService()
            .writeData('subscriptionPage', 'selectPlan');
        AppCache().setSubscriptionPage('selectPlan');
        await SecureStorageService()
            .setString('subscriptionPage', 'selectPlan');
        if (!mounted) return;
        context.push(
          AppRoutes.checkout,
          extra: {'page': 'selectPlan'},
        );
      } else {
        _analytics.logFreePlanSelected(plan.title as String);
        final resp = await ApiService().post(
          'plan/select-plan',
          {"planId": plan.id},
        );

        if (resp['success']) {
          await _handleFreePlanSuccess();
        } else {
          CommonService.animatedToast(resp['message'], 'error');
        }
      }
    } catch (_) {
      CommonService.animatedToast(catchError, 'error');
    }
  }

  Future<void> _handleFreePlanSuccess() async {
    await secureStorageService.writeData('signupInProgress', 'false');
    AppCache().setSignupInProgress('false');
    await LoginPostProcessor.goToAddPassKeyIfNeeded(
      pageKey: 'paymentSuccess',
      fallback: () async {
        if (!mounted) return;
        // M-04: Use go() instead of push() to replace the nav stack.
        // push() leaves plans on the stack, letting users press browser
        // back to return to plan selection after completing signup.
        context.go(AppRoutes.paymentSuccess, extra: {'webauthn': false});
      },
    );
  }
}
