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
import '../inbox_notifier.dart';

class TagListOverlayWidget extends ConsumerWidget {
  /// If true, tapping a tag will add it to selected emails instead of filtering
  final bool isForAddingTags;

  const TagListOverlayWidget({super.key, this.isForAddingTags = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final (:selectedEmailIds, :selectedEmailIdForReadingPane) = ref.watch(
      inboxProvider.select((s) => (
        selectedEmailIds: s.selectedEmailIds,
        selectedEmailIdForReadingPane: s.selectedEmailIdForReadingPane,
      )),
    );
    final inboxNotifier = ref.read(inboxProvider.notifier);

    final tags = ref.watch(
      tagsProvider.select((s) => s.tagsList?.data.tags ?? []),
    );

    // Helper to apply tag filter
    void applyTagFilter(int tagId) {
      inboxNotifier.applyTagFilter(tagId);
    }

    // Helper to add tag to selected emails
    Future<void> addTagToSelectedEmails(int tagId) async {
      final selectedIds = selectedEmailIds;
      final readingPaneEmailId = selectedEmailIdForReadingPane;

      // Determine which email(s) to add tag to
      int emailId = 0;
      if (selectedIds.isNotEmpty) {
        // Multiple selected - use emailId=0 to signal using selectedEmailIds
        emailId = 0;
      } else if (readingPaneEmailId != null) {
        emailId = readingPaneEmailId;
      }

      // Close overlay first to provide immediate UI feedback
      inboxNotifier.setShowTagList(false);

      if (emailId != 0 || selectedIds.isNotEmpty) {
        // Await the tag update to ensure state is properly updated
        // including readingPaneRefreshKey for reading pane refresh
        await inboxNotifier.addEmailTags([tagId], emailId, 0, 'add');
      }

      // Clear selection after tag update completes
      inboxNotifier.clearSelectionAfterTagAdd();
    }

    // Helper to handle tag tap based on mode
    void handleTagTap(int tagId) {
      if (isForAddingTags) {
        addTagToSelectedEmails(tagId);
      } else {
        applyTagFilter(tagId);
      }
    }

    // Helper to close overlays
    void closeOverlays() {
      inboxNotifier.setShowTagList(false);
      inboxNotifier.setShowFilter(false);
    }

    // ---------------- WEB ----------------
    if (kIsWeb && !AdaptiveService.isMobileLayout(context)) {
      return Stack(
        children: [
          /// Backdrop
          Positioned.fill(
            child: GestureDetector(
              onTap: closeOverlays,
              child: const ColoredBox(
                color: Colors.transparent,
              ),
            ),
          ),

          /// Dropdown
          Positioned(
            top: 0,
            right: 16,
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

                /// CONTENT
                child: tags.isNotEmpty
                    ? SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            for (int index = 0;
                                index < tags.length;
                                index++) ...[
                              InkWell(
                                key: Key('tag_list_item_web_${tags[index].id}'),
                                onTap: () => handleTagTap(tags[index].id),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
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
                                      Expanded(
                                        child: Text(
                                          tags[index].tag,
                                          style: AppTypography.labelMedium(context).copyWith(
                                            color: Theme.of(context).colorScheme.onSurface,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              if (index < tags.length - 1)
                                Divider(
                                  height: 1,
                                  thickness: 1,
                                  color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.2),
                                )
                            ]
                          ],
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Text(
                          "No Tags Found",
                          style: AppTypography.bodySmall(context).copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
              ),
            ),
          ),
        ],
      );
    }
    return InkWell(
      onTap: closeOverlays,
      child: Container(
        decoration: const BoxDecoration(color: AppStyles.backDrop),
        child: Column(
          children: [
            Container(
              constraints: BoxConstraints(
                maxHeight: AppBreakpoints.screenHeight(context) * 0.43,
              ),
              color: Theme.of(context).colorScheme.surface,
              padding: const EdgeInsets.only(top: 8),
              child: SingleChildScrollView(
                child: tags.isNotEmpty
                    ? Column(
                        children: [
                          for (int i = 0; i < tags.length; i++)
                            MyDrawerItem(
                              testId: 'tag_list_item_${tags[i].id}',
                              title: tags[i].tag,
                              svgIcon: svgTags,
                              showRightIcon: false,
                              onTap: () => handleTagTap(tags[i].id),
                            )
                        ],
                      )
                    : const SizedBox.shrink(),
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
}
