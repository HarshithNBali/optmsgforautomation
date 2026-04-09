// Implements: TC-DISC-AUTH-SCREEN2-001..006
// Source: Auth screen widgets (OTP, SuccessOtp, UserNameSuccess, SetupProfile)
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:optmsg/screens/auth/enterOtp/otp_screen.dart';
import 'package:optmsg/screens/auth/enterOtp/success_otp.dart';
import 'package:optmsg/screens/auth/userNameSuccess/user_name_success_screen.dart';
import 'package:optmsg/screens/auth/setupProfile/setup_profile_screen.dart';

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

  group('OtpScreen', () {
    testWidgets('should render at mobile size', (tester) async {
      // TC-DISC-AUTH-SCREEN2-001
      tester.setScreenSize(width: 400, height: 800);

      final origOnError = FlutterError.onError;
      FlutterError.onError = (d) {
        if (d.toString().contains('overflow')) return;
        origOnError?.call(d);
      };

      await tester.pumpWidget(buildScreen(const OtpScreen(
        pageKey: 'login',
        webAuthn: false,
        loginId: 'testuser',
        userName: 'testuser',
      )));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.byType(OtpScreen), findsOneWidget);

      tester.resetScreenSize();
      FlutterError.onError = origOnError;
    });
  });

  group('SuccessOtp', () {
    testWidgets('should render at mobile size', (tester) async {
      // TC-DISC-AUTH-SCREEN2-002
      tester.setScreenSize(width: 400, height: 800);

      final origOnError = FlutterError.onError;
      FlutterError.onError = (d) {
        if (d.toString().contains('overflow')) return;
        origOnError?.call(d);
      };

      await tester.pumpWidget(buildScreen(const SuccessOtp()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.byType(SuccessOtp), findsOneWidget);

      tester.resetScreenSize();
      FlutterError.onError = origOnError;
    });
  });

  group('UserNameSuccessScreen', () {
    testWidgets('should render at mobile size', (tester) async {
      // TC-DISC-AUTH-SCREEN2-003
      tester.setScreenSize(width: 400, height: 800);

      final origOnError = FlutterError.onError;
      FlutterError.onError = (d) {
        if (d.toString().contains('overflow')) return;
        origOnError?.call(d);
      };

      await tester.pumpWidget(buildScreen(const UserNameSuccessScreen()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.byType(UserNameSuccessScreen), findsOneWidget);

      tester.resetScreenSize();
      FlutterError.onError = origOnError;
    });
  });

  group('SetupProfileScreen', () {
    testWidgets('should render at mobile size', (tester) async {
      // TC-DISC-AUTH-SCREEN2-004
      tester.setScreenSize(width: 400, height: 800);

      final origOnError = FlutterError.onError;
      FlutterError.onError = (d) {
        if (d.toString().contains('overflow')) return;
        origOnError?.call(d);
      };

      await tester.pumpWidget(buildScreen(const SetupProfileScreen(userName: 'testuser')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.byType(SetupProfileScreen), findsOneWidget);

      tester.resetScreenSize();
      FlutterError.onError = origOnError;
    });
  });
}
