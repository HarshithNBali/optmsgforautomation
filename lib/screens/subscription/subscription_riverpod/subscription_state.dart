import 'package:freezed_annotation/freezed_annotation.dart';

part 'subscription_state.freezed.dart';

@freezed
abstract class SubscriptionState with _$SubscriptionState {
  const factory SubscriptionState({
    @Default({}) Map<String, dynamic> data,
    @Default(false) bool isLoading,
    @Default(false) bool isFreeUser,
  }) = _SubscriptionState;
}
