import 'dart:async';

import 'package:optmsg/repositories/notification/notification_api.dart';
import 'package:optmsg/screens/notifications/notification_riverpod/notification_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:optmsg/screens/auth/auth_riverpod/auth_notifier.dart';

import '../../../constant/app_config.dart';
import '../../../model/notification_list_model.dart';
import '../../../services/common_service.dart';
import '../../../services/socket_service.dart';
import '../../../services/storage_service.dart';
import '../../../services/count_notifier.dart';

final notificationProvider =
    NotifierProvider<NotificationNotifier, NotificationState>(
      NotificationNotifier.new,
    );

class NotificationNotifier extends Notifier<NotificationState> {
  StreamSubscription? _unReadCountSub;
  StreamSubscription? _notificationSub;
  bool _disposed = false;
  bool _isFetching = false;

  final SecureStorageService secureStorageService = SecureStorageService();

  @override
  NotificationState build() {
    _disposed = false;
    _isFetching = false;
    ref.onDispose(() {
      _disposed = true;
      _isFetching = false;
      _unReadCountSub?.cancel();
      _notificationSub?.cancel();
    });
    _setupListeners();
    return const NotificationState();
  }

  Map? userData;
  String? token;

  Future<void> getUserData() async {
    userData = ref.read(authProvider).userData;
    token = userData?['token'];
  }

  Future<void> _setupListeners() async {
    await getUserData();
    if (userData?['user']?['id'] == null) return;

    final userId = userData!['user']['id'];

    SocketService().emitEventWithAck(
      "notificationExists",
      {"userId": userId},
      ackCallback: (data) {
        if (_disposed) return;
        if (data != null) {
          state = state.copyWith(newNotification: data);
          ref
              .read(countProvider.notifier)
              .updateNotificationStatus(data.toString());
        }
      },
    );

    _unReadCountSub = SocketService()
        .onEvent('unReadCount')
        .listen(_updateUnreadCount);

    _notificationSub = SocketService().onEvent('notificationExists').listen((
      data,
    ) {
      if (_disposed) return;
      state = state.copyWith(newNotification: data);
      ref
          .read(countProvider.notifier)
          .updateNotificationStatus(data.toString());
    });
  }

  void _updateUnreadCount(dynamic data) {
    if (_disposed) return;
    if (data == null) return;

    state = state.copyWith(
      inboxCount: data['inboxCount'] ?? 0,
      trashCount: data['trashCount'] ?? 0,
      draftCount: data['draftCount'] ?? 0,
      archiveCount: data['archiveCount'] ?? 0,
    );
  }

  // ────────────────── Selection ──────────────────

  void toggleSelectFromList(int id) {
    final ids = [...state.selectedNotificationIds];

    if (ids.contains(id)) {
      ids.remove(id);
    } else {
      ids.add(id);
    }

    state = state.copyWith(
      selectedNotificationIds: ids,
      allNotificationIdsFlag: ids.length == state.items.length,
      longPressFlag: ids.isEmpty,
      showCheckboxes: ids.isEmpty ? false : state.showCheckboxes,
    );
  }

  void selectAllFromList() {
    final ids = state.items.map((e) => e.id).toList();

    state = state.copyWith(
      selectedNotificationIds: ids,
      allNotificationIdsFlag: true,
      longPressFlag: false,
    );
  }

