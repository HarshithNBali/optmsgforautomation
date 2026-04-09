import 'package:app_badge_plus/app_badge_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'count_notifier.freezed.dart';

// State class
@freezed
abstract class CountState with _$CountState {
  const factory CountState({
    @Default(0) int inboxCount,
    @Default(0) int draftCount,
    @Default(0) int archiveCount,
    @Default(0) int trashCount,
    @Default(false) bool isUpdateDialogVisible,
    @Default(false) bool isUpdatePopUpDismiss,
    @Default("no") String newNotification,
  }) = _CountState;
}

// Notifier
class CountNotifier extends Notifier<CountState> {
  // Tracks the actual unread notification count for badge computation.
  // Not part of Freezed state because it's only needed for the OS badge.
  int _unreadNotificationCount = 0;

  @override
  CountState build() => const CountState();

  void updateCounts({
    required int inbox,
    required int draft,
    required int archive,
    required int trash,
  }) {
    state = state.copyWith(
      inboxCount: inbox.toInt(),
      draftCount: draft.toInt(),
      archiveCount: archive.toInt(),
      trashCount: trash.toInt(),
    );
    _updateBadge();
  }

  void updateUpdateDialogState() {
    state = state.copyWith(isUpdateDialogVisible: true);
  }

  void updatePopUpDismissState() {
    state = state.copyWith(isUpdatePopUpDismiss: true);
  }

  void updateNotificationStatus(String status) {
    if (status == 'no') {
      _unreadNotificationCount = 0;
    }
    state = state.copyWith(newNotification: status);
    _updateBadge();
  }

  /// Call this whenever the exact unread notification count is known
  /// (e.g. after fetching the notification list).
  void updateUnreadNotificationCount(int count) {
    _unreadNotificationCount = count;
    _updateBadge();
  }

  void _updateBadge() async {
    if (!kIsWeb && await AppBadgePlus.isSupported()) {
      final total = state.inboxCount + _unreadNotificationCount;
      AppBadgePlus.updateBadge(total).catchError((_) {});
    }
  }
}

// Provider
final countProvider = NotifierProvider<CountNotifier, CountState>(
  () => CountNotifier(),
);
