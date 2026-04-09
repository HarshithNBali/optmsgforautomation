
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:optmsg/common/responsive/responsive.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../constant/app_typography.dart';
import '../../../../constant/img_path.dart';
import '../../../../constant/string_constant.dart';
import '../../../../constant/styles.dart';
import '../../../../widgets/drawer_item.dart';
import '../archive_list_notifier.dart';
import '../archive_state.dart';

Widget archiveFilterOverlay(
    ArchiveState s,
    ArchiveNotifier notifier,
    BuildContext context,
    ) {
  // ======================== WEB ========================
  if (kIsWeb) {
    return Stack(
      children: [
        // Backdrop – tap to close overlay
        Positioned.fill(
          child: GestureDetector(
            onTap: notifier.closeFilter,
            child: Container(color: Colors.transparent),
          ),
        ),

        // Dropdown menu (top-right)
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
                  /// -------- UNREAD FILTER --------
                  if (s.currentPath != notifier.sentPath)
                    InkWell(
                      onTap: notifier.applyUnreadFilter,
                      child: _menuRow(svgUnread, unread, context),
                    ),

                  if (s.currentPath != notifier.sentPath)
                    const Divider(height: 1),

                  /// -------- TAG FILTER --------
                  InkWell(
                    onTap: notifier.tagsOnclick,
                    child: _menuRow(svgTags, tag, context),
                  ),

                  /// -------- COMMUNITY FILTER --------
                  if (s.currentPath == notifier.trashPath) ...[
                    const Divider(height: 1),
                    InkWell(
                      onTap: notifier.applyCommunityFilter,
                      child: _menuRow(
                        svgFillFlag,
                        communityRecommendation,
                        context,
                        multiline: true,
                      ),
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

  // ======================== MOBILE ========================
  return InkWell(
    onTap: notifier.closeFilter,
    child: Container(
      decoration: const BoxDecoration(color: AppStyles.backDrop),
      child: Column(
        children: [
          Container(
            color: Theme.of(context).colorScheme.surface,
            padding: const EdgeInsets.only(top: 6),
            child: Column(
              children: [
                if (s.currentPath != notifier.sentPath)
                  MyDrawerItem(
                    title: unread,
                    svgIcon: svgArchive,
                    showRightIcon: false,
                    onTap: notifier.applyUnreadFilter,
                  ),

                MyDrawerItem(
                  title: tag,
                  svgIcon: svgTags,
                  showRightIcon: false,
                  onTap: notifier.tagsOnclick,
                ),

                if (s.currentPath == notifier.trashPath)
                  MyDrawerItem(
                    title: communityRecommendation,
                    svgColor: context.appColors.svgIconMuted,
                    svgIcon: svgFillFlag,
                    showRightIcon: false,
                    onTap: notifier.applyCommunityFilter,
                  ),
              ],
            ),
          ),
          Container(
            decoration: const BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(16.0),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

/// =============== MENU TILE WIDGET =================

Widget _menuRow(
    String icon,
    String label,
    BuildContext context, {
      bool multiline = false,
    }) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    child: Row(
      children: [
        SvgPicture.asset(
          icon,
          height: 20,
          width: 20,
          colorFilter:
          ColorFilter.mode(Theme.of(context).colorScheme.onSurfaceVariant, BlendMode.srcIn),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            softWrap: multiline,
            style: AppTypography.titleSmall(context).copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
      ],
    ),
  );
}
