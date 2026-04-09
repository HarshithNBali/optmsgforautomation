// Implements: TC-DISC-PLANS-001..005
// Source: lib/screens/subscription/plans/plans_provider.dart
// Coverage target: 100% for planRank(), 90%+ for selectedPlanTypeProvider
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:optmsg/screens/subscription/plans/plans_provider.dart';

void main() {
  group('planRank', () {
    test('should return 0 for reader plans', () {
      // TC-DISC-PLANS-001
      expect(planRank('Reader'), 0);
      expect(planRank('reader'), 0);
      expect(planRank('Free Reader Plan'), 0);
    });

    test('should return 1 for annual plans', () {
      // TC-DISC-PLANS-002
      expect(planRank('Annual'), 1);
      expect(planRank('annual'), 1);
      expect(planRank('Pro Annual'), 1);
    });

    test('should return 2 for other plans', () {
      // TC-DISC-PLANS-003
      expect(planRank('Monthly'), 2);
      expect(planRank('Pro'), 2);
      expect(planRank('Enterprise'), 2);
    });
  });

  group('selectedPlanTypeProvider', () {
    test('should default to annual', () {
      // TC-DISC-PLANS-004
      final container = ProviderContainer();
      expect(container.read(selectedPlanTypeProvider), 'annual');
      container.dispose();
    });

    test('should update when set is called', () {
      // TC-DISC-PLANS-005
      final container = ProviderContainer();
      container.read(selectedPlanTypeProvider.notifier).set('monthly');
      expect(container.read(selectedPlanTypeProvider), 'monthly');
      container.dispose();
    });
  });
}
