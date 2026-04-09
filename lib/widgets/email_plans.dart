import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:optmsg/constant/img_path.dart';
import 'package:optmsg/constant/styles.dart';
import 'package:optmsg/constant/app_typography.dart';
import 'package:optmsg/widgets/button_form_field.dart';
import 'package:optmsg/common/responsive/responsive.dart';

class Plan extends StatefulWidget {
  final String title;
  final String subtitle;
  final String price;
  final List<String> features;
  final VoidCallback onPressed;
  final bool isSelected;
  final Function(bool) onSelected;
  final Color? textColor;
  final bool borderCheck;
  final String page;

  const Plan({
    required this.borderCheck,
    required this.title,
    required this.subtitle,
    required this.price,
    required this.features,
    required this.onPressed,
    required this.isSelected,
    required this.onSelected,
    this.textColor,
    super.key,
    required this.page,
  });

  @override
  State<Plan> createState() => _PlanState();
}

class _PlanState extends State<Plan> {
  // Check if a feature is a limitation based on its text
  bool _isLimitationFeature(String feature) {
    final lowerFeature = feature.toLowerCase().trim();
    return lowerFeature.contains('reader only') ||
        lowerFeature.contains('cannot send email') ||
        lowerFeature.contains('deletes after');
  }

  // Calculate monthly price for Annual plan
  String _getDisplayPrice() {
    final isAnnualPlan = widget.title == "Annual Plan";

    if (isAnnualPlan) {
      // Remove $ and convert to number
      final priceValue = double.tryParse(
              widget.price.replaceAll('\$', '').replaceAll(',', '')) ??
          0;
      final monthlyPrice = priceValue / 12;
      return '\$${monthlyPrice.toStringAsFixed(2)}';
    }

    return widget.price;
  }

  // Get responsive card dimensions based on device type
  double _getCardWidth(BuildContext context) {
    final screenWidth = AppBreakpoints.screenWidth(context);
    if (AppBreakpoints.isMobileLayout(context)) {
      // Mobile: full width minus padding
      return screenWidth - 32;
    } else if (AppBreakpoints.isTabletLayout(context)) {
      // Tablet: ~45% of screen width
      return (screenWidth - 48) / 2;
    } else {
      // Desktop: fixed width or proportional
      return 320;
    }
  }

  double _getCardHeight(BuildContext context) {
    if (AppBreakpoints.isMobileLayout(context)) {
      return 420;
    }
    return 450;
  }

  @override
  Widget build(BuildContext context) {
    // Determine card styling based on plan type
    final isAnnualPlan = widget.title == "Annual Plan";

    final cardWidth = _getCardWidth(context);
    final cardHeight = _getCardHeight(context);

    return InkWell(
      onTap: () {
        widget.onSelected(!widget.isSelected);
      },
      child: Stack(
        children: [
          Container(
            width: cardWidth,
            height: cardHeight,
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: isAnnualPlan
                  ? context.appColors.linkBlue
                  : context.appColors.linkBlue.withValues(alpha: 0.3),
              border: widget.isSelected
                  ? (widget.borderCheck
                      ? null
                      : Border.all(color: context.appColors.accent))
                  : (!widget.borderCheck
                      ? null
                      : Border.all(color: context.appColors.accent)),
              borderRadius: BorderRadius.circular(AppStyles.radiusM),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Title - Fixed height to ensure alignment
                SizedBox(
                  height: 38,
                  child: Text(
                    widget.title,
                    style: AppTypography.planName(context).copyWith(
                      color: widget.textColor ?? context.colors.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      // widget.price,
                      _getDisplayPrice(),
                      style: AppTypography.displayLarge(context).copyWith(
                        color: context.colors.onPrimary,
                        fontWeight: FontWeight.bold,
                        height: 1.0,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        '/mo.',
                        style: AppTypography.titleLarge(context).copyWith(
                          color: context.colors.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                // const SizedBox(height: 16.0),

                SizedBox(
                  height: 28,
                  child: widget.title == "Annual Plan"
                      ? Text(
                          '(${widget.price} billed annually)',
                          style: AppTypography.planSubTitle(context).copyWith(
                            color: context.colors.onPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
                const SizedBox(height: 16.0),

                // Features - This will expand to fill available space
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: widget.features.map((feature) {
                        final isLimitation = _isLimitationFeature(feature);

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 4.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: isLimitation
                                    ? SvgPicture.asset(
                                        svgCross,
                                        width: 20,
                                        height: 20,
                                      )
                                    // : SvgPicture.asset(svgTick),
                                    : SvgPicture.asset(
                                        svgTick,
                                        width: 20,
                                        height: 20,
                                      ),
                              ),
                              const SizedBox(width: 8.0),
                              Expanded(
                                child: Text(
                                  feature,
                                  style: AppTypography.planSubTitle(context).copyWith(
                                    color: widget.textColor ?? context.colors.onPrimary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),

                // Button at the bottom - conditional styling
                const SizedBox(height: 16.0),
                _buildButton(),
              ],
            ),
          ),

          // Best deal tag for Annual plan
          if (widget.title == "Annual Plan")
            Positioned(
              top: 0.0,
              right: 0.0,
              child: SizedBox(
                width: 130.0,
                height: 130.0,
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(12.0),
                  ),
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
                              '30% SAVINGS',
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

  Widget _buildButton() {
    final isAnnualPlan = widget.title == "Annual Plan";

    // Annual plan gets gradient button, others get solid blue button
    if (isAnnualPlan) {
      return SizedBox(
        height: 48,
        child: CustomGradientButton(
          text: 'Get ${widget.title}',
          onPressed: widget.page == 'subscription'
              ? () {
                  widget.onSelected(!widget.isSelected);
                }
              : widget.onPressed,
        ),
      );
    } else {
      return SizedBox(
        height: 48,
        child: Container(
          decoration: BoxDecoration(
            color: context.appColors.linkBlue,
            borderRadius: BorderRadius.circular(AppStyles.radiusM),
          ),
          child: ElevatedButton(
            onPressed: widget.page == 'subscription'
                ? () {
                    widget.onSelected(!widget.isSelected);
                  }
                : widget.onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              padding: EdgeInsets.zero,
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppStyles.radiusM),
              ),
            ),
            child: Text(
              'Get ${widget.title}',
              style: AppTypography.labelLarge(context).copyWith(
                color: context.colors.onPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      );
    }
  }
}
