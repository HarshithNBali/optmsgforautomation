import 'package:freezed_annotation/freezed_annotation.dart';

part 'bottom_nav_state.freezed.dart';

@freezed
abstract class BottomNavState with _$BottomNavState {
  const factory BottomNavState({
    @Default(0) int currentIndex,
    @Default(true) bool showBottomNavBar,
    @Default(0) int inboxCount,
    @Default(0) int trashCount,
    @Default(0) int draftCount,
    @Default(0) int archiveCount,
    Map<String, dynamic>? userData,
    @Default(false) bool loading,
    @Default(false) bool initialized,
    String? lastRoute,
  }) = _BottomNavState;
}
