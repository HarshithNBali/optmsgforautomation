import 'package:optmsg/common/responsive/responsive.dart';
import 'package:optmsg/common/utilites/logger.dart';
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
import 'package:go_router/go_router.dart';
import '../widget/contact_filter_overlay.dart';

Widget tabletReadPane(
  ContactState s,
  ContactListNotifier n,
  BuildContext context,
  ContactListriverpod widget,
) {
  return OrientationBuilder(
    builder: (context, orientation) {
      final mediaQuery = MediaQuery.of(context);
      final screenWidth = mediaQuery.size.width;
      final screenHeight = mediaQuery.size.height;

      // Check if this is a phone in landscape - phones should NOT use panel layout
      final isPhoneLandscape = AppBreakpoints.isPhoneLandscape(context);

      // For tablets, check both OrientationBuilder and screen dimensions
      final isLandscape =
          orientation == Orientation.landscape && screenWidth > screenHeight;

      // Phone in landscape should use portrait layout (single column)
      if (isPhoneLandscape) {
        return _buildPortraitLayout(s, n, context, widget);
      }

      if (isLandscape) {
        return _buildLandscapeLayout(s, n, context, widget);
      }
      return _buildPortraitLayout(s, n, context, widget);
    },
  );
}

Widget _buildLandscapeLayout(
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
      !AppBreakpoints.isPhone(context);
  final dividerColor = context.colors.outlineVariant;
  final bool inMultiSelect = s.hasMultiSelection;
  final bool showCheckboxes = s.showCheckboxes || inMultiSelect;

  return Row(
    children: [
      Expanded(
        flex: 1,
        child: Column(
          children: [
            // Action bar
            if (!isSelectionMode)
              Container(
                height: 52,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  border: Border(
                    bottom: BorderSide(width: 1, color: dividerColor),
                  ),
                ),
                child: Row(
                  children: [
                    if (inMultiSelect) ...[
                      // Multi-select action bar: delete only (count in list header)
                      IconButton(
                        icon: SvgPicture.asset(
                          svgDelete,
                          height: 20,
                          width: 20,
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
                      _buildAddButton(
                        s,
                        n,
                        context,
                        showReadingPane: showReadingPane,
                      ),
                      if (showReadingPane &&
                          s.selectedContact != null &&
                          s.hasContacts) ...[
                        const SizedBox(width: 16),
                        IconButton(
                          icon: SvgPicture.asset(
                            svgEditForm,
                            height: 20,
                            width: 20,
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
                            height: 20,
                            width: 20,
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
                        borderRadius: BorderRadius.circular(AppStyles.radiusXL),
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
                                        ? Icons.indeterminate_check_box
                                        : Icons.check_box_outline_blank))
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
                      style: AppTypography.labelMedium(context).copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                  const Spacer(),
                  if (!isSelectionMode)
                    _contactFilterIcon(s, n, context),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(height: 1, color: dividerColor),
            ),
            Expanded(
              child: Stack(
                children: [
              _buildContactList(
                s,
                n,
                context,
                widget,
                isTabletLandscape: true,
                showReadingPane: showReadingPane,
                showCheckboxes: showCheckboxes,
              ),
              if (s.showFilter)
                contactFilterOverlay(context, n),
                ],
              ),
            ),
          ],
        ),
      ),
      if (showReadingPane) ...[
        Container(width: 1, color: dividerColor),
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
              : s.allContacts.isEmpty
                  ? ColoredBox(color: Theme.of(context).colorScheme.surface, child: const SizedBox.expand())
                  : const ReadingPanePlaceholder.contacts(),
        ),
      ],
    ],
  );
}

Widget _buildPortraitLayout(
  ContactState s,
  ContactListNotifier n,
  BuildContext context,
  ContactListriverpod widget,
) {
  return LayoutBuilder(
    builder: (context, constraints) {
      final double availableWidth = constraints.maxWidth > 0
          ? constraints.maxWidth * 0.7
          : MediaQuery.of(context).size.width * 0.7;
      return _buildPortraitContent(s, n, context, widget, availableWidth);
    },
  );
}

Widget _buildPortraitContent(
  ContactState s,
  ContactListNotifier n,
  BuildContext context,
  ContactListriverpod widget,
  double availableWidth,
) {
  // Hide reading pane and action bar for optin/addContact mode (contact selection only)
  final bool isSelectionMode =
      widget.type == 'optin' || widget.type == 'addContact';

  final bool showReadingPane =
      !isSelectionMode && s.readingPaneEnabled;
  final dividerColor = context.colors.outlineVariant;
  final bool inMultiSelect = s.hasMultiSelection;

  if (!showReadingPane) {
    // Original portrait layout: only contact list, navigate to details screen.
    return Column(
      children: [
        // Action bar
        if (!isSelectionMode)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(
                bottom: BorderSide(width: 1, color: dividerColor),
              ),
            ),
            child: Row(
              children: [
                if (inMultiSelect) ...[
                  IconButton(
                    icon: SvgPicture.asset(
                      svgDelete,
                      height: 20,
                      width: 20,
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
                  _buildAddButton(s, n, context, showReadingPane: false),
                ],
              ],
            ),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 4.0, 16.0, 4.0),
          child: Row(
            children: [
              Text(
                'Contacts',
                style: AppTypography.headlineMedium(context).copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Container(height: 1, color: dividerColor),
        ),
        Expanded(
          child: RefreshIndicator(
            color: Theme.of(context).colorScheme.primary,
            notificationPredicate: (_) => !inMultiSelect,
            onRefresh: () async {
              n.refreshContacts();
            },
            child: s.filteredContacts.isEmpty
                ? const Center(
                    child: EmptyState(variant: EmptyStateVariant.contacts),
                  )
                : Consumer(
                    builder: (context, ref, child) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 5.0),
                        child: AlphabetContactList(
                          letterIndexMap: ref.read(contactListProvider.notifier).letterIndexMap,
                          selectedTextStyle: AppTypography.alfaSelectedListText(context),
                          unselectedTextStyle: AppTypography.alfaListText(context),
                          itemExtent: (47 * MediaQuery.textScalerOf(context).scale(1.0)).clamp(47.0, 70.0),
                          itemCount: s.filteredContacts.length,
                          itemBuilder: (context, index) {
                            Contacts contact = s.filteredContacts[index];
                            final bool isMultiSelected = s.selectedContactIds.contains(contact.id);
                            return ContactListRow(
                              contact: contact,
                              isMultiSelected: isMultiSelected,
                              showCheckbox: inMultiSelect && !isSelectionMode,
                              sortByLastName: s.userData?['user']?['sortLastName'] == true,
                              onLongPress: isSelectionMode
                                  ? null
                                  : () => n.onLongPress(contact.id),
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
                                } else if (inMultiSelect) {
                                  n.toggleSelectContact(contact.id);
                                } else {
                                  context
                                      .push(
                                        AppRoutes.viewContactriverpod,
                                        extra: {
                                          'contact': contact,
                                          'page': 'list',
                                          'onContactUpdated':
                                              (
                                                Map<String, dynamic> result,
                                              ) async {
                                                FocusScope.of(context).unfocus();
                                                if (result['type'] == 'edit') {
                                                  n.updateContact(
                                                    result['contact'],
                                                  );
                                                } else if (result['type'] ==
                                                    'delete') {
                                                  n.deleteContactRecord(
                                                    result['contact'].id,
                                                  );
                                                } else if (result['type'] ==
                                                    'add') {
                                                  n.addContact(result['contact']);
                                                }
                                              },
                                        },
                                      )
                                      .then((result) {
                                        FocusScope.of(context).unfocus();
                                        printLog("result", result);
                                        if (result == null) return;
                                        if (result is Map &&
                                            result.containsKey('type')) {
                                          if (result['type'] == 'edit') {
                                            n.updateContact(result['contact']);
                                          } else if (result['type'] == 'delete') {
                                            n.deleteContactRecord(
                                              result['contact'].id,
                                            );
                                          } else if (result['type'] == 'add') {
                                            n.addContact(result['contact']);
                                          }
                                        }
                                      });
                                }
                              },
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }

  // Reading pane enabled in portrait: top contact list + bottom contact details.
  return Column(
    children: [
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
              IconButton(
                icon: SvgPicture.asset(
                  svgDelete,
                  height: 20,
                  width: 20,
                  colorFilter: ColorFilter.mode(
                    Theme.of(context).colorScheme.onSurfaceVariant,
                    BlendMode.srcIn,
                  ),
                ),
                onPressed: s.isInProcess
                    ? null
                    : () => n.handleDeleteSelectedContacts(),
                tooltip: 'Delete',
              ),
            ] else ...[
              _buildAddButton(s, n, context, showReadingPane: true),
              if (s.selectedContact != null) ...[
                const SizedBox(width: 16),
                IconButton(
                  icon: SvgPicture.asset(
                    svgEditForm,
                    height: 20,
                    width: 20,
                    colorFilter: ColorFilter.mode(
                      Theme.of(context).colorScheme.onSurfaceVariant,
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
                    height: 20,
                    width: 20,
                    colorFilter: ColorFilter.mode(
                      Theme.of(context).colorScheme.onSurfaceVariant,
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
      Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 4.0, 16.0, 4.0),
        child: Row(
          children: [
            Text(
              'Contacts',
              style: AppTypography.titleLarge(context).copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Container(height: 1, color: dividerColor),
      ),
      Expanded(
        child: Column(
          children: [
            // Top: contact list that updates the reading pane selection.
            Expanded(
              child: _buildContactList(
                s,
                n,
                context,
                widget,
                isTabletLandscape: true, // reuse reading-pane selection logic
                showReadingPane: showReadingPane,
                showCheckboxes: s.showCheckboxes || inMultiSelect,
              ),
            ),
            const Divider(),
            // Bottom: contact details view.
            Expanded(
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
                  : s.allContacts.isEmpty
                      ? ColoredBox(color: Theme.of(context).colorScheme.surface, child: const SizedBox.expand())
                      : const ReadingPanePlaceholder.contacts(),
            ),
          ],
        ),
      ),
    ],
  );
}

Widget _buildAddButton(
  ContactState s,
  ContactListNotifier n,
  BuildContext context, {
  bool showReadingPane = false,
}) {
  return CommonWebButton(
    onPressed: () async {
      final result = await context.push<Map<String, dynamic>?>(
        AppRoutes.addContactriverpod,
      );

      if (result != null) {
        if (result['type'] == 'add') {
          final Contacts newContact = result['contact'];
          n.addContact(newContact);

          // Always navigate to view contact page after adding
          // This gives clear confirmation and shows edit/delete options
          GoRouter.of(context).push(
            AppRoutes.viewContactriverpodPath(newContact.id),
            extra: {
              'contact': newContact,
              'page': 'addContact',
              'onContactUpdated': (Map<String, dynamic> updateResult) async {
                if (updateResult['type'] == 'edit') {
                  n.updateContact(updateResult['contact']);
                } else if (updateResult['type'] == 'delete') {
                  n.deleteContactRecord(updateResult['contact'].id);
                }
              },
            },
          );
        } else if (result['type'] == 'refresh') {
          // Contact was added but data couldn't be fetched, refresh the list
          n.refreshContacts();
        }
      }
    },
    iconData: Icons.add,
    label: 'Add',
    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
    iconSize: 20,
    spacing: 8,
    textStyle: AppTypography.titleLarge(context).copyWith(
      fontWeight: FontWeight.w500,
      color: context.colors.onPrimary,
    ),
    backgroundColor: context.appColors.accentButton,
    borderRadius: const BorderRadius.all(Radius.circular(8.0)),
    iconColor: context.colors.onPrimary,
  );
}

Widget _buildContactList(
  ContactState s,
  ContactListNotifier n,
  BuildContext context,
  ContactListriverpod widget, {
  bool isTabletLandscape = false,
  bool showReadingPane = false,
  bool showCheckboxes = false,
}) {
  final bool isSelectionMode =
      widget.type == 'optin' || widget.type == 'addContact';
  final bool inMultiSelect = s.hasMultiSelection;

  return RefreshIndicator(
    color: Theme.of(context).colorScheme.primary,
    notificationPredicate: (_) => !(inMultiSelect || showCheckboxes),
    onRefresh: () async {
      n.refreshContacts();
    },
    child: s.filteredContacts.isEmpty
        ? const Center(child: EmptyState(variant: EmptyStateVariant.contacts))
        : Consumer(
            builder: (context, ref, child) {
              return Padding(
                padding: const EdgeInsets.only(top: 5.0),
                child: AlphabetContactList(
                  letterIndexMap: ref.read(contactListProvider.notifier).letterIndexMap,
                  selectedTextStyle: AppTypography.alfaSelectedListText(context),
                  unselectedTextStyle: AppTypography.alfaListText(context),
                  itemExtent: (47 * MediaQuery.textScalerOf(context).scale(1.0)).clamp(47.0, 70.0),
                  itemCount: s.filteredContacts.length,
                  itemBuilder: (context, index) {
                    Contacts contact = s.filteredContacts[index];
                    bool isSelected = s.selectedContact?.id == contact.id;
                    bool isMultiSelected = s.selectedContactIds.contains(contact.id);
                    return ContactListRow(
                      contact: contact,
                      isSelected: isSelected,
                      isMultiSelected: isMultiSelected,
                      showCheckbox: showCheckboxes && !isSelectionMode,
                      sortByLastName: s.userData?['user']?['sortLastName'] == true,
                      onLongPress: isSelectionMode
                          ? null
                          : () => n.onLongPress(contact.id),
                      onTap: () {
                        if (widget.type != null && widget.type == 'optin') {
                          n.addAndDeleteEmail('add', widget.prevEmail.toString(), contact);
                        } else if (widget.type != null && widget.type == 'addContact') {
                          n.updateContact(contact);
                        } else {
                          if (kIsWeb) {
                            final keys = HardwareKeyboard.instance.logicalKeysPressed;
                            final isShift = keys.contains(LogicalKeyboardKey.shiftLeft) || keys.contains(LogicalKeyboardKey.shiftRight);
                            final isCtrlOrCmd = keys.contains(LogicalKeyboardKey.controlLeft) || keys.contains(LogicalKeyboardKey.controlRight) || keys.contains(LogicalKeyboardKey.metaLeft) || keys.contains(LogicalKeyboardKey.metaRight);
                            if (isShift) {
                              int from;
                              if (s.lastClickedIndex != -1) {
                                from = s.lastClickedIndex;
                              } else if (s.selectedContact != null) {
                                final viewedIdx = s.filteredContacts.indexWhere((c) => c.id == s.selectedContact!.id);
                                from = viewedIdx != -1 ? viewedIdx : index;
                              } else {
                                from = index;
                              }
                              n.selectContactRange(from, index);
                              return;
                            }
                            if (isCtrlOrCmd) {
                              if (s.selectedContactIds.isEmpty && s.selectedContact != null) {
                                final viewedIdx = s.filteredContacts.indexWhere((c) => c.id == s.selectedContact!.id);
                                if (viewedIdx != -1) n.toggleSingleSelectByIndex(viewedIdx);
                              }
                              n.toggleSingleSelectByIndex(index);
                              return;
                            }
                          }
                          if (inMultiSelect || showCheckboxes) {
                            n.toggleSelectContact(contact.id);
                            return;
                          }
                          if (isTabletLandscape && showReadingPane) {
                            n.selectContact(contact);
                          } else {
                            context.push(AppRoutes.viewContactriverpod, extra: {
                              'contact': contact, 'page': 'list',
                              'onContactUpdated': (Map<String, dynamic> result) async {
                                FocusScope.of(context).unfocus();
                                if (result['type'] == 'edit') { n.updateContact(result['contact']); }
                                else if (result['type'] == 'delete') { n.deleteContactRecord(result['contact'].id); }
                                else if (result['type'] == 'add') { n.addContact(result['contact']); }
                              },
                            }).then((result) {
                              FocusScope.of(context).unfocus();
                              printLog("result", result);
                              if (result == null) return;
                              if (result is Map && result.containsKey('type')) {
                                if (result['type'] == 'edit') { n.updateContact(result['contact']); }
                                else if (result['type'] == 'delete') { n.deleteContactRecord(result['contact'].id); }
                                else if (result['type'] == 'add') { n.addContact(result['contact']); }
                              }
                            });
                          }
                        }
                      },
                    );
                  },
                ),
              );
            },
          ),
  );
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
        colorFilter: ColorFilter.mode(
          Theme.of(context).colorScheme.primary,
          BlendMode.srcIn,
        ),
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
        colorFilter: ColorFilter.mode(
          Theme.of(context).colorScheme.primary,
          BlendMode.srcIn,
        ),
      ),
      onPressed: () => n.clearContactTypeFilter(),
      tooltip: 'Clear Companies Filter',
    );
  }
  return IconButton(
    icon: SvgPicture.asset(
      svgFilter,
      height: 20,
      width: 20,
      colorFilter: ColorFilter.mode(
        Theme.of(context).colorScheme.onSurfaceVariant,
        BlendMode.srcIn,
      ),
    ),
    onPressed: () => n.toggleFilter(),
    tooltip: 'Filter',
  );
}