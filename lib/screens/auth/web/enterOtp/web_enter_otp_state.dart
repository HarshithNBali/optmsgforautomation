import 'package:freezed_annotation/freezed_annotation.dart';

part 'web_enter_otp_state.freezed.dart';

@freezed
abstract class WebEnterOtpState with _$WebEnterOtpState {
  const factory WebEnterOtpState({
    @Default(false) bool isLoading,
    @Default('') String formattedPhoneNumber,
    @Default('+1') String countryCode,
    @Default('') String deviceToken,
    @Default(0) int resendCooldownSeconds,
    Map<String, dynamic>? userData,
  }) = _WebEnterOtpState;
}

