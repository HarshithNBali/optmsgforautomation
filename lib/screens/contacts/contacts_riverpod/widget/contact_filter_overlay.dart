import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:optmsg/constant/app_typography.dart';
import 'package:optmsg/common/responsive/responsive.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../constant/img_path.dart';
import '../../../../constant/styles.dart';
import '../../../../widgets/drawer_item.dart';
import '../contact_list_notifier.dart';

Widget contactFilterOverlay(
  BuildContext context,
  ContactListNotifier notifier,
) {
  void applyPersonFilter() {
    notifier.setContactTypeFilter('person');
  }

  void applyCompanyFilter() {
    notifier.setContactTypeFilter('company');
  }

  // ---------------- WEB ----------------
  if (kIsWeb) {
    return Stack(
      children: [
        /// Backdrop
        Positioned.fill(
          child: GestureDetector(
            onTap: () => notifier.setShowFilter(false),
            child: const ColoredBox(
              color: Colors.transparent,
            ),
          ),
        ),

        /// Dropdown menu
        Positioned(
          top: 0,
          right: 16,
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(AppStyles.radiusM),
            child: Container(
              width: AppBreakpoints.overlayMenuWidth,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(AppStyles.radiusM),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  /// PEOPLE
                  InkWell(
                    onTap: applyPersonFilter,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          SvgPicture.asset(
                            svgContactTypeUser,
                            height: 20,
                            width: 20,
                            colorFilter: ColorFilter.mode(
                              Theme.of(context).colorScheme.onSurfaceVariant,
                              BlendMode.srcIn,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'People',
                            style:
                                AppTypography.labelMedium(context).copyWith(
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  Divider(
                    height: 1,
                    thickness: 1,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurfaceVariant
                        .withValues(alpha: 0.2),
                  ),

                  /// COMPANIES
                  InkWell(
                    onTap: applyCompanyFilter,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          SvgPicture.asset(
                            svgContactTypeOffice,
                            height: 20,
                            width: 20,
                            colorFilter: ColorFilter.mode(
                              Theme.of(context).colorScheme.onSurfaceVariant,
                              BlendMode.srcIn,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Companies',
                            style:
                                AppTypography.labelMedium(context).copyWith(
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ---------------- MOBILE ----------------
  return InkWell(
    onTap: () => notifier.setShowFilter(false),
    child: Container(
      decoration: const BoxDecoration(color: AppStyles.backDrop),
      child: Column(
        children: [
          Container(
            color: Theme.of(context).colorScheme.surface,
            padding: const EdgeInsets.only(top: 5),
            child: Column(
              children: [
                MyDrawerItem(
                  title: 'People',
                  svgIcon: svgContactTypeUser,
                  showRightIcon: false,
                  onTap: applyPersonFilter,
                ),
                MyDrawerItem(
                  title: 'Companies',
                  svgIcon: svgContactTypeOffice,
                  showRightIcon: false,
                  onTap: applyCompanyFilter,
                ),
              ],
            ),
          ),
          Container(
            decoration: const BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
