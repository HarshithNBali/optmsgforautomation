import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:optmsg/services/global_variable_notifier.dart';

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer();
  });

  tearDown(() {
    container.dispose();
  });

  group('GlobalVariableNotifier', () {
    test('should start with empty pathList', () {
      final state = container.read(globalVariableProvider);

      expect(state.pathList, isEmpty);
    });

    test('addPath should append to pathList', () {
      container.read(globalVariableProvider.notifier).addPath('/api/inbox');
      final state = container.read(globalVariableProvider);

      expect(state.pathList, ['/api/inbox']);
    });

    test('addPath should accumulate multiple paths', () {
      final notifier = container.read(globalVariableProvider.notifier);
      notifier.addPath('/api/inbox');
      notifier.addPath('/api/profile');
      notifier.addPath('/api/tags');

      final state = container.read(globalVariableProvider);
      expect(state.pathList, ['/api/inbox', '/api/profile', '/api/tags']);
    });

    test('clearPathList should empty the list', () {
      final notifier = container.read(globalVariableProvider.notifier);
      notifier.addPath('/api/inbox');
      notifier.addPath('/api/profile');
      notifier.clearPathList();

      final state = container.read(globalVariableProvider);
      expect(state.pathList, isEmpty);
    });

    test('should start with default emailNavigation of "1"', () {
      final state = container.read(globalVariableProvider);

      expect(state.emailNavigation, '1');
    });

    test('updateGlobalEmailNavigation should set value', () {
      container
          .read(globalVariableProvider.notifier)
          .updateGlobalEmailNavigation('inbox');

      final state = container.read(globalVariableProvider);
      expect(state.emailNavigation, 'inbox');
    });

    test('clearGlobalEmailNavigation should reset to empty', () {
      final notifier = container.read(globalVariableProvider.notifier);
      notifier.updateGlobalEmailNavigation('archive');
      notifier.clearGlobalEmailNavigation();

      final state = container.read(globalVariableProvider);
      expect(state.emailNavigation, '');
    });

    test('setLastActivityCalled should set flag', () {
      container
          .read(globalVariableProvider.notifier)
          .setLastActivityCalled();

      final state = container.read(globalVariableProvider);
      expect(state.hasCalledLastActivity, true);
    });
  });
}
