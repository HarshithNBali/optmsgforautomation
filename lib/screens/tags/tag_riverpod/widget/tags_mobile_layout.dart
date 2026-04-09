import 'package:optmsg/common/responsive/responsive.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';

import 'package:optmsg/constant/app_typography.dart';
import '../../../../constant/img_path.dart';

import '../../../../widgets/load_container/delayed_loading_overlay.dart';
import '../../../../widgets/empty_state.dart';
import '../tags_notifier.dart';
import '../tags_state.dart';
import 'show_action_sheet.dart';

class TagsMobileLayout extends ConsumerWidget {
  final TagsState state;
  final TagsNotifier notifier;
  final TextEditingController tagController;
  final WidgetRef parentRef;

  const TagsMobileLayout({
    super.key,
    required this.state,
    required this.notifier,
    required this.tagController,
    required this.parentRef,
  });

  bool get _isInSelectionMode =>
      !state.longPressFlag || state.selectedTagIds.isNotEmpty;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tags = state.tags;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 4.0, 16.0, 4.0),
          child: Text(
            'Tags',
            style: AppTypography.headlineMedium(context).copyWith(
              color: context.colors.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Container(height: 1, color: context.colors.outlineVariant),
        ),
        Expanded(
          child: _buildTagsList(context, tags),
        ),
      ],
    );
  }

  Widget _buildTagsList(BuildContext context, List tags) {
    final inSelection = _isInSelectionMode;

    return DelayedLoadingOverlay(
      isLoading: state.isLoading && tags.isEmpty,
      child: RefreshIndicator(
        color: context.appColors.linkBlue,
        onRefresh: () async {
          notifier.getAllTags(isRefresh: true);
        },
        notificationPredicate: (_) => !inSelection,
        child: tags.isEmpty
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  if (!state.isLoading)
                    const Center(
                      child: EmptyState(variant: EmptyStateVariant.tags),
                    ),
                ],
              )
            : ListView.builder(
                physics: inSelection
                    ? const ClampingScrollPhysics()
                    : const AlwaysScrollableScrollPhysics(),
                itemCount: tags.length,
                itemBuilder: (context, index) {
                  final tag = tags[index];
                  final isSelected = state.selectedTagIds.contains(tag.id);

                  final tagItem = Column(
                    children: [
                      Container(
                        color: isSelected
                            ? context.appColors.messageSelectedRow
                            : Theme.of(context).colorScheme.surface,
                        child: ListTile(
                          leading: inSelection
                              ? Icon(
                                  isSelected
                                      ? Icons.check_box
                                      : Icons.check_box_outline_blank,
                                  color: Theme.of(context).colorScheme.primary,
                                  size: 20,
                                )
                              : SvgPicture.asset(
                                  svgFillTag,
                                  height: 24,
                                  width: 24,
                                ),
                          title: Text(
                            tag.tag,
                            style: AppTypography.drawerTitle(context),
                          ),
                          onTap: () {
                            if (inSelection) {
                              notifier.toggleSelectTag(tag.id);
                            } else {
                              tagController.text = tag.tag;
                              notifier.setId(tag.id);
                              notifier.setEditFlag(true);
                              showActionSheet(
                                  context, 'edit', parentRef, tagController);
                            }
                          },
                          onLongPress: () {
                            if (!inSelection) {
                              // Enter selection mode and select this tag
                              notifier.toggleSelectTag(tag.id);
                            }
                          },
                        ),
                      ),
                      const Divider(),
                    ],
                  );

                  // Disable swipe-to-delete in selection mode
                  if (inSelection) return tagItem;

                  return Dismissible(
                    key: Key(tag.id.toString()),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      color: context.colors.error,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      child:
                          Icon(Icons.delete, color: context.colors.onPrimary),
                    ),
                    confirmDismiss: (direction) async {
                      notifier.deleteTag(tag.id);
                      return false;
                    },
                    child: tagItem,
                  );
                },
              ),
      ),
    );
  }
}
