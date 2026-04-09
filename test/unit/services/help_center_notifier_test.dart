import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:optmsg/screens/helpCenter/help_center_notifier.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer();
  });

  tearDown(() {
    container.dispose();
  });

  group('HelpCenterNotifier', () {
    test('initial state should have defaults', () {
      final state = container.read(helpCenterProvider);
      expect(state.isLoading, false);
      expect(state.selectedCategory, '');
      expect(state.searchQuery, '');
      expect(state.expandedItems, isEmpty);
    });

    test('selectCategory should update selectedCategory', () {
      container.read(helpCenterProvider.notifier).selectCategory('billing');
      expect(container.read(helpCenterProvider).selectedCategory, 'billing');
    });

    test('search should update searchQuery', () {
      container.read(helpCenterProvider.notifier).search('password');
      expect(container.read(helpCenterProvider).searchQuery, 'password');
    });

    test('clearSearch should reset searchQuery', () {
      final notifier = container.read(helpCenterProvider.notifier);
      notifier.search('something');
      notifier.clearSearch();
      expect(container.read(helpCenterProvider).searchQuery, '');
    });

    test('toggleItem should add item to expanded list', () {
      container.read(helpCenterProvider.notifier).toggleItem('faq-1');
      expect(container.read(helpCenterProvider).expandedItems, ['faq-1']);
    });

    test('toggleItem should remove item if already expanded', () {
      final notifier = container.read(helpCenterProvider.notifier);
      notifier.toggleItem('faq-1');
      notifier.toggleItem('faq-1');
      expect(container.read(helpCenterProvider).expandedItems, isEmpty);
    });

    test('toggleItem should handle multiple items', () {
      final notifier = container.read(helpCenterProvider.notifier);
      notifier.toggleItem('faq-1');
      notifier.toggleItem('faq-2');
      notifier.toggleItem('faq-3');
      expect(container.read(helpCenterProvider).expandedItems,
          ['faq-1', 'faq-2', 'faq-3']);
    });

    test('collapseAll should clear expanded items', () {
      final notifier = container.read(helpCenterProvider.notifier);
      notifier.toggleItem('faq-1');
      notifier.toggleItem('faq-2');
      notifier.collapseAll();
      expect(container.read(helpCenterProvider).expandedItems, isEmpty);
    });
  });
}
