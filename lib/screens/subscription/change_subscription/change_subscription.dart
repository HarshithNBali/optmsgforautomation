import 'dart:convert';

import 'package:optmsg/constant/img_path.dart';
import 'package:optmsg/constant/styles.dart';
import 'package:optmsg/constant/app_typography.dart';
import 'package:optmsg/common/responsive/responsive.dart';
import 'package:optmsg/services/common_service.dart';
import 'package:go_router/go_router.dart';
import 'package:optmsg/router/app_routes.dart';
import 'package:optmsg/screens/auth/login_post_processor.dart';
import 'package:optmsg/widgets/promo_code_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:optmsg/services/app_bar_config_state.dart';
import 'package:optmsg/widgets/shell_layout.dart';

import '../../../constant/string_constant.dart';
import '../../../services/analytics_service.dart';
import '../../../services/api_service.dart';
import 'package:optmsg/common/app_manger/app_cache.dart';
import '../../../services/storage_service.dart';
import '../../../widgets/load_container/delayed_loading_overlay.dart';
import 'change_subscription_provider.dart'
    show changeSubscriptionProvider;

class ChangeSubscription extends ConsumerStatefulWidget {
  const ChangeSubscription({super.key});

  @override
  ConsumerState<ChangeSubscription> createState() => _ChangeSubscriptionState();
}

class _ChangeSubscriptionState extends ConsumerState<ChangeSubscription> {
  final TextEditingController _promoController = TextEditingController();

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final asyncPlans = ref.watch(changeSubscriptionProvider);

    final isMobile = AppBreakpoints.isMobileLayout(context);
    final isTablet = AppBreakpoints.isTabletLayout(context);

    final secureStorageService = SecureStorageService();

