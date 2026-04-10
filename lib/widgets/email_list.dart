import 'package:optmsg/services/common_service.dart';
import 'package:optmsg/services/html_sanitizer_service.dart';
import 'package:optmsg/widgets/add_email_modal.dart';
import 'package:optmsg/widgets/pop_up_modal.dart';
import 'package:optmsg/constant/string_constant.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:optmsg/constant/img_path.dart';
import 'package:optmsg/constant/styles.dart';
import 'package:optmsg/constant/app_typography.dart';
import 'package:optmsg/model/inbox_list_model.dart';
import 'package:optmsg/common/responsive/responsive.dart';
import 'package:optmsg/router/app_routes.dart';

class EmailList extends StatefulWidget {
  final int? userId;
  final String? emailType;
  final String title;
  final String svgIcon;
  final String? labelText;
  final VoidCallback? onTap;
  final Icon? rightIcon;
  final VoidCallback? onTapRightIcon;
  final PopupMenuButton? popupMenu;
  final bool? showRightIcon;
  final Emails? item;
  final VoidCallback? onLongPress;
  final bool? radioButton;
  final VoidCallback? radioOnTap;
  final bool? checkRadio;
  final Function? addEmailTags;
  final int index;
  final VoidCallback? onArchive;
  final VoidCallback? onDelete;
  final VoidCallback? onOptIn;
  final bool? hasAnySelection;
  final int? selectedEmailId;
  final String? testId;

  const EmailList({
    super.key,
    this.userId,
    required this.title,
    required this.svgIcon,
    this.labelText,
    this.onTap,
    this.rightIcon,
    this.onTapRightIcon,
    this.popupMenu,
    this.showRightIcon,
    this.item,
    this.onLongPress,
    this.radioButton,
    this.radioOnTap,
    this.checkRadio,
    this.emailType,
    this.addEmailTags,
    required this.index,
    this.onArchive,
    this.onDelete,
    this.onOptIn,
    this.hasAnySelection,
    this.selectedEmailId,
    this.testId,
  });

  @override
  State<EmailList> createState() => _EmailListState();
}

