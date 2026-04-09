import 'package:freezed_annotation/freezed_annotation.dart';

part 'account_state.freezed.dart';

/// Immutable state model for Account feature using Freezed.
@freezed
abstract class AccountState with _$AccountState {
  const factory AccountState({
    // Data
    Map<String, dynamic>? userData,
    @Default('') String subscriptionDate,
    
    // Flags
    @Default(false) bool isLoading,
  }) = _AccountState;

  // Private constructor for adding custom methods
  const AccountState._();

  /// Computed properties for better readability
  bool get hasUserData => userData != null;
  String get accountName => userData?['name'] ?? '';
  String get accountEmail => userData?['email'] ?? '';
  bool get hasSubscription => subscriptionDate.isNotEmpty;
}
