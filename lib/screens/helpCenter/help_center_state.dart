import 'package:freezed_annotation/freezed_annotation.dart';

part 'help_center_state.freezed.dart';

/// Immutable state model for Help Center feature using Freezed.
@freezed
abstract class HelpCenterState with _$HelpCenterState {
  const factory HelpCenterState({
    // Flags
    @Default(false) bool isLoading,
    
    // UI State
    @Default('') String selectedCategory,
    @Default('') String searchQuery,
    @Default([]) List<String> expandedItems,
  }) = _HelpCenterState;

  // Private constructor for adding custom methods
  const HelpCenterState._();

  /// Computed properties for better readability
  bool get hasSearchQuery => searchQuery.isNotEmpty;
  bool get hasExpandedItems => expandedItems.isNotEmpty;
  bool get hasSelectedCategory => selectedCategory.isNotEmpty;
}
