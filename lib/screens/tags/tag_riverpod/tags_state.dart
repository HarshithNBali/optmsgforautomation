import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../model/tags_list_model.dart';

part 'tags_state.freezed.dart';

/// Immutable state model for Tags feature using Freezed.
@freezed
abstract class TagsState with _$TagsState {
  const factory TagsState({
    // Data
    TagsListModel? tagsList,
    int? id,

    // Flags
    @Default(false) bool isLoading,
    @Default(false) bool editFlag,

    // Multi-select
    @Default([]) List<int> selectedTagIds,
    @Default(false) bool showCheckboxes,
    @Default(true) bool longPressFlag,
    @Default(false) bool allTagsFlag,
    @Default(-1) int lastClickedIndex,
  }) = _TagsState;

  // Private constructor for adding custom methods
  const TagsState._();

  /// Computed properties for better readability
  bool get hasTagsList => tagsList != null;
  bool get hasTags => tagsList?.data.tags.isNotEmpty ?? false;
  int get tagCount => tagsList?.data.tags.length ?? 0;
  bool get isEditMode => editFlag;
  bool get hasSelectedId => id != null;
  List<Tags> get tags => tagsList?.data.tags ?? [];
  bool get hasSelection => selectedTagIds.isNotEmpty;
  int get selectedCount => selectedTagIds.length;
  bool get isAllSelected => selectedTagIds.length == tags.length && tags.isNotEmpty;
}
