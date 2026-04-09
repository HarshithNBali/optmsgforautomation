import 'package:optmsg/main.dart';
import 'package:optmsg/services/api_service.dart';
import 'package:optmsg/services/common_service.dart';
import 'package:optmsg/services/html_sanitizer_service.dart';
import 'package:optmsg/widgets/add_email_modal.dart';
import 'package:optmsg/widgets/pop_up_modal.dart';
import 'package:go_router/go_router.dart';
import 'package:optmsg/constant/string_constant.dart';
import 'package:optmsg/model/sent_list_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:optmsg/constant/img_path.dart';
import 'package:optmsg/constant/styles.dart';
import 'package:optmsg/constant/app_typography.dart';
import 'package:optmsg/common/responsive/responsive.dart';
import 'package:optmsg/router/app_routes.dart';

class SentEmailList extends StatefulWidget {
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
  final int? selectedIndex;
  final VoidCallback? onArchive;
  final VoidCallback? onDelete;
  final VoidCallback? onOptIn;
  final VoidCallback? onMoveToInbox;
  final bool? hasAnySelection;
  final int? selectedEmailId;
  const SentEmailList({
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
    this.selectedIndex,
    this.onArchive,
    this.onDelete,
    this.onOptIn,
    this.onMoveToInbox,
    this.hasAnySelection,
    this.selectedEmailId,
  });

  @override
  State<SentEmailList> createState() => _SentEmailListState();
}

class _SentEmailListState extends State<SentEmailList> {
  bool _isHovering = false; // web-only hover state for showing icons

  @override

  /// This method is called when the [StatefulWidget] is inserted into the tree.
  ///
  /// It initializes the state of the widget and calls the [initState] method
  /// of its superclass. This is typically where you start any asynchronous
  /// operations, subscribe to streams, or initialize data that is required
  /// for the widget to function correctly.

  void initState() {
    super.initState();
  }

  @override

  /// Builds the widget tree for the sent email list item.
  ///
  /// Returns an [InkWell] widget containing a [Container] with various child widgets
  /// to display the details of an email such as sender/receiver, subject, and body text.
  ///
  /// The [InkWell] widget allows the entire item to be tappable, with actions for [onTap]
  /// and [onLongPress] defined based on the [radioButton] property.
  ///
  /// The [Container] includes:
  /// - A border indicating selection if [selectedIndex] matches [index].
  /// - A [Row] layout with a radio button or unchecked icon if [radioButton] is true.
  /// - Displays a dot if the email is unread and not sent by the current user or not of type "sent".
  /// - A [Column] containing:
  ///   - Recipient or sender email, displayed based on [emailType].
  ///   - Date of the email.
  ///   - Community status indicator if applicable.
  ///   - Subject and attachment icon if present.
  ///   - Email body text with a maximum of two lines.
  ///   - Tags associated with the email.
  ///
  /// The widget adjusts its layout and contents dynamically based on the properties
  /// and state of the [SentEmailList] widget.

