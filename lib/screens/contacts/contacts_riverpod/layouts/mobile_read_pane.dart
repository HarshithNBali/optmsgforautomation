import 'package:optmsg/common/utilites/logger.dart';
import 'package:go_router/go_router.dart';
import 'package:optmsg/router/app_routes.dart';
import '../../../../widgets/alphabet_contact_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:optmsg/constant/app_typography.dart';
import '../../../../model/contact_list_model.dart';
import '../../../../widgets/contact_list_row.dart';
import '../../../../widgets/empty_state.dart';
import '../contact_list_notifier.dart';
import '../contact_list_riverpod.dart';
import '../contact_state.dart';
import '../widget/contact_filter_overlay.dart';

Widget mobileReadPane(
  ContactState s,
  ContactListNotifier n,
  BuildContext context,
  ContactListriverpod widget,
  double availableWidth,
  Function() onClick,
) {
  return LayoutBuilder(
    builder: (context, constraints) {
      // Use constraints width if available, otherwise fall back to passed availableWidth
      final double effectiveWidth = constraints.maxWidth > 0
          ? constraints.maxWidth * 0.7
          : availableWidth;
      return _buildMobileContent(
        s,
        n,
        context,
        widget,
        effectiveWidth,
        onClick,
      );
    },
  );
}

Widget _buildMobileContent(
  ContactState s,
  ContactListNotifier n,
  BuildContext context,
  ContactListriverpod widget,
  double availableWidth,
  Function() onClick,
) {
  final bool isSelectionMode = widget.type == 'optin' || widget.type == 'addContact';
  final bool inMultiSelect = !s.longPressFlag;

  return Stack(
    children: [
    Column(
    children: [
      // Contact list
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
                        // PW-03: Use pre-computed letter index map from notifier
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
                                      AppRoutes.viewContactriverpodPath(
                                        contact.id,
                                      ),
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
                                        onClick();
                                        n.refreshContacts();
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
  ),
    if (s.showFilter)
      contactFilterOverlay(context, n),
    ],
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
