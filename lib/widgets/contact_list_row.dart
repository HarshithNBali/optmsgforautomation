import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:optmsg/common/responsive/responsive.dart';
import 'package:optmsg/constant/app_typography.dart';
import 'package:optmsg/constant/img_path.dart';
import 'package:optmsg/constant/styles.dart';
import 'package:optmsg/model/contact_list_model.dart';
import 'package:optmsg/services/common_service.dart';

/// A single contact row styled consistently with email list rows.
///
/// Provides hover highlighting (web/desktop), selection highlighting,
/// consistent thin dividers, and vertically centered content.
class ContactListRow extends StatefulWidget {
  const ContactListRow({
    super.key,
    required this.contact,
    required this.onTap,
    this.onLongPress,
    this.isSelected = false,
    this.isMultiSelected = false,
    this.showCheckbox = false,
    this.sortByLastName = false,
  });

  final Contacts contact;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  /// Whether this contact is the active/viewing contact (reading pane).
  final bool isSelected;

  /// Whether this contact is part of a multi-selection.
  final bool isMultiSelected;

  /// Whether to show the checkbox icon in leading position.
  final bool showCheckbox;

  /// Whether to bold the last name (true) or first name (false).
  final bool sortByLastName;

  @override
  State<ContactListRow> createState() => _ContactListRowState();
}

class _ContactListRowState extends State<ContactListRow> {
  bool _isHovering = false;

  void _setHover(bool value, bool isNotMobile) {
    if (kIsWeb && isNotMobile && mounted) {
      setState(() => _isHovering = value);
    }
  }

  Color _computeColor(BuildContext context, bool isNotMobile) {
    if (widget.isMultiSelected) return context.appColors.messageSelectedRow;
    if (isNotMobile && (widget.isSelected || _isHovering)) {
      return context.colors.primary.withValues(alpha: 0.1);
    }
    return Colors.transparent;
  }

  @override
  Widget build(BuildContext context) {
    final bool isNotMobile = !context.isMobile;
    final contact = widget.contact;
    final bool isCompanyOnly =
        contact.firstName.isEmpty && contact.lastName.isEmpty && contact.company.isNotEmpty;

    return RepaintBoundary(
      child: MouseRegion(
        onEnter: (_) => _setHover(true, isNotMobile),
        onExit: (_) => _setHover(false, isNotMobile),
        child: InkWell(
          onTap: widget.onTap,
          onLongPress: widget.onLongPress,
          child: Container(
            decoration: BoxDecoration(
              color: _computeColor(context, isNotMobile),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16, right: 10, top: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (widget.showCheckbox) _buildCheckbox(context),
                        if (widget.showCheckbox) const SizedBox(width: 8),
                        Expanded(
                          child: RichText(
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            text: TextSpan(
                              children: [
                                if (!isCompanyOnly) ...[
                                  TextSpan(
                                    text: CommonService().capitalize(contact.firstName),
                                    style: AppTypography.titleLarge(context).copyWith(
                                      fontWeight: widget.sortByLastName
                                          ? FontWeight.normal
                                          : FontWeight.bold,
                                      color: context.colors.onSurface,
                                    ),
                                  ),
                                  if (contact.firstName.isNotEmpty)
                                    const TextSpan(text: ' '),
                                  TextSpan(
                                    text: CommonService().capitalize(contact.lastName),
                                    style: AppTypography.titleLarge(context).copyWith(
                                      fontWeight: widget.sortByLastName
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      color: context.colors.onSurface,
                                    ),
                                  ),
                                ],
                                if (isCompanyOnly)
                                  TextSpan(
                                    text: CommonService().capitalize(getCompanyDisplayName(contact)),
                                    style: AppTypography.titleLarge(context).copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: context.colors.onSurface,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        SvgPicture.asset(
                          isCompanyOnly ? svgContactTypeOffice : svgContactTypeUser,
                          width: 20.0,
                          height: 20.0,
                        ),
                        const SizedBox(width: 10),
                      ],
                    ),
                  ),
                ),
                const Divider(height: 1),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCheckbox(BuildContext context) {
    final cbSize = AppStyles.checkboxSize(context);
    final iconSize = AppStyles.checkboxIconSize(context);
    return SizedBox(
      width: cbSize,
      height: cbSize,
      child: Center(
        child: Icon(
          widget.isMultiSelected ? Icons.check_box : Icons.check_box_outline_blank,
          color: Theme.of(context).colorScheme.primary,
          size: iconSize,
        ),
      ),
    );
  }
}

/// Returns the display name for a contact, preferring name over company.
String getCompanyDisplayName(Contacts contact) {
  if (contact.firstName.isNotEmpty && contact.lastName.isNotEmpty) {
    return "${contact.firstName} ${contact.lastName}";
  } else if (contact.lastName.isNotEmpty) {
    return contact.lastName;
  } else if (contact.firstName.isNotEmpty) {
    return contact.firstName;
  } else {
    return contact.company;
  }
}
