import 'dart:core';
import 'package:optmsg/common/utilites/logger.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:optmsg/common/responsive/breakpoints.dart';
import 'package:descope/descope.dart';
import 'package:optmsg/common/utilites/secure_print_helper.dart';
import 'package:optmsg/services/action_biometric_guard.dart';
import 'package:optmsg/main.dart';
import '../../../constant/app_config.dart';
import '../../../constant/string_constant.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../model/tags_list_model.dart';
import '../../../repositories/email/inbox_api.dart';
import '../../../repositories/tags/tag_api.dart';
import '../../../services/api_service.dart';
import '../../../services/common_service.dart';
import '../../../services/socket_service.dart';
import '../../../services/storage_service.dart';
import '../../../services/tags_provider.dart';
import '../../../services/count_notifier.dart';
import 'inbox_state.dart';
import 'package:optmsg/model/inbox_list_model.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:optmsg/common/app_manger/app_cache.dart';
import '../archive_riverpod/archive_list_notifier.dart';
import '../../auth/auth_riverpod/auth_notifier.dart';
import '../../contacts/contacts_riverpod/contact_list_notifier.dart';
import '../../settings/setting_riverpod/settings_notifier.dart';

final inboxProvider = NotifierProvider<InboxNotifier, InboxState>(
  InboxNotifier.new,
);

class InboxNotifier extends Notifier<InboxState> {
  // DI: read from providers on demand rather than late fields,
  // so fake notifiers in tests don't crash on uninitialized fields.
  SecureStorageService get _secureStorage => ref.read(storageServiceProvider);
  SocketService get _socket => ref.read(socketServiceProvider);
  InboxApi get _inboxApi => ref.read(inboxApiProvider);
  TagApi get _tagApi => ref.read(tagApiProvider);

  StreamSubscription? _inboxMessageSub;
  StreamSubscription? _newMessageSub;
  StreamSubscription? _trashMessageSub;

  Timer? _debounce;
  Timer? _socketDebounce;
  Timer? _undoTimer;
  int _requestCounter = 0;
  // Reset on each build(), set true in onDispose — guards async callbacks
  // from mutating state after the notifier has been torn down (H-06/H-07/H-08).
  bool _disposed = false;
  bool _isBootstrapping = false;

  List<Emails> _undoBuffer = [];
  List<int> _undoIds = [];

  @override
  InboxState build() {
    _disposed = false;
    // _listenerAdded intentionally NOT reset here — FlutterContacts.addListener
    // persists across rebuilds; resetting the flag would cause duplicate listeners.
    // H-07/H-08: cancel all subscriptions and timers on disposal
    ref.onDispose(() {
      _disposed = true;
      _debounce?.cancel();
      _socketDebounce?.cancel();
      _undoTimer?.cancel();
      _inboxMessageSub?.cancel();
      _newMessageSub?.cancel();
      _trashMessageSub?.cancel();
    });
    // C-10 fix: clear stale in-memory state on logout so User B never
    // briefly sees User A's inbox, and the socket authenticated as User A
    // is disconnected before User B's session begins.
    //
    // Also handles auto-bootstrap after hot refresh: authProvider.build()
    // returns initial (unauthenticated) then resolves async → isAuthenticated.
    // When that transition fires (false→true) and the inbox has no items,
    // we bootstrap.  The _isBootstrapping guard prevents double-firing when
    // the widget's initState() also calls bootstrap() in the same frame.
    // Sync: when global tag list changes (e.g., tag deleted via socket or
    // another client), purge any per-email tags that no longer exist.
    ref.listen<TagsState>(tagsProvider, (previous, next) {
      if (next.tagsList == null) return;
      final validTagIds = next.tagsList!.data.tags.map((t) => t.id).toSet();
      final currentItems = state.items;
      bool anyChanged = false;

      final updated = currentItems.map((email) {
        final filtered = email.emailRecipientTags
            .where((t) => validTagIds.contains(t.tagId))
            .toList();
        if (filtered.length != email.emailRecipientTags.length) {
          anyChanged = true;
          return email.copyWith(emailRecipientTags: filtered);
        }
        return email;
      }).toList();

      if (anyChanged) {
        state = state.copyWith(items: updated);
      }
    });

    ref.listen<bool>(authProvider.select((s) => s.isAuthenticated), (
      previous,
      next,
    ) {
      if (previous == true && next == false) {
        _socket.disconnect();
        Future.microtask(reset);
      }
      // Auto-bootstrap when auth resolves and inbox is empty (hot refresh).
      // On normal startup the widget's initState() handles this, but on hot
      // refresh initState() doesn't re-fire so this listener is the trigger.
      // Skip during signup: the user has no plan yet so email/tags APIs return
      // 405 "Please select subscription plan to continue", which causes a toast.
      if (next == true && state.items.isEmpty) {
        Future.microtask(() {
          if (!_disposed && AppCache().signupInProgress != 'true') bootstrap();
        });
      }
    });

    return const InboxState();
  }

  // ---------------------- PUBLIC BOOTSTRAP ----------------------
  Future<void> bootstrap({
    bool preserveReadingPane = false,
    int? emailIdToRestore,
    int? initialTagId,
    String? initialEmailType,
  }) async {
    // Re-entry guard: prevents double-bootstrap when both build() and
    // initState() schedule a microtask in the same frame.
    if (_isBootstrapping) return;
    _isBootstrapping = true;

    // Preserve reading pane selection during resize (when items already exist)
    // This prevents the reading pane from going blank when window is resized
    final savedReadingPaneId =
        emailIdToRestore ??
        (preserveReadingPane ? state.selectedEmailIdForReadingPane : null);
    final savedReadingPaneIndex = preserveReadingPane
        ? state.selectedEmailIndex
        : null;
    final savedReadingPaneSender = preserveReadingPane
        ? state.selectedEmailSender
        : null;
    final savedCurrentlyViewedId =
        emailIdToRestore ??
        (preserveReadingPane ? state.currentlyViewedEmailId : null);

    // Clear reading pane selection, overlay states, filter states, and items to avoid stale state issues
    // Clearing items prevents previously navigated messages from briefly appearing
    state = state.copyWith(
      selectedEmailIdForReadingPane: savedReadingPaneId,
      selectedEmailIndex: savedReadingPaneIndex,
      selectedEmailSender: savedReadingPaneSender,
      currentlyViewedEmailId: savedCurrentlyViewedId, // Also clear highlighting
      showReadingPaneMenuOptions: false,
      showFilter: false,
      showTagList: false,
      isSearch: false,
      showMenuOptions: false,
      // Reset filter states (or apply initial tag filter)
      tagIdFilter: initialTagId != null ? <int>[initialTagId] : <int>[],
      selectedTagIds: <int>[],
      tagFilter: initialTagId != null,
      // Set emailType for tag filtering ('all') or default ('inbox')
      emailType: initialEmailType ?? 'inbox',
      // Reset selection states
      selectedEmailIds: <int>[],
      selectedEmails: <String>[],
      showCheckboxes: false,
      // Reset search
      searchKey: '',
      // Clear items and inboxList to prevent stale messages from appearing.
      // Setting inboxList to null signals that getAllEmails hasn't completed yet,
      // which the UI uses to keep showing the spinner instead of NoData.
      items: <Emails>[],
      inboxList: null,
      // Mark as loading immediately so the empty-state widget never flashes
      // while the async bootstrap chain (getUserData → getAllEmails) runs.
      isLoading: true,
      // Clear any previous error so the retry button never flashes on re-bootstrap.
      errorMessage: null,
      // Reset pagination
      currentPage: 1,
      previousPage: 0,
    );

    try {
      await _getUserData();
    } catch (_) {
      // Ensure isLoading is always reset so the UI isn't stuck on a spinner.
      if (!_disposed) {
        state = state.copyWith(isLoading: false);
      }
    } finally {
      _isBootstrapping = false;
    }
  }

  // ---------------------- RESET FILTERS AND SELECTIONS ------------------------
  void resetFiltersAndSelections() {
    state = state.copyWith(
      // Reset filter states
      tagIdFilter: <int>[],
      selectedTagIds: <int>[],
      tagFilter: false,
      showFilter: false,
      showTagList: false,
      isTagListForFilter: false,
      // Reset selection states
      selectedEmailIds: <int>[],
      selectedEmails: <String>[],
      showCheckboxes: false,
      // Reset search
      searchKey: '',
      isSearch: false,
      // Reset overlay states
      showMenuOptions: false,
      showReadingPaneMenuOptions: false,
      // Reset reading pane selection - start with empty reading pane like archive
      selectedEmailIdForReadingPane: null,
      selectedEmailIndex: null,
      selectedEmailSender: null,
      currentlyViewedEmailId: null,
    );
  }

  // ---------------------- BASIC MUTATORS ------------------------
  void clearOverlayStates() {
    state = state.copyWith(
      showFilter: false,
      showTagList: false,
      isTagListForFilter: false,
      isSearch: false,
      showMenuOptions: false,
      showMoveOverlay: false,
      showReadingPaneMenuOptions: false,
      // Reset checkbox state when navigating between folders
      showCheckboxes: false,
      selectedEmailIds: <int>[],
      selectedEmails: <String>[],
      allEmailIdsFlag: false,
    );
  }

  void setSearchKey(String value) {
    state = state.copyWith(searchKey: value);
  }

  void setIsSearch(bool value) {
    state = state.copyWith(isSearch: value);
  }

  void setShowFilter(bool v) => state = state.copyWith(showFilter: v);
  void setShowTagList(bool v) => state = state.copyWith(showTagList: v);
  void setLongPressFlag(bool v) => state = state.copyWith(longPressFlag: v);
  void setShowMenuOptions(bool v) => state = state.copyWith(showMenuOptions: v);
  void setIsTagListForFilter(bool v) =>
      state = state.copyWith(isTagListForFilter: v);

