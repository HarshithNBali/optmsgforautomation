import 'package:freezed_annotation/freezed_annotation.dart';

part 'setting_state.freezed.dart';

/// Immutable state model for Settings feature using Freezed.
@freezed
abstract class SettingsState with _$SettingsState {
  const factory SettingsState({
    // User data
    Map<String, dynamic>? userData,
    
    // Flags
    @Default(false) bool isLoading,
    @Default(true) bool isNotificationSelected,
    @Default(false) bool isBiometricSelected,
    @Default(true) bool lastNameSorted,
    @Default(true) bool syncContact,
    @Default(true) bool readingPaneEnabled,
    /// Theme mode: 'system' (default), 'light', or 'dark'.
    @Default('system') String themeModePref,
    @Default(false) bool showLogoutDialog,
  }) = _SettingsState;

  // Private constructor for adding custom methods
  const SettingsState._();

  /// Computed properties for better readability
  bool get hasUserData => userData != null;
  String get userName => userData?['user']?['name'] ?? '';
  String get userEmail => userData?['user']?['email'] ?? '';
  bool get isNotificationEnabled => isNotificationSelected;
  bool get isBiometricEnabled => isBiometricSelected;
}
