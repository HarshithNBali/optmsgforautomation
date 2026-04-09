import 'dart:convert';


import 'package:optmsg/router/app_routes.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:optmsg/common/responsive/breakpoints.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:optmsg/screens/auth/auth_riverpod/auth_notifier.dart';
import 'package:optmsg/screens/settings/setting_riverpod/settings_notifier.dart';

import '../../../constant/img_path.dart';
import '../../../constant/string_constant.dart';
import '../../../model/contact_email_details.dart' as contact_model;
import '../../../model/contact_list_model.dart';
import '../../../repositories/contact/contact_api.dart';
import '../../../services/api_service.dart';
import '../../../services/common_service.dart';
// import '../../../services/email_sender_service.dart';
import '../../../widgets/pop_up_modal.dart';
// import 'package:optmsg/main.dart' show NavigationService;
import '../../../router/app_router.dart' show rootNavigatorKey;
import 'contact_state.dart';

final contactListProvider = NotifierProvider<ContactListNotifier, ContactState>(
  ContactListNotifier.new,
);

class ContactListNotifier extends Notifier<ContactState> {
  @override
  ContactState build() {
    api = ref.read(apiServiceProvider);
    _refreshCount = 0;
    readingPaneEnabled = true;
    // H-12: Track disposal so recursive getContacts() never writes state after
    // the notifier is torn down. Re-initialised on each build() call.
    _disposed = false;
    ref.onDispose(() => _disposed = true);
    return const ContactState();
  }

  bool _disposed = false;
  int _refreshCount = 0;
  late final ApiService api;
  bool readingPaneEnabled = true;

  // PW-03: Pre-computed letter→index map, rebuilt only when filteredContacts
  // or sort setting changes. Layout widgets read this for the alphabet sidebar.
  Map<String, int> _letterIndexMap = const {};
  Map<String, int> get letterIndexMap => _letterIndexMap;

  void _rebuildLetterIndexMap() {
    final sortLastName = state.userData?['user']?['sortLastName'] == true;
    final map = <String, int>{};
    for (int i = 0; i < state.filteredContacts.length; i++) {
      final key = _sortKey(state.filteredContacts[i], sortLastName);
      final letter = key.isNotEmpty ? key[0].toUpperCase() : '#';
      map.putIfAbsent(letter, () => i);
    }
    _letterIndexMap = map;
  }
  // -------------------------------
  /// INIT
  // -------------------------------
  Future<void> init() async {
    final userData = ref.read(authProvider).userData;

    // Read reading pane setting: prefer the settings provider (updated
    // synchronously by toggleReadingPane) so a toggle-then-navigate-back
    // doesn't race with the async storage write. Fall back to storage on
    // cold boot when the settings provider hasn't loaded yet.
    final settingsState = ref.read(settingsProvider);
    if (settingsState.hasUserData) {
      readingPaneEnabled = settingsState.readingPaneEnabled;
    } else {
      final readingPaneValue = await ref.read(storageServiceProvider).readData(
        'readingPaneEnabled',
      );
      final persisted = readingPaneValue == null
          ? true
          : readingPaneValue == 'true';
      readingPaneEnabled = persisted && (kIsWeb || AppBreakpoints.isPhysicalTablet);
    }

    // PW-03 Layer 2: Skip API re-fetch if contacts are already loaded for
    // this session. Pull-to-refresh and refreshContacts() clear allContacts
    // before calling init(), so they bypass this guard naturally.
    if (state.allContacts.isNotEmpty) {
      state = state.copyWith(
        userData: userData,
        readingPaneEnabled: readingPaneEnabled,
        selectedContact: null,
        clearSelectedContact: true,
        isLoading: false,
      );
      return;
    }

    state = state.copyWith(
      userData: userData,
      readingPaneEnabled: readingPaneEnabled,
      selectedContact: null,
      isLoading: true,
      allContacts: [],
      filteredContacts: [],
      clearSelectedContact: true,
    );
    searchFilterContact('');

    await getContacts(1);
  }

  /// Enable reading pane for native tablet/iPad in landscape mode
  void enableReadingPaneForNativeTabletLandscape(bool enabled) {
    state = state.copyWith(readingPaneEnabled: enabled);
  }