  void setShowCheckboxes(bool v) => state = state.copyWith(
    showCheckboxes: v,
    longPressFlag: v ? true : state.longPressFlag,
  );

  void setComposeHovered(bool v) => state = state.copyWith(isComposeHovered: v);

  void setEmailListPaneWidth(double width) =>
      state = state.copyWith(emailListPaneWidth: width);

  void setReadingPaneHeight(double height) =>
      state = state.copyWith(readingPaneHeight: height);

  void setReadingPaneEnabled(bool v) =>
      state = state.copyWith(readingPaneEnabled: v);

  void onLongPress(int? id, String? email) {
    if (state.longPressFlag) {
      final ids = <int>[];
      final emails = <String>[];
      if (id != null) ids.add(id);
      if (email != null) emails.add(email);
      state = state.copyWith(
        longPressFlag: false,
        allEmailIdsFlag: false,
        selectedEmailIds: ids,
        selectedEmails: emails,
        showMenuOptions: false,
      );
    } else {
      state = state.copyWith(
        longPressFlag: true,
        allEmailIdsFlag: false,
        selectedEmailIds: <int>[],
        selectedEmails: <String>[],
        showMenuOptions: false,
      );
    }
  }

  void toggleSearch() {
    state = state.copyWith(isSearch: !state.isSearch);
  }

  void clearSearchAndRefresh() {
    state = state.copyWith(searchKey: '');
    getAllEmails('');
  }

  void toggleFilter() {
    state = state.copyWith(showFilter: !state.showFilter, showTagList: false);
  }

  void clearUnreadFilterForDesktop(String searchKey) {
    state = state.copyWith(
      showFilter: false,
      isSearch: true,
      emailType: 'inbox',
      currentPage: 1,
      previousPage: 0,
    );
    getAllEmails(searchKey);
  }

  void clearTagFilterForDesktop(String searchKey) {
    state = state.copyWith(
      showFilter: false,
      isSearch: true,
      tagFilter: false,
      tagIdFilter: <int>[],
      emailType: 'inbox',
      currentPage: 1,
      previousPage: 0,
    );
    getAllEmails(searchKey);
  }

  void clearUnreadFilter(String searchKey) {
    state = state.copyWith(
      currentPage: 1,
      previousPage: 0,
      emailType: 'inbox',
      showFilter: false,
    );
    getAllEmails(searchKey, silent: true);
  }

  void clearTagFilterAndRefresh(String searchKey) {
    state = state.copyWith(
      tagFilter: false,
      tagIdFilter: <int>[],
      currentPage: 1,
      previousPage: 0,
      emailType: 'inbox',
      showFilter: false,
    );
    getAllEmails(searchKey, silent: true);
  }

  void applyUnreadFilter(String searchKey) {
    state = state.copyWith(
      currentPage: 1,
      previousPage: 0,
      emailType: 'unread',
      showFilter: false,
      // Clear reading pane selection when filter changes
      selectedEmailIdForReadingPane: null,
      selectedEmailSender: null,
      selectedEmailIndex: null,
      showReadingPaneMenuOptions: false,
    );
    getAllEmails(searchKey, silent: true);
  }

  void showTagListFromFilter() {
    state = state.copyWith(
      showFilter: false,
      showTagList: true,
      isTagListForFilter: true,
    );
  }

  void toggleMenuOptions() {
    state = state.copyWith(showMenuOptions: !state.showMenuOptions);
  }

  void updateReadingPaneSettings(bool enabled) {
    if (!enabled) {
      // Clear selection when turning reading pane OFF
      state = state.copyWith(
        readingPaneEnabled: false,
        readingPaneEnabledWeb: false,
        selectedEmailIdForReadingPane: null,
        currentlyViewedEmailId: null, // Also clear highlighting
        selectedEmailSender: null,
        selectedEmailIndex: null,
        selectedEmailTags: null,
      );
    } else {
      state = state.copyWith(
        readingPaneEnabled: true,
        readingPaneEnabledWeb: true,
      );
    }
  }

  void applyTagFilter(int tagId) {
    state = state.copyWith(
      currentPage: 1,
      previousPage: 0,
      showTagList: false,
      tagFilter: true,
      tagIdFilter: [tagId],
      selectedEmailIdForReadingPane: null,
      selectedEmailSender: null,
      selectedEmailIndex: null,
      showReadingPaneMenuOptions: false,
    );
    getAllEmails(state.searchKey, silent: true);
  }

  void clearSelectionAfterTagAdd() {
    state = state.copyWith(
      longPressFlag: true,
      selectedEmailIds: <int>[],
      selectedEmails: <String>[],
    );
  }

  void setCurrentlyViewedEmailId(int? id, [List? tags, int? index]) {
    String? senderEmail;
    if (id != null) {
      final emailIndex = state.items.indexWhere((e) => e.emailId == id);
      if (emailIndex != -1) {
        senderEmail = state.items[emailIndex].email.senderEmail;
      }
    }

    state = state.copyWith(
      currentlyViewedEmailId: id,
      selectedEmailIdForReadingPane: id,
      selectedEmailIndex: index,
      selectedEmailSender: senderEmail,
    );
  }

  void setSelectedEmailIdForReadingPane(int? id, [int? index]) {
    String? senderEmail;
    int? emailIndex;
    if (id != null) {
      emailIndex = state.items.indexWhere((e) => e.emailId == id);
      if (emailIndex != -1) {
        senderEmail = state.items[emailIndex].email.senderEmail;
      }
    }

    state = state.copyWith(
      selectedEmailIdForReadingPane: id,
      currentlyViewedEmailId: id, // Also set for email list highlighting
      selectedEmailSender: senderEmail,
      selectedEmailIndex: index ?? emailIndex,
      // Set lastClickedIndex so Shift+Click has an anchor from viewed email
      lastClickedIndex: (index ?? emailIndex) ?? -1,
    );

    // Mark the email as read in the local state when selected for viewing
    if (id != null) {
      _markEmailAsReadLocally(id);
    }
  }

  /// Marks an email as read in the local items list
  /// This is called when viewing an email in the reading pane
  void _markEmailAsReadLocally(int emailId) {
    final idx = state.items.indexWhere((e) => e.emailId == emailId);
    if (idx != -1 && !state.items[idx].isRead) {
      // H-15: Use copyWith on the item rather than direct field mutation
      final newItems = state.items
          .map((e) => e.emailId == emailId ? e.copyWith(isRead: true) : e)
          .toList();
      state = state.copyWith(items: newItems);
    }
  }

  /// Open compose in the reading pane (desktop/tablet).
  /// Pass a map with 'mode', 'emailId', 'toEmail', 'sourcePage'.
  void openComposeInReadingPane(Map<String, dynamic>? params) {
    state = state.copyWith(
      composeInReadingPane: params,
      // Clear email selection when showing compose
      selectedEmailIdForReadingPane: params != null ? null : state.selectedEmailIdForReadingPane,
    );
  }

  void closeReadingPaneMenu() {
    state = state.copyWith(showReadingPaneMenuOptions: false);
  }

  void clearReadingPaneSelection() {
    state = state.copyWith(
      selectedEmailIdForReadingPane: null,
      currentlyViewedEmailId: null,
      selectedEmailSender: null,
      selectedEmailIndex: null,
    );
  }

