import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_state.freezed.dart';

enum AuthStatus {
  unauthenticated,
  authenticating,
  authenticated,
  awaitingOtp,
  error,
}

/// Categorises auth errors so callers can choose different recovery paths.
enum AuthErrorType {
  /// Generic / unknown error.
  generic,

  /// Network connectivity failure.
  network,

  /// Invalid credentials or OTP.
  invalidCredentials,

  /// Subscription expired or invalid.
  subscriptionInvalid,

  /// Session expired (401 from backend).
  sessionExpired,

  /// Descope SDK error (passkey, OTP verification, etc.).
  descopeError,
}

/// Immutable state model for Authentication using Freezed.
@freezed
abstract class AuthState with _$AuthState {
  const factory AuthState({
    required AuthStatus status,
    @Default(false) bool isInitialized,
    String? errorMessage,
    @Default(AuthErrorType.generic) AuthErrorType errorType,
    Map<String, dynamic>? verifyUser,
    bool? isDescopeLogin,
    Map<String, dynamic>? userData,
    String? mobile,
    String? countryCode,
    String? formattedPhone,
    @Default(false) bool isUserNameAvailable,
    @Default(false) bool isReadOnly,
  }) = _AuthState;

  const AuthState._();

  // Helper factory methods for different states
  factory AuthState.initial() => const AuthState(
        status: AuthStatus.unauthenticated,
        isInitialized: false,
      );

  factory AuthState.unauthenticated() => const AuthState(
        status: AuthStatus.unauthenticated,
        isInitialized: true,
      );

  factory AuthState.authenticating() => const AuthState(
        status: AuthStatus.authenticating,
        isInitialized: true,
      );

  factory AuthState.authenticated(Map<String, dynamic> userData) => AuthState(
        status: AuthStatus.authenticated,
        userData: userData,
        isInitialized: true,
      );

  /// [isInitialized] should be `false` when called during app initialization
  /// (e.g. inside `_initialize()`) so the GoRouter redirect guard keeps waiting
  /// rather than firing prematurely to `/login`. Pass the default `true` for
  /// all post-initialization errors (OTP, login, profile, etc.).
  factory AuthState.error(
    String message, {
    AuthErrorType type = AuthErrorType.generic,
    bool isInitialized = true,
  }) =>
      AuthState(
        status: AuthStatus.error,
        errorMessage: message,
        errorType: type,
        isInitialized: isInitialized,
      );

  // Computed properties for better readability
  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isAuthenticating => status == AuthStatus.authenticating;
  bool get isUnauthenticated => status == AuthStatus.unauthenticated;
  bool get hasError => status == AuthStatus.error;
  bool get hasVerifyUser => verifyUser != null;
  bool get isDescopeEnabled => isDescopeLogin == true;
  bool get isLoading => status == AuthStatus.authenticating;
  bool get isAwaitingOtp => status == AuthStatus.awaitingOtp;
}
