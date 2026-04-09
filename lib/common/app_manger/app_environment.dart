import 'package:package_info_plus/package_info_plus.dart';

enum AppEnvironmentType { dev, stage, prod }

class AppEnvironment {
  static final AppEnvironment instance = AppEnvironment._internal();

  AppEnvironmentType? type;

  AppEnvironment._internal();

  Future<AppEnvironmentType> currentEnv() async {
    if (type != null) return Future.value(type);

    final info = await PackageInfo.fromPlatform();

    //info.appName
    type = _getTypeForAppName(info.appName);

    return type!;
  }

  Future<AppEnvironmentType> currentWebEnv(String env) async {
    type = getTypeForAppFlavor(env);

    return type!;
  }

  AppEnvironmentType getTypeForAppFlavor(String env) {
    switch (env) {
      case 'dev':
        return AppEnvironmentType.dev;
      case 'stage':
        return AppEnvironmentType.stage;

      case 'prod':
        return AppEnvironmentType.prod;

      default:
        return AppEnvironmentType.stage;
    }
  }

  AppEnvironmentType _getTypeForAppName(String name) {
    switch (name) {
      case "OptMsg-Dev":
        return AppEnvironmentType.dev;
      case "OptMsg-Stg":
        return AppEnvironmentType.stage;
      case "OptMsg":
        return AppEnvironmentType.prod;

      default:
        return AppEnvironmentType.stage;
    }
  }
}
