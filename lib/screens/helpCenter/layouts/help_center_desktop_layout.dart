import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../constant/app_typography.dart';
import '../../../constant/img_path.dart';
import '../../../constant/string_constant.dart';
import '../../../constant/styles.dart';
import 'package:optmsg/common/responsive/responsive.dart';
import '../../../widgets/drawer_item.dart';
import 'package:go_router/go_router.dart';
import '../../../router/app_routes.dart';

class HelpCenterDesktopLayout extends ConsumerWidget {
  const HelpCenterDesktopLayout({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
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
                    MyDrawerItem(
                      testId: 'help_contact_us_tile',
                      title: contactUs,
                      svgIcon: svgContactUs,
                      showIndicator: false,
                      showChevron: true,
                      onTap: () {
                        context.push(AppRoutes.staticPagePath('contact_us','help'));
                      },
                    ),
                    Divider(
                      color: context.colors.outlineVariant,
                      thickness: 1,
                      height: 1,
                    ),

                    MyDrawerItem(
                      testId: 'help_faq_tile',
                      title: faq,
                      svgIcon: svgFaq,
                      showIndicator: false,
                      showChevron: true,
                      onTap: () {
                        context.push(AppRoutes.faq);
                      },
                    ),
                    Divider(
                      color: context.colors.outlineVariant,
                      thickness: 1,
                      height: 1,
                    ),

                    MyDrawerItem(
                      testId: 'help_privacy_policy_tile',
                      title: privacyPolicy,
                      svgIcon: svgPrivacyPolicy,
                      showIndicator: false,
                      showChevron: true,
                      onTap: () {
                        context.push(AppRoutes.staticPagePath('privacy_policy','help'));
                      },
                    ),
                    Divider(
                      color: context.colors.outlineVariant,
                      thickness: 1,
                      height: 1,
                    ),

                    MyDrawerItem(
                      testId: 'help_terms_conditions_tile',
                      title: termsAndConditions,
                      svgIcon: svgTermsAndCondition,
                      showIndicator: false,
                      showChevron: true,
                      onTap: () {
                        context.push(AppRoutes.staticPagePath('terms_conditions','help'));
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),

          // APP VERSION TEXT
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
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
          ),
        ],
      ),
    );
  }
}
