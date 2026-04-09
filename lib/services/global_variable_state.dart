import 'package:freezed_annotation/freezed_annotation.dart';

part 'global_variable_state.freezed.dart';

@freezed
abstract class GlobalVariableState with _$GlobalVariableState {
  const factory GlobalVariableState({
    @Default([]) List<String> pathList,
    @Default(false) bool hasCalledLastActivity,
    @Default('1') String emailNavigation,
  }) = _GlobalVariableState;
}
