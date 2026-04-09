import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../constant/img_path.dart';
import '../../../../constant/string_constant.dart';
import '../../../../constant/styles.dart';
import '../../../../constant/app_typography.dart';
import 'package:optmsg/common/responsive/responsive.dart';
import '../../../../services/adaptive_service.dart';
import '../../../../services/common_service.dart';
import '../../../../widgets/drawer_item.dart';
import '../account_notifier.dart';

class AccountMobileLayout extends ConsumerWidget {
  const AccountMobileLayout({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(accountProvider);
    final notifier = ref.read(accountProvider.notifier);

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: context.colors.outlineVariant),
                  borderRadius: BorderRadius.circular(AppStyles.radiusM),
                ),
                child: Column(
                  children: [
                    // MEMBERSHIP ROW
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppStyles.space16, vertical: 14),
                      child: Row(
                        children: [
                          SvgPicture.asset(
                            svgMembers,
                            height: 24,
                            width: 24,
                            colorFilter: ColorFilter.mode(
                                context.colors.onSurface, BlendMode.srcIn),
                          ),
                          const SizedBox(width: AppStyles.space16),
                          Text(
                            membership,
                            style: AppTypography.drawerTitle(context),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            child: Icon(Icons.circle, color: context.colors.onSurfaceVariant, size: 6),
                          ),
                          Text(state.subscriptionDate),
                        ],
                      ),
                    ),
                    const Divider(),
                    MyDrawerItem(
                      title: deleteAccount,
                      svgIcon: svgDelete,
                      showIndicator: false,
                      showChevron: true,
                      onTap: () => notifier.showDeleteDialog(),
                    ),
                    if (CommonService().getPlatform() == 'web') ...[
                      const Divider(),
                      MyDrawerItem(
                        title: 'Subscription',
                        svgIcon: svgSubscription,
                        showIndicator: false,
                        showChevron: true,
                        onTap: () => notifier.navigateToBillingDetails(),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
        if (CommonService().getPlatform() == "android" ||
            CommonService().getPlatform() == "ios")
          Padding(
            padding: const EdgeInsets.all(AppStyles.space16),
            child: Container(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              width: AdaptiveService.screenWidth(context),
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(text: "NOTE:", style: AppTypography.noteText(context)),
                    TextSpan(text: " Please visit", style: AppTypography.slogan(context)),
                    TextSpan(text: " optmsg.com", style: AppTypography.emailText(context)),
                    TextSpan(
                      text: " to make changes to your subscription and payment method.",
                      style: AppTypography.slogan(context),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
