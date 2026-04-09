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
import 'package:optmsg/screens/tags/tag_riverpod/widget/show_action_sheet.dart';
import 'package:optmsg/services/app_bar_config_state.dart';
import 'package:optmsg/widgets/shell_layout.dart';

class DrawerTagsSection extends ConsumerStatefulWidget {
  final String currentLocation;

  const DrawerTagsSection({
    super.key,
    required this.currentLocation,
  });

  @override
  ConsumerState<DrawerTagsSection> createState() => _DrawerTagsSectionState();
}

class _DrawerTagsSectionState extends ConsumerState<DrawerTagsSection> {
  final TextEditingController _tagController = TextEditingController();

  @override
  void dispose() {
    _tagController.dispose();
    super.dispose();
  }

  bool _isTagSelected(int tagId) {
    final uri = Uri.tryParse(widget.currentLocation);
    if (uri == null) return false;
    return uri.path == '/tags' &&
        uri.queryParameters['id'] == tagId.toString();
  }

  @override
  Widget build(BuildContext context) {
    final tagsState = ref.watch(tagsProvider);
    final tags = [...(tagsState.tagsList?.data.tags ?? [])]
      ..sort((a, b) => a.tag.toLowerCase().compareTo(b.tag.toLowerCase()));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Section header — matches MyDrawerItem horizontal padding
        Padding(
          padding: const EdgeInsets.only(left: 27.0, right: 16.0, top: 8.0, bottom: 4.0),
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
                width: 28,
                height: 28,
                child: GestureDetector(
                  onTap: () {
                    _tagController.clear();
                    ref.read(tagsProvider.notifier).setEditFlag(false);
                    showActionSheet(context, 'add', ref, _tagController);
                  },
                  child: Tooltip(
                    message: 'Create new tag',
                    child: Center(
                      child: SvgPicture.asset(
                        svgAddIcon,
                        height: 18,
                        width: 18,
                        colorFilter: ColorFilter.mode(
                          context.colors.onSurfaceVariant,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Tag items
        ...tags.map((tagItem) => _DrawerTagItem(
              tag: tagItem,
              isActive: _isTagSelected(tagItem.id),
              onTap: () => _navigateToTag(tagItem),
              onEdit: () => _editTag(tagItem),
              onDelete: () => _deleteTag(tagItem),
            )),
      ],
    );
  }

  void _navigateToTag(Tags tagItem) {
    final tagsState = ref.read(tagsProvider);
    Navigator.of(context).pop(); // close drawer
    ShellLayout.of(context)?.setAppBarConfig(
      AppBarConfig(title: tagItem.tag),
    );
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
    if (_isTagSelected(tagItem.id)) {
      Navigator.of(context).pop(); // close drawer
      context.go(AppRoutes.inbox);
    }
  }
}

class _DrawerTagItem extends StatefulWidget {
  final Tags tag;
  final bool isActive;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _DrawerTagItem({
    required this.tag,
    required this.isActive,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<_DrawerTagItem> createState() => _DrawerTagItemState();
}

class _DrawerTagItemState extends State<_DrawerTagItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: widget.tag.tag,
      button: true,
      selected: widget.isActive,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
          decoration: BoxDecoration(
            color: widget.isActive
                ? AppStyles.orange.withValues(alpha: 0.1)
                : _isHovered
                    ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.08)
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(AppStyles.radiusS),
          ),
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(AppStyles.radiusS),
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 5.0),
          child: Column(
            children: [
              Row(
                children: [
                  // Active indicator — 3w x 24h (matches MyDrawerItem)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 3,
                    height: 24,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: widget.isActive ? AppStyles.orange : Colors.transparent,
                      borderRadius: BorderRadius.circular(AppStyles.radiusXS),
                    ),
                  ),
                  // Tag icon — 24px (matches MyDrawerItem SVG icons)
                  SvgPicture.asset(
                    svgTags,
                    height: 24,
                    width: 24,
                    colorFilter: ColorFilter.mode(
                      widget.isActive
                          ? AppStyles.orange
                          : context.colors.onSurface,
                      BlendMode.srcIn,
                    ),
                  ),
                  // Tag name — padding matches MyDrawerItem (14.5 horizontal)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14.5),
                      child: Text(
                        widget.tag.tag,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: widget.isActive
                            ? AppTypography.drawerTitle(context)
                                .copyWith(fontWeight: FontWeight.w700)
                            : AppTypography.drawerTitle(context),
                      ),
                    ),
                  ),
                  // 3-dot popup menu (replaces arrow in MyDrawerItem)
                  SizedBox(
                    width: 28,
                    height: 28,
                    child: PopupMenuButton<String>(
                      padding: EdgeInsets.zero,
                      iconSize: 18,
                      icon: Icon(
                        Icons.more_vert,
                        size: 18,
                        color: context.colors.onSurfaceVariant,
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
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),      // Padding
        ),      // InkWell
        ),      // AnimatedContainer
        ),      // MouseRegion
    );          // Semantics
  }
}
