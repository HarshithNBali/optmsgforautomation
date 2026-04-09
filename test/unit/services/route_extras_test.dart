// Implements: TC-DISC-EXTRAS-001..010
// Source: lib/router/route_extras.dart
// Coverage target: 100% (pure functions)
import 'package:flutter_test/flutter_test.dart';
import 'package:optmsg/router/route_extras.dart';

void main() {
  group('safeExtras', () {
    test('should return map when extra is Map<String, dynamic>', () {
      // TC-DISC-EXTRAS-001
      final extras = {'key': 'value', 'num': 42};
      expect(safeExtras(extras), equals(extras));
    });

    test('should return empty map when extra is null', () {
      // TC-DISC-EXTRAS-002
      expect(safeExtras(null), isEmpty);
    });

    test('should return empty map when extra is wrong type', () {
      // TC-DISC-EXTRAS-003
      expect(safeExtras('not a map'), isEmpty);
      expect(safeExtras(42), isEmpty);
      expect(safeExtras([1, 2, 3]), isEmpty);
    });
  });

  group('extraString', () {
    test('should return string value when key exists', () {
      // TC-DISC-EXTRAS-004
      expect(extraString({'name': 'John'}, 'name'), 'John');
    });

    test('should return fallback when key is missing', () {
      expect(extraString({}, 'name'), '');
      expect(extraString({}, 'name', 'default'), 'default');
    });

    test('should return fallback when value is not a string', () {
      // TC-DISC-EXTRAS-005
      expect(extraString({'num': 42}, 'num'), '');
      expect(extraString({'flag': true}, 'flag', 'fallback'), 'fallback');
    });
  });

  group('extraBool', () {
    test('should return bool value when key exists', () {
      // TC-DISC-EXTRAS-006
      expect(extraBool({'active': true}, 'active'), isTrue);
      expect(extraBool({'active': false}, 'active'), isFalse);
    });

    test('should return fallback when key is missing', () {
      expect(extraBool({}, 'active'), isFalse);
      expect(extraBool({}, 'active', true), isTrue);
    });

    test('should return fallback when value is not a bool', () {
      // TC-DISC-EXTRAS-007
      expect(extraBool({'flag': 'yes'}, 'flag'), isFalse);
      expect(extraBool({'flag': 1}, 'flag'), isFalse);
    });
  });

  group('extraTyped', () {
    test('should return typed value when type matches', () {
      // TC-DISC-EXTRAS-008
      expect(extraTyped<int>({'count': 5}, 'count'), 5);
      expect(extraTyped<String>({'name': 'X'}, 'name'), 'X');
      expect(extraTyped<List>({'items': [1, 2]}, 'items'), [1, 2]);
    });

    test('should return null when key is missing', () {
      // TC-DISC-EXTRAS-009
      expect(extraTyped<int>({}, 'count'), isNull);
    });

    test('should return null when type does not match', () {
      // TC-DISC-EXTRAS-010
      expect(extraTyped<int>({'count': 'not int'}, 'count'), isNull);
      expect(extraTyped<String>({'val': 42}, 'val'), isNull);
    });
  });
}
