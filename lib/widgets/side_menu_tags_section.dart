import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import 'package:optmsg/common/responsive/responsive.dart';
import 'package:optmsg/constant/img_path.dart';
import 'package:optmsg/constant/string_constant.dart';
import 'package:optmsg/constant/styles.dart';
import 'package:optmsg/constant/app_typography.dart';
import 'package:optmsg/model/tags_list_model.dart';
import 'package:optmsg/router/app_routes.dart';
import 'package:optmsg/screens/tags/tag_riverpod/tags_notifier.dart';
import 'package:optmsg/screens/tags/tag_riverpod/tags_state.dart';
import 'package:optmsg/screens/tags/tag_riverpod/widget/show_action_sheet.dart';

class SideMenuTagsSection extends ConsumerStatefulWidget {
  final bool isCollapsed;
  final String selectedItem;
  final Function(String) onItemSelected;
  final VoidCallback? onToggleCollapse;

  const SideMenuTagsSection({
    super.key,
    required this.isCollapsed,
    required this.selectedItem,
    required this.onItemSelected,
    this.onToggleCollapse,
  });

  @override
  ConsumerState<SideMenuTagsSection> createState() =>
      _SideMenuTagsSectionState();
}

class _SideMenuTagsSectionState extends ConsumerState<SideMenuTagsSection> {
  final TextEditingController _tagController = TextEditingController();

  @override
  void dispose() {
    _tagController.dispose();
    super.dispose();
  }

  Uri _currentUri(BuildContext context) {
    return GoRouterState.of(context).uri;
  }

  bool _isTagSelected(BuildContext context, int tagId) {
    final uri = _currentUri(context);
    return uri.path == '/tags' &&
        uri.queryParameters['id'] == tagId.toString();
  }

  bool _isAnyTagSelected(BuildContext context) {
    final uri = _currentUri(context);
    return uri.path == '/tags' && uri.queryParameters.containsKey('id');
  }

  @override
  Widget build(BuildContext context) {
    final tagsState = ref.watch(tagsProvider);

    if (widget.isCollapsed) {
      return _buildCollapsedView(context);
    }

    return _buildExpandedView(context, tagsState);
  }