  /// Update reading pane settings from global Settings (web toggle)
  /// Keeps contacts reading pane visibility in sync without requiring a refresh.
  void updateReadingPaneSettings(bool enabled) {
    if (!enabled) {
      // Clear selection when turning reading pane OFF
      state = state.copyWith(
        readingPaneEnabled: false,
        selectedContact: null,
        clearSelectedContact: true,
      );
    } else {
      state = state.copyWith(readingPaneEnabled: true);
    }
  }

  // -------------------------------
  /// FETCH CONTACTS
  // -------------------------------

  // A7: Iterative pagination — accumulates all pages, sets state once.
  Future<void> getContacts(int page) async {
    try {
      state = state.copyWith(isLoading: true);
      List<Contacts> allFetched = [];
      int currentPage = page;
      bool hasNext = true;

      while (hasNext) {
        final contacts = await ContactApi().getContactList({
          "page": currentPage,
          "limit": 1000,
          "search": "",
        });
        if (_disposed) return;

        // ST-race: If the request failed (null data), stop loading silently.
        // BaseAPIService already called SessionExpiryManager.handleExpiry() for
        // 401s, so there is nothing more to do here. Showing "No Internet"
        // for an auth failure would be misleading.
        if (contacts.data == null) {
          state = state.copyWith(isLoading: false);
          return;
        }

        final list = contacts.data!;

        if (!list.success) {
          // Don't surface raw auth-rejection messages ("Invalid Token",
          // "Unauthorized") — the session manager already handles these.
          final msg = list.message.toLowerCase();
          if (!msg.contains('invalid token') && !msg.contains('unauthorized')) {
            CommonService.animatedToast(list.message, 'error');
          }
          state = state.copyWith(isLoading: false);
          return;
        }

        allFetched.addAll(list.data.contacts);
        hasNext = list.data.nextPage;
        currentPage++;
      }

      final merged = [...state.allContacts, ...allFetched];
      _sortContacts(merged);

      // Apply existing search filter to the merged contacts
      final searchText = state.searchText;
      List<Contacts> filtered;
      if (searchText.isEmpty) {
        filtered = merged;
      } else {
        final q = searchText.toLowerCase();
        filtered = merged.where((c) {
          return ("${c.firstName} ${c.lastName}".toLowerCase().contains(q)) ||
              c.firstName.toLowerCase().contains(q) ||
              c.lastName.toLowerCase().contains(q) ||
              c.company.toLowerCase().contains(q);
        }).toList();
      }

      state = state.copyWith(
        allContacts: merged,
        filteredContacts: filtered,
        isLoading: false,
        isRefresh: false,
      );
      _rebuildLetterIndexMap();
    } catch (e) {
      if (_disposed) return;
      // Only show connectivity toast for actual network failures.
      if (e is NoInternetException) {
        CommonService.animatedToast("No Internet", 'error');
      }
      state = state.copyWith(isLoading: false);
    }
  }

  // -------------------------------
  /// SELECT CONTACT (READING PANE)
  // -------------------------------
  void selectContact(Contacts contact) {
    state = state.copyWith(
      selectedContact: contact,
      clearSelectedContact: false,
    );
  }

  void clearSelection() {
    state = state.copyWith(clearSelectedContact: true);
  }

  void clearSelectionContact() {
    state = state.copyWith(clearSelectedContact: true, selectedContact: null);
  }

  void setIsSearch(bool value) {
    state = state.copyWith(isSearch: value);
  }

  // -------------------------------
  /// MULTI-SELECT
  // -------------------------------

  /// Enter/exit multi-select mode (mobile long-press trigger).
  void onLongPress(int contactId) {
    if (state.longPressFlag) {
      // Enter multi-select mode with this contact pre-selected
      final idx = state.filteredContacts.indexWhere((c) => c.id == contactId);
      state = state.copyWith(
        longPressFlag: false,
        allContactsFlag: false,
        selectedContactIds: [contactId],
        lastClickedIndex: idx,
      );
    } else {
      // Exit multi-select mode
      clearMultiSelection();
    }
  }

