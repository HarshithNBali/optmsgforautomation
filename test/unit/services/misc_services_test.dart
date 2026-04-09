import 'package:flutter_test/flutter_test.dart';
import 'package:optmsg/common/app_manger/app_environment.dart';

void main() {
  // ===== AppEnvironment =====
  group('AppEnvironment', () {
    test('getTypeForAppFlavor should return correct type for dev', () {
      final result = AppEnvironment.instance.getTypeForAppFlavor('dev');
      expect(result, AppEnvironmentType.dev);
    });

    test('getTypeForAppFlavor should return correct type for stage', () {
      final result = AppEnvironment.instance.getTypeForAppFlavor('stage');
      expect(result, AppEnvironmentType.stage);
    });

    test('getTypeForAppFlavor should return correct type for prod', () {
      final result = AppEnvironment.instance.getTypeForAppFlavor('prod');
      expect(result, AppEnvironmentType.prod);
    });

    test('getTypeForAppFlavor should default to stage for unknown', () {
      final result = AppEnvironment.instance.getTypeForAppFlavor('unknown');
      expect(result, AppEnvironmentType.stage);
    });

    test('AppEnvironmentType should have 3 values', () {
      expect(AppEnvironmentType.values, hasLength(3));
      expect(AppEnvironmentType.values, contains(AppEnvironmentType.dev));
      expect(AppEnvironmentType.values, contains(AppEnvironmentType.stage));
      expect(AppEnvironmentType.values, contains(AppEnvironmentType.prod));
    });

    test('instance should be singleton', () {
      expect(identical(AppEnvironment.instance, AppEnvironment.instance), true);
    });
  });
}
