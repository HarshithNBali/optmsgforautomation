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

class HelpCenterTabletLayout extends ConsumerWidget {
  const HelpCenterTabletLayout({super.key});

  static Divider _divider(BuildContext context) => Divider(
    color: context.colors.outlineVariant,
    thickness: 1,
    height: 1,
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = _helpItems(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                        title: items[i].title,
                        svgIcon: items[i].icon,
                        showIndicator: false,
                        showChevron: true,
                        onTap: items[i].onTap,
                      ),
                      if (i != items.length - 1) _divider(context),
                    ],
                  ],
                ),
              ),
            ),
          ),

          const _AppVersion(),
        ],
      ),
    );
  }

  List<_HelpItem> _helpItems(BuildContext context) {
    return [
      _HelpItem(
        title: contactUs,
        icon: svgContactUs,
        onTap: () =>
            context.push(AppRoutes.staticPagePath('contact_us','help')),
      ),
      _HelpItem(
        title: faq,
        icon: svgFaq,
        onTap: () => context.push(AppRoutes.faq),
      ),
      _HelpItem(
        title: privacyPolicy,
        icon: svgPrivacyPolicy,
        onTap: () => context.push(
          AppRoutes.staticPagePath('privacy_policy','help'),
        ),
      ),
      _HelpItem(
        title: termsAndConditions,
        icon: svgTermsAndCondition,
        onTap: () => context.push(
          AppRoutes.staticPagePath('terms_conditions','help'),
        ),
      ),
    ];
  }
}

//////////////////////////////////////////////////////////////////////////////
/// Small helper classes
//////////////////////////////////////////////////////////////////////////////

class _HelpItem {
  final String title;
  final String icon;
  final VoidCallback onTap;

  const _HelpItem({
    required this.title,
    required this.icon,
    required this.onTap,
  });
}

class _AppVersion extends StatelessWidget {
  const _AppVersion();

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