  /// Toggle a single contact in/out of selection.
  void toggleSelectContact(int contactId) {
    final ids = [...state.selectedContactIds];
    if (ids.contains(contactId)) {
      ids.remove(contactId);
    } else {
      ids.add(contactId);
    }
    state = state.copyWith(
      selectedContactIds: ids,
      allContactsFlag: ids.length == state.filteredContacts.length &&
          state.filteredContacts.isNotEmpty,
      longPressFlag: ids.isEmpty,
      showCheckboxes: ids.isEmpty ? false : state.showCheckboxes,
    );
  }

  /// Select all filtered contacts.
  void selectAllContacts() {
    final ids = state.filteredContacts.map((c) => c.id).toList();
    state = state.copyWith(
      selectedContactIds: ids,
      allContactsFlag: true,
      longPressFlag: false,
    );
  }

  /// Exit multi-select, clear all selection state.
  void clearMultiSelection() {
    state = state.copyWith(
      selectedContactIds: [],
      allContactsFlag: false,
      longPressFlag: true,
      showCheckboxes: false,
      lastClickedIndex: -1,
    );
  }

  /// Shift+Click range selection.
  void selectContactRange(int fromIndex, int toIndex) {
    final contacts = state.filteredContacts;
    if (contacts.isEmpty) return;
    // If no prior click, anchor from the clicked index (select just that one)
    final effectiveFrom = fromIndex < 0 ? toIndex : fromIndex;
    final start = effectiveFrom.clamp(0, contacts.length - 1);
    final end = toIndex.clamp(0, contacts.length - 1);
    final lo = start < end ? start : end;
    final hi = start < end ? end : start;

    final ids = {...state.selectedContactIds};
    for (int i = lo; i <= hi; i++) {
      ids.add(contacts[i].id);
    }
    state = state.copyWith(
      selectedContactIds: ids.toList(),
      allContactsFlag: ids.length == contacts.length,
      longPressFlag: false,
      showCheckboxes: true,
      lastClickedIndex: toIndex.clamp(0, contacts.length - 1),
    );
  }

  /// Ctrl/Cmd+Click single toggle by index.
  void toggleSingleSelectByIndex(int index) {
    final contacts = state.filteredContacts;
    if (index < 0 || index >= contacts.length) return;
    final contact = contacts[index];
    final ids = [...state.selectedContactIds];
    if (ids.contains(contact.id)) {
      ids.remove(contact.id);
    } else {
      ids.add(contact.id);
    }
    state = state.copyWith(
      selectedContactIds: ids,
      allContactsFlag: ids.length == contacts.length,
      longPressFlag: ids.isEmpty,
      showCheckboxes: ids.length > 1 ? true : state.showCheckboxes,
      lastClickedIndex: index,
    );
  }

  /// Set selected contact IDs directly (used by drag-to-select).
  void setSelectedFromList(List<int> ids) {
    final contacts = state.filteredContacts;
    state = state.copyWith(
      selectedContactIds: ids,
      allContactsFlag: ids.length == contacts.length && contacts.isNotEmpty,
      longPressFlag: ids.isEmpty,
      showCheckboxes: ids.isEmpty ? false : state.showCheckboxes,
    );
  }

  /// Toggle checkbox visibility (desktop header).
  void setShowCheckboxes(bool value) {
    state = state.copyWith(
      showCheckboxes: value,
      longPressFlag: value ? true : state.longPressFlag,
    );
  }

  // -------------------------------
  /// CONTACT TYPE FILTER
  // -------------------------------

  /// Toggle filter overlay visibility.
  void toggleFilter() {
    state = state.copyWith(showFilter: !state.showFilter);
  }

  /// Direct setter for filter overlay.
  void setShowFilter(bool v) {
    state = state.copyWith(showFilter: v);
  }

  /// Apply person or company filter.
  void setContactTypeFilter(String filterType) {
    state = state.copyWith(
      contactTypeFilter: filterType,
      showFilter: false,
      selectedContact: null,
      clearSelectedContact: true,
    );
    _applyFilters();
  }

  /// Reset filter back to 'all'.
  void clearContactTypeFilter() {
    state = state.copyWith(
      contactTypeFilter: 'all',
      showFilter: false,
    );
    _applyFilters();
  }

