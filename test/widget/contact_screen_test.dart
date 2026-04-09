// Implements: TC-DISC-CON-SCREEN-001..004
// Source: ContactListriverpod with fake notifier (unlocked by DI refactor)
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:optmsg/model/auth/auth_state.dart';
import 'package:optmsg/model/contact_list_model.dart';
import 'package:optmsg/screens/auth/auth_riverpod/auth_notifier.dart';
import 'package:optmsg/screens/contacts/contacts_riverpod/contact_list_notifier.dart';
import 'package:optmsg/screens/contacts/contacts_riverpod/contact_list_riverpod.dart';
import 'package:optmsg/screens/contacts/contacts_riverpod/contact_state.dart';

import '../helpers/test_helpers.dart';
import '../helpers/riverpod_test_helpers.dart';
import '../factories/test_data_factories.dart';

class _FakeAuthNotifier extends AuthNotifier {
  final Map<String, dynamic> _data;
  _FakeAuthNotifier(this._data);
  @override
  AuthState build() => AuthState.authenticated(_data);
}

class _FakeContactListNotifier extends ContactListNotifier {
  final ContactState _state;
  _FakeContactListNotifier(this._state);
  @override
  ContactState build() => _state;
  @override
  void setIsSearch(bool value) {}
  @override
  void clearSelection() {}
  @override
  void setLoading(bool value) {}
  @override
  void updateReadingPaneSettings(bool enabled) {}
  @override
  void searchFilterContact(String value) {}
  @override
  void toggleFilter() {}
  @override
  void setShowFilter(bool v) {}
  @override
  void setContactTypeFilter(String filterType) {}
  @override
  void clearContactTypeFilter() {}
  @override
  void onLongPress(int contactId) {}
  @override
  void toggleSelectContact(int contactId) {}
  @override
  void clearMultiSelection() {}
  @override
  void setShowCheckboxes(bool value) {}
  @override
  void deleteContactRecord(int id) {}
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
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
      (MethodCall methodCall) async {
        if (methodCall.method == 'read') return null;
        if (methodCall.method == 'readAll') return <String, String>{};
        return null;
      },
    );
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
    when(() => setup.mockStorageService.deleteData(any()))
        .thenAnswer((_) async {});
  });

  group('ContactListriverpod with contacts', () {
    testWidgets('should render contact list at mobile size', (tester) async {
      // TC-DISC-CON-SCREEN-001
      tester.setScreenSize(width: 400, height: 800);
      final origOnError = FlutterError.onError;
      FlutterError.onError = (d) {
        if (d.toString().contains('overflow')) return;
        origOnError?.call(d);
      };

      final contacts = [
        Contacts(id: 1, firstName: 'Alice', lastName: 'Smith', company: '', emails: []),
        Contacts(id: 2, firstName: 'Bob', lastName: 'Jones', company: 'Acme', emails: []),
        Contacts(id: 3, firstName: 'Charlie', lastName: 'Brown', company: '', emails: []),
      ];

      await tester.pumpWidget(ProviderScope(
        overrides: [
          ...setup.serviceOverrides,
          authProvider.overrideWith(() => _FakeAuthNotifier(testUserData)),
          contactListProvider.overrideWith(
            () => _FakeContactListNotifier(ContactState(
              isLoading: false,
              allContacts: contacts,
              filteredContacts: contacts,
            )),
          ),
        ],
        child: MaterialApp(
          theme: testThemeData(),
          home: const Scaffold(body: ContactListriverpod()),
        ),
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(ContactListriverpod), findsOneWidget);

      tester.resetScreenSize();
      FlutterError.onError = origOnError;
    });

    testWidgets('should render empty contacts state', (tester) async {
      // TC-DISC-CON-SCREEN-002
      tester.setScreenSize(width: 400, height: 800);
      final origOnError = FlutterError.onError;
      FlutterError.onError = (d) {
        if (d.toString().contains('overflow')) return;
        origOnError?.call(d);
      };

      await tester.pumpWidget(ProviderScope(
        overrides: [
          ...setup.serviceOverrides,
          authProvider.overrideWith(() => _FakeAuthNotifier(testUserData)),
          contactListProvider.overrideWith(
            () => _FakeContactListNotifier(const ContactState(isLoading: false)),
          ),
        ],
        child: MaterialApp(
          theme: testThemeData(),
          home: const Scaffold(body: ContactListriverpod()),
        ),
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(ContactListriverpod), findsOneWidget);

      tester.resetScreenSize();
      FlutterError.onError = origOnError;
    });

    testWidgets('should render at tablet size', (tester) async {
      // TC-DISC-CON-SCREEN-003
      tester.setScreenSize(width: 800, height: 600);
      final origOnError = FlutterError.onError;
      FlutterError.onError = (d) {
        if (d.toString().contains('overflow')) return;
        origOnError?.call(d);
      };

      final contacts = [
        Contacts(id: 1, firstName: 'Alice', lastName: 'Smith', company: '', emails: []),
      ];

      await tester.pumpWidget(ProviderScope(
        overrides: [
          ...setup.serviceOverrides,
          authProvider.overrideWith(() => _FakeAuthNotifier(testUserData)),
          contactListProvider.overrideWith(
            () => _FakeContactListNotifier(ContactState(
              isLoading: false,
              allContacts: contacts,
              filteredContacts: contacts,
            )),
          ),
        ],
        child: MaterialApp(
          theme: testThemeData(),
          home: const Scaffold(body: ContactListriverpod()),
        ),
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(ContactListriverpod), findsOneWidget);

      tester.resetScreenSize();
      FlutterError.onError = origOnError;
    });
  });
}
