import 'package:optmsg/common/responsive/responsive.dart';
import 'package:optmsg/constant/app_typography.dart';
import 'package:optmsg/services/adaptive_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../constant/img_path.dart';
import '../../../../constant/styles.dart';
import '../../../../services/tags_provider.dart';
import '../../../../widgets/drawer_item.dart';
import '../archive_list_notifier.dart';
import '../archive_state.dart';

Widget archiveTagListOverlay(
    ArchiveState s, ArchiveNotifier notifier, BuildContext context) {
  if (kIsWeb && !AdaptiveService.isMobileLayout(context)) {
    // Web: Show positioned dropdown menu on the right side
    return Stack(
      children: [
        // Backdrop to close on tap
        Positioned.fill(
          child: GestureDetector(
            onTap: () {
              notifier.closeTagList();
            },
            child: Container(
              color: Colors.transparent,
            ),
          ),
        ),
        // Positioned dropdown menu - aligned to top-right
        Positioned(
          top: 0, // Position at the top of the Stack (below header)
          right: 16, // Position on the right side, aligned with filter icon
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(AppStyles.radiusM),
            clipBehavior: Clip.antiAlias,
            child: Container(
              width: AppBreakpoints.overlayMenuWidth,
              constraints: BoxConstraints(
                maxHeight: AppBreakpoints.screenHeight(context) * 0.43,
              ),
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
              child: Consumer(
                builder: (context, ref, child) {
                  final tagProvider = ref.read(tagsProvider);
                  if (tagProvider.tagsList != null &&
                      tagProvider.tagsList!.data.tags.isNotEmpty) {
                    return SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          for (int index = 0;
                              index < tagProvider.tagsList!.data.tags.length;
                              index++) ...[
                            InkWell(
                              onTap: () {
                                notifier.applyTagFilter(
                                  tagProvider.tagsList!.data.tags[index].id,
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                child: Row(
                                  children: [
                                    SvgPicture.asset(
                                      svgTags,
                                      height: 20,
                                      width: 20,
                                      colorFilter: ColorFilter.mode(
                                          Theme.of(context).colorScheme.onSurfaceVariant, BlendMode.srcIn),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        tagProvider
                                            .tagsList!.data.tags[index].tag,
                                        style: AppTypography.labelMedium(context).copyWith(
                                          color: Theme.of(context).colorScheme.onSurface,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (index <
                                tagProvider.tagsList!.data.tags.length - 1)
                              Divider(
                                height: 1,
                                thickness: 1,
                                color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.2),
                              ),
                          ],
                        ],
                      ),
                    );
                  } else {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      child: Text(
                        'No Tags Found',
                        style: AppTypography.bodySmall(context).copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
          ),
        ),
      ],
    );
  } else {
    return InkWell(
      onTap: () {
        notifier.closeTagList();
      },
      child: Container(
        decoration: const BoxDecoration(color: AppStyles.backDrop),
        child: Column(
          children: [
            Container(
              constraints: BoxConstraints(
                maxHeight: AppBreakpoints.screenHeight(context) * 0.43,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
              ),
              child: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: SingleChildScrollView(
                  child: Consumer(
                    builder: (context, ref, child) {
                      final tagProvider = ref.read(tagsProvider);
                      final tags = tagProvider.tagsList?.data.tags ?? [];
                      return Column(
                        children: [
                          if (tags.isNotEmpty)
                            for (int index = 0; index < tags.length; index++)
                              MyDrawerItem(
                                title: tags[index].tag,
                                svgIcon: svgTags,
                                showRightIcon: false,
                                onTap: () {
                                  notifier.applyTagFilter(tags[index].id);
                                },
                              ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                color: Colors.transparent,
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(16.0)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
