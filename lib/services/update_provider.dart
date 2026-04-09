import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'update_provider.freezed.dart';

// L-04: Converted to Freezed for consistency with other state classes.
@freezed
abstract class UpdateState with _$UpdateState {
  const factory UpdateState({
    @Default(false) bool isUpdateDialogVisible,
    @Default(false) bool isOptionalUpdateDismissed,
  }) = _UpdateState;
}

class UpdateNotifier extends Notifier<UpdateState> {
  @override
  UpdateState build() {
    return const UpdateState();
  }

  void setUpdateDialogVisible(bool isVisible) {
    state = state.copyWith(isUpdateDialogVisible: isVisible);
  }

  void dismissOptionalUpdate() {
    state = state.copyWith(isOptionalUpdateDismissed: true);
  }
}

final updateProvider = NotifierProvider<UpdateNotifier, UpdateState>(
  UpdateNotifier.new,
);
