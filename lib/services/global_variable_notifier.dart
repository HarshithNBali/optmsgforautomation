import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'global_variable_state.dart';

final globalVariableProvider =
    NotifierProvider<GlobalVariableNotifier, GlobalVariableState>(
  () => GlobalVariableNotifier(),
);

class GlobalVariableNotifier extends Notifier<GlobalVariableState> {
  @override
  GlobalVariableState build() => const GlobalVariableState();

  void setLastActivityCalled() {
    state = state.copyWith(hasCalledLastActivity: true);
  }

  void addPath(String path) {
    state = state.copyWith(
      pathList: [...state.pathList, path],
    );
  }

  void clearPathList() {
    state = state.copyWith(pathList: []);
  }

  void clearGlobalEmailNavigation() {
    state = state.copyWith(emailNavigation: '');
  }

  void updateGlobalEmailNavigation(String updatedValue) {
    state = state.copyWith(emailNavigation: updatedValue);
  }
}
