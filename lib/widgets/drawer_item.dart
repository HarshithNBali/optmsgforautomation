import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:optmsg/common/responsive/responsive.dart';
import 'package:optmsg/constant/styles.dart';
import 'package:optmsg/constant/app_typography.dart';

class MyDrawerItem extends StatefulWidget {
  final String title;
  final String svgIcon;
  final String? labelText;
  final VoidCallback? onTap;
  final Icon? rightIcon;
  final VoidCallback? onTapRightIcon;
  final PopupMenuButton? popupMenu;
  final bool? showRightIcon;
  final dynamic svgColor;
  final bool? draft;
  final bool isActive;
  final bool showIndicator;
  final bool showChevron;
  final String? testId;
  const MyDrawerItem({
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
    this.draft = false,
    this.isActive = false,
    this.showIndicator = true,
    this.showChevron = false,
    this.testId,
  });

  @override
  State<MyDrawerItem> createState() => _MyDrawerItemState();
}

class _MyDrawerItemState extends State<MyDrawerItem> {
  bool _isHovered = false;

  // Forward getters for cleaner access
  String get title => widget.title;
  String get svgIcon => widget.svgIcon;
  String? get labelText => widget.labelText;
  VoidCallback? get onTap => widget.onTap;
  Icon? get rightIcon => widget.rightIcon;
  VoidCallback? get onTapRightIcon => widget.onTapRightIcon;
  PopupMenuButton? get popupMenu => widget.popupMenu;
  bool? get showRightIcon => widget.showRightIcon;
  dynamic get svgColor => widget.svgColor;
  bool? get draft => widget.draft;
  bool get isActive => widget.isActive;
  bool get showIndicator => widget.showIndicator;
  bool get showChevron => widget.showChevron;

  @override

  /// Builds a widget that represents an item in the drawer.
  ///
  /// This widget is an [InkWell] that contains an icon, a title, and optional
  /// elements like a label, a right icon, and a popup menu.
  ///
  /// The [title] is displayed as a [Text] widget next to the icon, with styles
  /// defined in [AppStyles.drawerTitle].
  ///
  /// The [svgIcon] is displayed using [SvgPicture.asset], and its color can be
  /// customized with [svgColor].
  ///
  /// If [labelText] is provided, a [Container] with the label is displayed. The
  /// label's style changes based on the value of [draft].
  ///
  /// [InkWell] is used to handle taps, triggering [onTap] or [onTapRightIcon]
  /// if provided.
  ///
  /// The widget also includes a divider below the row of elements.

  Widget build(BuildContext context) {
    return Semantics(
      key: widget.testId != null ? Key(widget.testId!) : null,
      label: title,
      button: true,
      selected: isActive,
      child: MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
        decoration: BoxDecoration(
          color: isActive
              ? AppStyles.orange.withValues(alpha: 0.1)
              : _isHovered
                  ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.08)
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(AppStyles.radiusS),
        ),
        child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppStyles.radiusS),
        child: Padding(
        padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 5.0),
        child: Column(
          children: [
            Row(
              children: [
                // Active route indicator bar (only in drawer/side menu)
                if (showIndicator)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 3,
                    height: 24,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: isActive ? AppStyles.orange : Colors.transparent,
                      borderRadius: BorderRadius.circular(AppStyles.radiusXS),
                    ),
                  ),
                SvgPicture.asset(
                  height: 24,
                  width: 24,
                  svgIcon,
                  colorFilter: ColorFilter.mode(
                      svgColor ?? context.colors.onSurface, BlendMode.srcIn),
                ),
                Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14.5),
                    child: Text(
                      title,
                      style: isActive
                          ? AppTypography.drawerTitle(context).copyWith(fontWeight: FontWeight.w700)
                          : AppTypography.drawerTitle(context),
                    )),
                const Spacer(),
                // Fixed width container for count badge to ensure alignment
                if (labelText != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6.0, vertical: 2.0),
                    decoration: BoxDecoration(
                      color:
                          draft == true ? null : context.appColors.accent,
                      borderRadius: BorderRadius.circular(AppStyles.radiusFull),
                    ),
                    child: Text(
                      labelText!,
                      style: draft == true
                          ? AppTypography.draftCount(context)
                          : AppTypography.inboxCount(context),
                      textAlign: TextAlign.center,
                    ),
                  ),
                const SizedBox(width: 4),
                // Arrow aligned flush to right
                if (showRightIcon == true)
                  InkWell(
                    onTap: onTapRightIcon ?? onTap,
                    child: rightIcon ??
                        Icon(Icons.arrow_forward_ios,
                            size: 14, color: context.colors.onSurfaceVariant),
                  ),
                // Chevron for navigation rows (settings/help center)
                if (showChevron && showRightIcon != true && popupMenu == null)
                  Icon(Icons.chevron_right,
                      size: 20, color: context.colors.onSurfaceVariant),
                if (popupMenu != null)
                  SizedBox(
                    child: popupMenu,
                  ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            // Divider(
            //   color: AppStyles.stroke,
            //   thickness: 1,
            //   height: AdaptiveService.screenHeight(context) * 0.010,
            // ),
          ],
        ),
      ),  // Padding
      ),  // InkWell
      ),  // AnimatedContainer
      ),  // MouseRegion
    );    // Semantics
  }
}
