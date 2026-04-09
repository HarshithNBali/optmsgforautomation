import 'dart:async';

import 'package:descope/descope.dart';
import 'package:optmsg/common/responsive/breakpoints.dart';
import 'package:optmsg/repositories/email/draft_api.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../constant/app_config.dart';
import '../../../constant/string_constant.dart';
import '../../../model/draft_list_modal.dart';
import '../../../services/common_service.dart';
import '../../../services/count_notifier.dart';
import '../../../services/socket_service.dart';
import '../../../services/storage_service.dart';
import 'draft_state.dart';
import 'package:go_router/go_router.dart';
import '../../../router/app_router.dart' show rootNavigatorKey;
import '../../../router/app_routes.dart';
import '../../auth/auth_riverpod/auth_notifier.dart';
import '../../settings/setting_riverpod/settings_notifier.dart';

final draftProvider = NotifierProvider<DraftNotifier, DraftState>(
  DraftNotifier.new,
);

class DraftNotifier extends Notifier<DraftState> {
  bool _disposed = false;

  // DI: read from providers on demand rather than late fields,
  // so fake notifiers in tests don't crash on uninitialized fields.
  SecureStorageService get _storage => ref.read(storageServiceProvider);
  SocketService get _socket => ref.read(socketServiceProvider);
  DraftApi get _draftApi => ref.read(draftApiProvider);

  @override
  DraftState build() {
    _disposed = false;
    ref.onDispose(() {
      _disposed = true;
      _notificationSub?.cancel();
      _draftMessageSub?.cancel();
      _unReadCountSub?.cancel();
      _debounce?.cancel();
    });
    return const DraftState();
  }
  StreamSubscription? _notificationSub;
  StreamSubscription? _draftMessageSub;
  StreamSubscription? _unReadCountSub;
  Timer? _debounce;

  // ------------------------------------------------
  // INIT
  // ------------------------------------------------

  Future<void> bootstrap({int? emailIdToRestore}) async {
    // Mark as loading immediately so the empty-state widget never flashes
    // while the async chain (_manageComposeFlag → _getUserData → getAllEmails) runs.
    state = state.copyWith(isLoading: true, items: []);
    await _manageComposeFlag();
    await _getUserData();
    await setupListeners();

    if (emailIdToRestore != null) {
      state = state.copyWith(selectedEmailIdForReadingPane: emailIdToRestore);
    }

    await getAllEmails('');
  }

