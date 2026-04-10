import 'package:optmsg/common/responsive/responsive.dart';
import 'package:optmsg/constant/styles.dart';
import 'package:optmsg/constant/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'dart:async';

class WebMenuItems extends StatefulWidget {
  final String title;
  final String svgIcon;
  final String? labelText;
  final VoidCallback? onTap;
  final Icon? rightIcon;
  final VoidCallback? onTapRightIcon;
  final PopupMenuButton? popupMenu;
  final bool? showRightIcon;
  final Color? svgColor;
  final bool isSelected;
  final List<Widget> subItems;
  final bool? draft;
  final bool isCollapsed;
  final String? testId;

  const WebMenuItems({
    super.key,
    required this.title,
    required this.svgIcon,
    this.labelText,
    this.onTap,
    this.rightIcon,
    this.onTapRightIcon,
    this.popupMenu,
    this.showRightIcon,
    this.svgColor,
    this.isSelected = false,
    this.subItems = const [],
    this.draft = false,
    this.isCollapsed = false,
    this.testId,
  });

  @override
  State<WebMenuItems> createState() => _WebMenuItemsState();
}

class _WebMenuItemsState extends State<WebMenuItems> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final menuItem = MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeInOutCubic,
        margin: EdgeInsets.symmetric(
          horizontal: widget.isCollapsed ? 0.0 : 8.0,
          vertical: widget.isCollapsed ? 0.0 : 1.0,
        ),
        decoration: BoxDecoration(
          color: widget.isSelected
              ? AppStyles.orange.withValues(alpha: 0.1)
              : _isHovered
                  ? context.colors.onSurface.withValues(alpha: 0.08)
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(AppStyles.radiusS),
        ),
        child: Semantics(
          key: widget.testId != null ? Key(widget.testId!) : null,
          label: widget.title,
          button: true,
          selected: widget.isSelected,
          child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(AppStyles.radiusS),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOutCubic,
            padding: EdgeInsets.symmetric(
              horizontal: widget.isCollapsed ? 0.0 : 10.0,
              vertical: widget.isCollapsed ? 5.0 : 7.0,
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              },
              child: widget.isCollapsed
                  ? _buildCollapsedContent(key: const ValueKey('collapsed'))
                  : _buildExpandedContent(key: const ValueKey('expanded')),
            ),
          ),
        ),
        ),
      ),
    );

    // Wrap with tooltip when collapsed - show only name, no count
    if (widget.isCollapsed) {
      return _RightSideTooltip(
        message: widget.title,
        waitDuration: const Duration(milliseconds: 500),
        child: menuItem,
      );
    }

    return menuItem;
  }

  Widget _buildCollapsedContent({Key? key}) {
    return Column(
      key: key,
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            // Selection indicator bar on the left
            if (widget.isSelected)
              Positioned(
                left: -12,
                top: 8,
                bottom: 8,
                child: Container(
                  width: 3,
                  decoration: BoxDecoration(
                    color: AppStyles.orange,
                    borderRadius: BorderRadius.circular(AppStyles.radiusXS),
                  ),
                ),
              ),
            Center(
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: widget.isSelected
                      ? AppStyles.orange.withValues(alpha: 0.15)
                      : _isHovered
                          ? context.colors.onSurface.withValues(alpha: 0.08)
                          : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppStyles.radiusM),
                  border: widget.isSelected
                      ? Border.all(
                          color: AppStyles.orange.withValues(alpha: 0.3),
                          width: 1.5)
                      : null,
                ),
                child: Center(
                  child: SvgPicture.asset(
                    widget.svgIcon,
                    height: 20,
                    width: 20,
                    colorFilter: ColorFilter.mode(
                      widget.isSelected
                          ? AppStyles.orange
                          : (widget.svgColor ?? context.colors.onSurface),
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            ),
            // Count badge on top of icon when collapsed
            if (widget.labelText != null)
              Positioned(
                top: -2,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4.0,
                    vertical: 1.0,
                  ),
                  decoration: BoxDecoration(
                    color: widget.draft == true
                        ? AppStyles.orange
                        : context.appColors.accent,
                    borderRadius: BorderRadius.circular(AppStyles.radiusM),
                    border: Border.all(
                      color: context.colors.surface,
                      width: 1.5,
                    ),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 18,
                    minHeight: 18,
                  ),
                  child: Center(
                    child: Text(
                      widget.labelText!,
                      style: TextStyle(
                        color: context.colors.onPrimary,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildExpandedContent({Key? key}) {
    return Column(
      key: key,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
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

            SvgPicture.asset(
              widget.svgIcon,
              height: 20,
              width: 20,
              colorFilter: ColorFilter.mode(
                widget.isSelected
                    ? AppStyles.orange
                    : (widget.svgColor ?? context.colors.onSurface),
                BlendMode.srcIn,
              ),
            ),

            const SizedBox(width: 8),

            /// ✅ Text must stay flexible
            Expanded(
              child: Text(
                widget.title,
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

            /// ✅ Hide badge & icons when space is tight
            LayoutBuilder(
              builder: (context, constraints) {
                final bool canShowExtras = constraints.maxWidth > 140;

                if (!canShowExtras) return const SizedBox();

                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.labelText != null) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: widget.draft == true
                              ? AppStyles.orange.withValues(alpha: 0.15)
                              : context.appColors.accent,
                          borderRadius: BorderRadius.circular(AppStyles.radiusM),
                        ),
                        child: Text(
                          widget.labelText!,
                          style: widget.draft == true
                              ? AppTypography.draftCount(context)
                              : AppTypography.inboxCount(context),
                        ),
                      ),
                    ],
                    if (widget.showRightIcon == true) ...[
                      const SizedBox(width: 6),
                      Icon(
                        Icons.chevron_right,
                        size: 18,
                        color: widget.isSelected
                            ? AppStyles.orange
                            : context.colors.onSurfaceVariant,
                        semanticLabel: 'Expand',
                      ),
                    ],
                    if (widget.popupMenu != null) widget.popupMenu!,
                  ],
                );
              },
            ),
          ],
        ),
        // Sub items
        if (widget.subItems.isNotEmpty) ...widget.subItems,
      ],
    );
  }
}