  /// Shared filtering logic: combines search text + contact type filter.
  void _applyFilters() {
    final q = state.searchText.toLowerCase();
    final typeFilter = state.contactTypeFilter;

    final filtered = state.allContacts.where((contact) {
      // Search filter
      if (q.isNotEmpty) {
        final matchesSearch =
            '${contact.firstName.toLowerCase()} ${contact.lastName.toLowerCase()}'
                    .contains(q) ||
                contact.firstName.toLowerCase().contains(q) ||
                contact.lastName.toLowerCase().contains(q) ||
                contact.company.toLowerCase().contains(q);
        if (!matchesSearch) return false;
      }
      // Type filter
      if (typeFilter == 'person') {
        return contact.firstName.isNotEmpty || contact.lastName.isNotEmpty;
      } else if (typeFilter == 'company') {
        return contact.firstName.isEmpty &&
            contact.lastName.isEmpty &&
            contact.company.isNotEmpty;
      }
      return true; // 'all'
    }).toList();

    _sortContacts(filtered);
    state = state.copyWith(
      filteredContacts: filtered,
      selectedContactIds: [],
      longPressFlag: true,
      showCheckboxes: false,
      allContactsFlag: false,
      lastClickedIndex: -1,
    );
    _rebuildLetterIndexMap();
  }

  /// Show confirmation dialog for bulk delete.
  Future<void> handleDeleteSelectedContacts() async {
    if (state.selectedContactIds.isEmpty) return;
    final ctx = rootNavigatorKey.currentContext;
    if (ctx == null) return;

    final count = state.selectedContactIds.length;
    showDialog(
      context: ctx,
      builder: (_) => CustomPopupModal(
        icon: svgTrash,
        title: delete,
        subtitle: 'Delete $count contact${count > 1 ? 's' : ''}?',
        textButton1: cancel,
        textButton2: delete,
        onPressedButton1: () {
          Navigator.of(
            rootNavigatorKey.currentContext!,
            rootNavigator: true,
          ).pop();
        },
        onPressedButton2: () {
          Navigator.of(
            rootNavigatorKey.currentContext!,
            rootNavigator: true,
          ).pop();
          _deleteSelectedContactsApi();
        },
      ),
    );
  }

  /// Sequential API calls for bulk delete (no bulk endpoint exists).
  Future<void> _deleteSelectedContactsApi() async {
    final idsToDelete = [...state.selectedContactIds];
    state = state.copyWith(isInProcess: true);

    int successCount = 0;
    int failCount = 0;

    for (final id in idsToDelete) {
      try {
        final resp = await ContactApi().contactDelete({"id": id});
        if (_disposed) return;
        final resJson = resp.data ?? {};
        if (resJson['success'] == true) {
          successCount++;
          deleteContactRecord(id);
        } else {
          failCount++;
        }
      } catch (e) {
        failCount++;
      }
    }

    if (_disposed) return;

    if (successCount > 0) {
      CommonService.animatedToast(
        '$successCount contact${successCount > 1 ? 's' : ''} deleted',
        'success',
        null,
        true,
      );
    }
    if (failCount > 0) {
      CommonService.animatedToast(
        '$failCount contact${failCount > 1 ? 's' : ''} failed to delete',
        'error',
        null,
        true,
      );
    }

    clearMultiSelection();
    state = state.copyWith(isInProcess: false);
  }

  // -------------------------------
  /// ADD CONTACT
  // -------------------------------
  void addContact(Contacts contact) {
    final updated = [...state.allContacts, contact];

    // Sort the list to match AlphabetScrollView expectations
    _sortContacts(updated);

    state = state.copyWith(
      allContacts: updated,
      filteredContacts: updated,
      // Always select the newly added contact so edit/delete buttons show in action bar
      selectedContact: contact,
    );
    _rebuildLetterIndexMap();
  }

  // -------------------------------
  /// UPDATE CONTACT
  // -------------------------------
  void updateContact(Contacts contact) {
    final updated = [
      for (final c in state.allContacts)
        if (c.id == contact.id) contact else c,
    ];

    // Re-sort in case name changed affecting position
    _sortContacts(updated);

    state = state.copyWith(
      allContacts: updated,
      filteredContacts: updated,
      // Keep selected contact updated if it matches
      selectedContact: state.selectedContact?.id == contact.id
          ? contact
          : state.selectedContact,
    );
    _rebuildLetterIndexMap();
  }

