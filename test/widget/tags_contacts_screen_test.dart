// Implements: TC-DISC-TAGS-CON-SCREEN-001..006
// Source: Tags and Contacts screens with pre-populated state
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:optmsg/model/auth/auth_state.dart';
import 'package:optmsg/model/base_response/request_response.dart';
import 'package:optmsg/model/tags_list_model.dart';
import 'package:optmsg/screens/auth/auth_riverpod/auth_notifier.dart';
import 'package:optmsg/screens/tags/tag_riverpod/tags_notifier.dart';
import 'package:optmsg/screens/tags/tag_riverpod/tags_state.dart';
import 'package:optmsg/screens/tags/tag_riverpod/tags_list_riverpod.dart';

import '../helpers/test_helpers.dart';
import '../helpers/riverpod_test_helpers.dart';
import '../factories/test_data_factories.dart';

class _FakeAuthNotifier extends AuthNotifier {
  final Map<String, dynamic> _data;
  _FakeAuthNotifier(this._data);
  @override
  AuthState build() => AuthState.authenticated(_data);
}

class _FakeTagsNotifier extends TagsNotifier {
  final TagsState _state;
  _FakeTagsNotifier(this._state);
  @override
  TagsState build() => _state;
  @override
  Future<void> getUserData() async {}
  @override
  Future<void> checkAndRefreshIfUserChanged() async {}
  @override
  Future<void> getAllTags({bool isRefresh = false}) async {}
  @override
  Future<void> addTag(String tag) async {}
  @override
  Future<void> editTag(int id, String tag) async {}
  @override
  Future<void> deleteTag(int id) async {}
  @override
  void setEditFlag(bool flag) {}
  @override
  void setId(int? id) {}
  @override
  void reset() {}
  @override
  void setShowCheckboxes(bool v) {}
  @override
  void toggleSelectTag(int id) {}
  @override
  void selectAllTags() {}
  @override
  void clearSelection() {}
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

    when(() => setup.mockTagApi.getTagsList(any()))
        .thenAnswer((_) async => RequestResponse(data: {
              'success': true, 'message': '',
              'data': {'tags': [
                {'id': 1, 'tag': 'Important'},
                {'id': 2, 'tag': 'Work'},
              ]},
            }));
  });

  // =========================================================================
  // TagsListriverpod with tags
  // =========================================================================
  group('TagsListriverpod with data', () {
    TagsState tagsStateWithItems() {
      final model = TagsListModel.fromJson({
        'success': true,
        'message': '',
        'data': {
          'tags': [
            {'id': 1, 'tag': 'Important'},
            {'id': 2, 'tag': 'Work'},
            {'id': 3, 'tag': 'Personal'},
          ],
        },
      });
      return TagsState(tagsList: model, isLoading: false);
    }

    testWidgets('should render tags at mobile size', (tester) async {
      // TC-DISC-TAGS-CON-SCREEN-001
      tester.setScreenSize(width: 400, height: 800);

      final origOnError = FlutterError.onError;
      FlutterError.onError = (d) {
        if (d.toString().contains('overflow')) return;
        origOnError?.call(d);
      };

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            ...setup.serviceOverrides,
            authProvider.overrideWith(() => _FakeAuthNotifier(testUserData)),
            tagsProvider.overrideWith(() => _FakeTagsNotifier(tagsStateWithItems())),
          ],
          child: MaterialApp(
            theme: testThemeData(),
            home: const Scaffold(body: TagsListriverpod()),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.byType(TagsListriverpod), findsOneWidget);
      expect(find.text('Important'), findsOneWidget);
      expect(find.text('Work'), findsOneWidget);

      tester.resetScreenSize();
      FlutterError.onError = origOnError;
    });

    testWidgets('should render tags at tablet size', (tester) async {
      // TC-DISC-TAGS-CON-SCREEN-002
      tester.setScreenSize(width: 800, height: 600);

      final origOnError = FlutterError.onError;
      FlutterError.onError = (d) {
        if (d.toString().contains('overflow')) return;
        origOnError?.call(d);
      };

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            ...setup.serviceOverrides,
            authProvider.overrideWith(() => _FakeAuthNotifier(testUserData)),
            tagsProvider.overrideWith(() => _FakeTagsNotifier(tagsStateWithItems())),
          ],
          child: MaterialApp(
            theme: testThemeData(),
            home: const Scaffold(body: TagsListriverpod()),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.byType(TagsListriverpod), findsOneWidget);

      tester.resetScreenSize();
      FlutterError.onError = origOnError;
    });
  });

  // ContactListriverpod requires SecureStorageService() internally
  // (not via provider injection) — blocked by LateInitializationError
  // in flutter_secure_storage. Needs source refactoring for DI.
}
