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

class AccountDesktopLayout extends ConsumerWidget {
  const AccountDesktopLayout({super.key});

  static const Divider _divider = Divider();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(accountProvider);
    final notifier = ref.read(accountProvider.notifier);
    final isWeb = CommonService().getPlatform() == 'web';

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 24,
              ),
              child: _AccountCard(
                children: [
                  _MembershipRow(date: state.subscriptionDate),
                  _divider,
                  _DrawerAction(
                    title: deleteAccount,
                    icon: svgDelete,
                    onTap: () =>
                        notifier.showDeleteDialog(),
                  ),
                  if (isWeb) ...[
                    _divider,
                    _DrawerAction(
                      title: 'Subscription',
                      icon: svgSubscription,
                      onTap: () => notifier
                          .navigateToBillingDetails(),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

//////////////////////////////////////////////////////////////////////////////
/// Card wrapper
//////////////////////////////////////////////////////////////////////////////

class _AccountCard extends StatelessWidget {
  final List<Widget> children;

  const _AccountCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: context.colors.outlineVariant),
        borderRadius: BorderRadius.circular(AppStyles.radiusM),
      ),
      child: Column(children: children),
    );
  }
}

//////////////////////////////////////////////////////////////////////////////
/// Membership row
//////////////////////////////////////////////////////////////////////////////

class _MembershipRow extends StatelessWidget {
  final String date;

  const _MembershipRow({required this.date});

  @override
  Widget build(BuildContext context) {
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
            child:
            Icon(Icons.circle, color: context.colors.onSurfaceVariant, size: 6),
          ),
          Text(date),
        ],
      ),
    );
  }
}

//////////////////////////////////////////////////////////////////////////////
/// Drawer action item
//////////////////////////////////////////////////////////////////////////////

class _DrawerAction extends StatelessWidget {
  final String title;
  final String icon;
  final VoidCallback onTap;

  const _DrawerAction({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return MyDrawerItem(
      title: title,
      svgIcon: icon,
      showIndicator: false,
      showChevron: true,
      onTap: onTap,
    );
  }
}