    // Push route — must include title
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ShellLayout.of(context)?.setAppBarConfig(const AppBarConfig(
          title: 'Change Subscription Plan',
          hideUpgradeBanner: true,
        ));
      }
    });

    return Scaffold(
      body: asyncPlans.when(
        loading: () => const DelayedLoadingOverlay(
          isLoading: true,
          child: SizedBox.expand(),
        ),
        error: (e, _) {
          return const Center(child: Text('Something went wrong'));
        },
        data: (planData) {
          final (:plans, :currentPlanType) = planData;
          final availablePlans = plans.data.plans
              .where((p) => p.charge > 0 && p.type != currentPlanType)
              .toList();

          // S-05: Compute savings percentage from plan data
          final allPaidPlans = plans.data.plans.where((p) => p.charge > 0).toList();
          final monthlyPlan = allPaidPlans.where((p) => p.type == 'monthly').firstOrNull;
          final annualPlan = allPaidPlans.where((p) => p.type == 'annual').firstOrNull;
          int savingsPercent = 0;
          if (monthlyPlan != null && annualPlan != null) {
            final monthlyCharge = (monthlyPlan.charge is num)
                ? (monthlyPlan.charge as num).toDouble()
                : double.tryParse(monthlyPlan.charge.toString()) ?? 0.0;
            final annualCharge = (annualPlan.charge is num)
                ? (annualPlan.charge as num).toDouble()
                : double.tryParse(annualPlan.charge.toString()) ?? 0.0;
            if (monthlyCharge > 0) {
              savingsPercent = ((monthlyCharge * 12 - annualCharge) /
                      (monthlyCharge * 12) *
                      100)
                  .round();
            }
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(changeSubscriptionProvider);
            },
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(isMobile ? 12 : 15),
                child: Column(
                  children: [
                    // S-04: Promo code input field
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: PromoCodeTextField(
                        controller: _promoController,
                        labelText: 'Promo Code (optional)',
                        showRightText: _promoController.text.isNotEmpty,
                        rightText: 'Clear',
                        onSuffixTap: () {
                          _promoController.clear();
                          setState(() {});
                        },
                        onChange: () => setState(() {}),
                      ),
                    ),
                    if (isMobile)
                      ...availablePlans.map((plan) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: _PlanCard(
                            title: plan.title,
                            price: '\$${plan.charge}',
                            features: plan.features,
                            selected: false,
                            isMobile: true,
                            savingsPercent: savingsPercent,
                            onSelect: null,
                            onAction: () => _handlePlanAction(
                                context, plan, currentPlanType,
                                secureStorageService),
                          ),
                        );
                      })
                    else
                      Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        alignment: WrapAlignment.center,
                        children: availablePlans.map((plan) {
                          return _PlanCard(
                            title: plan.title,
                            price: '\$${plan.charge}',
                            features: plan.features,
                            selected: false,
                            isTablet: isTablet,
                            savingsPercent: savingsPercent,
                            onSelect: null,
                            onAction: () => _handlePlanAction(
                                context, plan, currentPlanType,
                                secureStorageService),
                          );
                        }).toList(),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _handlePlanAction(
    BuildContext context,
    dynamic plan,
    String currentPlanType,
    SecureStorageService secureStorageService,
  ) async {
    AnalyticsService.instance.logSubscriptionChangeStart(
      currentPlanType,
      plan.title as String,
    );
    final promoCode = _promoController.text.trim();

    if (plan.charge > 0) {
      await secureStorageService.writeObjectData(
          'selected_plan', plan.toJson());

      // Web fallback: if WebCrypto key is lost, checkout_notifier can recover
      // the plan from SharedPreferences (same pattern as select_plan.dart).
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('selected_plan_json', jsonEncode(plan.toJson()));

      await SecureStorageService()
          .writeData('subscriptionPage', 'subscription');
      AppCache().setSubscriptionPage('subscription');

      await SecureStorageService()
          .setString('subscriptionPage', 'subscription');
      if (!context.mounted) return;
      context.push(AppRoutes.checkout, extra: {
        'page': 'subscription',
        if (promoCode.isNotEmpty) 'promoCode': promoCode,
      });
    } else {
      try {
        // S-04: Include promo code in the plan/select-plan API call
        final Map<String, dynamic> data = {"planId": plan.id};
        if (promoCode.isNotEmpty) {
          data["promo"] = promoCode;
        }
        final resp = await ApiService().post('plan/select-plan', data);

        if (resp['success']) {
          if (!context.mounted) return;
          await LoginPostProcessor.goToAddPassKeyIfNeeded(
            pageKey: 'paymentSuccess',
            fallback: () async {
              if (!context.mounted) return;
              context.pushReplacement(AppRoutes.paymentSuccess);
            },
          );
        } else {
          CommonService.animatedToast(resp['message'], 'error');
        }
      } catch (_) {
        CommonService.animatedToast(catchError, 'error');
      }
    }
  }
}

class _PlanCard extends StatelessWidget {
  final String title;
  final String price;
  final List<String> features;
  final bool selected;
  final VoidCallback? onSelect;
  final VoidCallback onAction;
  final bool isMobile;
  final bool isTablet;
  final int savingsPercent;

  const _PlanCard({
    required this.title,
    required this.price,
    required this.features,
    required this.selected,
    this.onSelect,
    required this.onAction,
    this.isMobile = false,
    this.isTablet = false,
    this.savingsPercent = 0,
  });

  @override
  Widget build(BuildContext context) {
    final isAnnualPlan = title == "Annual Plan";
    final border = Border.all(
      color: context.appColors.accentHover,
      width: selected ? 3 : 1,
    );

    String getDisplayPrice() {
      if (isAnnualPlan) {
        final priceValue =
            double.tryParse(price.replaceAll('\$', '').replaceAll(',', '')) ??
                0;
        final monthlyPrice = priceValue / 12;
        return '\$${monthlyPrice.toStringAsFixed(2)}';
      }
      return price;
    }

    final gradient = isAnnualPlan
        ? LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [context.appColors.linkBlue, context.appColors.linkBlue])
        : context.appColors.appBarGradient ?? const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xff121e57), Color(0xff2748c3)]);

    final cardWidth = isMobile ? double.infinity : (isTablet ? 280.0 : 320.0);
    final cardMinHeight = isMobile ? 420.0 : 450.0;

    return InkWell(
      onTap: selected ? null : onSelect,
      borderRadius: BorderRadius.circular(AppStyles.radiusM),
      child: Stack(
        children: [
          Container(
            width: cardWidth,
            constraints: BoxConstraints(minHeight: cardMinHeight),
            decoration: BoxDecoration(
              gradient: gradient,
              border: border,
              borderRadius: BorderRadius.circular(AppStyles.radiusM),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: AppTypography.planName(context).copyWith(
                    color: context.colors.onPrimary,
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      getDisplayPrice(),
                      style: TextStyle(
                        color: context.colors.onPrimary,
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        height: 1.0,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        '/mo.',
                        style: TextStyle(
                          color: context.colors.onPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 28,
                  child: title == "Annual Plan"
                      ? Text(
                          '($price billed annually)',
                          style: AppTypography.planSubTitle(context).copyWith(
                            color: context.colors.onPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
                const SizedBox(height: 16.0),
                ...features.where((f) => f.isNotEmpty).map((f) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        children: [
                          SvgPicture.asset(svgRightGreen,
                              width: 20, height: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              f,
                              style: AppTypography.planSubTitle(context).copyWith(
                                color: context.colors.onPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
                const SizedBox(height: 54),
                Align(
                  alignment: Alignment.centerLeft,
                  child: SizedBox(
                    width: isMobile ? double.infinity : 260,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: isAnnualPlan
                            ? context.appColors.accentGradient
                            : LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [context.appColors.linkBlue, context.appColors.linkBlue],
                              ),
                        borderRadius: BorderRadius.circular(AppStyles.radiusM),
                      ),
                      child: TextButton(
                        onPressed: onAction,
                        style: TextButton.styleFrom(
                          foregroundColor: context.colors.onPrimary,
                          backgroundColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 21),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppStyles.radiusM)),
                        ),
                        child: Text(
                          'Get $title',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // S-05: Dynamically computed savings badge
          if (isAnnualPlan && savingsPercent > 0)
            Positioned(
              top: 0.0,
              right: 0.0,
              child: SizedBox(
                width: 130.0,
                height: 130.0,
                child: ClipRRect(
                  borderRadius:
                      const BorderRadius.only(topRight: Radius.circular(12.0)),
                  child: Stack(
                    children: [
                      Positioned(
                        top: 24.0,
                        right: -35.0,
                        child: Transform.rotate(
                          angle: 0.785398,
                          child: Container(
                            width: 140.0,
                            padding: const EdgeInsets.symmetric(vertical: 6.0),
                            decoration: BoxDecoration(
                              gradient: context.appColors.accentGradient,
                            ),
                            child: Text(
                              '$savingsPercent% SAVINGS',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: context.colors.onPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 9.0,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