  // ---------------------- PAGINATION / SEARCH -------------------
  Future<void> onSearchChanged(String value) async {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 1000), () async {
      if (_disposed) return;
      state = state.copyWith(
        currentPage: 1,
        previousPage: 0,
        searchKey: value,
        // Clear reading pane selection when search changes
        selectedEmailIdForReadingPane: null,
        currentlyViewedEmailId: null, // Also clear highlighting
        selectedEmailSender: null,
        selectedEmailIndex: null,
        showReadingPaneMenuOptions: false,
      );
      if (_disposed) return;
      await getAllEmails(state.searchKey);
    });
  }

  Future<void> refresh() async {
    // Prevent multiple concurrent refreshes
    if (state.isFetching) return;

    // Reset pagination for refresh, show search bar on pull-down
    state = state.copyWith(isSearch: true, currentPage: 1, previousPage: 0);
    await getAllEmails(state.searchKey, isRefresh: true);
  }

  /// Reload the email list when returning to the page
  /// Resets pagination and clears overlays without opening search
  Future<void> reloadList() async {
    state = state.copyWith(
      currentPage: 1,
      previousPage: 0,
      showFilter: false,
      showTagList: false,
      isSearch: false,
      showMenuOptions: false,
    );
    await getAllEmails(state.searchKey, isRefresh: true);
  }

  // ---------------------- SOCKETS -------------------------------
  Future<void> _initSockets() async {
    final userData = state.userData;
    if (userData == null || userData['user'] == null) return;

    final userId = (userData['user']['id'] as num?)?.toInt();
    if (userId == null) return;

    // unread counts
    _socket.emitEventWithAck(
      'unReadCount',
      {'userId': userId},
      ackCallback: (data) {
        if (_disposed) return;
        if (data != null) {
          _updateBadgeFromSocket(data);
        }
      },
    );

    // notificationExists and unread counts are handled centrally by
    // SocketService → countProvider. No duplicate listeners needed here (H-01).

    // PH-04: newMessage / trashMessage → debounced refresh.
    // Rapid-fire events (e.g. 10 messages in 2s) coalesce into a single
    // refresh instead of triggering 10 sequential full-page fetches.
    _newMessageSub?.cancel();
    _newMessageSub = _socket.onEvent('newMessage').listen((data) {
      if (_disposed) return;
      _debouncedSocketRefresh();
    });

    _trashMessageSub?.cancel();
    _trashMessageSub = _socket.onEvent('trashMessage').listen((data) {
      if (_disposed) return;
      _debouncedSocketRefresh();
    });
  }

  /// PH-04: Coalesce rapid-fire socket events into a single refresh.
  void _debouncedSocketRefresh() {
    _socketDebounce?.cancel();
    _socketDebounce = Timer(const Duration(milliseconds: 500), () {
      if (_disposed) return;
      refresh();
    });
  }

  void updateNotificationFlag(bool flag) {
    state = state.copyWith(newNotification: flag);
    // Sync with centralized countProvider
    ref
        .read(countProvider.notifier)
        .updateNotificationStatus(flag ? 'yes' : 'no');
  }

  Future<void> triggerContactSyncFromSettings() async {
    // ✅ Web guard: Permission.contacts and openAppSettings are mobile-only APIs
    if (kIsWeb) {
      printLog(
        '[CONTACT_SYNC] triggerContactSyncFromSettings',
        'Skipped on web (contacts are device-only)',
      );
      return;
    }

    printLog(
      '[CONTACT_SYNC] triggerContactSyncFromSettings called',
      'Checking current permission status',
    );

    // Step 1: Check current permission status first (no request yet)
    final permissionStatus = await Permission.contacts.status;
    printLog(
      '[CONTACT_SYNC] Current permission status',
      permissionStatus.toString(),
    );

    if (permissionStatus.isGranted) {
      // ✅ Already granted — force re-sync by resetting the sync flag
      printLog('[CONTACT_SYNC] Permission ALREADY GRANTED', 'Forcing re-sync');
      await _secureStorage.writeData('isContactAlreadySync', 'no');
      await _secureStorage.writeData('userContactPermission', 'granted');
      await filterContacts();
      printLog(
        '[CONTACT_SYNC] Re-sync complete',
        'Contacts uploaded from Settings toggle',
      );
      return;
    }

    if (permissionStatus.isPermanentlyDenied) {
      // ⚠️ Permanently denied — user must go to App Settings manually
      printLog(
        '[CONTACT_SYNC] Permission PERMANENTLY DENIED',
        'Opening App Settings',
      );
      CommonService.animatedToast(
        'Please enable Contacts permission in App Settings to sync contacts',
        'warning',
      );
      openAppSettings();
      return;
    }

    // Not determined or previously denied — request permission now
    printLog(
      '[CONTACT_SYNC] Requesting contacts permission',
      'Status was: ${permissionStatus.toString()}',
    );

    final result = await Permission.contacts.request();
    printLog('[CONTACT_SYNC] Permission request result', result.toString());

    if (result.isGranted) {
      printLog('[CONTACT_SYNC] Permission GRANTED', 'Starting contact upload');
      await _secureStorage.writeData('userContactPermission', 'granted');
      await _secureStorage.writeData('isContactAlreadySync', 'no');
      await filterContacts();
      printLog('[CONTACT_SYNC] Upload complete from Settings toggle', '');
    } else if (result.isPermanentlyDenied) {
      printLog(
        '[CONTACT_SYNC] Permission PERMANENTLY DENIED after request',
        'Opening App Settings',
      );
      await _secureStorage.writeData(
        'userContactPermission',
        'permanentDenied',
      );
      CommonService.animatedToast(
        'Contacts permission permanently denied. Enable it in App Settings to sync.',
        'warning',
      );
      openAppSettings();
    } else {
      // Denied (not permanent) — disable sync on server
      printLog(
        '[CONTACT_SYNC] Permission DENIED',
        'Disabling contact sync on server',
      );
      await _secureStorage.writeData('userContactPermission', 'denied');
      await syncContacts(); // This calls API to set contactSynch: false on server
    }
  }

  /// H-01: Only extract the native badge count here. countProvider is updated
  /// centrally by SocketService._updateCountNotifier() — no duplicate needed.
  void _updateBadgeFromSocket(dynamic data) {
    if (!kIsWeb) {
      final badgeCount = data['badgeCount'] ?? 0;
      state = state.copyWith(badgeCount: badgeCount);
    }
  }

  // ---------------------- USER DATA / SETTINGS ------------------
  Future<void> _getUserData() async {
    Map<String, dynamic>? userData = ref.read(authProvider).userData;
    if (userData == null) {
      // Genuinely not authenticated — reset loading so the UI isn't stuck.
      if (_disposed) return;
      state = state.copyWith(isLoading: false);
      return;
    }

    final token = userData['token'];
    final user = userData['user'] as Map<String, dynamic>?;

    // Read reading pane setting: prefer the settings provider (updated
    // synchronously by toggleReadingPane) so a toggle-then-navigate-back
    // doesn't race with the async storage write.  Fall back to storage on
    // cold boot when the settings provider hasn't loaded yet.
    final settingsState = ref.read(settingsProvider);
    final bool readingPaneEnabled;
    if (settingsState.hasUserData) {
      readingPaneEnabled = settingsState.readingPaneEnabled;
    } else {
      final String? readingPaneValue = await _secureStorage.readData(
        'readingPaneEnabled',
      );
      readingPaneEnabled = readingPaneValue == null
          ? true
          : readingPaneValue == 'true';
    }

    state = state.copyWith(
      userData: userData,
      token: token ?? '',
      syncContact: user?['contactSynch'] ?? true,
      // Enable reading pane for web and native tablets (tablets will show it in landscape)
      readingPaneEnabledWeb:
          readingPaneEnabled && (kIsWeb || AppBreakpoints.isPhysicalTablet),
      // Preserve emailType if already set (e.g. 'all' for tag filter from bootstrap)
      emailType: state.emailType != 'inbox' ? state.emailType : 'inbox',
    );

    // Prefer the Descope session JWT — userData['token'] may be null when
    // the ST-3 web recovery path rebuilt userData from the profile API (which
    // returns {'user': ...} with no 'token' field).
    final socketToken = Descope.sessionManager.session?.sessionJwt
        ?? (userData['token'] as String?)
        ?? '';
    final userId = user?['id'];
    if (userId != null) {
      try {
        await _socket.initSocket(socketUrl, socketToken, userId);
      } catch (_) {
        // Socket init failure should not block inbox loading
      }
    }

    // Run contact sync in background for mobile - don't block inbox loading
    if (!kIsWeb) {
      _runContactSyncInBackground(userData);
    }
    await _initSockets();
    // PH-05: Fetch emails and tags in parallel — they are independent.
    // STAB-03: _getAllEmailsWithRetry has exponential backoff (1s, 2s, 4s).
    await Future.wait([
      _getAllEmailsWithRetry(state.searchKey),
      _maybeLoadTags(),
    ]);
  }

  /// Runs contact sync in the background without blocking inbox loading
  void _runContactSyncInBackground(Map<String, dynamic> userData) {
    // Use Future.microtask to run after current frame completes
    Future.microtask(() async {
      try {
        final userContactPermission = await _secureStorage.readData(
          'userContactPermission',
        );
        if (userContactPermission != null &&
            (userContactPermission == 'granted' ||
                userContactPermission == 'permitted')) {
          await filterContactsToJson();
        } else if ((userContactPermission == 'denied' ||
                userContactPermission == 'permanentDenied' ||
                userContactPermission == null) &&
            userData['user']['contactSynch'] == true) {
          await filterContactsToJson();
        } else if (userContactPermission == null ||
            userContactPermission == 'denied') {
          await filterContactsToJson();
        }
      } catch (e) {
        // Silently fail contact sync to prevent blocking user
      }
    });
  }

  Future<void> _maybeLoadTags() async {
    // if (!kIsWeb) return;
    // Only fetch tags if not already loaded in the shared provider
    final tagState = ref.read(tagsProvider);
    if (tagState.tagsList == null || tagState.tagsList!.data.tags.isEmpty) {
      await getAllTags();
    }
  }

  // STAB-03: Exponential backoff retry for the initial email fetch.
  // Retries up to 3 times (1s, 2s, 4s delays) on transient network errors.
  Future<void> _getAllEmailsWithRetry(String searchKey) async {
    const maxAttempts = 3;
    for (var attempt = 1; attempt <= maxAttempts; attempt++) {
      await getAllEmails(searchKey);
      if (_disposed) return;
      // Success or non-retryable error — stop retrying.
      if (state.errorMessage == null || attempt == maxAttempts) return;
      // Only retry on transient errors, not auth/server failures.
      if (state.errorMessage != catchError) return;
      // Wait with exponential backoff before retrying.
      await Future.delayed(Duration(seconds: 1 << (attempt - 1)));
      if (_disposed) return;
      // Reset page to 1 for the retry.
      state = state.copyWith(currentPage: 1, errorMessage: null);
    }
  }

  // ---------------------- EMAIL LIST API ------------------------
  Future<void> getAllEmails(
    String searchKey, {
    bool isRefresh = false,
    bool silent = false,
  }) async {
    // H-10: prevent concurrent fetches that cause pagination desync
    if (state.isFetching && !isRefresh) return;
    state = state.copyWith(isFetching: true);

    // Show loader only when required
    if (state.currentPage == 1 && !isRefresh) {
      state = state.copyWith(isLoading: true);
    }
    // Snapshot for reads within this method
    final s = state;
    final reqData = <String, dynamic>{
      'type': s.emailType,
      'page': s.currentPage,
      'limit': itemCount,
      'search': searchKey,
    };

    if (s.tagIdFilter.isNotEmpty) {
      reqData['tagsId'] = s.tagIdFilter;
    }

    try {
      final value = await _inboxApi.getInboxEmails(reqData);
      if (_disposed) return;

      final inboxList = value.data!;
      if (!inboxList.success) {
        // Only toast when there's a message — auth errors (401) return empty
        // message because _handleSessionExpiry() already showed "Session expired".
        // Also skip "No internet connection" — the global snackbar handles it.
        if (inboxList.message.isNotEmpty &&
            inboxList.message != noInternet) {
          CommonService.animatedToast(inboxList.message, 'error', null, true);
        }

        if (_disposed) return;
        // Don't set errorMessage for connectivity failures — keep cached items visible.
        if (inboxList.message == noInternet) {
          state = state.copyWith(isLoading: false, isFetching: false);
        } else {
          state = state.copyWith(
            isLoading: false,
            isFetching: false,
            errorMessage: inboxList.message,
          );
        }
        return;
      }

      final List<Emails> newItems =
          s.currentPage > 1 && s.currentPage != s.previousPage
          ? [...s.items, ...inboxList.data!.emails]
          : inboxList.data!.emails;

      int currentPage = s.currentPage;
      final int previousPage = s.currentPage;

      if (inboxList.data!.nextPage == true) {
        currentPage = s.currentPage + 1;
      }

      if (_disposed) return;

      // Preserve existing selections - only clear if explicitly requested via bootstrap
      // or if this is a fresh load (page 1 with no prior selection)
      final shouldPreserveSelection =
          state.selectedEmailIds.isNotEmpty ||
          state.selectedEmailIdForReadingPane != null;

      state = state.copyWith(
        inboxList: inboxList,
        items: newItems,
        totalEmailCount: newItems.length,
        previousPage: previousPage,
        currentPage: currentPage,
        isLoading: false,
        isFetching: false,
        errorMessage: null,
        // Only clear selections if there was no prior selection
        allEmailIdsFlag: shouldPreserveSelection
            ? state.allEmailIdsFlag
            : false,
        selectedEmailIds: shouldPreserveSelection
            ? state.selectedEmailIds
            : const <int>[],
        selectedEmails: shouldPreserveSelection
            ? state.selectedEmails
            : const <String>[],
      );

      // Don't restore reading pane selection - start with empty reading pane like archive
      // This ensures the reading pane shows "Select a message to read" when first coming to inbox
    } catch (error) {
      if (_disposed) return;

      // Auth-related failure: the session expiry handler already set
      // isAuthenticated=false and the router is redirecting to login.
      // Don't overwrite the inbox UI with an error state in this case —
      // the user will never see it, and it prevents the "Something went wrong"
      // flash that appears briefly before the redirect completes.
      if (!ref.read(authProvider).isAuthenticated) {
        state = state.copyWith(isLoading: false, isFetching: false);
        return;
      }

      if (error is NoInternetException) {
        // Don't set errorMessage — keep showing cached items.
        // The global connectivity snackbar already notifies the user.
        state = state.copyWith(isLoading: false, isFetching: false);
      } else {
        state = state.copyWith(
          isLoading: false,
          isFetching: false,
          errorMessage: catchError,
        );
        CommonService.animatedToast(
          catchError,
          'error',
          null,
          true,
        );
      }
    }
  }

  // ---------------------- EMAIL STATUS --------------------------
  Future<void> updateEmailStatus(String type, List<int> ids, int index) async {
    List<int> list = parseIds(ids);
    if (list.isEmpty) return;
    try {
      /* final resp = await ApiService().post(
        'email/update-email-status',
        {
          'key': type,
          'emailIds': ids,
          'value': type == 'isRead' ? false : true,
        },
      );*/
      final response = await _inboxApi.updateEmailStatus({
        'key': type,
        'emailIds': list,
        'value': type == 'isRead' ? false : true,
      });
      final resp = response.data!;

      if (!resp['success']) {
        CommonService.animatedToast(resp['message'], 'error', null, true);
        return;
      }

      if (type == 'isRead') {
        final newItems = [...state.items];
        for (final emailId in ids) {
          final idx = newItems.indexWhere((e) => e.emailId == emailId);
          if (idx != -1) {
            newItems[idx] = newItems[idx].copyWith(isRead: false);
          }
        }
        state = state.copyWith(items: newItems);
      }

      // refresh unread count
      final userData = state.userData;
      if (userData != null && userData['user'] != null) {
        final userId = userData['user']['id'];
        _socket.emitEventWithAck(
          'unReadCount',
          {'userId': userId},
          ackCallback: (data) {
            if (data != null) {
              _updateBadgeFromSocket(data);
            }
          },
        );
      }
    } catch (error) {
      if (error is! NoInternetException) {
        CommonService.animatedToast(
          catchError,
          'error',
          null,
          true,
        );
      }
    }
  }

  Future<void> markSelectedAsRead() async {
    final ids = state.selectedEmailIds;
    if (ids.isEmpty) return;

    try {
      /*final resp = await ApiService().post(
        'email/update-email-status',
        {
          'key': 'isRead',
          'emailIds': ids,
          'value': true,
        },
      );*/
      final response = await _inboxApi.updateEmailStatus({
        'key': 'isRead',
        'emailIds': ids,
        'value': true,
      });
      final resp = response.data!;
      if (!resp['success']) {
        CommonService.animatedToast(resp['message'], 'error', null, true);
        return;
      }

      final newItems = [...state.items];
      for (final id in ids) {
        final idx = newItems.indexWhere((e) => e.emailId == id);
        if (idx != -1) newItems[idx] = newItems[idx].copyWith(isRead: true);
      }

      state = state.copyWith(items: newItems);

      final userData = state.userData;
      if (userData != null && userData['user'] != null) {
        _socket.emitEventWithAck(
          'unReadCount',
          {'userId': userData['user']['id']},
          ackCallback: (data) {
            if (data != null) _updateBadgeFromSocket(data);
          },
        );
      }
    } catch (error) {
      if (error is! NoInternetException) {
        CommonService.animatedToast(
          catchError,
          'error',
          null,
          true,
        );
      }
    }
  }

  Future<void> getAllTags() async {
    try {
      final response = await _tagApi.getTagsList(<String, dynamic>{
        'search': '',
      });
      final tagsList = TagsListModel.fromJson(response.data!);
      if (!tagsList.success) {
        CommonService.animatedToast(tagsList.message, 'error', null, true);
        return;
      }
      state = state.copyWith(tagsItems: tagsList.data.tags);
      ref.read(tagsProvider.notifier).setTagsList(tagsList);
      // Also sync with TagsNotifier so Tags folder sees updated tags
      // ref.read(tagsNotifierProvider.notifier).setTagsList(tagsList);
    } catch (error) {
      if (error is! NoInternetException) {
        CommonService.animatedToast(
          catchError,
          'error',
          null,
          true,
        );
      }
    }
  }

  Future<void> addEmailTags(
    List<int> tagIds,
    int emailId,
    int index,
    String type,
  ) async {
    try {
      final ids = emailId == 0 ? state.selectedEmailIds : [emailId];
      final response = await _inboxApi.getEmailTags({
        'emailIds': ids,
        'tagsId': tagIds,
        'type': type,
      });
      final resp = response.data!;
      /* final resp = await ApiService().post(
        'email/emails-tags',
        {
          'emailIds': ids,
          'tagsId': tagIds,
          'type': type,
        },
      );*/
      if (!resp['success']) {
        CommonService.animatedToast(resp['message'], 'error', null, true);
        return;
      }

      final newItems = [...state.items];

      if (emailId != 0) {
        // Single email update
        final idx = newItems.indexWhere((e) => e.emailId == emailId);
        if (idx != -1) {
          if (type == 'delete') {
            // Create a new list to ensure state change is detected
            final updatedTags = newItems[idx].emailRecipientTags
                .where((t) => !tagIds.contains(t.tagId))
                .toList();
            // Use copyWith to create a new email object with updated tags
            newItems[idx] = newItems[idx].copyWith(
              emailRecipientTags: updatedTags,
            );
          } else {
            // Try to get tags from API response
            List<EmailRecipientTags> updatedTags = [];
            try {
              final email = resp['data']?['email'];
              if (email != null) {
                final tagsJson =
                    (email['emailTags'] != null &&
                        (email['emailTags'] as List).isNotEmpty)
                    ? email['emailTags']
                    : email['emailRecipientTags'] ?? [];

                updatedTags = (tagsJson as List<dynamic>)
                    .map(
                      (e) => EmailRecipientTags.fromJson(
                        e as Map<String, dynamic>,
                      ),
                    )
                    .toList();
              }
            } catch (_) {
              // If API response parsing fails, use fallback
            }

            // Fallback: build tags locally if API response didn't work
            if (updatedTags.isEmpty && tagIds.isNotEmpty) {
              final tagState = ref.read(tagsProvider);
              final tagsList = tagState.tagsList?.data.tags ?? [];
              final tagsToAdd = tagsList
                  .where((tag) => tagIds.contains(tag.id))
                  .toList();

              final existingTagIds = newItems[idx].emailRecipientTags
                  .map((t) => t.tagId)
                  .toList();

              final newTags = <EmailRecipientTags>[];
              for (final tag in tagsToAdd) {
                if (!existingTagIds.contains(tag.id)) {
                  final emailRecipientTag = EmailRecipientTags.fromJson({
                    'id': 0,
                    'tagId': tag.id,
                    'emailRecipientsId': newItems[idx].receiverId,
                    'tag': {'id': tag.id, 'tag': tag.tag},
                  });
                  newTags.add(emailRecipientTag);
                }
              }

              updatedTags = [...newItems[idx].emailRecipientTags, ...newTags];
            }

            // Use copyWith to create a new email object with updated tags
            if (updatedTags.isNotEmpty) {
              newItems[idx] = newItems[idx].copyWith(
                emailRecipientTags: updatedTags,
              );
            }
          }
        }
      } else {
        // Multiple emails update (emailId == 0)
        final tagState = ref.read(tagsProvider);
        final tagsList = tagState.tagsList?.data.tags ?? [];

        // Get tag information for the tagIds being added/removed
        final tagsToAdd = tagsList
            .where((tag) => tagIds.contains(tag.id))
            .toList();

        for (final selectedId in ids) {
          final idx = newItems.indexWhere((e) => e.emailId == selectedId);
          if (idx != -1) {
            if (type == 'delete') {
              // Remove tags from this email
              final updatedTags = newItems[idx].emailRecipientTags
                  .where((t) => !tagIds.contains(t.tagId))
                  .toList();
              newItems[idx] = newItems[idx].copyWith(
                emailRecipientTags: updatedTags,
              );
            } else {
              // Add tags to this email
              final existingTagIds = newItems[idx].emailRecipientTags
                  .map((t) => t.tagId)
                  .toList();

              // Create new EmailRecipientTags for tags that don't already exist
              final newTags = <EmailRecipientTags>[];
              for (final tag in tagsToAdd) {
                if (!existingTagIds.contains(tag.id)) {
                  // Create EmailRecipientTags object
                  final emailRecipientTag = EmailRecipientTags.fromJson({
                    'id': 0, // Temporary ID, will be updated by server
                    'tagId': tag.id,
                    'emailRecipientsId': newItems[idx].receiverId,
                    'tag': {'id': tag.id, 'tag': tag.tag},
                  });
                  newTags.add(emailRecipientTag);
                }
              }

              // Combine existing tags with new tags
              final updatedTags = [
                ...newItems[idx].emailRecipientTags,
                ...newTags,
              ];
              newItems[idx] = newItems[idx].copyWith(
                emailRecipientTags: updatedTags,
              );
            }
          }
        }
      }

      // Check if the currently viewed email in reading pane was updated
      final viewedEmailUpdated =
          state.selectedEmailIdForReadingPane != null &&
          ids.contains(state.selectedEmailIdForReadingPane);

      // Invalidate cached email detail so the reading pane re-fetches
      // fresh data (including updated tags) instead of hitting stale cache.
      if (viewedEmailUpdated) {
        AppCache().invalidateEmailDetail(state.selectedEmailIdForReadingPane!);
      }

      state = state.copyWith(
        items: newItems,
        // Increment refresh key to force reading pane reload if viewing updated email
        readingPaneRefreshKey: viewedEmailUpdated
            ? state.readingPaneRefreshKey + 1
            : state.readingPaneRefreshKey,
      );
    } catch (error) {
      if (error is! NoInternetException) {
        CommonService.animatedToast(
          catchError,
          'error',
          null,
          true,
        );
      }
    }
  }

  // ---------------------- CONTACT SYNC --------------------------
  Future<void> filterContactsToJson() async {
    final isContactsAlreadySync = await _secureStorage.readData(
      'isContactAlreadySync',
    );

    await Permission.contacts
        .onDeniedCallback(() async {
          await _deferSecureStorageWrite(
            'userContactPermission',
            'permanentDenied',
          );
          await syncContacts();
        })
        .onGrantedCallback(() async {
          // Add listener only once
          if (!_listenerAdded) {
            FlutterContacts.onDatabaseChange.listen((_) async {
              try {
                await _deferSecureStorageWrite(
                  'userContactPermission',
                  'permitted',
                );
                await _deferSecureStorageWrite('contactListner', 'yes');
                await _deferSecureStorageWrite('isContactAlreadySync', 'no');

                ref.read(contactListProvider.notifier).refreshContacts();
              } catch (e) {
                debugPrint('Contact database change listener error: $e');
              }
            });

            _listenerAdded = true;
          }

          // Sync contacts if needed
          if (isContactsAlreadySync != 'yes' && state.syncContact == true) {
            await filterContacts();
          }
        })
        .onPermanentlyDeniedCallback(() async {
          await _deferSecureStorageWrite(
            'userContactPermission',
            'permanentDenied',
          );
          await syncContacts();
        })
        .onRestrictedCallback(() async {
          await _deferSecureStorageWrite(
            'userContactPermission',
            'permanentDenied',
          );
          await syncContacts();
        })
        .onLimitedCallback(() async {
          await _deferSecureStorageWrite(
            'userContactPermission',
            'permanentDenied',
          );
          await syncContacts();
        })
        .onProvisionalCallback(() async {
          await _deferSecureStorageWrite(
            'userContactPermission',
            'permanentDenied',
          );
          await syncContacts();
        })
        .request();
  }

  bool _listenerAdded = false;

  Future<void> _deferSecureStorageWrite(String key, String value) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      await _secureStorage.writeData(key, value);
    } catch (e) {
      // Failed to write to secure storage
    }
  }

  Future<void> filterContacts() async {
    try {
      // A1: allProperties excludes photos/thumbnails in flutter_contacts v2.0.0,
      // avoiding 50-200MB of image data on devices with 1000+ contacts.
      // Do NOT switch to ContactProperties.all (which includes photos).
      // TODO: Re-enable photos when local storage caching is implemented.
      final contacts = await FlutterContacts.getAll(
        properties: ContactProperties.allProperties,
      );

      // Move heavy filtering/serialization to a background isolate so the
      // main isolate stays free for lifecycle handlers (biometric lock, etc.).
      // With 3000+ contacts the inline loop blocked the event loop for 1-4s.
      final filteredContacts = await compute(
        _filterContactsIsolate,
        contacts.map((c) => c.toJson()).toList(),
      );

      await _inboxApi.contactUpload({'data': filteredContacts});

      await _deferSecureStorageWrite('isContactAlreadySync', 'yes');
      final userData = state.userData;
      if (userData != null) {
        await ref.read(authProvider.notifier).updateUserField('contactSynch', true);
        final updatedUser = {...userData['user'], 'contactSynch': true};
        state = state.copyWith(userData: {...userData, 'user': updatedUser});
      }
    } catch (e) {
      printLog('[CONTACT_SYNC] filterContacts error', e.toString());
    }
  }

  Future<void> syncContacts() async {
    try {
      final response = await _inboxApi.contactUploadToggleContactSync({
        'contactSynch': false,
      });
      final resp = response.data!;
      /* final resp = await ApiService()
          .post('user/toggle-contact-synch', {'contactSynch': false});*/
      if (resp['success']) {
        final userData = state.userData;
        if (userData != null) {
          await ref.read(authProvider.notifier).updateUserField('contactSynch', false);
          final updatedUser = {...userData['user'], 'contactSynch': false};
          state = state.copyWith(userData: {...userData, 'user': updatedUser});
        }

        CommonService.animatedToast(resp['message'], 'success', null, true);
      } else {
        CommonService.animatedToast(resp['message'], 'error', null, true);
      }
    } catch (_) {
      // ignore
    }
  }

  // ---------------------- SELECTION -----------------------------
  void toggleSelectFromList(int id, String email) {
    final ids = [...state.selectedEmailIds];
    final emails = [...state.selectedEmails];

    if (ids.contains(id)) {
      ids.remove(id);
      emails.remove(email);
    } else {
      ids.add(id);
      emails.add(email);
    }

    state = state.copyWith(
      selectedEmailIds: ids,
      selectedEmails: emails,
      allEmailIdsFlag: ids.length == state.items.length,
      longPressFlag: ids.isEmpty,
      showCheckboxes: ids.isEmpty ? false : state.showCheckboxes,
    );
  }

  void selectAllFromList() {
    final ids = state.items.map((e) => e.emailId).toList();
    final emails = state.items.map((e) => e.email.senderEmail).toList();

    state = state.copyWith(
      selectedEmailIds: ids,
      selectedEmails: emails,
      allEmailIdsFlag: true,
      longPressFlag: false,
    );
  }

  void clearSelection() {
    state = state.copyWith(
      selectedEmailIds: <int>[],
      selectedEmails: <String>[],
      allEmailIdsFlag: false,
      longPressFlag: true,
      showCheckboxes: false,
      lastClickedIndex: -1,
    );
  }

  /// Selects a contiguous range of emails between [fromIndex] and [toIndex].
  /// Merges with existing selection (union).
  void selectRangeFromList(int fromIndex, int toIndex) {
    final items = state.items;
    if (items.isEmpty) return;
    final start = fromIndex.clamp(0, items.length - 1);
    final end = toIndex.clamp(0, items.length - 1);
    final lo = start < end ? start : end;
    final hi = start < end ? end : start;

    final ids = {...state.selectedEmailIds};
    final emails = {...state.selectedEmails};

    for (int i = lo; i <= hi; i++) {
      ids.add(items[i].emailId);
      emails.add(items[i].email.senderEmail);
    }

    state = state.copyWith(
      selectedEmailIds: ids.toList(),
      selectedEmails: emails.toList(),
      allEmailIdsFlag: ids.length == items.length,
      longPressFlag: false,
      showCheckboxes: true,
      lastClickedIndex: toIndex.clamp(0, items.length - 1),
    );
  }

  /// Toggles a single email by list index (for Ctrl/Cmd+Click).
  void toggleSingleSelectByIndex(int index) {
    final items = state.items;
    if (index < 0 || index >= items.length) return;
    final item = items[index];
    final ids = [...state.selectedEmailIds];
    final emails = [...state.selectedEmails];

    if (ids.contains(item.emailId)) {
      ids.remove(item.emailId);
      emails.remove(item.email.senderEmail);
    } else {
      ids.add(item.emailId);
      emails.add(item.email.senderEmail);
    }

    state = state.copyWith(
      selectedEmailIds: ids,
      selectedEmails: emails,
      allEmailIdsFlag: ids.length == items.length,
      longPressFlag: ids.isEmpty,
      showCheckboxes: ids.length > 1 ? true : state.showCheckboxes,
      lastClickedIndex: index,
    );
  }

  void setSelectedFromList(List<int> ids, List<String> mails) {
    state = state.copyWith(
      selectedEmailIds: ids,
      selectedEmails: mails,
      allEmailIdsFlag: ids.length == state.items.length,
      longPressFlag: ids.isEmpty,
      showCheckboxes: ids.isEmpty ? false : state.showCheckboxes,
    );
  }

  /// Called from menu, swipe action, or hover action
  /// [email] - optional email address for single email opt-in (from hover/swipe)
  void handleOptIn({String? email}) {
    // If email is provided directly (from hover/swipe action), use it
    if (email != null && email.isNotEmpty) {
      final item = state.items.cast<Emails?>().firstWhere(
        (e) => e?.email.senderEmail == email,
        orElse: () => null,
      );
      final name = _buildSenderDisplayName(
        item?.email.sender.firstName,
        item?.email.sender.lastName,
      );
      startAddEmailFlow([email], senderNames: {email: name});
      return;
    }

    // Check if there are selected emails (multi-select case)
    if (state.selectedEmails.isNotEmpty) {
      final names = <String, String?>{};
      for (final selEmail in state.selectedEmails) {
        final item = state.items.cast<Emails?>().firstWhere(
          (e) => e?.email.senderEmail == selEmail,
          orElse: () => null,
        );
        names[selEmail] = _buildSenderDisplayName(
          item?.email.sender.firstName,
          item?.email.sender.lastName,
        );
      }
      startAddEmailFlow(state.selectedEmails, senderNames: names);
      return;
    }

    // If no multi-select, check if viewing email in reading pane
    if (state.selectedEmailIdForReadingPane != null &&
        state.selectedEmailSender != null &&
        state.selectedEmailSender!.isNotEmpty) {
      final idx = state.selectedEmailIndex;
      final item =
          (idx != null && idx >= 0 && idx < state.items.length)
              ? state.items[idx]
              : null;
      final name = _buildSenderDisplayName(
        item?.email.sender.firstName,
        item?.email.sender.lastName,
      );
      startAddEmailFlow(
        [state.selectedEmailSender!],
        senderNames: {state.selectedEmailSender!: name},
      );
    }
  }

  /// Handle opt-in action for a single email from swipe action
  void handleSingleEmailOptIn(String email, int index) {
    if (email.isEmpty) return;
    final item =
        (index >= 0 && index < state.items.length)
            ? state.items[index]
            : null;
    final name = _buildSenderDisplayName(
      item?.email.sender.firstName,
      item?.email.sender.lastName,
    );
    startAddEmailFlow([email], senderNames: {email: name});
  }

  /// Builds a display name from first and last name parts.
  /// Returns null if both are empty/null.
  String? _buildSenderDisplayName(String? firstName, String? lastName) {
    final parts = [firstName?.trim(), lastName?.trim()]
        .where((p) => p != null && p.isNotEmpty)
        .toList();
    return parts.isEmpty ? null : parts.join(' ');
  }

  /// Starts recursive email check flow
  Future<void> startAddEmailFlow(
    List<String> emails, {
    Map<String, String?> senderNames = const {},
  }) async {
    if (emails.isEmpty) return;

    state = state.copyWith(allEmailsTrue: true, pendingOptInEmails: emails);

    await _checkEmailSequentially(emails, 0, senderNames: senderNames);
  }

  /// Core logic migrated from `_displayAddEmailModal`.
  /// Iterative loop — avoids unbounded stack growth for large recipient lists.
  Future<void> _checkEmailSequentially(
    List<String> emails,
    int startIndex, {
    Map<String, String?> senderNames = const {},
  }) async {
    for (int index = startIndex; index < emails.length; index++) {
      final email = emails[index];

      try {
        final response = await _inboxApi.checkEmail({"email": email});
        final resp = response.data!;

        if (!resp['success']) {
          CommonService.animatedToast(resp['message'], 'error', null, true);
          return;
        }

        final exists = resp['data']['status'] == true;

        if (exists) {
          // Email already in a contact — continue to next.
          continue;
        }

        // Needs the opt-in modal; pause here and wait for the dialog result
        // (handleOptInDialogResult will resume from index + 1).
        state = state.copyWith(
          allEmailsTrue: false,
          pendingOptInEmail: email,
          pendingOptInSenderName: senderNames[email],
        );
        return;
      } catch (error) {
        if (error is! NoInternetException) {
          CommonService.animatedToast(
            'Error checking email',
            'error',
            null,
            true,
          );
        }
        return;
      }
    }

    // Reached end of list — all emails already existed.
    if (emails.isNotEmpty && state.allEmailsTrue) {
      CommonService.animatedToast(
        'Emails are already present in a contact',
        'info',
      );
    }
  }

  /// Resume flow after dialog closes.
  Future<void> handleOptInDialogResult(String? result) async {
    final emails = state.pendingOptInEmails;
    final currentEmail = state.pendingOptInEmail;
    state = state.copyWith(pendingOptInEmail: null, pendingOptInSenderName: null);

    // "Skip all" or cancel pressed, or no current email
    if (result == 'skip_all' ||
        result == 'cancel-email' ||
        result == 'existing_contact' ||
        currentEmail == null) {
      state = state.copyWith(pendingOptInEmails: []);
      return;
    }

    final index = emails.indexOf(currentEmail);
    if (index == -1) {
      state = state.copyWith(pendingOptInEmails: []);
      return;
    }

    await _checkEmailSequentially(emails, index + 1);
  }

  // ---------------------- CHANGE EMAIL STATUS (UNDO) -----------
  Future<void> changeEmailStatusWithUndo(String status) async {
    if (state.selectedEmailIds.isEmpty) return;

    final removedItems = <Emails>[];
    final removedIndices = <int, int>{};

    final items = [...state.items];

    for (final id in state.selectedEmailIds) {
      final index = items.indexWhere((e) => e.emailId == id);
      if (index != -1) {
        removedItems.add(items[index]);
        removedIndices[id] = index;
      }
    }

    final remaining = items
        .where((e) => !state.selectedEmailIds.contains(e.emailId))
        .toList();

    state = state.copyWith(
      items: remaining,
      isInProcess: true,
      undoBuffer: removedItems,
      undoIds: state.selectedEmailIds,
      showMenuOptions: false,
    );

    clearSelection();

    // show toast with undo
    bool undo = false;
    _requestCounter++;
    final currentReq = _requestCounter;

    void undoAction() {
      if (_disposed) return;
      final currentItems = [...state.items];
      for (final item in removedItems) {
        final insertIndex = removedIndices[item.emailId] ?? currentItems.length;
        if (insertIndex <= currentItems.length) {
          currentItems.insert(insertIndex, item);
        } else {
          currentItems.add(item);
        }
      }
      state = state.copyWith(
        items: currentItems,
        undoBuffer: <Emails>[],
        undoIds: <int>[],
        isInProcess: false,
      );
      undo = true;
    }

    CommonService.animatedToast(
      CommonService().undoStatus(status.replaceAll('is', '')),
      "Undo",
      undoAction,
      true,
    );

    _undoTimer?.cancel();
    _undoTimer = Timer(const Duration(seconds: 3), () async {
      if (_disposed) return;
      if (_disposed) return;
      if (currentReq == _requestCounter && !undo) {
        await updateEmailStatus(status, state.undoIds, 0);
        if (_disposed) return;
        if (_disposed) return;
        state = state.copyWith(
          undoBuffer: <Emails>[],
          undoIds: <int>[],
          isInProcess: false,
        );
      }
    });
  }

  Future<void> handleMarkUnread() async {
    final s = state;

    // Determine which email IDs to mark - either selected emails or reading pane email
    List<int> emailIdsToMark = [];

    if (s.selectedEmailIds.isNotEmpty) {
      emailIdsToMark = s.selectedEmailIds;
    } else if (s.selectedEmailIdForReadingPane != null) {
      emailIdsToMark = [s.selectedEmailIdForReadingPane!];
    }

    if (emailIdsToMark.isEmpty) return;

    final isUnread = s.items
        .where((e) => emailIdsToMark.contains(e.emailId))
        .every((e) => !e.isRead);

    // Make API call to update email status on server
    // BUG FIX: Use emailIdsToMark instead of s.selectedEmailIds
    // When using reading pane, selectedEmailIds is empty but emailIdsToMark has the reading pane email ID
    try {
      final response = await _inboxApi.updateEmailStatus({
        "key": "isRead",
        "emailIds": emailIdsToMark,
        "value": isUnread,
      });
      final resp = response.data!;
      if (!resp['success']) {
        CommonService.animatedToast(resp['message'], 'error', null, true);
        return;
      }
    } catch (error) {
      if (error is! NoInternetException) {
        CommonService.animatedToast(catchError, 'error', null, true);
      }
      return;
    }

    final updated = s.items.map((e) {
      if (emailIdsToMark.contains(e.emailId)) {
        return e.copyWith(isRead: isUnread);
      }
      return e;
    }).toList();

    state = s.copyWith(
      items: updated,
      selectedEmailIds: [],
      selectedEmails: [],
      allEmailIdsFlag: false,
      longPressFlag: true,
      // Only close reading pane when marking as unread (not when marking as read)
      selectedEmailIdForReadingPane: isUnread ? s.selectedEmailIdForReadingPane : null,
      currentlyViewedEmailId: isUnread ? s.currentlyViewedEmailId : null,
      selectedEmailIndex: isUnread ? s.selectedEmailIndex : null,
      selectedEmailSender: isUnread ? s.selectedEmailSender : null,
    );

    // Refresh unread counts after marking as read/unread
    final userData = s.userData;
    if (userData != null && userData['user'] != null) {
      _socket.emitEventWithAck(
        'unReadCount',
        {'userId': userData['user']['id']},
        ackCallback: (data) {
          if (data != null) _updateBadgeFromSocket(data);
        },
      );
    }
  }

  void handleArchive() {
    // First check if there are selected emails (multi-select case)
    if (state.selectedEmailIds.isNotEmpty) {
      changeStatusWithUndo("isArchive", state.selectedEmailIds);
      return;
    }

    // If no multi-select, check if viewing email in reading pane
    if (state.selectedEmailIdForReadingPane != null) {
      changeStatusWithUndo("isArchive", [state.selectedEmailIdForReadingPane!]);
    }
  }

  void handleDelete() {
    // First check if there are selected emails (multi-select case)
    if (state.selectedEmailIds.isNotEmpty) {
      changeStatusWithUndo("isTrash", state.selectedEmailIds);
      return;
    }

    // If no multi-select, check if viewing email in reading pane
    if (state.selectedEmailIdForReadingPane != null) {
      changeStatusWithUndo("isTrash", [state.selectedEmailIdForReadingPane!]);
    }
  }

  Future<void> changeStatusWithUndo(String status, List<int> ids) async {
    if (ids.isEmpty) return;

    // Debug log to verify correct status is being used
    debugPrint("changeStatusWithUndo: status=$status, ids=$ids");

    _undoBuffer = state.items.where((e) => ids.contains(e.emailId)).toList();

    _undoIds = List.from(ids);

    final remaining = state.items
        .where((e) => !ids.contains(e.emailId))
        .toList();

    // Check if the currently viewed email is being removed
    final bool isReadingPaneItemRemoved =
        state.selectedEmailIdForReadingPane != null &&
        ids.contains(state.selectedEmailIdForReadingPane);

    // Auto-advance: select next email when reading pane item is removed
    final autoAdvance = isReadingPaneItemRemoved
        ? _computeAutoAdvance(remaining, state.selectedEmailIndex)
        : null;

    state = state.copyWith(
      items: remaining,
      selectedEmailIds: [],
      selectedEmails: [],
      allEmailIdsFlag: false,
      longPressFlag: true,
      selectedEmailIdForReadingPane: isReadingPaneItemRemoved
          ? autoAdvance?.$1
          : state.selectedEmailIdForReadingPane,
      currentlyViewedEmailId: isReadingPaneItemRemoved
          ? autoAdvance?.$1
          : state.currentlyViewedEmailId,
      selectedEmailSender: isReadingPaneItemRemoved
          ? autoAdvance?.$3
          : state.selectedEmailSender,
      selectedEmailIndex: isReadingPaneItemRemoved
          ? autoAdvance?.$2
          : state.selectedEmailIndex,
    );
    _requestCounter++;

    // Mark auto-advanced email as read
    if (autoAdvance != null) {
      _markEmailAsReadLocally(autoAdvance.$1);
    }

    _undoTimer?.cancel();

    // Debug log to verify API payload
    final apiPayload = {"key": status, "emailIds": _undoIds, "value": true};
    debugPrint("changeStatusWithUndo API call: $apiPayload");
    updateEmailStatus(status, _undoIds, 0);

    // Refresh archiveProvider so that the moved emails appear instantly in Archive/Trash/Sent
    ref.read(archiveProvider.notifier).refresh();

    // Refresh unread counts after status change (e.g., moving to trash)
    final userData = state.userData;
    if (userData != null && userData['user'] != null) {
      _socket.emitEventWithAck(
        'unReadCount',
        {'userId': userData['user']['id']},
        ackCallback: (data) {
          if (data != null) _updateBadgeFromSocket(data);
        },
      );
    }
  }

  /// Computes the next email to auto-advance to after removing item(s).
  /// Returns (emailId, index, senderEmail) or null if list is empty.
  (int, int, String?)? _computeAutoAdvance(
    List<Emails> remaining,
    int? previousIndex,
  ) {
    if (remaining.isEmpty) return null;
    // Clamp to last item if we were at or past the end
    final idx = (previousIndex ?? 0).clamp(0, remaining.length - 1);
    final next = remaining[idx];
    return (next.emailId, idx, next.email.senderEmail);
  }

  /// Removes an email from the list without making an API call.
  /// Used when ViewEmail (in reading pane mode) has already made the API call
  /// and needs to update the local list state.
  void removeEmailFromListById(int emailId) {
    final remaining = state.items.where((e) => e.emailId != emailId).toList();

    // Check if the currently viewed email is being removed
    final bool isReadingPaneItemRemoved =
        state.selectedEmailIdForReadingPane == emailId;

    // Auto-advance: select next email when reading pane item is removed
    final autoAdvance = isReadingPaneItemRemoved
        ? _computeAutoAdvance(remaining, state.selectedEmailIndex)
        : null;

    state = state.copyWith(
      items: remaining,
      selectedEmailIds: [],
      selectedEmails: [],
      allEmailIdsFlag: false,
      longPressFlag: true,
      selectedEmailIdForReadingPane: isReadingPaneItemRemoved
          ? autoAdvance?.$1
          : state.selectedEmailIdForReadingPane,
      currentlyViewedEmailId: isReadingPaneItemRemoved
          ? autoAdvance?.$1
          : state.currentlyViewedEmailId,
      selectedEmailSender: isReadingPaneItemRemoved
          ? autoAdvance?.$3
          : state.selectedEmailSender,
      selectedEmailIndex: isReadingPaneItemRemoved
          ? autoAdvance?.$2
          : state.selectedEmailIndex,
    );
    _requestCounter++;

    // Mark auto-advanced email as read
    if (autoAdvance != null) {
      _markEmailAsReadLocally(autoAdvance.$1);
    }
  }

  /// Marks an email as unread in the local list without making an API call.
  /// Used when ViewEmail has already made the API call.
  void markEmailAsUnreadInList(int emailId) {
    final items = [...state.items];
    bool found = false;

    for (int i = 0; i < items.length; i++) {
      if (items[i].emailId == emailId) {
        items[i] = items[i].copyWith(isRead: false);
        found = true;
        break;
      }
    }

    if (found) {
      state = state.copyWith(items: items);
    }
  }

  /// Mark a single email as read in the local list (no API call).
  /// Used when returning from viewing a message — the backend already
  /// marked it as read via email_detail_notifier.
  void markEmailAsReadInList(int emailId) {
    final items = [...state.items];
    bool found = false;

    for (int i = 0; i < items.length; i++) {
      if (items[i].emailId == emailId) {
        if (items[i].isRead) return; // already read
        items[i] = items[i].copyWith(isRead: true);
        found = true;
        break;
      }
    }

    if (found) {
      state = state.copyWith(items: items);
    }
  }

  void updateEmailTagsInList(int emailId, List<EmailRecipientTags> tags) {
    final items = [...state.items];
    final idx = items.indexWhere((e) => e.emailId == emailId);
    if (idx == -1) return;
    items[idx] = items[idx].copyWith(emailRecipientTags: tags);
    state = state.copyWith(items: items);
  }

  Future<void> handlePrint() async {
    final id = state.selectedEmailIdForReadingPane;
    if (id == null) return;

    ActionBiometricGuard.markDeparture();

    final ctx = NavigationService.navigatorKey.currentContext;
    if (ctx == null) return;

    final sessionToken = Descope.sessionManager.session?.sessionJwt ?? state.token;
    final emailIndex = state.items.indexWhere((e) => e.emailId == id);
    final emailSubject =
        emailIndex != -1 ? state.items[emailIndex].email.subject : null;
    await openSecurePrint(
      printUrl: '$printUrl$id',
      token: sessionToken,
      context: ctx,
      subject: emailSubject,
    );
  }

  /// Get existing tag IDs for an email
  List<int> getExistingTagIdsForEmail(int emailId, int index) {
    final items = state.items;
    final emailIndex = items.indexWhere((e) => e.emailId == emailId);

    if (emailIndex == -1) return [];

    final email = items[emailIndex];

    // Inbox uses emailRecipientTags directly on the email object
    if (email.emailRecipientTags.isNotEmpty) {
      return email.emailRecipientTags
          .map((tagItem) => tagItem.tagId)
          .where((id) => id != 0)
          .toList();
    }

    return [];
  }

  /// Prepare tag dialog state — UI listens and shows PopUpModalTagList.
  void showList(int emailId, int itemIndex, {bool isMove = false}) {
    List<int> tagsToUse = state.selectedTagIds;

    if (emailId != 0) {
      tagsToUse = getExistingTagIdsForEmail(emailId, 0);
      state = state.copyWith(selectedTagIds: tagsToUse);
    }

    state = state.copyWith(
      showTagDialog: true,
      tagDialogEmailId: emailId,
      tagDialogItemIndex: itemIndex,
      tagDialogIsMove: isMove,
      tagDialogInitialTagIds: List<int>.from(tagsToUse),
    );
  }

  /// Called by UI when tag dialog's "Add" button is pressed.
  Future<void> handleTagDialogSave() async {
    final emailId = state.tagDialogEmailId;
    final itemIndex = state.tagDialogItemIndex;
    final isMove = state.tagDialogIsMove;
    final initialTagIds = state.tagDialogInitialTagIds;
    final currentSelectedTags = state.selectedTagIds;

    // Check if no email is selected
    if (state.selectedEmailIds.isEmpty && emailId == 0) {
      CommonService.animatedToast("Please select Email", 'warning', null, true);
      return;
    }

    // Find tags to add (newly selected) and tags to delete (unchecked)
    final tagsToAdd = currentSelectedTags
        .where((tagId) => !initialTagIds.contains(tagId))
        .toList();
    final tagsToDelete = initialTagIds
        .where((tagId) => !currentSelectedTags.contains(tagId))
        .toList();

    // If no initial tags and no tags selected, show warning
    // But if user had tags and unchecked all, allow deletion
    if (initialTagIds.isEmpty && currentSelectedTags.isEmpty) {
      CommonService.animatedToast("Please select Tag", 'warning', null, true);
      return;
    }

    // Delete unchecked tags
    for (final tagId in tagsToDelete) {
      if (emailId != 0) {
        await addEmailTags([tagId], emailId, itemIndex, 'delete');
      } else if (state.selectedEmailIds.isNotEmpty) {
        await addEmailTags([tagId], 0, 0, 'delete');
      }
    }

    // Add newly selected tags
    if (tagsToAdd.isNotEmpty) {
      await addEmailTags(tagsToAdd, emailId, itemIndex, 'add');
    }

    // If this is a "Move" action, archive the emails after tagging
    if (isMove) {
      handleArchive();
    }

    if (emailId != 0 && state.selectedEmailIdForReadingPane == emailId) {
      final tagState = ref.read(tagsProvider);
      state = state.copyWith(selectedEmailTags: tagState.tagsList);
    }
  }

  /// Called by UI when tag dialog is dismissed.
  void dismissTagDialog() {
    state = state.copyWith(showTagDialog: false);
  }

  /// Called by PopUpModalTagList callback when tag selection changes.
  void updateSelectedTagIds(List<int> value) {
    state = state.copyWith(selectedTagIds: value);
  }

  void handleMoveToFolderAction() {
    // Close other overlays and show the move destination picker
    state = state.copyWith(
      showMenuOptions: false,
      showReadingPaneMenuOptions: false,
      showTagList: false,
      showMoveOverlay: true,
    );
  }

  void dismissMoveOverlay() {
    state = state.copyWith(showMoveOverlay: false);
  }

  void handleMoveToSystemFolder(String statusKey) {
    dismissMoveOverlay();

    if (state.selectedEmailIds.isNotEmpty) {
      changeStatusWithUndo(statusKey, state.selectedEmailIds);
    } else if (state.selectedEmailIdForReadingPane != null) {
      changeStatusWithUndo(statusKey, [state.selectedEmailIdForReadingPane!]);
    }
  }

  Future<void> handleMoveToTag(int tagId) async {
    dismissMoveOverlay();

    final ids = state.selectedEmailIds.isNotEmpty
        ? state.selectedEmailIds
        : (state.selectedEmailIdForReadingPane != null
            ? [state.selectedEmailIdForReadingPane!]
            : <int>[]);
    if (ids.isEmpty) return;

    // Step 1: Tag the email(s)
    final emailId = ids.length == 1 ? ids.first : 0;
    await addEmailTags([tagId], emailId, 0, 'add');

    // Step 2: Archive (move out of inbox)
    handleArchive();
  }

  void handleTagAction() {
    // Close menu options
    state = state.copyWith(
      showMenuOptions: false,
      showReadingPaneMenuOptions: false,
      showTagList: false, // Don't show overlay, use popup instead
    );

    List<int> existingTagIds = [];
    final hasListSelection = state.selectedEmailIds.isNotEmpty;
    final hasReadingPaneSelection = state.selectedEmailIdForReadingPane != null;
    final isReadingPaneSelectionOnly =
        hasReadingPaneSelection && !hasListSelection;

    // Prioritize reading pane selection when email is open (similar to archive)
    if (isReadingPaneSelectionOnly) {
      // Compute index from email ID if not already set
      int emailIndex =
          state.selectedEmailIndex ??
          state.items.indexWhere(
            (e) => e.emailId == state.selectedEmailIdForReadingPane,
          );

      if (emailIndex == -1) emailIndex = 0; // Fallback to 0 if not found

      // Get tags for reading pane email
      existingTagIds = getExistingTagIdsForEmail(
        state.selectedEmailIdForReadingPane!,
        emailIndex,
      );
      state = state.copyWith(
        selectedTagIds: existingTagIds,
        showReadingPaneMenuOptions: false,
        selectedEmailIndex: emailIndex,
      );

      // Use post frame callback to ensure state update completes before showing modal
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showList(state.selectedEmailIdForReadingPane!, emailIndex);
      });
    } else if (hasListSelection) {
      if (state.selectedEmailIds.isEmpty) return;
      // For single selection, get existing tags
      if (state.selectedEmailIds.length == 1) {
        existingTagIds = getExistingTagIdsForEmail(
          state.selectedEmailIds.first,
          0,
        );
      }
      state = state.copyWith(selectedTagIds: existingTagIds);
      // Use post frame callback to ensure state update completes before showing modal
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showList(0, 1);
      });
    }
  }

  /// Get current action email senders (for opt-in) - works for both list and reading pane
  List<String> _currentActionEmailSenders() {
    if (state.selectedEmails.isNotEmpty) {
      return List<String>.from(state.selectedEmails);
    }
    if (state.selectedEmailSender != null &&
        state.selectedEmailSender!.isNotEmpty) {
      return [state.selectedEmailSender!];
    }
    return [];
  }

  /// Handle bulk opt-in action - works for both list selection and reading pane selection
  void handleBulkOptInAction() {
    final senders = _currentActionEmailSenders();
    if (senders.isEmpty) return;

    final uniqueEmails = senders.toSet().toList();
    startAddEmailFlow(uniqueEmails);
  }

  /// Reset inbox state to initial state (used during logout)
  /// Remove a globally-deleted tag from every inbox email's in-memory tag list.
  void purgeDeletedTag(int tagId) {
    final updated = state.items.map((email) {
      final filtered = email.emailRecipientTags
          .where((t) => t.tagId != tagId)
          .toList();
      return (filtered.length == email.emailRecipientTags.length)
          ? email
          : email.copyWith(emailRecipientTags: filtered);
    }).toList();
    final updatedTagsItems =
        state.tagsItems.where((t) => t.id != tagId).toList();
    state = state.copyWith(items: updated, tagsItems: updatedTagsItems);
  }

  void reset() {
    _debounce?.cancel();
    _socketDebounce?.cancel();
    _undoTimer?.cancel();
    _inboxMessageSub?.cancel();
    _newMessageSub?.cancel();
    _trashMessageSub?.cancel();
    _undoBuffer.clear();
    _undoIds.clear();
    state = const InboxState();
  }

  List<int> parseIds(dynamic ids, {bool throwIfInvalid = false}) {
    if (ids == null) return [];

    // If single value → wrap into list
    final List<dynamic> rawList = ids is List ? ids : [ids];

    final List<int> result = [];

    for (final value in rawList) {
      if (value == null) continue;

      if (value is int) {
        result.add(value);
      } else if (value is String) {
        final parsed = int.tryParse(value.trim());
        if (parsed != null) {
          result.add(parsed);
        } else if (throwIfInvalid) {
          throw FormatException('Invalid id format: "$value"');
        }
      } else if (throwIfInvalid) {
        throw FormatException('Unsupported id type: ${value.runtimeType}');
      }
    }

    return result;
  }
}

