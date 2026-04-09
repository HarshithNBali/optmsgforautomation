import '../../../model/sent_list_model.dart';
import '../../../model/tags_list_model.dart';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'archive_state.freezed.dart';

@freezed
abstract class ArchiveState with _$ArchiveState {
  const factory ArchiveState({
    // Flags
    @Default(false) bool isLoading,
    @Default(false) bool isFetching,
    @Default(false) bool isSearch,
    @Default(false) bool showFilter,
    @Default(false) bool showTagList,
    @Default(true) bool longPressFlag,
    @Default(false) bool allEmailIdsFlag,
    @Default(false) bool tagFilter,
    @Default(false) bool showCheckboxes,
    @Default(false) bool showMenuOptions,
    @Default(false) bool showMoveOverlay,
    @Default(true) bool readingPaneEnabled,
    @Default(false) bool showReadingPaneMenuOptions,
    @Default(true) bool allEmailsTrue,
    @Default(false) bool isInProcess,

    // Lists / data
    @Default([]) List<Emails> items,
    @Default([]) List<int> selectedEmailIds,
    @Default([]) List<String> selectedEmails,
    @Default(-1) int lastClickedIndex,
    @Default([]) List<int> tagIdFilter,
    @Default([]) List<int> selectedTagIds,

    // Pagination
    @Default(0) int previousPage,
    @Default(1) int currentPage,
    @Default(0) int totalEmailCount,
    @Default(-1) int selectedIndex,

    // Filters / search
    @Default('') String searchKey,
    String? emailType,
    String? currentPath,
    @Default('') String communityEmail,

    // Reading pane
    int? selectedEmailIdForReadingPane,
    TagsListModel? selectedEmailTags,
    int? selectedEmailIndex,
    String? selectedEmailSender,
    @Default(0) int readingPaneRefreshKey,
    double? emailListPaneWidth,
    // API models
    SentListModel? inboxList,
    @Default(false) bool isComposeHovered,
    // Notification
    @Default(false) bool newNotification,
  }) = _ArchiveState;

  const ArchiveState._();
  bool get hasEmails => items.isNotEmpty;
  bool get hasSelection => selectedEmailIds.isNotEmpty;
  int get selectedCount => selectedEmailIds.length;
  bool get isAllSelected => selectedEmailIds.length == items.length && items.isNotEmpty;
}
