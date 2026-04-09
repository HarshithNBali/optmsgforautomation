import 'package:freezed_annotation/freezed_annotation.dart';

part 'enter_otp_state.freezed.dart';

/// Immutable state model for Enter OTP feature using Freezed.
@freezed
abstract class EnterOtpState with _$EnterOtpState {
  const factory EnterOtpState({
    // Flags
    @Default(false) bool loading,
    
    // Phone data
    @Default('') String formattedPhone,
    @Default('') String mobile,
    @Default('+1') String countryCode,
    
    // User data
    Map<String, dynamic>? userData,
  }) = _EnterOtpState;

  const EnterOtpState._();

  // Computed properties for better readability
  bool get isLoading => loading;
  bool get hasUserData => userData != null;
  bool get hasMobile => mobile.isNotEmpty;
  String get displayPhone => formattedPhone.isNotEmpty ? formattedPhone : mobile;
  bool get isValid => mobile.isNotEmpty && userData != null;
  String get fullPhone => '$countryCode$mobile';
}