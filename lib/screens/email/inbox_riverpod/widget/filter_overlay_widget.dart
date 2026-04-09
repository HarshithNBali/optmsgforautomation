import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:optmsg/constant/app_typography.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:optmsg/common/responsive/responsive.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../constant/img_path.dart';
import '../../../../constant/string_constant.dart';
import '../../../../constant/styles.dart';
import '../../../../services/common_service.dart';
import '../../../../services/tags_provider.dart';
import '../../../../widgets/drawer_item.dart';
import '../inbox_notifier.dart';

Widget filterOverlayWidget(WidgetRef ref, BuildContext context) {
  final searchKey = ref.watch(inboxProvider.select((s) => s.searchKey));
  final notifier = ref.read(inboxProvider.notifier);
  final tags = ref.watch(
    tagsProvider.select((s) => s.tagsList?.data.tags ?? []),
  );

  // ---------------- Helpers ----------------

  void applyUnreadFilter() {
    notifier.applyUnreadFilter(searchKey);
  }

  void openTags() {

    if (tags.isNotEmpty) {
      notifier.showTagListFromFilter();
    } else {
      CommonService.animatedToast(
        "No Tags Found",
        "warning",
        null,
        true,
      );
    }
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
                  /// UNREAD
                  InkWell(
                    onTap: applyUnreadFilter,
                    child: Padding(
                      padding:
                      const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          SvgPicture.asset(
                            svgUnread,
                            height: 20,
                            width: 20,
                            colorFilter: ColorFilter.mode(
                              Theme.of(context).colorScheme.onSurfaceVariant,
                              BlendMode.srcIn,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            unread,
                            style: AppTypography.labelMedium(context).copyWith(
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
                    color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.2),
                  ),

                  /// TAGS
                  InkWell(
                    onTap: openTags,
                    child: Padding(
                      padding:
                      const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          SvgPicture.asset(
                            svgTags,
                            height: 20,
                            width: 20,
                            colorFilter: ColorFilter.mode(
                              Theme.of(context).colorScheme.onSurfaceVariant,
                              BlendMode.srcIn,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            tag,
                            style: AppTypography.labelMedium(context).copyWith(
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
      decoration:
      const BoxDecoration(color: AppStyles.backDrop),
      child: Column(
        children: [
          Container(
            color: Theme.of(context).colorScheme.surface,
            padding: const EdgeInsets.only(top: 5),
            child: Column(
              children: [
                MyDrawerItem(
                  title: unread,
                  svgIcon: svgArchive,
                  showRightIcon: false,
                  onTap: applyUnreadFilter,
                ),

                MyDrawerItem(
                  title: tag,
                  svgIcon: svgTags,
                  showRightIcon: false,
                  onTap: openTags,
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
