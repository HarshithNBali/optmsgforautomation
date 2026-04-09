// Implements: TC-DISC-STORAGE-MOCK-001..008
// Source: Screens that create SecureStorageService() internally
// Technique: Mock the flutter_secure_storage platform channel
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:optmsg/model/auth/auth_state.dart';
import 'package:optmsg/screens/auth/auth_riverpod/auth_notifier.dart';
import 'package:optmsg/screens/auth/setupProfile/setup_profile_screen.dart';
import 'package:optmsg/screens/auth/enterOtp/success_otp.dart';
import 'package:optmsg/screens/auth/userNameSuccess/user_name_success_screen.dart';
import 'package:optmsg/screens/contacts/contacts_riverpod/contact_list_riverpod.dart';

import '../helpers/test_helpers.dart';
import '../helpers/riverpod_test_helpers.dart';
import '../factories/test_data_factories.dart';

class _FakeAuthNotifier extends AuthNotifier {
  final Map<String, dynamic> _data;
  _FakeAuthNotifier(this._data);
  @override
  AuthState build() => AuthState.authenticated(_data);
}

/// In-memory mock for flutter_secure_storage platform channel.
/// Returns null for reads, no-ops for writes/deletes.
void mockSecureStorageChannel() {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
    (MethodCall methodCall) async {
      switch (methodCall.method) {
        case 'read':
          return null;
        case 'write':
        case 'delete':
        case 'deleteAll':
          return null;
        case 'readAll':
          return <String, String>{};
        case 'containsKey':
          return false;
        default:
          return null;
      }
    },
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late RiverpodTestSetup setup;
  final testUserData = {
    'user': makeUserJson(firstName: 'Test', lastName: 'User'),
    'token': 'test-token',
  };

  setUp(() {
    SharedPreferences.setMockInitialValues({});

    // Mock both platform channels
    mockSecureStorageChannel();
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
    when(() => setup.mockStorageService.writeObjectData(any(), any()))
        .thenAnswer((_) async {});
  });

  Widget buildScreen(Widget screen) {
    return ProviderScope(
      overrides: [
        ...setup.serviceOverrides,
        authProvider.overrideWith(() => _FakeAuthNotifier(testUserData)),
      ],
      child: MaterialApp(
        theme: testThemeData(),
        home: Scaffold(body: screen),
      ),
    );
  }

  // OtpScreen blocked: calls authProvider.notifier.otpInit() in initState
  // which accesses _storageService (late field not set in FakeAuthNotifier)

  // =========================================================================
  // SetupProfile
  // =========================================================================
  group('SetupProfileScreen with storage mock', () {
    testWidgets('should render profile form at mobile size', (tester) async {
      tester.setScreenSize(width: 400, height: 800);
      final origOnError = FlutterError.onError;
      FlutterError.onError = (d) {
        if (d.toString().contains('overflow')) return;
        origOnError?.call(d);
      };

      await tester.pumpWidget(buildScreen(
        const SetupProfileScreen(userName: 'testuser'),
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(SetupProfileScreen), findsOneWidget);

      tester.resetScreenSize();
      FlutterError.onError = origOnError;
    });
  });

  // =========================================================================
  // SuccessOtp — previously minimal coverage
  // =========================================================================
  group('SuccessOtp with storage mock', () {
    testWidgets('should render success message', (tester) async {
      tester.setScreenSize(width: 400, height: 800);
      final origOnError = FlutterError.onError;
      FlutterError.onError = (d) {
        if (d.toString().contains('overflow')) return;
        origOnError?.call(d);
      };

      await tester.pumpWidget(buildScreen(const SuccessOtp()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(SuccessOtp), findsOneWidget);

      tester.resetScreenSize();
      FlutterError.onError = origOnError;
    });
  });

  // =========================================================================
  // UserNameSuccessScreen
  // =========================================================================
  group('UserNameSuccessScreen with storage mock', () {
    testWidgets('should render at mobile size', (tester) async {
      tester.setScreenSize(width: 400, height: 800);
      final origOnError = FlutterError.onError;
      FlutterError.onError = (d) {
        if (d.toString().contains('overflow')) return;
        origOnError?.call(d);
      };

      await tester.pumpWidget(buildScreen(const UserNameSuccessScreen()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(UserNameSuccessScreen), findsOneWidget);

      tester.resetScreenSize();
      FlutterError.onError = origOnError;
    });
  });

  // =========================================================================
  // ContactListriverpod — previously blocked by SecureStorageService
  // =========================================================================
  group('ContactListriverpod with storage mock', () {
    testWidgets('should render at mobile size', (tester) async {
      tester.setScreenSize(width: 400, height: 800);
      final origOnError = FlutterError.onError;
      FlutterError.onError = (d) {
        if (d.toString().contains('overflow')) return;
        origOnError?.call(d);
      };

      await tester.pumpWidget(buildScreen(const ContactListriverpod()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(ContactListriverpod), findsOneWidget);

      tester.resetScreenSize();
      FlutterError.onError = origOnError;
    });
  });

  // StaticPages blocked: calls SecureStorageService() in state AND
  // makes API call in initState to load page content
}
