import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../model/profile_model.dart';

part 'checkout_state.freezed.dart';

@freezed
abstract class CheckoutState with _$CheckoutState {
  const factory CheckoutState({
    @Default(false) bool isLoading,
    Map<String, dynamic>? selectedPlan,
    @Default('') String subscriptionPage,
    @Default(false) bool isPromoApplied,
    @Default(0) double grandTotal,
    @Default(0) double originalCharge,
    @Default(0) double discount,
    @Default('') String discountType,
    @Default('') String planType,
    @Default('') String token,
    MyProfile? profile,
    @Default('') String promoCode,
    String? errorMessage,
    String? paymentStatus,
  }) = _CheckoutState;
}
