import 'package:freezed_annotation/freezed_annotation.dart';

part 'passkey_state.freezed.dart';

/// Immutable state model for Passkey feature using Freezed.
@freezed
abstract class PasskeyState with _$PasskeyState {
  const factory PasskeyState({
    // Flags
    @Default(false) bool isLoading,
    @Default(false) bool isEnabling,
    @Default(false) bool isEnabled,
    @Default(false) bool passkeySupported,
    @Default(false) bool hasCompletedOnboarding,

    // Data
    Map<String, dynamic>? userData,
    String? errorMessage,
  }) = _PasskeyState;

  const PasskeyState._();

  // Computed properties for better readability
  bool get hasUserData => userData != null;
  bool get hasError => errorMessage != null;
  // canEnable: attempt passkey add as long as we have user data and aren't already loading.
  // passkeySupported is NOT gated here — mobile's Descope.passkey.isSupported() can return
  // false even when add() works fine. If truly unsupported, add() throws DescopeException.
  bool get canEnable => !isLoading && !isEnabled && hasUserData;
  String get userName =>
      '${userData?['user']?['firstName'] ?? ''} ${userData?['user']?['lastName'] ?? ''}'
          .trim();
  String get userEmail => userData?['user']?['userName'] ?? '';
  String get loginId => userData?['user']?['userName'] ?? '';
  String get boardingStatus => userData?['user']?['boardingSteps'] ?? '';
}
