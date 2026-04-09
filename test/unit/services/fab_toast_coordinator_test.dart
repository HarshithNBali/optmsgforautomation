// Implements: TC-DISC-FAB-001..003
// Source: lib/services/fab_toast_coordinator.dart
// Coverage target: 100%
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:optmsg/services/fab_toast_coordinator.dart';

void main() {
  group('FabToastCoordinator', () {
    setUp(() {
      FabToastCoordinator.isToastVisible.value = false;
    });

    test('isToastVisible should be false after reset', () {
      // TC-DISC-FAB-001
      expect(FabToastCoordinator.isToastVisible.value, isFalse);
    });

    test('isToastVisible should be settable', () {
      // TC-DISC-FAB-002
      FabToastCoordinator.isToastVisible.value = true;
      expect(FabToastCoordinator.isToastVisible.value, isTrue);

      // Reset for other tests
      FabToastCoordinator.isToastVisible.value = false;
    });

    test('isToastVisible should be a ValueNotifier<bool>', () {
      // TC-DISC-FAB-003
      expect(FabToastCoordinator.isToastVisible, isA<ValueNotifier<bool>>());
    });
  });
}
