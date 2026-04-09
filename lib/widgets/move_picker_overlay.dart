import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:optmsg/common/responsive/responsive.dart';
import 'package:optmsg/constant/app_typography.dart';
import 'package:optmsg/constant/img_path.dart';
import 'package:optmsg/constant/styles.dart';
import 'package:optmsg/services/adaptive_service.dart';
import 'package:optmsg/services/tags_provider.dart';
import 'package:optmsg/widgets/drawer_item.dart';

/// A destination picker overlay for the "Move" action.
///
/// Shows system folder destinations (filtered by [currentFolder]) and
/// the user's custom tags. Selecting a system folder calls
/// [onSystemFolderSelected]; selecting a tag calls [onTagSelected].
class MovePickerOverlay extends ConsumerWidget {
  /// Which screen we're on: 'inbox' | 'archive' | 'sent' | 'trash'
  final String currentFolder;

  /// Origin of selected emails: 'allSent' | 'allReceived' | 'mixed' | 'none'
  final String selectionOrigin;

  /// Called with the status key (e.g. 'isArchive') when a system folder is tapped.
  final void Function(String statusKey) onSystemFolderSelected;

  /// Called with the tag ID when a tag destination is tapped.
  final void Function(int tagId) onTagSelected;

  /// Called to dismiss the overlay.
  final VoidCallback onDismiss;

  const MovePickerOverlay({
    super.key,
    required this.currentFolder,
    required this.selectionOrigin,
    required this.onSystemFolderSelected,
    required this.onTagSelected,
    required this.onDismiss,
  });

  /// Returns the list of system folder destinations available from [currentFolder].
  List<_FolderDestination> _systemFolders() {
    switch (currentFolder) {
      case 'inbox':
        return const [
          _FolderDestination('Archive', svgArchive, 'isArchive'),
          _FolderDestination('Trash', svgTrash1, 'isTrash'),
        ];
      case 'archive':
        return [
          if (selectionOrigin != 'allSent')
            const _FolderDestination('Inbox', svgInbox, 'isInbox'),
          if (selectionOrigin != 'allReceived')
            const _FolderDestination('Sent', svgSent, 'isSent'),
          const _FolderDestination('Trash', svgTrash1, 'isTrash'),
        ];
      case 'sent':
        return const [
          _FolderDestination('Archive', svgArchive, 'isArchive'),
          _FolderDestination('Trash', svgTrash1, 'isTrash'),
        ];
      case 'trash':
        return [
          if (selectionOrigin != 'allSent')
            const _FolderDestination('Inbox', svgInbox, 'isInbox'),
          const _FolderDestination('Archive', svgArchive, 'isArchive'),
          if (selectionOrigin != 'allReceived')
            const _FolderDestination('Sent', svgSent, 'isSent'),
        ];
      default:
        return const [];
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tags = ref.watch(
      tagsProvider.select((s) => s.tagsList?.data.tags ?? []),
    );
    final folders = _systemFolders();

    final content = _buildContent(context, folders, tags);

    // Desktop / web: positioned dropdown
    if (kIsWeb && !AdaptiveService.isMobileLayout(context)) {
      return Stack(
        children: [
          // Backdrop
          Positioned.fill(
            child: GestureDetector(
              onTap: onDismiss,
              child: const ColoredBox(color: Colors.transparent),
            ),
          ),
          // Dropdown
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
                child: SingleChildScrollView(child: content),
              ),
            ),
          ),
        ],
      );
    }

    // Mobile: full-width overlay with backdrop
    return InkWell(
      onTap: onDismiss,
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
              child: SingleChildScrollView(child: content),
            ),
            // Transparent spacer below
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

  Widget _buildContent(
    BuildContext context,
    List<_FolderDestination> folders,
    List<dynamic> tags,
  ) {
    // Desktop uses inline InkWell items; mobile uses MyDrawerItem
    final isDesktop = kIsWeb && !AdaptiveService.isMobileLayout(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // System folders
        for (int i = 0; i < folders.length; i++) ...[
          if (isDesktop)
            _desktopItem(
              context,
              icon: folders[i].icon,
              label: folders[i].label,
              onTap: () => onSystemFolderSelected(folders[i].statusKey),
            )
          else
            MyDrawerItem(
              title: folders[i].label,
              svgIcon: folders[i].icon,
              showRightIcon: false,
              onTap: () => onSystemFolderSelected(folders[i].statusKey),
            ),
          if (isDesktop && i < folders.length - 1)
            Divider(
              height: 1,
              thickness: 1,
              color: Theme.of(context)
                  .colorScheme
                  .onSurfaceVariant
                  .withValues(alpha: 0.2),
            ),
        ],

        // Divider between folders and tags
        if (folders.isNotEmpty && tags.isNotEmpty)
          Divider(
            height: 1,
            thickness: 2,
            color: Theme.of(context)
                .colorScheme
                .onSurfaceVariant
                .withValues(alpha: 0.3),
          ),

        // Tags section
        if (tags.isNotEmpty)
          for (int i = 0; i < tags.length; i++) ...[
            if (isDesktop)
              _desktopItem(
                context,
                icon: svgTags,
                label: tags[i].tag,
                onTap: () => onTagSelected(tags[i].id),
              )
            else
              MyDrawerItem(
                title: tags[i].tag,
                svgIcon: svgTags,
                showRightIcon: false,
                onTap: () => onTagSelected(tags[i].id),
              ),
            if (isDesktop && i < tags.length - 1)
              Divider(
                height: 1,
                thickness: 1,
                color: Theme.of(context)
                    .colorScheme
                    .onSurfaceVariant
                    .withValues(alpha: 0.2),
              ),
          ],

        // Empty state
        if (folders.isEmpty && tags.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text(
              'No destinations available',
              style: AppTypography.bodySmall(context).copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
      ],
    );
  }

  Widget _desktopItem(
    BuildContext context, {
    required String icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            SvgPicture.asset(
              icon,
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
                label,
                style: AppTypography.labelMedium(context).copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FolderDestination {
  final String label;
  final String icon;
  final String statusKey;

  const _FolderDestination(this.label, this.icon, this.statusKey);
}
