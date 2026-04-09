import 'package:optmsg/common/responsive/responsive.dart';
import 'package:optmsg/constant/app_typography.dart';
import 'package:optmsg/constant/img_path.dart';
import 'package:optmsg/constant/string_constant.dart';
import 'package:optmsg/screens/tags/tag_riverpod/tags_notifier.dart';
import 'package:optmsg/screens/tags/tag_riverpod/tags_state.dart';
import 'package:optmsg/screens/tags/tag_riverpod/widget/show_action_sheet.dart';
import 'package:optmsg/screens/tags/tag_riverpod/widget/tags_desktop_layout.dart';
import 'package:optmsg/screens/tags/tag_riverpod/widget/tags_mobile_layout.dart';
import 'package:optmsg/screens/tags/tag_riverpod/widget/tags_tablet_layout.dart';
import 'package:optmsg/widgets/load_container/delayed_loading_overlay.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:optmsg/services/app_bar_config_state.dart';
import 'package:optmsg/widgets/shell_layout.dart';

class TagsListriverpod extends ConsumerStatefulWidget {
  const TagsListriverpod({
    super.key,
    this.onLongPress,
    this.isSideMenuCollapsed,
    this.onToggleSideMenu,
  });

  final VoidCallback? onLongPress;
  final bool? isSideMenuCollapsed;
  final VoidCallback? onToggleSideMenu;

  @override
  ConsumerState<TagsListriverpod> createState() => _TagsListriverpodState();
}

class _TagsListriverpodState extends ConsumerState<TagsListriverpod>
    with WidgetsBindingObserver {
  final TextEditingController _tagController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(tagsProvider.notifier).getAllTags(isRefresh: true);
        _pushAppBarConfig();
      }
    });

    // Listen for selection state changes to update AppBar
    ref.listenManual(
      tagsProvider.select((s) => (s.longPressFlag, s.selectedTagIds.length)),
      (_, _) {
        if (mounted) _pushAppBarConfig();
      },
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tagController.dispose();
    super.dispose();
  }

  void _pushAppBarConfig() {
    if (!mounted) return;
    final s = ref.read(tagsProvider);
    final n = ref.read(tagsProvider.notifier);
    final isInSelectionMode = !s.longPressFlag || s.selectedTagIds.isNotEmpty;
    final isMobile = AppBreakpoints.isMobileLayout(context);

    if (!isInSelectionMode || !isMobile) {
      // Normal mode or desktop/tablet
      ShellLayout.of(context)?.setAppBarConfig(
        AppBarConfig(
          showAddButton: true,
          onAdd: () {
            showActionSheet(context, 'add', ref, _tagController);
          },
        ),
      );
    } else {
      // Selection mode — mobile only
      ShellLayout.of(context)?.setAppBarConfig(
        AppBarConfig(
          title: '',
          isSelectionMode: true,
          selectionLeading: _buildSelectionLeadingWidget(s, n),
          selectionActions: _buildSelectionActionsWidgets(s, n),
        ),
      );
    }
  }

  Widget _buildSelectionLeadingWidget(TagsState s, TagsNotifier n) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(width: 5),
        IconButton(
          onPressed: () => n.clearSelection(),
          icon: SvgPicture.asset(
            svgLeftArrow,
            colorFilter: ColorFilter.mode(
              Theme.of(context).appBarTheme.foregroundColor ??
                  Theme.of(context).colorScheme.onSurface,
              BlendMode.srcIn,
            ),
          ),
        ),
        IconButton(
          icon: s.allTagsFlag
              ? const Icon(Icons.check_box)
              : s.selectedTagIds.isNotEmpty
                  ? const Icon(Icons.indeterminate_check_box)
                  : const Icon(Icons.check_box_outline_blank),
          onPressed: () {
            if (s.allTagsFlag) {
              n.clearSelection();
            } else {
              n.selectAllTags();
            }
          },
        ),
        Text(
          s.allTagsFlag
              ? 'All Selected (${s.selectedCount})'
              : s.selectedTagIds.isNotEmpty
                  ? '${s.selectedCount} selected'
                  : selectAll,
          style: AppTypography.labelMedium(context).copyWith(
            color: context.colors.primary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  List<Widget> _buildSelectionActionsWidgets(TagsState s, TagsNotifier n) {
    return [
      if (s.selectedTagIds.isNotEmpty)
        IconButton(
          onPressed: () => n.deleteSelectedTags(),
          icon: SvgPicture.asset(
            svgDelete,
            height: 24,
            width: 24,
            colorFilter: ColorFilter.mode(
              Theme.of(context).appBarTheme.foregroundColor ??
                  Theme.of(context).colorScheme.onSurface,
              BlendMode.srcIn,
            ),
          ),
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(tagsProvider);
    final notifier = ref.watch(tagsProvider.notifier);
    final isTablet = AppBreakpoints.isTabletLayout(context);
    final isNativeTabletLandscape =
        !kIsWeb &&
        isTablet &&
        MediaQuery.of(context).orientation == Orientation.landscape;

    return SafeArea(
      top: false,
      bottom: false,
      child: DelayedLoadingOverlay(
        isLoading: state.isLoading,
        child: ResponsiveLayoutBuilder(
          mobile: (ctx, deviceType, width) => TagsMobileLayout(
            state: state,
            notifier: notifier,
            tagController: _tagController,
            parentRef: ref,
          ),
          tablet: (ctx, deviceType, width) => isNativeTabletLandscape
              ? TagsDesktopLayout(
                  state: state,
                  notifier: notifier,
                  tagController: _tagController,
                  parentRef: ref,
                )
              : TagsTabletLayout(
                  state: state,
                  notifier: notifier,
                  tagController: _tagController,
                  parentRef: ref,
                ),
          desktop: (ctx, deviceType, width) => TagsDesktopLayout(
            state: state,
            notifier: notifier,
            tagController: _tagController,
            parentRef: ref,
          ),
        ),
      ),
    );
  }
}
