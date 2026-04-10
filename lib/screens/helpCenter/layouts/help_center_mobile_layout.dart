import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:optmsg/common/responsive/responsive.dart';

import '../../../constant/app_typography.dart';
import '../../../constant/img_path.dart';
import '../../../constant/string_constant.dart';
import '../../../constant/styles.dart';
import '../../../widgets/drawer_item.dart';
import 'package:go_router/go_router.dart';
import '../../../router/app_routes.dart';

class HelpCenterMobileLayout extends ConsumerWidget {
  const HelpCenterMobileLayout({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = _helpCenterItems(context);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: context.colors.outlineVariant),
                  borderRadius: BorderRadius.circular(AppStyles.radiusM),
                ),
                child: Column(
                  children: [
                    for (int i = 0; i < items.length; i++) ...[
                        MyDrawerItem(
                          testId: items[i].testId,
                          title: items[i].title,
                          svgIcon: items[i].icon,
                          showIndicator: false,
                          showChevron: true,
                          onTap: () => context.push(items[i].route),
                        ),
                      if (i != items.length - 1)
                        Divider(
                          color: context.colors.outlineVariant,
                          thickness: 1,
                          height: 1,
                        ),
                    ],
                  ],
                ),
              ),
            ),
          ),

          // APP VERSION
          const _AppVersionText(),
        ],
      ),
    );
  }

  List<_HelpCenterItem> _helpCenterItems(BuildContext context) {
    return [
      _HelpCenterItem(
        title: contactUs,
        icon: svgContactUs,
        route: AppRoutes.staticPagePath('contact_us', 'help'),
        testId: 'help_contact_us_tile',
      ),
      const _HelpCenterItem(
        title: faq,
        icon: svgFaq,
        route: AppRoutes.faq,
        testId: 'help_faq_tile',
      ),
      _HelpCenterItem(
        title: privacyPolicy,
        icon: svgPrivacyPolicy,
        route: AppRoutes.staticPagePath('privacy_policy', 'help'),
        testId: 'help_privacy_policy_tile',
      ),
      _HelpCenterItem(
        title: termsAndConditions,
        icon: svgTermsAndCondition,
        route: AppRoutes.staticPagePath('terms_conditions', 'help'),
        testId: 'help_terms_conditions_tile',
      ),
    ];
  }
}

/* -------------------- MODELS -------------------- */

class _HelpCenterItem {
  final String title;
  final String icon;
  final String route;
  final String testId;

  const _HelpCenterItem({
    required this.title,
    required this.icon,
    required this.route,
    required this.testId,
  });
}

/* -------------------- FOOTER -------------------- */

class _AppVersionText extends StatelessWidget {
  const _AppVersionText();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      child: FutureBuilder<PackageInfo>(
        future: PackageInfo.fromPlatform(),
        builder: (context, snapshot) {
          final version = snapshot.data?.version ?? '';
          final buildNumber = snapshot.data?.buildNumber ?? '';
          final display = buildNumber.isNotEmpty
              ? 'v$version.$buildNumber'
              : 'v$version';
          return Text(
            display,
            textAlign: TextAlign.center,
            style: AppTypography.labelSmall(context).copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          );
        },
      ),
    );
  }
}