  /// Called by SettingsNotifier after the sort toggle changes so the contact
  /// list re-sorts without requiring a full refresh.
  void updateSortSetting(bool sortLastName) {
    if (state.userData == null) return;
    final updatedUserData = {
      ...state.userData!,
      'user': {
        ...state.userData!['user'],
        'sortLastName': sortLastName,
      },
    };
    final allSorted = [...state.allContacts];
    _sortContactsList(allSorted, sortLastName);
    final filteredSorted = [...state.filteredContacts];
    _sortContactsList(filteredSorted, sortLastName);
    state = state.copyWith(
      userData: updatedUserData,
      allContacts: allSorted,
      filteredContacts: filteredSorted,
    );
    _rebuildLetterIndexMap();
  }

  void _sortContacts(List<Contacts> contacts) {
    final bool sortLastName = state.userData?['user']?['sortLastName'] ?? false;
    _sortContactsList(contacts, sortLastName);
  }

  /// Returns the sort key for a contact.
  /// - Last name sort: lastName → firstName → company
  /// - First name sort: firstName → lastName → company
  String _sortKey(Contacts c, bool sortLastName) {
    final first = c.firstName.trim().toLowerCase();
    final last = c.lastName.trim().toLowerCase();
    final company = c.company.trim().toLowerCase();
    if (sortLastName) {
      return last.isNotEmpty ? last : first.isNotEmpty ? first : company;
    } else {
      return first.isNotEmpty ? first : last.isNotEmpty ? last : company;
    }
  }

  void _sortContactsList(List<Contacts> contacts, bool sortLastName) {
    contacts.sort((a, b) {
      final aKey = _sortKey(a, sortLastName);
      final bKey = _sortKey(b, sortLastName);
      final cmp = aKey.compareTo(bKey);
      if (cmp != 0) return cmp;
      // Tie-break: secondary name field, then company
      final aSecondary = sortLastName
          ? a.firstName.trim().toLowerCase()
          : a.lastName.trim().toLowerCase();
      final bSecondary = sortLastName
          ? b.firstName.trim().toLowerCase()
          : b.lastName.trim().toLowerCase();
      final cmp2 = aSecondary.compareTo(bSecondary);
      if (cmp2 != 0) return cmp2;
      return a.company.trim().toLowerCase().compareTo(
        b.company.trim().toLowerCase(),
      );
    });
  }

  // -------------------------------
  /// DELETE CONTACT
  // -------------------------------
  void deleteContactRecord(int id) {
    final updated = state.allContacts.where((c) => c.id != id).toList();
    final q = state.searchText.toLowerCase();

    // Apply search filter to the updated list
    List<Contacts> filtered;
    if (q.isEmpty) {
      filtered = updated;
    } else {
      filtered = updated.where((c) {
        return ("${c.firstName} ${c.lastName}").toLowerCase().contains(q) ||
            c.firstName.toLowerCase().contains(q) ||
            c.lastName.toLowerCase().contains(q) ||
            c.company.toLowerCase().contains(q);
      }).toList();
    }

    // Clear the selected contact after deletion - don't auto-select first contact
    // Reading pane should show "Select a contact" message
    final updatedSelectedIds = state.selectedContactIds.where((i) => i != id).toList();
    state = state.copyWith(
      allContacts: updated,
      filteredContacts: filtered,
      selectedContact: null,
      clearSelectedContact: true,
      selectedContactIds: updatedSelectedIds,
    );
    _rebuildLetterIndexMap();
  }

  void setLoading(bool value) {
    state = state.copyWith(isLoading: value);
  }

  // -------------------------------
  /// REFRESH
  // -------------------------------
  Future<void> refresh() async {
    state = state.copyWith(
      isRefresh: true,
      allContacts: [],
      filteredContacts: [],
      isLoading: true,
      selectedContact: null,
      clearSelectedContact: true,
      selectedContactIds: [],
      longPressFlag: true,
      showCheckboxes: false,
      allContactsFlag: false,
      lastClickedIndex: -1,
      contactTypeFilter: 'all',
      showFilter: false,
    );

    await getContacts(1);
  }

