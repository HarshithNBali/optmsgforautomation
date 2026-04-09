import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../model/profile_model.dart';

part 'profile_state.freezed.dart';

/// Immutable state model for Profile feature using Freezed.
@freezed
abstract class ProfileState with _$ProfileState {
  const factory ProfileState({
    // Flags
    @Default(false) bool isLoading,
    @Default(false) bool isEdit,
    
    // Data
    MyProfile? profile,
  }) = _ProfileState;

  // Private constructor for adding custom methods
  const ProfileState._();

  /// Computed properties for better readability
  bool get hasProfile => profile != null;
  bool get isEditMode => isEdit;
  bool get isViewMode => !isEdit;
}