class _EmailListState extends State<EmailList> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    final item = widget.item!;
    final bool isNotMobile = !AppBreakpoints.isMobileLayout(context);

    final bool showCheckbox = widget.radioButton == true ||
        (widget.hasAnySelection == true && (isNotMobile || kIsWeb));

    final bool isActive = widget.selectedEmailId != null &&
        widget.selectedEmailId == item.emailId;

    return Semantics(
      label: '${item.isRead ? '' : 'Unread '}email from ${item.email.sender.firstName}, ${item.email.subject}',
      selected: isActive,
      child: RepaintBoundary(
      child: MouseRegion(
      onEnter: (_) => _setHover(true, isNotMobile),
      onExit: (_) => _setHover(false, isNotMobile),
      child: InkWell(
        key: widget.testId != null ? Key(widget.testId!) : null,
        onTap: widget.onTap,
        onLongPress: widget.onLongPress,
        child: Container(
          padding: EdgeInsets.only(
            left: showCheckbox ? 8 : 0,
            right: 10,
            top: 6,
          ),
          decoration: BoxDecoration(
            color: () {
              final bool isMultiSelected = widget.checkRadio == true;
              if (isMultiSelected) return context.appColors.messageSelectedRow;
              if (isNotMobile && (isActive || _isHovering)) {
                return context.colors.primary.withValues(alpha: 0.1);
              }
              return Colors.transparent;
            }(),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showCheckbox)
                _buildCheckbox(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: SizedBox(width: 12, child: _buildReadIndicator(item.isRead)),
              ),
              Expanded(child: _buildEmailContent(item, context)),
            ],
          ),
        ),
      ),
    ),
    ),
    );
  }

  // ───────────────────────── HELPERS ─────────────────────────

  void _setHover(bool value, bool isNotMobile) {
    if (kIsWeb && isNotMobile && mounted) {
      setState(() => _isHovering = value);
    }
  }

  Widget _buildCheckbox() {
    final isSelected = widget.checkRadio == true;
    final cbSize = AppStyles.checkboxSize(context);
    final iconSize = AppStyles.checkboxIconSize(context);
    return Semantics(
      label: isSelected ? 'Deselect email' : 'Select email',
      checked: isSelected,
      child: SizedBox(
        width: cbSize,
        height: cbSize,
        child: InkWell(
          key: widget.testId != null ? Key('${widget.testId}_checkbox') : null,
          borderRadius: BorderRadius.circular(AppStyles.radiusXL),
          onTap: widget.radioOnTap,
          child: Center(
            child: Icon(
              isSelected ? Icons.check_box : Icons.check_box_outline_blank,
              color: Theme.of(context).colorScheme.primary,
              size: iconSize,
              semanticLabel: isSelected ? 'Deselect email' : 'Select email',
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

  Widget _buildEmailContent(Emails item, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(item),
        const SizedBox(height: 1),
        _buildSubject(item),
        const SizedBox(height: 1),
        _buildMessage(item, context, maxLines: 2),
        _buildTags(item),
        const SizedBox(height: 5),
        const Divider(height: 1),
      ],
    );
  }

  Widget _buildHeader(Emails item) {
    final bool unread = !item.isRead;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            CommonService().capitalize(
              item.email.sender.firstName.toString(),
            ),
            overflow: TextOverflow.ellipsis,
            style: AppTypography.messageListSender(context, unread: unread),
          ),
        ),
        Flexible(
          flex: 0,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(child: _buildHoverActions()),
              Text(
                CommonService.formatDateString(
                  item.email.created,
                  type: "onlyDate",
                ),
                style: AppTypography.messageListTimestamp(context, unread: unread),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHoverActions() {
    if (!(kIsWeb && _isHovering && widget.radioButton != true)) {
      return const SizedBox.shrink();
    }

    // Only render icons whose callbacks are non-null. An InkWell with onTap:null
    // is non-interactive and passes touches through to the outer InkWell (opening
    // the email instead of triggering the action).
    return Row(
      children: [
        if (widget.onArchive != null)
          _hoverIcon(
            archive,
            svgArchive,
            widget.onArchive!,
            key: widget.testId != null ? Key('${widget.testId}_archive') : null,
          ),
        if (widget.onDelete != null)
          _hoverIcon(
            'Move to Trash',
            svgDelete,
            widget.onDelete!,
            key: widget.testId != null ? Key('${widget.testId}_delete') : null,
          ),
        if (widget.onOptIn != null)
          _hoverIcon(
            optIn,
            svgOptin,
            widget.onOptIn!,
            key: widget.testId != null ? Key('${widget.testId}_optin') : null,
          ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _hoverIcon(String tooltip, String asset, VoidCallback onTap, {Key? key}) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        key: key,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: SvgPicture.asset(
            asset,
            height: 20,
            width: 20,
            colorFilter: ColorFilter.mode(context.colors.onSurfaceVariant, BlendMode.srcIn),
          ),
        ),
      ),
    );
  }

  Widget _buildSubject(Emails item) {
    final bool unread = !item.isRead;
    return Row(
      children: [
        Expanded(
          child: Text(
            item.email.subject.isNotEmpty ? item.email.subject : "(no subject)",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.messageListSubject(context, unread: unread),
          ),
        ),
        if (item.email.attachments.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: SvgPicture.asset(svgAttachment),
          ),
      ],
    );
  }

  Widget _buildMessage(Emails item, BuildContext context, {int maxLines = 2}) {
    final text =
        HtmlSanitizerService().htmlReplaceString(item.email.messageText ?? '');
    final style = AppTypography.messageListPreview(context);
    // Reserve fixed line space so every row is the same height.
    final lineHeight = (style.fontSize ?? 13) * (style.height ?? 1.35);
    final reservedHeight = lineHeight * maxLines;

    return SizedBox(
      width: AppBreakpoints.screenWidth(context) * 0.83,
      height: reservedHeight,
      child: Text(
        text.isNotEmpty ? text : 'This Message has no content.',
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
        style: style,
      ),
    );
  }

  Widget _buildTags(Emails item) {
    return Wrap(
      spacing: 2,
      runSpacing: 2,
      children: item.emailRecipientTags.map((tag) {
        return GestureDetector(
          onTap: () => context.push(AppRoutes.tagEmailsPath(tag.tag.id)),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
            decoration: BoxDecoration(
              color: context.appColors.tagChipBg,
              borderRadius: BorderRadius.circular(AppStyles.radiusS),
            ),
            child: Text(
              tag.tag.tag,
              style: AppTypography.labelSmall(context).copyWith(
                color: context.appColors.tagChipText,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ───────────────────────── MODALS ─────────────────────────

  void commRecConfirmModal(String senderEmail) {
    showDialog(
      context: context,
      builder: (_) => CustomPopupModal(
        title: communityRecommendation,
        subtitle:
            'Your community has recommended this email. Are you sure you want to proceed?',
        textButton1: 'Cancel',
        textButton2: 'Add',
        onPressedButton1: () => context.pop(),
        onPressedButton2: () {
          context.pop();
          gotoAddRecipient(senderEmail);
        },
      ),
    );
  }

  void gotoAddRecipient(String senderEmail) {
    showDialog(
      context: context,
      builder: (_) => AddEmailModal(
        saveFlag: () {},
        title: addEmail,
        type: "longPress",
        subtitleFirst: senderEmail,
        subtitle: addEmailcontact,
      ),
    );
  }
}
