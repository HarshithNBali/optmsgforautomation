import 'package:optmsg/services/common_service.dart';
import 'package:optmsg/services/html_sanitizer_service.dart';
import 'package:optmsg/constant/string_constant.dart';
import 'package:optmsg/model/draft_list_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:optmsg/constant/img_path.dart';
import 'package:optmsg/constant/styles.dart';
import 'package:optmsg/constant/app_typography.dart';
import 'package:optmsg/common/responsive/responsive.dart';

class DraftEmailList extends StatefulWidget {
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
  const DraftEmailList({
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
    this.addEmailTags,
    this.emailType,
    required this.index,
    this.onArchive,
    this.onDelete,
    this.onOptIn,
    this.hasAnySelection,
    this.selectedEmailId,
  });

  @override
  State<DraftEmailList> createState() => _DraftEmailListState();
}

class _DraftEmailListState extends State<DraftEmailList> {
  bool _isHovering = false; // web-only hover state for showing icons

  @override

  /// This function is called when the widget is inserted into the tree.
  ///
  /// It sets the state of the widget with the values of [widget.selectedEmailIds]
  /// and [widget.selectedEmails].
  void initState() {
    super.initState();
  }

  @override

  /// This function is called when the widget is rebuilt.
  ///
  /// It returns a [InkWell] widget with a [Container] as its child.
  ///
  /// The [Container] displays the following information:
  ///
  /// - Draft
  /// - Date
  /// - Subject
  /// - Attachments
  /// - Email Body
  ///
  /// The [InkWell] widget is used to make the entire widget clickable.
  ///
  /// The [Container] is also used to add padding to the widget.
  Widget build(BuildContext context) {
    final item = widget.item;
    // Show checkbox on hover for medium/large screens, when in selection mode, or when any email is selected
    final bool isNotMobile = !AppBreakpoints.isMobileLayout(context);
    final bool showCheckbox = widget.radioButton == true ||
        (widget.hasAnySelection == true && (isNotMobile || kIsWeb));
    // Compare email IDs for highlighting - ensure both are not null and match
    final bool isActive = widget.selectedEmailId != null &&
        item?.id != null &&
        widget.selectedEmailId == item?.id;
    final isSelected = widget.checkRadio == true;
    return Semantics(
      label: 'Draft, ${item?.subject ?? 'No subject'}',
      selected: isActive,
      child: MouseRegion(
      onEnter: (event) {
        if (kIsWeb && isNotMobile && mounted) {
          setState(() => _isHovering = true);
        }
      },
      onExit: (event) {
        if (kIsWeb && isNotMobile && mounted) {
          setState(() => _isHovering = false);
        }
      },
      child: InkWell(
        onTap: widget.onTap,
        onLongPress: widget.onLongPress,
        child: Container(
          decoration: BoxDecoration(
            color: () {
              if (isSelected) return context.appColors.messageSelectedRow;
              if (isNotMobile && (isActive || _isHovering)) {
                return context.colors.primary.withValues(alpha: 0.1);
              }
              return Colors.transparent;
            }(),
          ),
          padding: EdgeInsets.only(left: showCheckbox ? 8 : 0, right: 15, top: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Show checkbox on hover for medium/large screens, or when in selection mode
              if (showCheckbox)
                Semantics(
                  label: isSelected ? 'Deselect draft' : 'Select draft',
                  checked: isSelected,
                  child: SizedBox(
                    width: AppStyles.checkboxSize(context),
                    height: AppStyles.checkboxSize(context),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(AppStyles.radiusXL),
                      onTap: widget.radioOnTap,
                      child: Center(
                        child: Icon(
                          isSelected ? Icons.check_box : Icons.check_box_outline_blank,
                          color: Theme.of(context).colorScheme.primary,
                          size: AppStyles.checkboxIconSize(context),
                        ),
                      ),
                    ),
                  ),
                ),
              // Spacer for alignment with header (16px to match inbox dot container)
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            "Draft",
                            style: AppTypography.draftText(context),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Show hover icons only on web, when hovering, not in selection mode, and not mobile
                            if (kIsWeb &&
                                _isHovering &&
                                widget.radioButton != true &&
                                isNotMobile) ...[
                              // Delete icon (drafts can only be deleted, not archived or opted-in)
                              Tooltip(
                                message: delete,
                                child: InkWell(
                                  onTap: widget.onDelete,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0),
                                    child: SvgPicture.asset(
                                      svgDelete,
                                      height: 20,
                                      width: 20,
                                      colorFilter: ColorFilter.mode(
                                          Theme.of(context).colorScheme.onSurfaceVariant, BlendMode.srcIn),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                            ],
                            Flexible(
                              child: Text(
                                CommonService.formatDateString(item!.created,
                                    type: 'onlyDate'),
                                textAlign: TextAlign.right,
                                style: AppTypography.messageListTimestamp(context),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                              overflow: TextOverflow.ellipsis,
                              item.subject.isNotEmpty
                                  ? item.subject
                                  : noSubject,
                              style: AppTypography.messageListSubject(context)),
                        ),
                        if (item.attachments.isNotEmpty)
                          SvgPicture.asset(svgAttachment),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Builder(
                            builder: (context) {
                              final style = AppTypography.messageListPreview(context);
                              final twoLineHeight = (style.fontSize ?? 13) * (style.height ?? 1.3) * 2;
                              return SizedBox(
                                height: twoLineHeight,
                                child: Text(
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                    () {
                                      final parsed = HtmlSanitizerService()
                                          .htmlReplaceString(item.message);
                                      return parsed.isEmpty ? noBody : parsed;
                                    }(),
                                    style: style),
                              );
                            },
                          ),
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(width: 1, color: context.colors.outlineVariant),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
    );
  }

  /// Returns a string containing all the names of the receivers in the list.
  ///
  /// If the list is empty or null, it returns an empty string.
  ///
  /// The returned string is in the format "To: name1, name2, ...".
  ///
  /// This function is used to display the names of the receivers of an email in
  /// the inbox and drafts pages.
  String getFullSendName(List<dynamic>? data) {
    if (data!.isNotEmpty) {
      List<String> names = [];
      for (int i = 0; i < data.length; i++) {
        if (data[i].receiver.firstName != null) {
          names.add(data[i].receiver.firstName);
        }
      }
      return "To: ${names.join(", ")}";
    } else {
      return ""; // Return an empty string if data is null or empty
    }
  }
}
