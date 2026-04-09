import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../model/inbox_list_model.dart';
import '../../../model/tags_list_model.dart';

part 'inbox_state.freezed.dart';

/// Immutable state model for inbox list using Freezed.
///
/// This replaces the manual copyWith implementation with Freezed's
/// code generation for compile-time safety and less boilerplate.
@freezed
abstract class InboxState with _$InboxState {
  const factory InboxState({
    // Flags
    @Default(true) bool isLoading,
    @Default(false) bool isFetching,
    @Default(false) bool isSearch,
    @Default(false) bool showFilter,
    @Default(false) bool showTagList,
    @Default(false) bool isTagListForFilter, // New flag to distinguish filter vs apply
    @Default(true) bool longPressFlag,
    @Default(false) bool allEmailIdsFlag,
    @Default(false) bool tagFilter,
    @Default(true) bool allEmailsTrue,
    @Default(false) bool showMenuOptions,
    @Default(false) bool showMoveOverlay,
    @Default(true) bool readingPaneEnabled,
    @Default(false) bool showReadingPaneMenuOptions,
    @Default(false) bool showCheckboxes,
    @Default(false) bool isComposeHovered,
    @Default(true) bool syncContact,
    @Default(false) bool isInProcess,
    @Default(true) bool readingPaneEnabledWeb,

    // Paging / Search / Filter
    @Default(0) int previousPage,
    @Default(1) int currentPage,
    @Default('') String searchKey,
    @Default([]) List<int> selectedEmailIds,
    @Default([]) List<String> selectedEmails,
    @Default(-1) int lastClickedIndex,
    @Default(0) int badgeCount,
    @Default('inbox') String? emailType,
    @Default('') String token,
    InboxListModel? inboxList,
    @Default([]) List<int> tagIdFilter,
    @Default(0) int totalEmailCount,
    @Default([]) List<int> selectedTagIds,

    // Reading Pane
    int? selectedEmailIdForReadingPane,
    // Compose in reading pane (when set, shows compose instead of email detail)
    Map<String, dynamic>? composeInReadingPane,
    TagsListModel? selectedEmailTags,
    int? selectedEmailIndex,
    String? selectedEmailSender,
    @Default(0) int readingPaneRefreshKey,
    int? currentlyViewedEmailId,
    double? emailListPaneWidth,
    double? readingPaneHeight,

    // Data
    @Default([]) List<Emails> items,
    Map<String, dynamic>? userData,

    // Undo
    @Default([]) List<Emails> undoBuffer,
    @Default([]) List<int> undoIds,

    // Notification
    @Default(false) bool newNotification,
    String? pendingOptInEmail,
    String? pendingOptInSenderName,
    @Default([]) List<String> pendingOptInEmails,

    // Tags
    @Default([]) List<Tags> tagsItems,
    @Default(false) bool showTagDialog,
    @Default(0) int tagDialogEmailId,
    @Default(0) int tagDialogItemIndex,
    @Default(false) bool tagDialogIsMove,
    @Default([]) List<int> tagDialogInitialTagIds,

    // Error
    String? errorMessage,
  }) = _InboxState;

  // Private constructor for adding custom methods
  const InboxState._();

  /// Computed properties for better readability
  bool get hasEmails => items.isNotEmpty;
  bool get hasSelection => selectedEmailIds.isNotEmpty;
  bool get canLoadMore => inboxList?.data?.nextPage ?? false;
  int get selectedCount => selectedEmailIds.length;
  bool get isAllSelected => selectedEmailIds.length == items.length && items.isNotEmpty;
  bool get hasActiveFilters => tagIdFilter.isNotEmpty || searchKey.isNotEmpty;
  bool get isReadingPaneActive => selectedEmailIdForReadingPane != null;
}