/// Background isolate function for filtering/serializing contacts.
/// Must be top-level (not a class method) for [compute].
/// Mirrors the logic from onboarding.dart's _filterContactsIsolate.
List<Map<String, dynamic>> _filterContactsIsolate(
    List<Map<String, dynamic>> rawContacts) {
  final List<Map<String, dynamic>> filtered = [];

  for (final json in rawContacts) {
    final emails = json['emails'] as List<dynamic>? ?? [];
    if (emails.isEmpty) continue;

    final name = json['name'] as Map<String, dynamic>? ?? {};
    final firstName = ((name['first'] as String?) ?? '').trim();
    final lastName = ((name['last'] as String?) ?? '').trim();
    final hasValidFirstName = firstName.isNotEmpty;

    final orgs = json['organizations'] as List<dynamic>? ?? [];
    final hasValidCompany = orgs.any((o) {
      final orgMap = o as Map<String, dynamic>? ?? {};
      return ((orgMap['company'] as String?) ?? '').trim().isNotEmpty;
    });

    if (!hasValidFirstName && !hasValidCompany) continue;

    final phones = <String>[];
    for (final p in json['phones'] as List<dynamic>? ?? []) {
      final phoneMap = p as Map<String, dynamic>? ?? {};
      final number = (phoneMap['number'] as String?) ?? '';
      if (number.isNotEmpty) phones.add(number);
    }

    final emailList = <String>[];
    for (final e in emails) {
      final emailMap = e as Map<String, dynamic>? ?? {};
      final address = (emailMap['address'] as String?) ?? '';
      if (address.isNotEmpty) emailList.add(address);
    }

    final companyList = <String>[];
    for (final o in orgs) {
      final orgMap = o as Map<String, dynamic>? ?? {};
      final company = ((orgMap['company'] as String?) ?? '').trim();
      if (company.isNotEmpty) companyList.add(company);
    }

    filtered.add({
      'phoneId': json['id'] ?? '',
      'firstName': firstName,
      'lastName': lastName,
      'phones': phones,
      'emails': emailList,
      'company': companyList,
      'data': json,
    });
  }

  return filtered;
}
