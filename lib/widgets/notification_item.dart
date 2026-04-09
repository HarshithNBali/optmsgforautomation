import 'package:optmsg/services/common_service.dart';
import 'package:optmsg/constant/img_path.dart';
import 'package:optmsg/constant/app_typography.dart';
import 'package:optmsg/constant/styles.dart';
import 'package:optmsg/common/responsive/responsive.dart';
import 'package:optmsg/model/notification_list_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class NotificationItem extends StatefulWidget {
  final Function? onTap;
  final Notifications item;
  final int index;
  final Function()? onLongPress;
  final bool showCheckbox;
  final bool isSelected;
  final VoidCallback? onCheckboxChanged;
  final VoidCallback? onDelete;
  final VoidCallback? onToggleRead;

  const NotificationItem({
    super.key,
    this.onTap,
    required this.item,
    required this.index,
    this.onLongPress,
    this.showCheckbox = false,
    this.isSelected = false,
    this.onCheckboxChanged,
    this.onDelete,
    this.onToggleRead,
  });

  @override
  State<NotificationItem> createState() => _NotificationItemState();
}

class _NotificationItemState extends State<NotificationItem> {
  bool isExpanded = false;
  bool _isHovering = false;

  void _setHover(bool value, bool isNotMobile) {
    if (kIsWeb && isNotMobile && mounted) {
      setState(() => _isHovering = value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final isNotMobile = !AppBreakpoints.isMobileLayout(context);

    return MouseRegion(
      onEnter: (_) => _setHover(true, isNotMobile),
      onExit: (_) => _setHover(false, isNotMobile),
      child: InkWell(
        onTap: () {
          setState(() {
            isExpanded = !isExpanded;
          });
          widget.onTap?.call();
        },
        onLongPress: widget.onLongPress,
        child: Container(
          padding: EdgeInsets.only(left: widget.showCheckbox ? 8 : 0, right: 10, top: 6),
          decoration: BoxDecoration(
            color: () {
              if (widget.isSelected) return context.appColors.messageSelectedRow;
              if (isNotMobile && _isHovering) {
                return context.colors.primary.withValues(alpha: 0.1);
              }
              return Colors.transparent;
            }(),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.showCheckbox) _buildCheckbox(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: SizedBox(
                  width: 12,
                  child: _buildReadIndicator(item.isRead ?? true),
                ),
              ),
              Expanded(child: _buildContent(item)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(Notifications item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(item),
        const SizedBox(height: 1),
        _buildPreview(item),
        const SizedBox(height: 5),
        const Divider(height: 1),
      ],
    );
  }

  Widget _buildHeader(Notifications item) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            CommonService().capitalize(item.title.toString()),
            overflow: TextOverflow.ellipsis,
            maxLines: isExpanded ? 100 : 1,
            style: AppTypography.messageListSender(context),
          ),
        ),
        Flexible(
          flex: 0,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(child: _buildHoverActions()),
              Text(
                CommonService.formatDateString(item.created),
                style: AppTypography.messageListTimestamp(context),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHoverActions() {
    if (!(kIsWeb && _isHovering && !widget.showCheckbox)) {
      return const SizedBox.shrink();
    }

    return Row(
      children: [
        if (widget.onDelete != null)
          _hoverIcon('Delete', svgDelete, widget.onDelete!),
        if (widget.onToggleRead != null)
          _hoverIcon(
            (widget.item.isRead ?? false) ? 'Mark as Unread' : 'Mark as Read',
            (widget.item.isRead ?? false) ? svgUnread : svgRead,
            widget.onToggleRead!,
          ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _hoverIcon(String tooltip, String asset, VoidCallback onTap) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: SvgPicture.asset(
            asset,
            height: 20,
            width: 20,
            colorFilter: ColorFilter.mode(
              context.colors.onSurfaceVariant,
              BlendMode.srcIn,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPreview(Notifications item) {
    final style = AppTypography.messageListPreview(context);
    final lineHeight = (style.fontSize ?? 13) * (style.height ?? 1.35);
    final reservedHeight = lineHeight * 2;

    if (isExpanded) {
      return Text(
        item.body,
        style: style,
      );
    }

    return SizedBox(
      height: reservedHeight,
      child: Text(
        item.body.isNotEmpty ? item.body : 'This notification has no content.',
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: style,
      ),
    );
  }

  Widget _buildCheckbox() {
    final cbSize = AppStyles.checkboxSize(context);
    final iconSize = AppStyles.checkboxIconSize(context);
    return Semantics(
      label:
          widget.isSelected ? 'Deselect notification' : 'Select notification',
      checked: widget.isSelected,
      child: SizedBox(
        width: cbSize,
        height: cbSize,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppStyles.radiusXL),
          onTap: widget.onCheckboxChanged,
          child: Center(
            child: Icon(
              widget.isSelected
                  ? Icons.check_box
                  : Icons.check_box_outline_blank,
              color: Theme.of(context).colorScheme.primary,
              size: iconSize,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReadIndicator(bool isRead) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Center(
        child: SvgPicture.asset(
          isRead ? blankDot : svgDot,
          colorFilter: isRead
              ? null
              : ColorFilter.mode(
                  context.appColors.accent,
                  BlendMode.srcIn,
                ),
        ),
      ),
    );
  }
}
