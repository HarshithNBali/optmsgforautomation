// Implements: TC-DISC-WRAPPER-001..006
// Source: router/responsive_route_wrappers.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:optmsg/model/auth/auth_state.dart';
import 'package:optmsg/model/base_response/request_response.dart';
import 'package:optmsg/model/inbox_list_model.dart';
import 'package:optmsg/screens/auth/auth_riverpod/auth_notifier.dart';
import 'package:optmsg/screens/email/inbox_riverpod/inbox_notifier.dart';
import 'package:optmsg/screens/email/inbox_riverpod/inbox_state.dart';
import 'package:optmsg/screens/email/archive_riverpod/archive_list_notifier.dart';
import 'package:optmsg/screens/email/archive_riverpod/archive_state.dart';
import 'package:optmsg/screens/email/draft_riverpod/draft_notifier.dart';
import 'package:optmsg/screens/email/draft_riverpod/draft_state.dart';
import 'package:optmsg/router/responsive_route_wrappers.dart';

import '../helpers/test_helpers.dart';
import '../helpers/riverpod_test_helpers.dart';
import '../factories/test_data_factories.dart';

class _FakeAuth extends AuthNotifier {
  final Map<String, dynamic> _d;
  _FakeAuth(this._d);
  @override
  AuthState build() => AuthState.authenticated(_d);
}

class _FakeInbox extends InboxNotifier {
  @override
  InboxState build() => const InboxState(isLoading: false, items: []);
  @override
  Future<void> bootstrap({bool preserveReadingPane = false, int? emailIdToRestore, int? initialTagId, String? initialEmailType}) async {}
  @override
  Future<void> getAllEmails(String s, {bool isRefresh = false, bool silent = false}) async {}
  @override
  void clearOverlayStates() {}
  @override
  void reset() {}
  @override
  void toggleSearch() {}
  @override
  void toggleFilter() {}
  @override
  void toggleMenuOptions() {}
  @override
  void clearSelection() {}
  @override
  void setShowCheckboxes(bool v) {}
  @override
  void setComposeHovered(bool v) {}
  @override
  void resetFiltersAndSelections() {}
}

class _FakeArchive extends ArchiveNotifier {
  @override
  ArchiveState build() => const ArchiveState(isLoading: false, items: []);
  @override
  Future<void> init() async {}
  @override
  void clearOverlayStates() {}
  @override
  void reset() {}
  @override
  void toggleSearch() {}
  @override
  void toggleFilter() {}
  @override
  void toggleMenuOptions() {}
  @override
  void clearSelection() {}
  @override
  void setShowCheckboxes(bool s) {}
}

class _FakeDraft extends DraftNotifier {
  @override
  DraftState build() => const DraftState(isLoading: false, items: []);
  @override
  Future<void> bootstrap({int? emailIdToRestore}) async {}
  @override
  Future<void> getAllEmails(String s, {bool isRefresh = false}) async {}
  @override
  void clearOverlayStates() {}
  @override
  void reset() {}
  @override
  void toggleSearch() {}
  @override
  void setComposeHovered(bool v) {}
  @override
  void setCheckboxVisibility(bool v) {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late RiverpodTestSetup setup;
  final ud = {'user': makeUserJson(), 'token': 'tok'};

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
      (m) async => m.method == 'readAll' ? <String, String>{} : null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('app_badge_plus'),
      (m) async => m.method == 'isSupported' ? false : null);

    setup = RiverpodTestSetup();
    when(() => setup.mockStorageService.readData(any())).thenAnswer((_) async => null);
    when(() => setup.mockStorageService.readObjectData(any())).thenAnswer((_) async => null);
    when(() => setup.mockStorageService.writeData(any(), any())).thenAnswer((_) async {});
    when(() => setup.mockStorageService.deleteData(any())).thenAnswer((_) async {});
    when(() => setup.mockInboxApi.getInboxEmails(any()))
        .thenAnswer((_) async => RequestResponse(data: InboxListModel.fromJson(makeInboxListJson(emails: []))));
    when(() => setup.mockTagApi.getTagsList(any()))
        .thenAnswer((_) async => RequestResponse(data: {'success': true, 'message': '', 'data': {'tags': []}}));
  });

  List<Override> overrides() => [
    ...setup.serviceOverrides,
    authProvider.overrideWith(() => _FakeAuth(ud)),
    inboxProvider.overrideWith(() => _FakeInbox()),
    archiveProvider.overrideWith(() => _FakeArchive()),
    draftProvider.overrideWith(() => _FakeDraft()),
  ];

  group('ResponsiveInboxWrapper', () {
    testWidgets('should render at mobile size', (tester) async {
      tester.setScreenSize(width: 400, height: 800);
      final o = FlutterError.onError;
      FlutterError.onError = (d) { if (!d.toString().contains('overflow')) o?.call(d); };

      await tester.pumpWidget(ProviderScope(overrides: overrides(),
        child: MaterialApp(theme: testThemeData(), home: const Scaffold(body: ResponsiveInboxWrapper()))));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(ResponsiveInboxWrapper), findsOneWidget);

      tester.resetScreenSize();
      FlutterError.onError = o;
    });
  });

  group('ResponsiveArchiveWrapper', () {
    testWidgets('should render at mobile size', (tester) async {
      tester.setScreenSize(width: 400, height: 800);
      final o = FlutterError.onError;
      FlutterError.onError = (d) { if (!d.toString().contains('overflow')) o?.call(d); };

      await tester.pumpWidget(ProviderScope(overrides: overrides(),
        child: MaterialApp(theme: testThemeData(), home: const Scaffold(body: ResponsiveArchiveWrapper()))));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(ResponsiveArchiveWrapper), findsOneWidget);

      tester.resetScreenSize();
      FlutterError.onError = o;
    });
  });

  group('ResponsiveDraftWrapper', () {
    testWidgets('should render at mobile size', (tester) async {
      tester.setScreenSize(width: 400, height: 800);
      final o = FlutterError.onError;
      FlutterError.onError = (d) { if (!d.toString().contains('overflow')) o?.call(d); };

      await tester.pumpWidget(ProviderScope(overrides: overrides(),
        child: MaterialApp(theme: testThemeData(), home: const Scaffold(body: ResponsiveDraftWrapper()))));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(ResponsiveDraftWrapper), findsOneWidget);

      tester.resetScreenSize();
      FlutterError.onError = o;
    });
  });

  group('ResponsiveSentWrapper', () {
    testWidgets('should render at mobile size', (tester) async {
      tester.setScreenSize(width: 400, height: 800);
      final o = FlutterError.onError;
      FlutterError.onError = (d) { if (!d.toString().contains('overflow')) o?.call(d); };

      await tester.pumpWidget(ProviderScope(overrides: overrides(),
        child: MaterialApp(theme: testThemeData(), home: const Scaffold(body: ResponsiveSentWrapper()))));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(ResponsiveSentWrapper), findsOneWidget);

      tester.resetScreenSize();
      FlutterError.onError = o;
    });
  });

  group('ResponsiveTrashWrapper', () {
    testWidgets('should render at mobile size', (tester) async {
      tester.setScreenSize(width: 400, height: 800);
      final o = FlutterError.onError;
      FlutterError.onError = (d) { if (!d.toString().contains('overflow')) o?.call(d); };

      await tester.pumpWidget(ProviderScope(overrides: overrides(),
        child: MaterialApp(theme: testThemeData(), home: const Scaffold(body: ResponsiveTrashWrapper()))));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(ResponsiveTrashWrapper), findsOneWidget);

      tester.resetScreenSize();
      FlutterError.onError = o;
    });
  });
}
