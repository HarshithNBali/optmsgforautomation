// Implements: TC-DISC-HC-001..006
// Source: lib/screens/helpCenter/help_center_notifier.dart
// Coverage target: 95%+
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:optmsg/screens/helpCenter/help_center_notifier.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer container;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    container = ProviderContainer();
  });

  tearDown(() => container.dispose());

  group('HelpCenterNotifier', () {
    test('should have correct initial state', () {
      // TC-DISC-HC-001
      final state = container.read(helpCenterProvider);
      expect(state.selectedCategory, isEmpty);
      expect(state.searchQuery, '');
      expect(state.expandedItems, isEmpty);
    });

    test('init should set inCompose to false', () async {
      // TC-DISC-HC-002
      SharedPreferences.setMockInitialValues({'inCompose': true});
      final notifier = container.read(helpCenterProvider.notifier);

      await notifier.init();

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('inCompose'), isFalse);
    });

    test('manageComposeFlag should set inCompose to false', () async {
      // TC-DISC-HC-003
      SharedPreferences.setMockInitialValues({'inCompose': true});
      final notifier = container.read(helpCenterProvider.notifier);

      await notifier.manageComposeFlag();

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('inCompose'), isFalse);
    });

    test('selectCategory should update state', () {
      // TC-DISC-HC-004
      container.read(helpCenterProvider.notifier).selectCategory('general');
      expect(
        container.read(helpCenterProvider).selectedCategory,
        'general',
      );
    });

    test('search should update searchQuery', () {
      container.read(helpCenterProvider.notifier).search('billing');
      expect(container.read(helpCenterProvider).searchQuery, 'billing');
    });

    test('clearSearch should reset searchQuery', () {
      // TC-DISC-HC-005
      final notifier = container.read(helpCenterProvider.notifier);
      notifier.search('something');
      notifier.clearSearch();
      expect(container.read(helpCenterProvider).searchQuery, '');
    });

    test('toggleItem should add item to expandedItems', () {
      // TC-DISC-HC-006
      container.read(helpCenterProvider.notifier).toggleItem('faq-1');
      expect(
        container.read(helpCenterProvider).expandedItems,
        contains('faq-1'),
      );
    });

    test('toggleItem should remove item when already expanded', () {
      final notifier = container.read(helpCenterProvider.notifier);
      notifier.toggleItem('faq-1');
      notifier.toggleItem('faq-1');
      expect(
        container.read(helpCenterProvider).expandedItems,
        isNot(contains('faq-1')),
      );
    });

    test('collapseAll should clear expandedItems', () {
      final notifier = container.read(helpCenterProvider.notifier);
      notifier.toggleItem('faq-1');
      notifier.toggleItem('faq-2');
      notifier.collapseAll();
      expect(container.read(helpCenterProvider).expandedItems, isEmpty);
    });
  });
}
