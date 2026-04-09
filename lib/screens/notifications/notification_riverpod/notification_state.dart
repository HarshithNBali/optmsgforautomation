
import '../../../model/notification_list_model.dart';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification_state.freezed.dart';

@freezed
abstract class NotificationState with _$NotificationState {
  const factory NotificationState({
    @Default([]) List<Notifications> items,
    @Default(false) bool isLoading,
    @Default(1) int currentPage,
    @Default(true) bool hasMore,
    @Default(0) int inboxCount,
    @Default(0) int draftCount,
    @Default(0) int trashCount,
    @Default(0) int archiveCount,
    @Default("no") String newNotification,
    @Default(false) bool isNewNotification,

    // Multi-select
    @Default([]) List<int> selectedNotificationIds,
    @Default(true) bool longPressFlag,
    @Default(false) bool allNotificationIdsFlag,
    @Default(false) bool showCheckboxes,
    @Default(-1) int lastClickedIndex,
  }) = _NotificationState;

  const NotificationState._();

  bool get hasSelection => selectedNotificationIds.isNotEmpty;
  int get selectedCount => selectedNotificationIds.length;
  bool get isAllSelected =>
      selectedNotificationIds.length == items.length && items.isNotEmpty;
}