  void clearSelection() {
    state = state.copyWith(
      selectedNotificationIds: <int>[],
      allNotificationIdsFlag: false,
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

    final ids = {...state.selectedNotificationIds};

    for (int i = lo; i <= hi; i++) {
      ids.add(items[i].id);
    }

    state = state.copyWith(
      selectedNotificationIds: ids.toList(),
      allNotificationIdsFlag: ids.length == items.length,
      longPressFlag: false,
      showCheckboxes: true,
      lastClickedIndex: toIndex.clamp(0, items.length - 1),
    );
  }

  void toggleSingleSelectByIndex(int index) {
    final items = state.items;
    if (index < 0 || index >= items.length) return;
    final item = items[index];
    final ids = [...state.selectedNotificationIds];

    if (ids.contains(item.id)) {
      ids.remove(item.id);
    } else {
      ids.add(item.id);
    }

    state = state.copyWith(
      selectedNotificationIds: ids,
      allNotificationIdsFlag: ids.length == items.length,
      longPressFlag: ids.isEmpty,
      showCheckboxes: ids.length > 1 ? true : state.showCheckboxes,
      lastClickedIndex: index,
    );
  }

  void setShowCheckboxes(bool v) =>
      state = state.copyWith(showCheckboxes: v);

  // ────────────────── Selection State Query ──────────────────

  String getSelectionState() {
    if (state.selectedNotificationIds.isEmpty) return 'none';

    List<bool> statuses = [];
    for (final id in state.selectedNotificationIds) {
      final idx = state.items.indexWhere((e) => e.id == id);
      if (idx != -1) {
        statuses.add(state.items[idx].isRead ?? false);
      }
    }

    if (statuses.isEmpty) return 'none';

    if (state.selectedNotificationIds.length == 1) {
      return statuses.first ? 'singleRead' : 'singleUnread';
    }

    final allRead = statuses.every((s) => s == true);
    final allUnread = statuses.every((s) => s == false);

    if (allRead) return 'allRead';
    if (allUnread) return 'allUnread';
    return 'mixed';
  }

  // ────────────────── Bulk Actions ──────────────────

  Future<void> bulkDelete() async {
    final idsToDelete = [...state.selectedNotificationIds];
    if (idsToDelete.isEmpty) return;

    // Optimistic: remove from list
    final updated =
        state.items.where((i) => !idsToDelete.contains(i.id)).toList();
    state = state.copyWith(items: updated);
    clearSelection();
    _syncCounts(updated);

    // Fire all API calls in parallel
    await Future.wait(
      idsToDelete
          .map((id) => NotificationApi().notificationDelete({'id': id})),
    );
  }

  Future<void> bulkMarkAsRead() async {
    final ids = [...state.selectedNotificationIds];
    if (ids.isEmpty) return;

    // Optimistic update
    final updatedItems = state.items.map((item) {
      if (ids.contains(item.id) && !(item.isRead ?? false)) {
        return item.copyWith(isRead: true);
      }
      return item;
    }).toList();

    state = state.copyWith(items: updatedItems);
    clearSelection();
    _syncCounts(updatedItems);

    // Fire API calls for items that were unread
    final unreadIds = state.items
        .where((i) => ids.contains(i.id) && !(i.isRead ?? false))
        .map((i) => i.id)
        .toList();

    if (unreadIds.isNotEmpty) {
      await Future.wait(
        unreadIds.map(
            (id) => NotificationApi().notificationRead({'id': id, 'isRead': true})),
      );
    }
  }

  Future<void> bulkMarkAsUnread() async {
    final ids = [...state.selectedNotificationIds];
    if (ids.isEmpty) return;

    // Optimistic update
    final updatedItems = state.items.map((item) {
      if (ids.contains(item.id) && (item.isRead ?? false)) {
        return item.copyWith(isRead: false);
      }
      return item;
    }).toList();

    state = state.copyWith(items: updatedItems);
    clearSelection();
    _syncCounts(updatedItems);

    // Fire API calls for items that were read
    final readIds = state.items
        .where((i) => ids.contains(i.id) && (i.isRead ?? false))
        .map((i) => i.id)
        .toList();

    if (readIds.isNotEmpty) {
      await Future.wait(
        readIds.map(
            (id) => NotificationApi().notificationRead({'id': id, 'isRead': false})),
      );
    }
  }

  void handleBulkMarkAction() {
    final selState = getSelectionState();
    if (selState == 'singleUnread' || selState == 'allUnread') {
      bulkMarkAsRead();
    } else {
      bulkMarkAsUnread();
    }
  }

  void _syncCounts(List<Notifications> items) {
    final isNewNotif = isNew(items);
    final unreadNotifCount = items.where((e) => e.isRead == false).length;
    state = state.copyWith(isNewNotification: isNewNotif);
    ref
        .read(countProvider.notifier)
        .updateNotificationStatus(isNewNotif ? 'yes' : 'no');
    ref
        .read(countProvider.notifier)
        .updateUnreadNotificationCount(unreadNotifCount);
  }

  // ────────────────── API ──────────────────

  Future<void> fetchNotifications({bool refresh = false}) async {
    if (_isFetching) return;
    if (!refresh && !state.hasMore) return;

    _isFetching = true;

    if (refresh) {
      state = state.copyWith(currentPage: 1, items: [], hasMore: true);
    }

    state = state.copyWith(isLoading: true);

    try {
      final response = await NotificationApi().getNotification({
        "page": state.currentPage,
        "limit": itemCount,
      });

      if (response.data == null) {
        state = state.copyWith(isLoading: false);
        return;
      }
      final model = NotificationListModel.fromJson(response.data!);

      if (model.success != true) {
        state = state.copyWith(isLoading: false);
        return;
      }

      final newItems = model.data.notifications;

      final updatedItems = [...state.items, ...newItems];

      final isNewNotif = isNew(updatedItems);
      final unreadNotifCount = updatedItems
          .where((e) => e.isRead == false)
          .length;
      state = state.copyWith(
        items: updatedItems,
        currentPage: state.currentPage + 1,
        isLoading: false,
        hasMore: newItems.length == itemCount,
        isNewNotification: isNewNotif,
      );
      ref
          .read(countProvider.notifier)
          .updateNotificationStatus(isNewNotif ? 'yes' : 'no');
      ref
          .read(countProvider.notifier)
          .updateUnreadNotificationCount(unreadNotifCount);
    } catch (e) {
      state = state.copyWith(isLoading: false);
    } finally {
      _isFetching = false;
    }
  }

  Future<void> deleteNotification(int id, int index) async {
    final updated = [...state.items]..removeAt(index);
    _syncCounts(updated);
    state = state.copyWith(items: updated);

    final response = await NotificationApi().notificationDelete({'id': id});
    final resp = response.data ?? {};

    CommonService.animatedToast(
      resp['message'],
      resp['success'] ? 'success' : 'error',
    );
  }

  Future<void> toggleRead(int id, int index) async {
    if (index < 0 || index >= state.items.length) return;
    final item = state.items[index];

    try {
      final response = await NotificationApi().notificationRead({
        'id': id,
        'isRead': !item.isRead!,
      });
      final resp = response.data ?? {};

      if (resp['success']) {
        final updatedItem = item.copyWith(isRead: !(item.isRead ?? false));
        final updatedItems = [
          ...state.items.sublist(0, index),
          updatedItem,
          ...state.items.sublist(index + 1),
        ];
        _syncCounts(updatedItems);
        state = state.copyWith(items: updatedItems);
      }
    } catch (_) {
      // API error — no state change needed
    }
  }

  bool isNew(List<Notifications> list) {
    return list.any((e) => e.isRead == false);
  }
}
