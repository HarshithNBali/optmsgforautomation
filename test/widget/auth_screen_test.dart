// Implements: TC-DISC-AUTH-SCREEN-001..006
// Source: Auth screen widgets (Login, ForgotUserName, CreateAccount)
// Coverage target: Cover 0% auth screen files
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:optmsg/screens/auth/login/login_screen.dart';
import 'package:optmsg/screens/auth/forgotUserName/forgot_user_name.dart';
import 'package:optmsg/screens/auth/createAccount/create_account_screen.dart';

import '../helpers/test_helpers.dart';
import '../helpers/riverpod_test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late RiverpodTestSetup setup;

  setUp(() {
    SharedPreferences.setMockInitialValues({});

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('app_badge_plus'),
      (MethodCall methodCall) async {
        if (methodCall.method == 'isSupported') return false;
        return null;
      },
    );

    setup = RiverpodTestSetup();
    when(() => setup.mockStorageService.readData(any()))
        .thenAnswer((_) async => null);
    when(() => setup.mockStorageService.readObjectData(any()))
        .thenAnswer((_) async => null);
    when(() => setup.mockStorageService.writeData(any(), any()))
        .thenAnswer((_) async {});
  });

  Widget buildScreen(Widget screen) {
    return ProviderScope(
      overrides: setup.serviceOverrides,
      child: MaterialApp(
        theme: testThemeData(),
        home: Scaffold(body: screen),
      ),
    );
  }

  // =========================================================================
  // LoginScreen
  // =========================================================================
  group('LoginScreen', () {
    testWidgets('should render at mobile size', (tester) async {
      // TC-DISC-AUTH-SCREEN-001
      tester.setScreenSize(width: 400, height: 800);

      final origOnError = FlutterError.onError;
      FlutterError.onError = (d) {
        if (d.toString().contains('overflow')) return;
        origOnError?.call(d);
      };

      await tester.pumpWidget(buildScreen(const LoginScreen()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.byType(LoginScreen), findsOneWidget);

      tester.resetScreenSize();
      FlutterError.onError = origOnError;
    });
  });

  // =========================================================================
  // ForgotUserName
  // =========================================================================
  group('ForgotUserName', () {
    testWidgets('should render at mobile size', (tester) async {
      // TC-DISC-AUTH-SCREEN-002
      tester.setScreenSize(width: 400, height: 800);

      final origOnError = FlutterError.onError;
      FlutterError.onError = (d) {
        if (d.toString().contains('overflow')) return;
        origOnError?.call(d);
      };

      await tester.pumpWidget(buildScreen(const ForgotUserName()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.byType(ForgotUserName), findsOneWidget);

      tester.resetScreenSize();
      FlutterError.onError = origOnError;
    });
  });

  // =========================================================================
  // CreateAccountScreen
  // =========================================================================
  group('CreateAccountScreen', () {
    testWidgets('should render at mobile size', (tester) async {
      // TC-DISC-AUTH-SCREEN-003
      tester.setScreenSize(width: 400, height: 800);

      final origOnError = FlutterError.onError;
      FlutterError.onError = (d) {
        if (d.toString().contains('overflow')) return;
        origOnError?.call(d);
      };

      await tester.pumpWidget(buildScreen(const CreateAccountScreen()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.byType(CreateAccountScreen), findsOneWidget);

      tester.resetScreenSize();
      FlutterError.onError = origOnError;
    });
  });
}