  Widget _buildCollapsedView(BuildContext context) {
    final isSelected = _isAnyTagSelected(context);
    return Tooltip(
      message: tag,
      waitDuration: const Duration(milliseconds: 500),
      child: InkWell(
        onTap: widget.onToggleCollapse,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(vertical: 1.0),
          padding: const EdgeInsets.symmetric(vertical: 5.0),
          child: Center(
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppStyles.orange.withValues(alpha: 0.15)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(AppStyles.radiusM),
                border: isSelected
                    ? Border.all(
                        color: AppStyles.orange.withValues(alpha: 0.3),
                        width: 1.5)
                    : null,
              ),
              child: Center(
                child: SvgPicture.asset(
                  svgTags,
                  height: 20,
                  width: 20,
                  colorFilter: ColorFilter.mode(
                    isSelected
                        ? AppStyles.orange
                        : context.colors.onSurface,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExpandedView(BuildContext context, TagsState tagsState) {
    final tags = [...(tagsState.tagsList?.data.tags ?? [])]
      ..sort((a, b) => a.tag.toLowerCase().compareTo(b.tag.toLowerCase()));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Section header — matches WebMenuItems padding/sizing
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 6.0),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  tag,
                  style: AppTypography.drawerTitle(context).copyWith(
                    color: context.colors.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(
                width: 20,
                height: 20,
                child: GestureDetector(
                  onTap: () {
                    _tagController.clear();
                    ref.read(tagsProvider.notifier).setEditFlag(false);
                    showActionSheet(context, 'add', ref, _tagController);
                  },
                  child: Tooltip(
                    message: 'Create new tag',
                    child: SvgPicture.asset(
                      svgAddIcon,
                      height: 16,
                      width: 16,
                      colorFilter: ColorFilter.mode(
                        context.colors.onSurfaceVariant,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Tag items
        ...tags.map((tagItem) => _TagMenuItem(
              tag: tagItem,
              isSelected: _isTagSelected(context, tagItem.id),
              onTap: () => _navigateToTag(tagItem),
              onEdit: () => _editTag(tagItem),
              onDelete: () => _deleteTag(tagItem),
            )),
      ],
    );
  }

  void _navigateToTag(Tags tagItem) {
    final tagsState = ref.read(tagsProvider);
    context.go(
      AppRoutes.tagEmailsPath(tagItem.id),
      extra: {
        'data': {
          'tagId': tagItem.id,
          'tagName': tagItem.tag,
          'tagsList': tagsState.tagsList,
        },
        'tagsList': tagsState.tagsList,
      },
    );
  }

  void _editTag(Tags tagItem) {
    final notifier = ref.read(tagsProvider.notifier);
    _tagController.text = tagItem.tag;
    notifier.setId(tagItem.id);
    notifier.setEditFlag(true);
    showActionSheet(context, 'edit', ref, _tagController);
  }

  void _deleteTag(Tags tagItem) {
    ref.read(tagsProvider.notifier).deleteTag(tagItem.id);
    // If currently viewing this tag, navigate away
    if (_isTagSelected(context, tagItem.id)) {
      context.go(AppRoutes.inbox);
    }
  }
}

class _TagMenuItem extends StatefulWidget {
  final Tags tag;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _TagMenuItem({
    required this.tag,
    required this.isSelected,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<_TagMenuItem> createState() => _TagMenuItemState();
}

class _TagMenuItemState extends State<_TagMenuItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 1.0),
        decoration: BoxDecoration(
          color: widget.isSelected
              ? AppStyles.orange.withValues(alpha: 0.1)
              : _isHovered
                  ? context.colors.onSurface.withValues(alpha: 0.08)
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(AppStyles.radiusS),
        ),
        child: Semantics(
          label: widget.tag.tag,
          button: true,
          selected: widget.isSelected,
          child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(AppStyles.radiusS),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 10.0, vertical: 7.0),
            child: Row(
              children: [
                // Selection indicator — matches WebMenuItems (3w x 20h)
                if (widget.isSelected)
                  Container(
                    width: 3,
                    height: 16,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: AppStyles.orange,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                // Tag icon — matches WebMenuItems SVG icons
                SvgPicture.asset(
                  svgTags,
                  height: 20,
                  width: 20,
                  colorFilter: ColorFilter.mode(
                    widget.isSelected
                        ? AppStyles.orange
                        : context.colors.onSurface,
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox(width: 8),
                // Tag name — uses drawerTitle as-is (matches WebMenuItems)
                Expanded(
                  child: Text(
                    widget.tag.tag,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: widget.isSelected
                        ? AppTypography.drawerTitle(context).copyWith(
                            color: AppStyles.orange,
                            fontWeight: FontWeight.w600,
                          )
                        : AppTypography.drawerTitle(context),
                  ),
                ),
                // 3-dot menu — always in layout, transparent when not hovered
                Opacity(
                  opacity: (_isHovered || widget.isSelected) ? 1.0 : 0.0,
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: PopupMenuButton<String>(
                      padding: EdgeInsets.zero,
                      iconSize: 16,
                      enabled: _isHovered || widget.isSelected,
                      icon: Icon(
                        Icons.more_vert,
                        size: 16,
                        color: widget.isSelected
                            ? AppStyles.orange
                            : context.colors.onSurfaceVariant,
                      ),
                      tooltip: 'Tag actions',
                      onSelected: (value) {
                        if (value == 'edit') {
                          widget.onEdit();
                        } else if (value == 'delete') {
                          widget.onDelete();
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit_outlined, size: 18),
                              SizedBox(width: 8),
                              Text('Edit'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete_outline, size: 18),
                              SizedBox(width: 8),
                              Text('Delete'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),        // Padding
          ),        // InkWell
        ),          // Semantics
      ),            // Container (outer)
    );              // MouseRegion
  }
}