  Widget build(BuildContext context) {
    final item = widget.item; // Access the item property from widget
    final bool shouldShowBorder = widget.selectedIndex == widget.index &&
        widget.item?.communityStatus == true &&
        widget.emailType == "trash";
    // Show checkbox on hover for medium/large screens, when in selection mode, or when any email is selected
    final bool isNotMobile = !AppBreakpoints.isMobileLayout(context);
    final bool showCheckbox = widget.radioButton == true ||
        (widget.hasAnySelection == true && (isNotMobile || kIsWeb));
    // Compare email IDs for highlighting - check both item.id and receivers[0].emailId
    final int? emailId =
        (item?.receivers != null && item!.receivers!.isNotEmpty)
            ? item.receivers![0].emailId
            : item?.id;
    final bool isActive = widget.selectedEmailId != null &&
        emailId != null &&
        widget.selectedEmailId == emailId;
    final isSelected = widget.checkRadio == true;
    return Semantics(
      label: 'Sent to ${item?.receivers?.isNotEmpty == true ? (item!.receivers![0].receiver?.firstName ?? item.receivers![0].receiverEmail ?? '') : ''}, ${item?.subject ?? 'No subject'}',
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
            border: shouldShowBorder
                ? Border.all(
                    color: context.appColors.linkBlue.withValues(alpha: 0.5),
                    width: 2,
                  )
                : null,
            color: () {
              if (isSelected) return context.appColors.messageSelectedRow;
              if (isNotMobile && (isActive || _isHovering)) {
                return context.colors.primary.withValues(alpha: 0.1);
              }
              return Colors.transparent;
            }(),
            borderRadius: BorderRadius.circular(AppStyles.radiusM),
          ),
          padding: EdgeInsets.only(left: showCheckbox ? 8 : 0, right: 15, top: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Show checkbox on hover for medium/large screens, or when in selection mode
              if (showCheckbox)
                Semantics(
                  label: isSelected ? 'Deselect email' : 'Select email',
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
              if (showCheckbox) const SizedBox(width: 5),

              // Spacer/Dot indicator container - fixed 16px width for alignment with header
              // Sent-origin emails are always treated as read (no unread concept for sender).
              // Client-side override: the backend's update-email-status API for isRead
              // only affects recipient records, not the sender's view.
              // TODO(backend): Support isRead for sender's view of sent emails so this
              // client-side override can be removed.
              widget.emailType == 'sent' ||
                      item!.senderId == widget.userId ||
                      item.isDraft == true
                  ? const SizedBox(width: 16)
                  : SizedBox(
                      width: 16,
                      child: item.receivers != null &&
                              item.receivers!.isNotEmpty &&
                              item.receivers![0].isRead == false &&
                              widget.emailType != "sent"
                          ? Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Center(
                                child: SvgPicture.asset(svgDot,
                                    colorFilter: ColorFilter.mode(
                                        context.appColors.accent,
                                        BlendMode.srcIn)),
                              ),
                            )
                          : Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Center(
                                child: SvgPicture.asset(blankDot),
                              ),
                            ),
                    ),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (widget.emailType == "sent")
                          Text("To: ", style: AppTypography.messageListSender(context)),
                        Expanded(
                          child: item!.isDraft == true
                              ? Text(
                                  'Draft',
                                  style: AppTypography.messageListSender(context).copyWith(
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                )
                              : widget.emailType == "sent"
                              ? Text(
                                  CommonService().capitalize(
                                    item.receivers![0].receiverEmail
                                        .toString()
                                        .split('@')
                                        .first,
                                  ),
                                  style: AppTypography.messageListSender(context),
                                  overflow: TextOverflow.ellipsis,
                                )
                              : Text(
                                  CommonService().capitalize(
                                    item.sender!.firstName
                                        .toString()
                                        .split('@')
                                        .first,
                                  ),
                                  style: AppTypography.messageListSender(context),
                                  overflow: TextOverflow.ellipsis,
                                ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Show hover icons only on web, when hovering, not in selection mode, and not mobile
                            if (kIsWeb &&
                                _isHovering &&
                                widget.radioButton != true &&
                                isNotMobile) ...[
                              // Show Move to Inbox icon for archive and trash screens
                              if (widget.emailType == 'archive' ||
                                  widget.emailType == 'trash')
                                Tooltip(
                                  message: inbox,
                                  child: InkWell(
                                    onTap: widget.onMoveToInbox,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0),
                                      child: SvgPicture.asset(
                                        svgInbox,
                                        height: 20,
                                        width: 20,
                                        colorFilter: ColorFilter.mode(
                                            Theme.of(context).colorScheme.onSurfaceVariant, BlendMode.srcIn),
                                      ),
                                    ),
                                  ),
                                ),
                              // Show Archive icon for sent and trash screens
                              if (widget.emailType == 'sent' ||
                                  widget.emailType == 'trash')
                                Tooltip(
                                  message: archive,
                                  child: InkWell(
                                    onTap: widget.onArchive,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0),
                                      child: SvgPicture.asset(
                                        svgArchive,
                                        height: 20,
                                        width: 20,
                                        colorFilter: ColorFilter.mode(
                                            Theme.of(context).colorScheme.onSurfaceVariant, BlendMode.srcIn),
                                      ),
                                    ),
                                  ),
                                ),
                              // Delete icon - show "Permanently Delete" for trash, "Move to Trash" for others
                              Tooltip(
                                message: widget.emailType == 'trash'
                                    ? 'Permanently Delete'
                                    : 'Move to Trash',
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
                              // Opt-In icon
                              Tooltip(
                                message: optIn,
                                child: InkWell(
                                  onTap: widget.onOptIn,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0),
                                    child: SvgPicture.asset(
                                      svgOptin,
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
                            Text(
                              CommonService.formatDateString(
                                  item.created.toString(),
                                  type: "onlyDate"),
                              style: AppTypography.messageListTimestamp(context),
                            ),
                          ],
                        ),
                      ],
                    ),
                    if (item.communityStatus != null &&
                        item.communityStatus == true &&
                        widget.emailType == "trash")
                      Padding(
                        padding: const EdgeInsets.only(bottom: 3.0, top: 3.0),
                        child: InkWell(
                          onTap: () {
                            _displayAddEmailModal(item.senderEmail!);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: context.appColors.tintOrange,
                              borderRadius: BorderRadius.circular(AppStyles.radiusS),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0, vertical: 5.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SvgPicture.asset(
                                    svgFillFlag,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    communityRecommendation,
                                    style: AppTypography.flag(context),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              (item.subject != null && item.subject!.isNotEmpty)
                                  ? item.subject!
                                  : "(no subject)",
                              style: AppTypography.messageListSubject(context)),
                        ),
                        if (item.attachments!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 8.0), // Add some padding if needed
                            child: SvgPicture.asset(svgAttachment),
                          ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Wrap(
                                alignment: WrapAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 3),
                                    child: Builder(
                                      builder: (context) {
                                        final style = AppTypography.messageListPreview(context);
                                        final twoLineHeight = (style.fontSize ?? 13) * (style.height ?? 1.3) * 2;
                                        return SizedBox(
                                          width: AppBreakpoints.screenWidth(context) * 0.83,
                                          height: twoLineHeight,
                                          child: RichText(
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            text: TextSpan(
                                              style: style,
                                              children: [
                                                TextSpan(
                                                  style: style,
                                                  text: () {
                                                    final parsed = HtmlSanitizerService()
                                                        .htmlReplaceString(
                                                          item.messageText
                                                              .toString(),
                                                        );
                                                    return parsed.isNotEmpty
                                                        ? parsed
                                                        : 'This Message has no content. ';
                                                  }(),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              Wrap(
                                spacing: 2,
                                runSpacing: 2,
                                children: [
                                  ...(() {
                                    // Pick tags list from either emailTag or receivers[0].emailRecipientTags
                                    List<dynamic> tagsList =
                                        (item.emailTag?.isNotEmpty ?? false)
                                            ? List<dynamic>.from(
                                                item.emailTag ?? [])
                                            : (item.receivers?.isNotEmpty ??
                                                    false)
                                                ? List<dynamic>.from(item
                                                        .receivers![0]
                                                        .emailRecipientTags ??
                                                    [])
                                                : [];

                                    return tagsList.map((tagItem) {
                                      String tagName = '';
                                      int? tagId;

                                      if (tagItem is Map<String, dynamic>) {
                                        // Map case from JSON
                                        tagName = tagItem['tag']?['tag'] ?? '';
                                        tagId = tagItem['tag']?['id'];
                                      } else {
                                        // Model object case — try safe property access
                                        try {
                                          final dynamic tagObj = tagItem.tag;
                                          if (tagObj != null) {
                                            tagName = tagObj.tag ?? '';
                                            tagId = tagObj.id;
                                          }
                                        } catch (_) {
                                          // If no .tag property exists, fallback to empty
                                          tagName = '';
                                        }
                                      }

                                      return GestureDetector(
                                        onTap: tagId != null
                                            ? () => context.push(
                                                AppRoutes.tagEmailsPath(tagId!))
                                            : null,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 5.0, vertical: 2.0),
                                          decoration: BoxDecoration(
                                            color:
                                                context.appColors.tagChipBg,
                                            borderRadius:
                                                BorderRadius.circular(AppStyles.radiusS),
                                          ),
                                          child: Text(
                                            tagName,
                                            style: AppTypography.labelSmall(context).copyWith(
                                              color: context.appColors.tagChipText,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      );
                                    }).toList();
                                  })(),
                                ],
                              )
                            ],
                          ),
                        ),
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

  /// Method to show a confirmation modal for community recommendation.
  void commRecConfirmModal(String senderEmail) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomPopupModal(
          onPressedButton1: () {
            context.pop();
          },
          onPressedButton2: () {
            context.pop();
            gotoAddRecipient(senderEmail);
          },
          textButton1: 'Cancel',
          textButton2: 'Add',
          icon: null,
          title: communityRecommendation,
          subtitle:
              'Your community has recommended this email. Are you sure you want to proceed?',
        );
      },
    );
  }

  /// Method to show a modal for adding a recipient.
  void gotoAddRecipient(String senderEmail) {
    showDialog(
        context: NavigationService.navigatorKey.currentContext ?? context,
        builder: (BuildContext context) {
          return AddEmailModal(
            saveFlag: () {},
            title: addEmail,
            type: "longPress",
            subtitleFirst: senderEmail,
            subtitle: addEmailcontact,
          );
        });
  }

  /// Method to show a modal for adding a recipient.
  Future<void> _displayAddEmailModal(String email) async {
    // Call API to check if email is already added to a contact
    try {
      Map<String, dynamic> resp =
          await ApiService().post('contact/check-email', {"email": email});
      if (!mounted) return;
      if (resp['success']) {
        if (resp['data']['status']) {
          CommonService.animatedToast(
            'Email is already present in a contact',
            'info',
          );
        } else {
          commRecConfirmModal(email);
        }
        // Email is not added to any contact, proceed to display modal
      } else {
        CommonService.animatedToast(resp['message'], 'error');
      }
    } catch (error) {
      if (error is! NoInternetException) {
        CommonService.animatedToast('Error checking email', 'error');
      }
    }
  }
}
