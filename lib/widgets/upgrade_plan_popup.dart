import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:optmsg/constant/app_typography.dart';
import 'package:optmsg/constant/img_path.dart';
import 'package:optmsg/constant/styles.dart';
import 'package:optmsg/common/responsive/responsive.dart';

Widget upgradePlanPopup({
  required BuildContext context,
  required String userEmail,
  required VoidCallback onUpgrade,
  required VoidCallback onClose,
  int? subscriptionEndDate,
}) {
  // Logic for days remaining
  int daysRemaining() {
    if (subscriptionEndDate == null) return 0;
    int endMs = subscriptionEndDate < 2000000000
        ? subscriptionEndDate * 1000
        : subscriptionEndDate;
    final now = DateTime.now();
    final end = DateTime.fromMillisecondsSinceEpoch(endMs);
    final diff = end.difference(now).inDays;
    return diff < 0 ? 0 : diff;
  }

  final bool isMobile = AppBreakpoints.isMobileLayout(context);
  final int days = daysRemaining();

  return ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: AppBreakpoints.popupMaxWidth),
    child: Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(AppStyles.radiusM),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () {
                onClose();
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                child: SvgPicture.asset(
                  svgCloseBtn,
                  height: 24,
                  width: 24,
                  colorFilter: ColorFilter.mode(
                    context.colors.onPrimary,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          ),
          // Content
          SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(isMobile ? 24.0 : 32.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 12),
                  // Clock icon
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: SvgPicture.asset(
                        svgClockImg,
                        width: 32,
                        height: 32,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Main heading
                  Text(
                    'Your Reader Plan ends in $days ${days == 1 ? 'day' : 'days'}',
                    textAlign: TextAlign.center,
                    style: AppTypography.displayLarge(context).copyWith(
                      color: context.colors.onPrimary,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Message
                  Text(
                    'Upgrade to a paid plan today to keep your address $userEmail and begin sending messages.',
                    textAlign: TextAlign.center,
                    style: AppTypography.bodyMedium(context).copyWith(
                      color: context.colors.onPrimary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Upgrade button
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: onUpgrade,
                      borderRadius: BorderRadius.circular(AppStyles.radiusS),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          gradient: context.appColors.accentGradient,
                          borderRadius: BorderRadius.circular(AppStyles.radiusS),
                        ),
                        child: Text(
                          'Upgrade your plan',
                          textAlign: TextAlign.center,
                          style: AppTypography.titleMedium(context).copyWith(
                            color: context.colors.onPrimary,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Footer text
                  Text(
                    'Don\'t miss out on uninterrupted service and premium features.',
                    textAlign: TextAlign.center,
                    style: AppTypography.bodySmall(context).copyWith(
                      color: context.colors.onPrimary,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