  Future<void> _manageComposeFlag() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('inCompose', false);
  }

  Future<void> _getUserData() async {
    // Try storage first; fall back to in-memory AuthState if a background
    // clearAllData() wiped storage (race between logout cleanup and re-login).
    final data = ref.read(authProvider).userData;

    // Read reading pane from settings provider (avoids storage race after toggle).
    // Fall back to storage on cold boot when settings hasn't loaded yet.
    final sState = ref.read(settingsProvider);
    final bool readingPaneEnabled;
    if (sState.hasUserData) {
      readingPaneEnabled = sState.readingPaneEnabled;
    } else {
      final readingPane = await _storage.readData('readingPaneEnabled');
      readingPaneEnabled = readingPane == null ? true : readingPane == 'true';
    }

    state = state.copyWith(
      userData: data,
      token: data?['token'] ?? '',
      // Enable reading pane for web and native tablets (tablets will show it in landscape)
      readingPaneEnabled:
          readingPaneEnabled && (kIsWeb || AppBreakpoints.isPhysicalTablet),
    );
  }

  // ------------------------------------------------
  // SOCKET / NOTIFICATION
  // ------------------------------------------------

  Future<void> setupListeners() async {
    try {
      final userId = state.userData?['user']?['id'];
      if (userId == null) return;

      // Badge count
      _socket.emitEventWithAck(
        'unReadCount',
        {"userId": userId},
        ackCallback: (data) {
          if (data != null && kIsWeb) {
            ref.read(countProvider.notifier).updateCounts(
                  inbox: data['inboxCount'] ?? 0,
                  draft: data['draftCount'] ?? 0,
                  trash: data['trashCount'] ?? 0,
                  archive: data['archiveCount'] ?? 0,
                );
          }
        },
      );

      // Initial notification state
      _socket.emitEventWithAck(
        "notificationExists",
        {"userId": userId},
        ackCallback: (data) {
          final hasNotification = data != null && data != 'no' && data != false;
          state = state.copyWith(newNotification: hasNotification);
          // Sync with centralized countProvider
          ref
              .read(countProvider.notifier)
              .updateNotificationStatus(data.toString());
        },
      );

      // Live updates for notifications
      _notificationSub?.cancel();
      _notificationSub =
          _socket.onEvent('notificationExists').listen((data) {
        final hasNotification = data != null && data != 'no' && data != false;
        if (!_disposed) state = state.copyWith(newNotification: hasNotification);
        // Sync with centralized countProvider
        ref
            .read(countProvider.notifier)
            .updateNotificationStatus(data.toString());
      });

      // Listen for draft updates (when draft is saved/updated from compose)
      _draftMessageSub?.cancel();
      _draftMessageSub =
          _socket.onEvent('draftMessage').listen((data) {
        if (_disposed) return;
        // Refresh drafts list when a new draft is saved or updated
        // Skip refresh if already fetching to avoid race conditions
        if (!state.isFetching && !state.isLoading) {
          getAllEmails(state.searchKey, isRefresh: true);
        }
      });

      // Also listen for unReadCount which is emitted after draft save
      // This ensures the list updates even if draftMessage isn't emitted
      _unReadCountSub?.cancel();
      _unReadCountSub = _socket.onEvent('unReadCount').listen((data) {
        if (_disposed) return;
        if (data != null && kIsWeb) {
          // Update counts
          ref.read(countProvider.notifier).updateCounts(
                inbox: data['inboxCount'] ?? 0,
                draft: data['draftCount'] ?? 0,
                trash: data['trashCount'] ?? 0,
                archive: data['archiveCount'] ?? 0,
              );
        }
      });
    } catch (e) {
      // Draft socket error
    }
  }

  void updateNotificationFlag(bool flag) {
    state = state.copyWith(newNotification: flag);
    // Sync with centralized countProvider
    ref
        .read(countProvider.notifier)
        .updateNotificationStatus(flag ? 'yes' : 'no');
  }

  // ------------------------------------------------
  // SELECTION
  // ------------------------------------------------

  void toggleSelect(int id, String email) {
    final ids = [...state.selectedEmailIds];
    final mails = [...state.selectedEmails];

    if (ids.contains(id)) {
      ids.remove(id);
      mails.remove(email);
    } else {
      ids.add(id);
      mails.add(email);
    }

    state = state.copyWith(
      selectedEmailIds: ids,
      selectedEmails: mails,
      allEmailIdsFlag: ids.length == state.items.length,
      longPressFlag: false,
    );
  }

  /// Toggle selection from list (for long press on email item)
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

  void clearSelection() {
    state = state.copyWith(
      selectedEmailIds: [],
      selectedEmails: [],
      allEmailIdsFlag: false,
      longPressFlag: true,
      showCheckboxes: false,
      lastClickedIndex: -1,
    );
  }

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
      ids.add(items[i].id);
      emails.add('');
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

  void toggleSingleSelectByIndex(int index) {
    final items = state.items;
    if (index < 0 || index >= items.length) return;
    final item = items[index];
    final ids = [...state.selectedEmailIds];
    final emails = [...state.selectedEmails];

    if (ids.contains(item.id)) {
      ids.remove(item.id);
      emails.remove('');
    } else {
      ids.add(item.id);
      emails.add('');
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

  /// Set selected emails from list (used by CustomDismissible checkbox selection)
  void setSelectedFromList(List<int> ids, List<String> mails) {
    state = state.copyWith(
      selectedEmailIds: ids,
      selectedEmails: mails,
      allEmailIdsFlag: ids.length == state.items.length,
      longPressFlag: ids.isEmpty,
      showCheckboxes: ids.isEmpty ? false : state.showCheckboxes,
    );
  }

  void selectAllFromList() {
    final ids = state.items.map((e) => e.id).toList();

    state = state.copyWith(
      selectedEmailIds: ids,
      allEmailIdsFlag: true,
      longPressFlag: false,
      totalEmailCount: ids.length,
    );
  }

  void onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 800), () {
      state = state.copyWith(
        searchKey: value,
        currentPage: 1,
        previousPage: 0,
      );
      getAllEmails(value);
    });
  }

  void toggleSearch() {
    state = state.copyWith(isSearch: !state.isSearch);
  }

  void clearOverlayStates() {
    state = state.copyWith(
      isSearch: false,
      searchKey: '',
      // Reset checkbox state when navigating between folders
      showCheckboxes: false,
      selectedEmailIds: <int>[],
      selectedEmails: <String>[],
      allEmailIdsFlag: false,
    );
  }

  // ------------------------------------------------
  // VIEW DETAIL
  // ------------------------------------------------

  void setCurrentlyViewed(int id, int index) {
    state = state.copyWith(
      currentlyViewedEmailId: id,
      selectedEmailIdForReadingPane: id,
      selectedEmailIndex: index,
      lastClickedIndex: index,
    );
  }

  Future<void> getAllEmails(
    String search, {
    bool isRefresh = false,
  }) async {
    if (state.isFetching) return;

    state = state.copyWith(
      isFetching: true,
      isLoading: state.currentPage == 1 && !isRefresh,
    );

    try {
      final resp = await _draftApi.getDraftEmail({
        "page": state.currentPage,
        "limit": itemCount,
        "search": search,
      });
      if (_disposed) return;
      if (resp.data!['success'] != true) {
        CommonService.animatedToast(
            resp.data!['message'] ?? 'Something went wrong',
            'error',
            null,
            true);
        state = state.copyWith(
          isLoading: false,
          isFetching: false,
        );
        return;
      }
      final model = DraftListModel.fromJson(resp.data!);

      final emails = state.currentPage > 1
          ? [...state.items, ...model.data.emails]
          : model.data.emails;

      state = state.copyWith(
        draftList: model,
        items: emails,
        previousPage: state.currentPage,
        currentPage: model.data.nextPage == true
            ? state.currentPage + 1
            : state.currentPage,
        totalEmailCount: emails.length,
        isLoading: false,
        isFetching: false,
        selectedEmailIds: [],
        allEmailIdsFlag: false,
      );
    } catch (_) {
      if (_disposed) return;
      state = state.copyWith(
        isLoading: false,
        isFetching: false,
      );
    }
  }

  Future<void> deleteDrafts(List ids) async {
    final response = await _draftApi.deleteDraft({"draftIds": ids});
    if (_disposed) return;
    Map<String, dynamic>? resp = response.data;
    if (resp!['success']) {
      final userId = state.userData?['user']?['id'];
      _socket.emitEventWithAck('unReadCount', {"userId": userId},
          ackCallback: (data) {
        if (data != null) {
          ref.read(countProvider.notifier).updateCounts(
              inbox: data['inboxCount'] ?? 0,
              draft: data['draftCount'] ?? 0,
              trash: data['trashCount'] ?? 0,
              archive: data['archiveCount'] ?? 0);
        }
      });
    } else {
      CommonService.animatedToast(resp['message'], 'error', null, true);
    }

    final filtered = state.items.where((e) => !ids.contains(e.id)).toList();

    state = state.copyWith(
      items: filtered,
      selectedEmailIds: [],
      allEmailIdsFlag: false,
    );
  }

  void setCheckboxVisibility(bool v) =>
      state = state.copyWith(showCheckboxes: v);

  void setComposeHovered(bool v) => state = state.copyWith(isComposeHovered: v);
  Future<void> gotoViewDetail(int id) async {
    setCurrentlyViewedEmailId(id);
    final int pageId = DateTime.now().microsecondsSinceEpoch;
    final DateTime now = DateTime.now();
    final int offsetInMinutes = now.timeZoneOffset.inMinutes;

    final result = await rootNavigatorKey.currentContext!.push<String?>(
      AppRoutes.compose,
      extra: {
        'url': '${defaultBaseUrl}email/compose?emailId=$id'
            '&type=draft'
            '&pageId=$pageId'
            '&timeZone=$offsetInMinutes',
        'token': Descope.sessionManager.session?.sessionJwt ?? state.token,
        'type': 'updateDraft',
        'emailId': id,
        'pageId': pageId,
        'sourcePage': AppRoutes.drafts,
      },
    );

    // Refresh drafts list if a draft was saved or deleted
    if (result == 'draftSaved' || result == 'draftDeleted') {
      await getAllEmails(state.searchKey, isRefresh: true);
    }
  }

  void setCurrentlyViewedEmailId(int id) {
    final idx = state.items.indexWhere((e) => e.id == id);
    state = state.copyWith(
      currentlyViewedEmailId: id,
      lastClickedIndex: idx >= 0 ? idx : state.lastClickedIndex,
    );
  }

  void setSelectedEmailIdForReadingPane(int? id) {
    state = state.copyWith(selectedEmailIdForReadingPane: id);
  }

  void setEmailListPaneWidth(double width) {
    state = state.copyWith(emailListPaneWidth: width);
  }

  void updateReadingPaneSettings(bool enabled) {
    if (!enabled) {
      // Clear selection when turning reading pane OFF
      state = state.copyWith(
        readingPaneEnabled: false,
        selectedEmailIdForReadingPane: null,
        selectedEmailIndex: null,
      );
    } else {
      state = state.copyWith(readingPaneEnabled: true);
    }
  }

  Future<void> gotoCompose() async {
    // Free user check
    final userData = state.userData;
    if (userData == null || userData['user']['isFreeUser'] == true) {
      CommonService.animatedToast(freeUserWarning, 'warning', null, true);
      return;
    }

    final int pageId = DateTime.now().microsecondsSinceEpoch;
    final DateTime now = DateTime.now();
    final int offsetInMinutes = now.timeZoneOffset.inMinutes;

    final result = await rootNavigatorKey.currentContext!.push<String?>(
      AppRoutes.compose,
      extra: {
        'url': '${defaultBaseUrl}email/compose'
            '?pageId=$pageId'
            '&timeZone=$offsetInMinutes',
        'token': Descope.sessionManager.session?.sessionJwt ?? state.token,
        'type': 'compose',
        'pageId': pageId,
        'sourcePage': AppRoutes.drafts,
      },
    );

    // Refresh drafts list if a draft was saved
    if (result == 'draftSaved') {
      await getAllEmails(state.searchKey, isRefresh: true);
    }
  }

  // ------------------------------------------------
  // CLEANUP
  // ------------------------------------------------

  /// Reset draft state to initial state (used during logout)
  void reset() {
    _notificationSub?.cancel();
    _draftMessageSub?.cancel();
    _unReadCountSub?.cancel();
    state = const DraftState();
  }

  /// Refresh the drafts list (can be called externally)
  Future<void> refresh() async {
    // Prevent multiple concurrent refreshes
    if (state.isFetching) return;

    state = state.copyWith(
      currentPage: 1,
      previousPage: 0,
    );
    await getAllEmails(state.searchKey, isRefresh: true);
  }
}
