import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:optmsg/model/base_response/request_response.dart';
import 'package:optmsg/screens/auth/auth_riverpod/auth_notifier.dart';
import 'package:optmsg/screens/tags/tag_riverpod/tags_notifier.dart';

import '../../helpers/riverpod_test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late RiverpodTestSetup setup;
  late ProviderContainer container;
  late TagsNotifier notifier;

  setUp(() async {
    setup = RiverpodTestSetup();
    when(() => setup.mockStorageService.readObjectData(any()))
        .thenAnswer((_) async => null);
    when(() => setup.mockStorageService.readData(any()))
        .thenAnswer((_) async => null);

    container = ProviderContainer(overrides: setup.serviceOverrides);
    container.read(authProvider);
    await Future.delayed(Duration.zero);

    // TagsNotifier.build() fires Future.microtask(_init) which reads authProvider
    // and calls getUserData. Let it settle.
    await runZonedGuarded(() async {
      notifier = container.read(tagsProvider.notifier);
      await Future.delayed(const Duration(milliseconds: 50));
    }, (e, _) {});
  });

  tearDown(() => container.dispose());

  group('TagsNotifier build()', () {
    test('should return default TagsState', () {
      final state = container.read(tagsProvider);
      expect(state.isLoading, isA<bool>());
      expect(state.tagsList, isNull);
    });
  });

  group('TagsNotifier pure mutators', () {
    test('setEditFlag should update editFlag', () {
      notifier.setEditFlag(true);
      expect(container.read(tagsProvider).editFlag, true);
    });

    test('setId should update id', () {
      notifier.setId(42);
      expect(container.read(tagsProvider).id, 42);
    });

    test('reset should restore initial state', () {
      notifier.setEditFlag(true);
      notifier.setId(5);
      notifier.reset();

      final state = container.read(tagsProvider);
      expect(state.editFlag, false);
      expect(state.id, isNull);
      expect(state.tagsList, isNull);
    });
  });

  group('TagsNotifier getAllTags', () {
    test('should populate tagsList on success', () async {
      when(() => setup.mockTagApi.getTagsList(any()))
          .thenAnswer((_) async => RequestResponse(data: {
                'success': true,
                'message': '',
                'data': {
                  'tags': [
                    {'id': 1, 'tag': 'Work'},
                    {'id': 2, 'tag': 'Personal'},
                  ],
                },
              }));

      await notifier.getAllTags();

      final state = container.read(tagsProvider);
      expect(state.tagsList, isNotNull);
      expect(state.tagsList!.data.tags, hasLength(2));
      expect(state.isLoading, false);
    });

    test('should handle unsuccessful response', () async {
      when(() => setup.mockTagApi.getTagsList(any()))
          .thenAnswer((_) async => RequestResponse(data: {
                'success': false,
                'message': 'Error',
                'data': {'tags': []},
              }));

      await notifier.getAllTags();

      final state = container.read(tagsProvider);
      expect(state.isLoading, false);
    });
  });

  group('TagsNotifier addTag', () {
    test('should call API and refresh tags on success', () async {
      // Stub addTags
      when(() => setup.mockTagApi.addTags(any()))
          .thenAnswer((_) async => RequestResponse(data: {
                'success': true,
                'message': 'Tag added',
              }));

      // Stub getAllTags for the refresh
      when(() => setup.mockTagApi.getTagsList(any()))
          .thenAnswer((_) async => RequestResponse(data: {
                'success': true,
                'message': '',
                'data': {
                  'tags': [
                    {'id': 1, 'tag': 'NewTag'},
                  ],
                },
              }));

      await notifier.addTag('NewTag');

      verify(() => setup.mockTagApi.addTags({'tag': 'NewTag'})).called(1);
    });

    test('should handle API failure', () async {
      when(() => setup.mockTagApi.addTags(any()))
          .thenAnswer((_) async => RequestResponse(data: {
                'success': false,
                'message': 'Duplicate tag',
              }));

      await notifier.addTag('Duplicate');

      final state = container.read(tagsProvider);
      expect(state.isLoading, false);
    });
  });

  group('TagsNotifier editTag', () {
    test('should call API with id and tag', () async {
      when(() => setup.mockTagApi.editTag(any()))
          .thenAnswer((_) async => RequestResponse(data: {
                'success': true,
                'message': 'Tag updated',
              }));

      when(() => setup.mockTagApi.getTagsList(any()))
          .thenAnswer((_) async => RequestResponse(data: {
                'success': true,
                'message': '',
                'data': {'tags': [{'id': 1, 'tag': 'Updated'}]},
              }));

      await notifier.editTag(1, 'Updated');

      verify(() => setup.mockTagApi.editTag({'id': 1, 'tag': 'Updated'}))
          .called(1);
    });
  });

  group('TagsNotifier deleteTag', () {
    test('should call API with id', () async {
      when(() => setup.mockTagApi.deleteTag(any()))
          .thenAnswer((_) async => RequestResponse(data: {
                'success': true,
                'message': 'Tag deleted',
              }));

      when(() => setup.mockTagApi.getTagsList(any()))
          .thenAnswer((_) async => RequestResponse(data: {
                'success': true,
                'message': '',
                'data': {'tags': []},
              }));

      await notifier.deleteTag(1);

      verify(() => setup.mockTagApi.deleteTag({'id': 1})).called(1);
    });
  });
}