  Future<void> refreshContacts() async {
    _refreshCount++;

    if (_refreshCount != 1) return;

    searchFilterContact('');
    state = state.copyWith(
      searchText: "",
      isRefresh: false,
      isLoading: true,
      allContacts: [],
      filteredContacts: [],
      selectedContact: null,
      clearSelectedContact: true,
      selectedContactIds: [],
      longPressFlag: true,
      showCheckboxes: false,
      allContactsFlag: false,
      lastClickedIndex: -1,
      contactTypeFilter: 'all',
      showFilter: false,
    );

    try {
      await init();
    } finally {
      _refreshCount = 0;
    }
  }

  void searchFilterContact(String value) {
    state = state.copyWith(searchText: value);
    _applyFilters();
  }

  Future<void> fetchContactDetails(int contactId) async {
    try {
      final data = await ContactApi().getContactDetails({"id": contactId});
      if (_disposed) return;
      final Map<String, dynamic> resJson = data.data ?? {};
      /* final Map<String, dynamic> resJson = await api.post(
        'contact/details',
        {"id": contactId},
      );*/

      if (!resJson['success']) return;
      final res = contact_model.contactEmailDetailsModelFromJson(
        jsonEncode(resJson),
      );

      // Extract emails
      List<Emails> emailsList = [];

      if (res.data?.contacts != null) {
        for (final c in res.data!.contacts!) {
          if (c.email != null) {
            emailsList.add(Emails(id: c.id, email: c.email));
          }
        }
      }

      final updatedContacts = state.allContacts.map((contact) {
        if (contact.id != contactId) return contact;

        // Update only the selected contact
        return Contacts(
          id: contact.id,
          firstName: contact.firstName,
          lastName: contact.lastName,
          company: contact.company,
          phones: contact.phones,
          emails: emailsList,
        );
      }).toList();

      // Re-select updated contact for reading pane
      final updatedSelected = updatedContacts.firstWhere(
        (contact) => contact.id == contactId,
      );

      state = state.copyWith(
        allContacts: updatedContacts,
        filteredContacts: updatedContacts,
        selectedContact: updatedSelected,
      );
      updateContact(updatedSelected);
    } catch (error) {
      CommonService.animatedToast('Failed to load contact details', 'error');
    }
  }

  Future<void> handleEditContact() async {
    // Capture state values at the start to avoid accessing state after disposal
    final selectedContact = state.selectedContact;
    final readingPaneEnabled = state.readingPaneEnabled;

    if (selectedContact == null) {
      return;
    }

    // Prevent multiple simultaneous calls
    if (state.isInProcess) {
      return;
    }

    try {
      state = state.copyWith(isInProcess: true);

      // Fetch details before navigation
      List<contact_model.Contact> contactData = [];
      try {
        Map<String, dynamic> contactdetails = await ApiService().post(
          'contact/details',
          {"id": selectedContact.id},
        );
        if (_disposed) return;

        if (contactdetails['success'] == true) {
          try {
            var res = contact_model.contactEmailDetailsModelFromJson(
              jsonEncode(contactdetails),
            );
            if (res.data?.contacts != null) {
              contactData = res.data!.contacts!;
            }
          } catch (parseError) {
            // Continue with empty contactData - edit page can still work
          }
        }
      } catch (apiError) {
        // Continue with empty contactData - edit page can still work
      }

      final navigatorContext = rootNavigatorKey.currentContext;

      // If we still don't have a valid context, return early
      if (navigatorContext == null) {
        state = state.copyWith(isInProcess: false);
        return;
      }

      dynamic result;
      try {
        result = await GoRouter.of(navigatorContext).push(
          AppRoutes.editContactriverpodPath(selectedContact.id),
          extra: {
            'contact': selectedContact,
            'contactData': contactData,
            'isReadingPaneMode': readingPaneEnabled,
          },
        );
      } catch (navError) {
        rethrow; // Re-throw to be caught by outer catch block
      }
      if (_disposed) return;

      // Use navigatorContext for focus operations
      FocusScope.of(navigatorContext).unfocus();

      if (result == null) {
        state = state.copyWith(isInProcess: false);
        return;
      }

      if (result['type'] == 'edit') {
        updateContact(result['contact']);

        // Force re-load email details for reading pane
        if (readingPaneEnabled) {
          fetchContactDetails(result['contact'].id);
        }
      } else if (result['type'] == 'delete') {
        deleteContactRecord(result['contact'].id);
      }
    } catch (error) {
      // Only show toast if ToastManager is initialized
      try {
        if (error is! NoInternetException) {
          CommonService.animatedToast(
            'Error processing request',
            'error',
            null,
            true,
          );
        }
      } catch (toastError) {
        // ToastManager not initialized, just log the error
      }
    } finally {
      if (!_disposed) state = state.copyWith(isInProcess: false);
    }
  }