class MyDrawerSubItem extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const MyDrawerSubItem({
    super.key,
    required this.title,
    required this.onTap,
  });

  @override

  /// Builds a single sub item in the drawer.
  ///
  /// This widget is used inside [MyDrawerItem] to create a sub item in the drawer.
  /// It is a simple [InkWell] with a [Text] and an icon.
  ///
  /// The [title] is the text of the sub item.
  ///
  /// The [onTap] callback is called when the sub item is tapped.
  Widget build(BuildContext context) {
    return Semantics(
      label: title,
      button: true,
      child: Padding(
      padding: const EdgeInsets.only(left: 30.0, top: 8.0, bottom: 8.0),
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            Icon(Icons.chevron_right, color: context.colors.onSurface, semanticLabel: 'Sub-item'),
            const SizedBox(width: 10),
            Text(
              title,
              style: AppTypography.drawerTitle(context),
            ),
          ],
        ),
      ),
    ),
    );
  }
}

class _RightSideTooltip extends StatefulWidget {
  final String message;
  final Widget child;
  final Duration waitDuration;

  const _RightSideTooltip({
    required this.message,
    required this.child,
    this.waitDuration = const Duration(milliseconds: 500),
  });

  @override
  State<_RightSideTooltip> createState() => _RightSideTooltipState();
}

class _RightSideTooltipState extends State<_RightSideTooltip> {
  OverlayEntry? _overlayEntry;
  Timer? _showTimer;
  bool _isHovered = false;

  void _showTooltip(BuildContext context, Offset position) {
    if (_overlayEntry != null) return;

    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: offset.dx + size.width + 4,
        top: offset.dy + (size.height / 2) - 12,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.inverseSurface,
              borderRadius: BorderRadius.circular(AppStyles.radiusXS),
            ),
            child: Text(
              widget.message,
              style: TextStyle(
                color: context.colors.onPrimary,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _hideTooltip() {
    _showTimer?.cancel();
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  void dispose() {
    _showTimer?.cancel();
    _hideTooltip();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _showTimer = Timer(widget.waitDuration, () {
          if (_isHovered && mounted) {
            _showTooltip(context, Offset.zero);
          }
        });
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _hideTooltip();
      },
      child: widget.child,
    );
  }
}
