import 'package:freezed_annotation/freezed_annotation.dart';

part 'payment_method_state.freezed.dart';

@freezed
abstract class PaymentMethodState with _$PaymentMethodState {
  const factory PaymentMethodState({
    @Default(false) bool isLoading,
    @Default(false) bool showNoData,
    @Default([]) List<Map<String, dynamic>> cardData,
  }) = _PaymentMethodState;
}
