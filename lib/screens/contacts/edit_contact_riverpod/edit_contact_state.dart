import 'package:freezed_annotation/freezed_annotation.dart';

part 'edit_contact_state.freezed.dart';

@freezed
abstract class EditContactState with _$EditContactState {
  const factory EditContactState({
    @Default(false) bool isLoading,
    @Default(0) int emailFieldCount,
  }) = _EditContactState;
}
