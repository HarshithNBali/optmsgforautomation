import 'package:freezed_annotation/freezed_annotation.dart';

part 'add_contact_state.freezed.dart';

@freezed
abstract class AddContactState with _$AddContactState {
  const factory AddContactState({
    @Default(false) bool isLoading,
    @Default(1) int emailFieldCount,
  }) = _AddContactState;
}
