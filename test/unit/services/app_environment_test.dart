// Implements: TC-DISC-ENV-001..008
// Source: lib/common/app_manger/app_environment.dart
// Coverage target: 90%+
import 'package:flutter_test/flutter_test.dart';
import 'package:optmsg/common/app_manger/app_environment.dart';

void main() {
  group('AppEnvironment', () {
    test('should be a singleton', () {
      // TC-DISC-ENV-001
      final a = AppEnvironment.instance;
      final b = AppEnvironment.instance;
      expect(identical(a, b), isTrue);
    });

    group('getTypeForAppFlavor', () {
      test('should return dev for "dev"', () {
        // TC-DISC-ENV-002
        expect(
          AppEnvironment.instance.getTypeForAppFlavor('dev'),
          AppEnvironmentType.dev,
        );
      });

      test('should return stage for "stage"', () {
        expect(
          AppEnvironment.instance.getTypeForAppFlavor('stage'),
          AppEnvironmentType.stage,
        );
      });

      test('should return prod for "prod"', () {
        // TC-DISC-ENV-003
        expect(
          AppEnvironment.instance.getTypeForAppFlavor('prod'),
          AppEnvironmentType.prod,
        );
      });

      test('should return stage for unknown flavor', () {
        // TC-DISC-ENV-004
        expect(
          AppEnvironment.instance.getTypeForAppFlavor('unknown'),
          AppEnvironmentType.stage,
        );
      });

      test('should return stage for empty string', () {
        expect(
          AppEnvironment.instance.getTypeForAppFlavor(''),
          AppEnvironmentType.stage,
        );
      });
    });

    group('currentWebEnv', () {
      test('should set type and return it', () async {
        // TC-DISC-ENV-005
        final result = await AppEnvironment.instance.currentWebEnv('prod');
        expect(result, AppEnvironmentType.prod);
        expect(AppEnvironment.instance.type, AppEnvironmentType.prod);
      });

      test('should update type on subsequent calls', () async {
        // TC-DISC-ENV-006
        await AppEnvironment.instance.currentWebEnv('dev');
        expect(AppEnvironment.instance.type, AppEnvironmentType.dev);

        await AppEnvironment.instance.currentWebEnv('stage');
        expect(AppEnvironment.instance.type, AppEnvironmentType.stage);
      });
    });
  });

  group('AppEnvironmentType', () {
    test('should have three values', () {
      // TC-DISC-ENV-007
      expect(AppEnvironmentType.values, hasLength(3));
      expect(AppEnvironmentType.values, contains(AppEnvironmentType.dev));
      expect(AppEnvironmentType.values, contains(AppEnvironmentType.stage));
      expect(AppEnvironmentType.values, contains(AppEnvironmentType.prod));
    });
  });
}