  Future<void> handleDeleteContact() async {
    if (state.selectedContact == null) return;

    final Contacts contactToDelete = state.selectedContact!;
    final ctx = rootNavigatorKey.currentContext;
    if (ctx == null) return;

    showDialog(
      context: ctx,
      builder: (_) => CustomPopupModal(
        icon: svgTrash,

        title: delete,
        subtitle: deleteContact,

        textButton1: cancel,
        textButton2: delete,

        // CANCEL
        onPressedButton1: () {
          Navigator.of(
            rootNavigatorKey.currentContext!,
            rootNavigator: true,
          ).pop();
        },

        // CONFIRM DELETE
        onPressedButton2: () {
          Navigator.of(
            rootNavigatorKey.currentContext!,
            rootNavigator: true,
          ).pop();
          deleteContactApi(contactToDelete.id);
        },
      ),
    );
  }

  Future<void> deleteContactApi(int contactId) async {
    try {
      state = state.copyWith(isInProcess: true);

      final resp = await ContactApi().contactDelete({"id": contactId});
      if (_disposed) return;
      state = state.copyWith(isInProcess: false);
      final Map<String, dynamic> resJson = resp.data ?? {};
      /* await api.post('contact/delete', {"id": contactId});*/

      if (resJson['success']) {
        int existingIndex = state.allContacts.indexWhere(
          (c) => c.id == contactId,
        );
        if (existingIndex != -1) {
          deleteContactRecord(contactId);
        }

        // Toast success
        CommonService.animatedToast(resJson['message'], 'success', null, true);
      } else {
        CommonService.animatedToast(resJson['message'], 'error', null, true);
      }
    } catch (error) {
      if (error is! NoInternetException) {
        CommonService.animatedToast(
          'Error deleting contact',
          'error',
          null,
          true,
        );
      }
    } finally {
      if (!_disposed) state = state.copyWith(isInProcess: false);
    }
  }

  Future<void> addAndDeleteEmail(
    String type,
    String value,
    Contacts contact,
  ) async {
    try {
      final resp = await ContactApi().addDeleteEmail({
        "email": value,
        "contactId": contact.id,
        "type": type,
      });
      // state = state.copyWith(isLoading: false);
      final resJson = resp.data ?? {}; /*await api.post(
        'contact/add-delete-email',
        {
          "email": value,
          "contactId": contact.id,
          "type": type,
        },
      );*/

      if (!resJson['success']) {
        CommonService.animatedToast(resJson['message'], 'error');
        return;
      }

      // Success toast - Show BEFORE navigation pop
      CommonService.animatedToast(resJson['message'], 'success');

      final ctx = rootNavigatorKey.currentContext;
      if (ctx == null) return;

      switch (type) {
        case 'add':
          // Signal success to the caller so they can continue the flow
          ctx.pop('success');
          break;

        case 'delete':
          Navigator.of(ctx, rootNavigator: true).pop();
          break;
      }
    } catch (error) {
      // Error toast removed as per requirement
    } finally {
      // Hide loader
      // state = state.copyWith(isLoading: false);
    }
  }

  Future<void> uploadContacts(List<Map<String, dynamic>> contacts) async {
    state = state.copyWith(isInProcess: true);
    try {
      final resp = await api.post('contact/upload', {'data': contacts});
      if (_disposed) return;
      if (resp['success']) {
        CommonService.animatedToast(
          resp['message'] ?? 'Contacts uploaded successfully',
          'success',
        );
        await refresh();
      } else {
        CommonService.animatedToast(
          resp['message'] ?? 'Failed to upload contacts',
          'error',
        );
      }
    } catch (e) {
      CommonService.animatedToast('Error uploading contacts', 'error');
    } finally {
      if (!_disposed) state = state.copyWith(isInProcess: false);
    }
  }
}
