import 'package:optmsg/common/responsive/responsive.dart';
import '../../../../widgets/alphabet_contact_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../constant/img_path.dart';
import '../../../../constant/styles.dart';
import 'package:optmsg/constant/app_typography.dart';
import '../../../../model/contact_list_model.dart';
import '../../../../widgets/contact_list_row.dart';
import '../../../../widgets/empty_state.dart';
import '../../../../widgets/reading_pane_placeholder.dart';
import '../../../../widgets/common_web_button.dart';
import '../../view_contact_riverpod/view_contact_riverpod.dart';
import '../contact_list_notifier.dart';
import '../contact_list_riverpod.dart';
import '../contact_state.dart';
import 'package:optmsg/router/app_routes.dart';
import 'package:optmsg/router/navigation_helper.dart';
import 'package:go_router/go_router.dart';
import '../widget/contact_filter_overlay.dart';

Widget webReadPane(
  ContactState s,
  ContactListNotifier n,
  BuildContext context,
  ContactListriverpod widget,
) {
  // Hide reading pane and action bar for optin/addContact mode (contact selection only)
  final bool isSelectionMode =
      widget.type == 'optin' || widget.type == 'addContact';
  final bool showReadingPane =
      !isSelectionMode &&
      s.readingPaneEnabled &&
      (s.filteredContacts.isNotEmpty || s.selectedContact != null);
  final dividerColor = context.colors.outlineVariant;
  final bool inMultiSelect = s.hasMultiSelection;
  final bool showCheckboxes = s.showCheckboxes || inMultiSelect;

  return Column(
    children: [
      // Action bar with Add button (like inbox compose button) - hide for selection mode only if NOT optin
      if (!isSelectionMode || widget.type == 'optin')
        Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border(bottom: BorderSide(width: 1, color: dividerColor)),
          ),
          child: Row(
            children: [
              if (inMultiSelect) ...[
                // Multi-select action bar: delete only (count shown in list header)
                IconButton(
                  icon: SvgPicture.asset(
                    svgDelete,
                    height: 24,
                    width: 24,
                    colorFilter: ColorFilter.mode(
                      context.colors.onSurfaceVariant,
                      BlendMode.srcIn,
                    ),
                  ),
                  onPressed: s.isInProcess
                      ? null
                      : () => n.handleDeleteSelectedContacts(),
                  tooltip: 'Delete',
                ),
              ] else ...[
                // Normal action bar
                // Add button
                _AddButton(
                  onTap: () async {
                    final result = await context.push<Map<String, dynamic>?>(
                      AppRoutes.addContactriverpod,
                    );

                    if (result != null && result['type'] == 'add') {
                      final Contacts newContact = result['contact'];
                      // Add contact to riverpod state
                      n.addContact(newContact);

                      // Check for optin flow - if so, immediately use the new contact
                      if (widget.type == 'optin' && widget.prevEmail != null) {
                        n.addAndDeleteEmail(
                          'add',
                          widget.prevEmail!,
                          newContact,
                        );
                        return;
                      }

                      // If reading pane is enabled, no need to navigate - details will show in 3rd panel
                      // If reading pane is disabled, navigate to view contact page
                      if (!showReadingPane) {
                        GoRouter.of(context).push(
                          AppRoutes.viewContactriverpodPath(newContact.id),
                          extra: {
                            'contact': newContact,
                            'page': 'addContact',
                            'onContactUpdated':
                                (Map<String, dynamic> updateResult) async {
                                  if (updateResult['type'] == 'edit') {
                                    n.updateContact(updateResult['contact']);
                                  } else if (updateResult['type'] == 'delete') {
                                    n.deleteContactRecord(
                                      updateResult['contact'].id,
                                    );
                                  }
                                },
                          },
                        );
                      }
                    }
                  },
                ),
                if (s.selectedContact != null &&
                    s.hasContacts &&
                    showReadingPane) ...[
                  const SizedBox(width: 16),
                  IconButton(
                    icon: SvgPicture.asset(
                      svgEditForm,
                      height: 24,
                      width: 24,
                      colorFilter: ColorFilter.mode(
                        context.colors.onSurfaceVariant,
                        BlendMode.srcIn,
                      ),
                    ),
                    onPressed: s.isInProcess
                        ? null
                        : () {
                            n.handleEditContact();
                          },
                    tooltip: 'Edit',
                  ),
                  IconButton(
                    icon: SvgPicture.asset(
                      svgDelete,
                      height: 24,
                      width: 24,
                      colorFilter: ColorFilter.mode(
                        context.colors.onSurfaceVariant,
                        BlendMode.srcIn,
                      ),
                    ),
                    onPressed: () {
                      n.handleDeleteContact();
                    },
                    tooltip: 'Delete',
                  ),
                ],
              ],
            ],
          ),
        ),
      // Row with Contact List and Reading Pane
      Expanded(
        child: Row(
          children: [
            // Contact List Pane
            Expanded(
              flex: showReadingPane ? 1 : 1,
              child: Column(
                children: [
                  // "Contacts" header — matches inbox list header pattern
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 4, 16, 4),
                    child: Row(
                      children: [
                        if (s.hasContacts && !isSelectionMode)
                          SizedBox(
                            width: 36,
                            height: 36,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(
                                AppStyles.radiusXL,
                              ),
                              onTap: () {
                                if (!showCheckboxes && !inMultiSelect) {
                                  n.setShowCheckboxes(true);
                                } else if (s.allContactsFlag) {
                                  n.clearMultiSelection();
                                } else {
                                  n.selectAllContacts();
                                }
                              },
                              onLongPress: (showCheckboxes || inMultiSelect)
                                  ? () {
                                      n.clearMultiSelection();
                                    }
                                  : null,
                              child: Center(
                                child: Icon(
                                  (showCheckboxes || inMultiSelect)
                                      ? (s.allContactsFlag
                                            ? Icons.check_box
                                            : (inMultiSelect
                                                  ? Icons
                                                        .indeterminate_check_box
                                                  : Icons
                                                        .check_box_outline_blank))
                                      : Icons.check_box_outline_blank,
                                  color: context.colors.primary,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        Text(
                          'Contacts',
                          style: AppTypography.headlineMedium(context).copyWith(
                            color: context.colors.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (s.selectedContactIds.isNotEmpty) ...[
                          const SizedBox(width: 12),
                          Text(
                            s.allContactsFlag
                                ? 'All Selected (${s.selectedCount})'
                                : '${s.selectedCount} selected',
                            style: AppTypography.labelMedium(
                              context,
                            ).copyWith(color: context.colors.onSurfaceVariant),
                          ),
                        ],
                        const Spacer(),
                        if (!isSelectionMode) _contactFilterIcon(s, n, context),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Container(height: 1, color: dividerColor),
                  ),
                  // Contact list + filter overlay
                  Expanded(
                    child: Stack(
                      children: [
                        RefreshIndicator(
                          color: Theme.of(context).colorScheme.primary,
                          notificationPredicate: (_) =>
                              !(inMultiSelect || showCheckboxes),
                          onRefresh: () async {
                            n.refreshContacts();
                          },
                          child: s.filteredContacts.isEmpty
                              ? const Center(
                                  child: EmptyState(
                                    variant: EmptyStateVariant.contacts,
                                  ),
                                )
                              : Consumer(
                                  builder: (context, ref, child) {
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 5.0),
                                      child: AlphabetContactList(
                                        // PW-03: Use pre-computed letter index map from notifier
                                        letterIndexMap: ref
                                            .read(contactListProvider.notifier)
                                            .letterIndexMap,
                                        selectedTextStyle:
                                            AppTypography.alfaSelectedListText(
                                              context,
                                            ),
                                        unselectedTextStyle:
                                            AppTypography.alfaListText(context),
                                        itemExtent:
                                            (47 *
                                                    MediaQuery.textScalerOf(
                                                      context,
                                                    ).scale(1.0))
                                                .clamp(47.0, 70.0),
                                        itemCount: s.filteredContacts.length,
                                        itemBuilder: (context, index) {
                                          Contacts contact =
                                              s.filteredContacts[index];
                                          bool isSelected =
                                              s.selectedContact?.id ==
                                              contact.id;
                                          bool isMultiSelected = s
                                              .selectedContactIds
                                              .contains(contact.id);
                                          return ContactListRow(
                                            testId: 'contact_list_row_${contact.id}',
                                            contact: contact,
                                            isSelected: isSelected,
                                            isMultiSelected: isMultiSelected,
                                            showCheckbox:
                                                showCheckboxes &&
                                                !isSelectionMode,
                                            sortByLastName:
                                                s.userData?['user']?['sortLastName'] ==
                                                true,
                                            onLongPress: isSelectionMode
                                                ? null
                                                : () =>
                                                      n.onLongPress(contact.id),
                                            onTap: () {
                                              if (widget.type != null &&
                                                  widget.type == 'optin') {
                                                n.addAndDeleteEmail(
                                                  'add',
                                                  widget.prevEmail.toString(),
                                                  contact,
                                                );
                                              } else if (widget.type != null &&
                                                  widget.type == 'addContact') {
                                                n.updateContact(contact);
                                              } else {
                                                // Check keyboard modifiers for desktop
                                                if (kIsWeb) {
                                                  final keys = HardwareKeyboard
                                                      .instance
                                                      .logicalKeysPressed;
                                                  final isShift =
                                                      keys.contains(
                                                        LogicalKeyboardKey
                                                            .shiftLeft,
                                                      ) ||
                                                      keys.contains(
                                                        LogicalKeyboardKey
                                                            .shiftRight,
                                                      );
                                                  final isCtrlOrCmd =
                                                      keys.contains(
                                                        LogicalKeyboardKey
                                                            .controlLeft,
                                                      ) ||
                                                      keys.contains(
                                                        LogicalKeyboardKey
                                                            .controlRight,
                                                      ) ||
                                                      keys.contains(
                                                        LogicalKeyboardKey
                                                            .metaLeft,
                                                      ) ||
                                                      keys.contains(
                                                        LogicalKeyboardKey
                                                            .metaRight,
                                                      );

                                                  if (isShift) {
                                                    int from;
                                                    if (s.lastClickedIndex !=
                                                        -1) {
                                                      from = s.lastClickedIndex;
                                                    } else if (s
                                                            .selectedContact !=
                                                        null) {
                                                      final viewedIdx = s
                                                          .filteredContacts
                                                          .indexWhere(
                                                            (c) =>
                                                                c.id ==
                                                                s
                                                                    .selectedContact!
                                                                    .id,
                                                          );
                                                      from = viewedIdx != -1
                                                          ? viewedIdx
                                                          : index;
                                                    } else {
                                                      from = index;
                                                    }
                                                    n.selectContactRange(
                                                      from,
                                                      index,
                                                    );
                                                    return;
                                                  }
                                                  if (isCtrlOrCmd) {
                                                    if (s
                                                            .selectedContactIds
                                                            .isEmpty &&
                                                        s.selectedContact !=
                                                            null) {
                                                      final viewedIdx = s
                                                          .filteredContacts
                                                          .indexWhere(
                                                            (c) =>
                                                                c.id ==
                                                                s
                                                                    .selectedContact!
                                                                    .id,
                                                          );
                                                      if (viewedIdx != -1) {
                                                        n.toggleSingleSelectByIndex(
                                                          viewedIdx,
                                                        );
                                                      }
                                                    }
                                                    n.toggleSingleSelectByIndex(
                                                      index,
                                                    );
                                                    return;
                                                  }
                                                }

                                                if (inMultiSelect ||
                                                    showCheckboxes) {
                                                  n.toggleSelectContact(
                                                    contact.id,
                                                  );
                                                  return;
                                                }

                                                n.selectContact(contact);

                                                if (!showReadingPane) {
                                                  context.pushTo(
                                                    AppRoutes
                                                        .viewContactriverpod,
                                                    extra: {
                                                      'contact': contact,
                                                      'page': 'list',
                                                      'onContactUpdated': (result) async {
                                                        FocusScope.of(
                                                          context,
                                                        ).unfocus();
                                                        if (result['type'] ==
                                                            'edit') {
                                                          n.updateContact(
                                                            result['contact'],
                                                          );
                                                        } else if (result['type'] ==
                                                            'delete') {
                                                          n.deleteContactRecord(
                                                            result['contact']
                                                                .id,
                                                          );
                                                        } else if (result['type'] ==
                                                            'add') {
                                                          n.addContact(
                                                            result['contact'],
                                                          );
                                                        }
                                                      },
                                                    },
                                                  );
                                                }
                                              }
                                            },
                                          );
                                        },
                                      ),
                                    );
                                  },
                                ),
                        ),
                        if (s.showFilter) contactFilterOverlay(context, n),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Divider between panes (only show when reading pane is enabled)
            if (showReadingPane) Container(width: 1, color: dividerColor),
            // Reading Pane (only show when reading pane is enabled)
            if (showReadingPane)
              Expanded(
                flex: 2,
                child: s.selectedContact != null
                    ? ViewContactriverpod(
                        key: ValueKey(s.selectedContact!.id),
                        contact: s.selectedContact!,
                        page: 'list',
                        hideAppBar: true,
                        onContactUpdated: (result) async {
                          FocusScope.of(context).unfocus();
                          if (result['type'] == 'edit') {
                            n.updateContact(result['contact']);
                          } else if (result['type'] == 'delete') {
                            n.deleteContactRecord(result['contact'].id);
                          } else if (result['type'] == 'add') {
                            n.addContact(result['contact']);
                          }
                        },
                      )
                    : const ReadingPanePlaceholder.contacts(),
              ),
          ],
        ),
      ),
    ],
  );
}

class _AddButton extends StatefulWidget {
  final VoidCallback onTap;

  const _AddButton({required this.onTap});

  @override
  State<_AddButton> createState() => _AddButtonState();
}

class _AddButtonState extends State<_AddButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return CommonWebButton(
      onPressed: widget.onTap,
      iconData: Icons.add,
      label: 'Add',
      onHoverStart: () => setState(() => _isHovered = true),
      onHoverEnd: () => setState(() => _isHovered = false),
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 0.0),
      iconSize: 20,
      // spacing: 8,
      textStyle: AppTypography.titleLarge(
        context,
      ).copyWith(fontWeight: FontWeight.w500, color: context.colors.onPrimary),
      backgroundColor: _isHovered
          ? context.appColors.accentHover
          : context.appColors.accentButton,
      borderRadius: const BorderRadius.all(Radius.circular(8.0)),
      iconColor: context.colors.onPrimary,
      testId: 'contacts_add_button',
    );
  }
}

Widget _contactFilterIcon(
  ContactState s,
  ContactListNotifier n,
  BuildContext context,
) {
  if (s.contactTypeFilter == 'person') {
    return IconButton(
      icon: SvgPicture.asset(
        svgContactTypeUser,
        height: 20,
        width: 20,
        colorFilter: ColorFilter.mode(context.colors.primary, BlendMode.srcIn),
      ),
      onPressed: () => n.clearContactTypeFilter(),
      tooltip: 'Clear People Filter',
    );
  }
  if (s.contactTypeFilter == 'company') {
    return IconButton(
      icon: SvgPicture.asset(
        svgContactTypeOffice,
        height: 20,
        width: 20,
        colorFilter: ColorFilter.mode(context.colors.primary, BlendMode.srcIn),
      ),
      onPressed: () => n.clearContactTypeFilter(),
      tooltip: 'Clear Companies Filter',
    );
  }
  // Default: no filter active
  return IconButton(
    icon: SvgPicture.asset(
      svgFilter,
      height: 20,
      width: 20,
      colorFilter: ColorFilter.mode(
        context.colors.onSurfaceVariant,
        BlendMode.srcIn,
      ),
    ),
    onPressed: () => n.toggleFilter(),
    tooltip: 'Filter',
  );
}

String getCompanyName(Contacts contact) {
  String combinedName;
  if (contact.firstName.isNotEmpty && contact.lastName.isNotEmpty) {
    combinedName = "${contact.firstName} ${contact.lastName}";
  } else if (contact.lastName.isNotEmpty) {
    combinedName = contact.lastName;
  } else if (contact.firstName.isNotEmpty) {
    combinedName = contact.firstName;
  } else {
    combinedName = contact.company;
  }
  return combinedName;
}
