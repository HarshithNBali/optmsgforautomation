import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../constant/img_path.dart';
import '../../../../constant/string_constant.dart';
import '../../../../constant/styles.dart';
import '../../../../constant/app_typography.dart';
import 'package:optmsg/common/responsive/responsive.dart';
import '../../../../services/common_service.dart';
import '../../../../widgets/drawer_item.dart';
import '../account_notifier.dart';

class AccountTabletLayout extends ConsumerWidget {
  const AccountTabletLayout({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(accountProvider);
    final notifier = ref.read(accountProvider.notifier);
    final isWeb = CommonService().getPlatform() == 'web';

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: _buildContainer(context,
          child: Column(
            children: [
              _buildMembershipRow(context, state.subscriptionDate),
              _divider,
              MyDrawerItem(
                title: deleteAccount,
                svgIcon: svgDelete,
                showIndicator: false,
                showChevron: true,
                onTap: () => notifier.showDeleteDialog(),
              ),
              if (isWeb) ...[
                _divider,
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
    );
  }

  /// ---------- Reusable Container ----------
  Widget _buildContainer(BuildContext context, {required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: context.colors.outlineVariant),
        borderRadius: BorderRadius.circular(AppStyles.radiusM),
      ),
      child: child,
    );
  }

  /// ---------- Membership Row ----------
  Widget _buildMembershipRow(BuildContext context, String subscriptionDate) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          SvgPicture.asset(svgMembers, height: 24, width: 24,
            colorFilter: ColorFilter.mode(context.colors.onSurface, BlendMode.srcIn),
          ),
          const SizedBox(width: 14.5),
          Text(membership, style: AppTypography.drawerTitle(context)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: Icon(Icons.circle, color: context.colors.onSurfaceVariant, size: 6),
          ),
          Text(subscriptionDate),
        ],
      ),
    );
  }

  /// ---------- Common Divider ----------
  static const Divider _divider = Divider();
}
