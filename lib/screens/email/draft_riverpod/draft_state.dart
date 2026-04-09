import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../model/draft_list_modal.dart';

part 'draft_state.freezed.dart';

/// Immutable state model for Draft feature using Freezed.
@freezed
abstract class DraftState with _$DraftState {
  const factory DraftState({
    // Flags
    @Default(false) bool isLoading,
    @Default(false) bool isFetching,
    @Default(false) bool isSearch,
    @Default(true) bool longPressFlag,
    @Default(false) bool allEmailIdsFlag,
    @Default(false) bool showCheckboxes,
    @Default(false) bool isComposeHovered,

    // Lists / data
    @Default([]) List<Emails> items,
    @Default([]) List<int> selectedEmailIds,
    @Default([]) List<String> selectedEmails,
    @Default(-1) int lastClickedIndex,

    // Pagination
    @Default(0) int previousPage,
    @Default(1) int currentPage,
    @Default('') String searchKey,
    @Default(0) int totalEmailCount,
    @Default('draft') String? emailType,

    // Reading pane
    @Default(false) bool readingPaneEnabled,
    int? selectedEmailIdForReadingPane,
    int? selectedEmailIndex,
    int? currentlyViewedEmailId,
    double? emailListPaneWidth,

    // API models
    DraftListModel? draftList,

    // User data
    Map<String, dynamic>? userData,
    @Default('') String token,

    // Notifications
    @Default(false) bool newNotification,
  }) = _DraftState;

  // Private constructor for adding custom methods
  const DraftState._();

  /// Computed properties for better readability
  bool get hasEmails => items.isNotEmpty;
  bool get hasSelection => selectedEmailIds.isNotEmpty;
  bool get canLoadMore => draftList?.data.nextPage ?? false;
  int get selectedCount => selectedEmailIds.length;
  bool get isAllSelected => selectedEmailIds.length == items.length && items.isNotEmpty;
  bool get isReadingPaneActive => selectedEmailIdForReadingPane != null;
}
