import 'package:optmsg/common/responsive/responsive.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';

import 'package:optmsg/constant/app_typography.dart';
import '../../../../constant/img_path.dart';
import '../../../../constant/styles.dart';
import '../../../../constant/string_constant.dart';
import '../../../../model/tags_list_model.dart';
import '../../../../widgets/load_container/delayed_loading_overlay.dart';
import '../../../../widgets/empty_state.dart';
import '../../../../widgets/common_web_button.dart';
import '../tags_notifier.dart';
import '../tags_state.dart';
import 'show_action_sheet.dart';

class TagsTabletLayout extends ConsumerWidget {
  final TagsState state;
  final TagsNotifier notifier;
  final TextEditingController tagController;
  final WidgetRef parentRef;

  const TagsTabletLayout({
    super.key,
    required this.state,
    required this.notifier,
    required this.tagController,
    required this.parentRef,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tags = state.tags;
    final dividerColor = context.colors.outlineVariant;
    final isTablet = AppBreakpoints.isTabletLayout(context);
    final isNativeTabletLandscape =
        !kIsWeb &&
        isTablet &&
        MediaQuery.of(context).orientation == Orientation.landscape;
    final bool canShowToggle = kIsWeb || isNativeTabletLandscape;
    final bool isMultiSelectActive =
        canShowToggle &&
        (state.showCheckboxes || state.selectedTagIds.isNotEmpty);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Add button row
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border(
              bottom: BorderSide(width: 1, color: dividerColor),
            ),
          ),
          child: Row(
            children: [
              CommonWebButton(
                onPressed: () {
                  showActionSheet(context, 'add', parentRef, tagController);
                },
                iconAsset: svgTags,
                label: add,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                iconSize: 20,
                spacing: 8,
                textStyle: AppTypography.titleMedium(context).copyWith(
                  fontWeight: FontWeight.w500,
                  color: context.colors.onPrimary,
                ),
                backgroundColor: context.appColors.accentButton,
                borderRadius: const BorderRadius.all(Radius.circular(8)),
              ),
              const Spacer(),
              if (state.hasSelection)
                IconButton(
                  icon: SvgPicture.asset(
                    svgDelete,
                    height: 20,
                    width: 20,
                    colorFilter: ColorFilter.mode(
                      context.colors.onSurfaceVariant,
                      BlendMode.srcIn,
                    ),
                  ),
                  tooltip: 'Delete Selected',
                  onPressed: () => notifier.deleteSelectedTags(),
                ),
            ],
          ),
        ),
        // Header with checkbox toggle
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 4, 16, 4),
          child: Row(
            children: [
              if (canShowToggle)
                SizedBox(
                  width: 36,
                  height: 36,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(AppStyles.radiusXL),
                    onTap: () {
                      if (!isMultiSelectActive) {
                        notifier.setShowCheckboxes(true);
                      } else if (state.allTagsFlag) {
                        notifier.clearSelection();
                      } else {
                        notifier.selectAllTags();
                      }
                    },
                    onLongPress: isMultiSelectActive
                        ? () {
                            notifier.setShowCheckboxes(false);
                            notifier.clearSelection();
                          }
                        : null,
                    child: Center(
                      child: Icon(
                        isMultiSelectActive
                            ? (state.allTagsFlag
                                ? Icons.check_box
                                : (state.selectedTagIds.isNotEmpty
                                    ? Icons.indeterminate_check_box
                                    : Icons.check_box_outline_blank))
                            : Icons.check_box_outline_blank,
                        color: context.colors.primary,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              Text(
                'Tags',
                style: AppTypography.headlineMedium(context).copyWith(
                  color: context.colors.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (state.selectedTagIds.isNotEmpty) ...[
                const SizedBox(width: 12),
                Text(
                  state.isAllSelected
                      ? 'All Selected (${state.selectedCount})'
                      : '${state.selectedCount} selected',
                  style: AppTypography.labelMedium(context).copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Container(height: 1, color: dividerColor),
        ),
        Expanded(
          child: _TabletTagsListView(
            state: state,
            notifier: notifier,
            tags: tags,
            tagController: tagController,
            parentRef: parentRef,
            isMultiSelectActive: isMultiSelectActive,
          ),
        ),
      ],
    );
  }
}

class _TabletTagsListView extends StatefulWidget {
  final TagsState state;
  final TagsNotifier notifier;
  final List<Tags> tags;
  final TextEditingController tagController;
  final WidgetRef parentRef;
  final bool isMultiSelectActive;

  const _TabletTagsListView({
    required this.state,
    required this.notifier,
    required this.tags,
    required this.tagController,
    required this.parentRef,
    required this.isMultiSelectActive,
  });

  @override
  State<_TabletTagsListView> createState() => _TabletTagsListViewState();
}

class _TabletTagsListViewState extends State<_TabletTagsListView> {
  final Map<int, GlobalKey> _itemKeys = {};
  bool _isDragSelecting = false;
  int _dragAnchorIndex = -1;
  int _lastDragIndex = -1;
  Set<int> _preExistingSelection = {};

  bool get _isInSelectionMode =>
      widget.state.showCheckboxes || widget.state.selectedTagIds.isNotEmpty;

  int _indexAtPosition(double globalY) {
    for (final entry in _itemKeys.entries) {
      final ro = entry.value.currentContext?.findRenderObject() as RenderBox?;
      if (ro == null || !ro.hasSize || !ro.attached) continue;
      final topLeft = ro.localToGlobal(Offset.zero);
      if (globalY >= topLeft.dy && globalY < topLeft.dy + ro.size.height) {
        return entry.key;
      }
    }
    return -1;
  }

  void _updateDragSelection(int currentIndex) {
    if (_dragAnchorIndex < 0 || currentIndex < 0) return;
    final lo = _dragAnchorIndex < currentIndex ? _dragAnchorIndex : currentIndex;
    final hi = _dragAnchorIndex < currentIndex ? currentIndex : _dragAnchorIndex;
    final dragIds = <int>{};
    for (int i = lo; i <= hi; i++) {
      if (i < widget.tags.length) dragIds.add(widget.tags[i].id);
    }
    widget.notifier.setSelectedFromList(
      {..._preExistingSelection, ...dragIds}.toList(),
    );
  }

  void _handleTap(int index) {
    if (kIsWeb) {
      final keys = HardwareKeyboard.instance.logicalKeysPressed;
      final isShift = keys.contains(LogicalKeyboardKey.shiftLeft) ||
          keys.contains(LogicalKeyboardKey.shiftRight);
      final isCtrlOrCmd = keys.contains(LogicalKeyboardKey.controlLeft) ||
          keys.contains(LogicalKeyboardKey.controlRight) ||
          keys.contains(LogicalKeyboardKey.metaLeft) ||
          keys.contains(LogicalKeyboardKey.metaRight);

      if (isShift) {
        final from = widget.state.lastClickedIndex != -1
            ? widget.state.lastClickedIndex
            : index;
        widget.notifier.selectRangeFromList(from, index);
        return;
      }
      if (isCtrlOrCmd) {
        widget.notifier.toggleSingleSelectByIndex(index);
        return;
      }
    }

    if (_isInSelectionMode) {
      widget.notifier.toggleSelectTag(widget.tags[index].id);
      return;
    }

    widget.tagController.text = widget.tags[index].tag;
    widget.notifier.setId(widget.tags[index].id);
    widget.notifier.setEditFlag(true);
    showActionSheet(context, 'edit', widget.parentRef, widget.tagController);
  }

  @override
  Widget build(BuildContext context) {
    final tags = widget.tags;
    final showCheckbox = widget.isMultiSelectActive;

    return DelayedLoadingOverlay(
      isLoading: widget.state.isLoading && tags.isEmpty,
      child: tags.isEmpty
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                if (!widget.state.isLoading)
                  const Center(
                    child: EmptyState(variant: EmptyStateVariant.tags),
                  ),
              ],
            )
          : Listener(
              onPointerDown: (event) {
                if (!_isInSelectionMode) return;
                final idx = _indexAtPosition(event.position.dy);
                if (idx >= 0) {
                  _dragAnchorIndex = idx;
                  _lastDragIndex = -1;
                  _isDragSelecting = false;
                  _preExistingSelection = Set.from(widget.state.selectedTagIds);
                }
              },
              onPointerMove: (event) {
                if (!_isInSelectionMode || _dragAnchorIndex < 0) return;
                final idx = _indexAtPosition(event.position.dy);
                if (idx >= 0 && idx != _dragAnchorIndex) {
                  if (!_isDragSelecting) _isDragSelecting = true;
                  if (idx != _lastDragIndex) {
                    _lastDragIndex = idx;
                    _updateDragSelection(idx);
                  }
                }
              },
              onPointerUp: (_) {
                _isDragSelecting = false;
                _dragAnchorIndex = -1;
                _lastDragIndex = -1;
                _preExistingSelection = {};
              },
              child: ListView.builder(
                physics: _isInSelectionMode
                    ? const ClampingScrollPhysics()
                    : null,
                itemCount: tags.length,
                itemBuilder: (context, index) {
                  final tag = tags[index];
                  final isSelected = widget.state.selectedTagIds.contains(tag.id);
                  _itemKeys.putIfAbsent(index, () => GlobalKey());

                  return KeyedSubtree(
                    key: _itemKeys[index],
                    child: Column(
                      children: [
                        Container(
                          color: isSelected
                              ? context.appColors.messageSelectedRow
                              : Theme.of(context).colorScheme.surface,
                          child: ListTile(
                            leading: showCheckbox
                                ? Icon(
                                    isSelected
                                        ? Icons.check_box
                                        : Icons.check_box_outline_blank,
                                    color: context.colors.primary,
                                    size: 20,
                                  )
                                : SvgPicture.asset(svgFillTag, height: 24, width: 24),
                            title: Text(
                              tag.tag,
                              style: AppTypography.drawerTitle(context),
                            ),
                            trailing: showCheckbox
                                ? null
                                : Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: SvgPicture.asset(
                                          svgEditForm,
                                          height: 20,
                                          width: 20,
                                          colorFilter: ColorFilter.mode(
                                            context.colors.onSurfaceVariant,
                                            BlendMode.srcIn,
                                          ),
                                        ),
                                        onPressed: () {
                                          widget.tagController.text = tag.tag;
                                          widget.notifier.setId(tag.id);
                                          widget.notifier.setEditFlag(true);
                                          showActionSheet(context, 'edit',
                                              widget.parentRef, widget.tagController);
                                        },
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                      ),
                                      const SizedBox(width: 16),
                                      IconButton(
                                        icon: SvgPicture.asset(
                                          svgDelete,
                                          height: 20,
                                          width: 20,
                                          colorFilter: ColorFilter.mode(
                                            context.colors.onSurfaceVariant,
                                            BlendMode.srcIn,
                                          ),
                                        ),
                                        onPressed: () => widget.notifier.deleteTag(tag.id),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                      ),
                                    ],
                                  ),
                            onTap: () => _handleTap(index),
                          ),
                        ),
                        const Divider(),
                      ],
                    ),
                  );
                },
              ),
            ),
    );
  }
}
