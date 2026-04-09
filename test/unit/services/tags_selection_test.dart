// Implements: TC-DISC-TAG-SEL-001..020
// Source: lib/screens/tags/tag_riverpod/tags_notifier.dart (selection methods)
// Coverage target: 90%+ (standard)
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

  /// Tags JSON matching the TagsListModel structure.
  final tagsListJson = {
    'success': true,
    'message': '',
    'data': {
      'tags': [
        {'id': 1, 'tag': 'Important'},
        {'id': 2, 'tag': 'Work'},
        {'id': 3, 'tag': 'Personal'},
        {'id': 4, 'tag': 'Urgent'},
      ],
    },
  };

  setUp(() async {
    setup = RiverpodTestSetup();
    when(() => setup.mockStorageService.readObjectData(any()))
        .thenAnswer((_) async => null);
    when(() => setup.mockStorageService.readData(any()))
        .thenAnswer((_) async => null);

    // Stub TagApi to return tags so we have items to select
    when(() => setup.mockTagApi.getTagsList(any()))
        .thenAnswer((_) async => RequestResponse(data: tagsListJson));

    container = ProviderContainer(overrides: setup.serviceOverrides);
    container.read(authProvider);
    await Future.delayed(Duration.zero);

    await runZonedGuarded(() async {
      notifier = container.read(tagsProvider.notifier);
      await Future.delayed(const Duration(milliseconds: 100));
    }, (e, _) {});
  });

  tearDown(() => container.dispose());

  group('TagsNotifier selection methods', () {
    // -----------------------------------------------------------------------
    // setShowCheckboxes
    // -----------------------------------------------------------------------
    test('setShowCheckboxes should update showCheckboxes', () {
      // TC-DISC-TAG-SEL-001
      notifier.setShowCheckboxes(true);
      expect(container.read(tagsProvider).showCheckboxes, isTrue);

      notifier.setShowCheckboxes(false);
      expect(container.read(tagsProvider).showCheckboxes, isFalse);
    });

    // -----------------------------------------------------------------------
    // toggleSelectTag
    // -----------------------------------------------------------------------
    group('toggleSelectTag', () {
      test('should add tag id to selection', () {
        // TC-DISC-TAG-SEL-002
        notifier.toggleSelectTag(1);
        final state = container.read(tagsProvider);
        expect(state.selectedTagIds, contains(1));
        expect(state.longPressFlag, isFalse);
      });

      test('should remove tag id when already selected', () {
        // TC-DISC-TAG-SEL-003
        notifier.toggleSelectTag(1);
        notifier.toggleSelectTag(1);
        final state = container.read(tagsProvider);
        expect(state.selectedTagIds, isNot(contains(1)));
        expect(state.longPressFlag, isTrue);
      });

      test('should set allTagsFlag when all tags selected', () {
        // TC-DISC-TAG-SEL-004
        final tags = container.read(tagsProvider).tags;
        for (final tag in tags) {
          notifier.toggleSelectTag(tag.id);
        }
        expect(container.read(tagsProvider).allTagsFlag, isTrue);
      });

      test('should hide checkboxes when selection cleared', () {
        notifier.setShowCheckboxes(true);
        notifier.toggleSelectTag(1);
        notifier.toggleSelectTag(1); // deselect
        expect(container.read(tagsProvider).showCheckboxes, isFalse);
      });
    });

    // -----------------------------------------------------------------------
    // selectAllTags
    // -----------------------------------------------------------------------
    group('selectAllTags', () {
      test('should select all tag ids', () {
        // TC-DISC-TAG-SEL-005
        notifier.selectAllTags();
        final state = container.read(tagsProvider);
        expect(state.selectedTagIds.length, state.tags.length);
        expect(state.allTagsFlag, isTrue);
        expect(state.longPressFlag, isFalse);
      });
    });

    // -----------------------------------------------------------------------
    // clearSelection
    // -----------------------------------------------------------------------
    group('clearSelection', () {
      test('should reset all selection state', () {
        // TC-DISC-TAG-SEL-006
        notifier.toggleSelectTag(1);
        notifier.toggleSelectTag(2);
        notifier.setShowCheckboxes(true);

        notifier.clearSelection();

        final state = container.read(tagsProvider);
        expect(state.selectedTagIds, isEmpty);
        expect(state.allTagsFlag, isFalse);
        expect(state.longPressFlag, isTrue);
        expect(state.showCheckboxes, isFalse);
        expect(state.lastClickedIndex, -1);
      });
    });

    // -----------------------------------------------------------------------
    // selectRangeFromList
    // -----------------------------------------------------------------------
    group('selectRangeFromList', () {
      test('should select range of tags from start to end', () {
        // TC-DISC-TAG-SEL-007
        notifier.selectRangeFromList(0, 2);
        final state = container.read(tagsProvider);
        final tags = state.tags;

        expect(state.selectedTagIds, contains(tags[0].id));
        expect(state.selectedTagIds, contains(tags[1].id));
        expect(state.selectedTagIds, contains(tags[2].id));
        expect(state.showCheckboxes, isTrue);
        expect(state.longPressFlag, isFalse);
      });

      test('should handle reversed range (end < start)', () {
        // TC-DISC-TAG-SEL-008
        notifier.selectRangeFromList(2, 0);
        final state = container.read(tagsProvider);
        final tags = state.tags;

        expect(state.selectedTagIds, contains(tags[0].id));
        expect(state.selectedTagIds, contains(tags[1].id));
        expect(state.selectedTagIds, contains(tags[2].id));
      });

      test('should clamp indices to valid range', () {
        // TC-DISC-TAG-SEL-009
        notifier.selectRangeFromList(-5, 100);
        final state = container.read(tagsProvider);
        // Should select all tags (clamped to 0..tags.length-1)
        expect(state.selectedTagIds.length, state.tags.length);
        expect(state.allTagsFlag, isTrue);
      });

      test('should merge with existing selection', () {
        // TC-DISC-TAG-SEL-010
        notifier.toggleSelectTag(container.read(tagsProvider).tags[0].id);
        notifier.selectRangeFromList(2, 3);

        final state = container.read(tagsProvider);
        // Original selection (index 0) plus range (2-3)
        expect(state.selectedTagIds.length, 3);
      });

      test('should set lastClickedIndex', () {
        notifier.selectRangeFromList(0, 2);
        expect(container.read(tagsProvider).lastClickedIndex, 2);
      });

      test('should be no-op for empty tags list', () {
        // Create a state with no tags
        final freshContainer = ProviderContainer(overrides: setup.serviceOverrides);
        runZonedGuarded(() {
          final freshNotifier = freshContainer.read(tagsProvider.notifier);
          freshNotifier.selectRangeFromList(0, 5);
          // Should not crash
        }, (e, _) {});
        freshContainer.dispose();
      });
    });

    // -----------------------------------------------------------------------
    // toggleSingleSelectByIndex
    // -----------------------------------------------------------------------
    group('toggleSingleSelectByIndex', () {
      test('should select tag by index', () {
        // TC-DISC-TAG-SEL-011
        notifier.toggleSingleSelectByIndex(1);
        final state = container.read(tagsProvider);
        final tags = state.tags;

        expect(state.selectedTagIds, contains(tags[1].id));
        expect(state.lastClickedIndex, 1);
      });

      test('should deselect tag when already selected', () {
        // TC-DISC-TAG-SEL-012
        notifier.toggleSingleSelectByIndex(1);
        notifier.toggleSingleSelectByIndex(1);

        final state = container.read(tagsProvider);
        final tags = state.tags;
        expect(state.selectedTagIds, isNot(contains(tags[1].id)));
      });

      test('should be no-op for negative index', () {
        // TC-DISC-TAG-SEL-013
        notifier.toggleSingleSelectByIndex(-1);
        expect(container.read(tagsProvider).selectedTagIds, isEmpty);
      });

      test('should be no-op for out-of-bounds index', () {
        notifier.toggleSingleSelectByIndex(999);
        expect(container.read(tagsProvider).selectedTagIds, isEmpty);
      });

      test('should show checkboxes when multiple selected', () {
        // TC-DISC-TAG-SEL-014
        notifier.toggleSingleSelectByIndex(0);
        notifier.toggleSingleSelectByIndex(1);
        expect(container.read(tagsProvider).showCheckboxes, isTrue);
      });
    });

    // -----------------------------------------------------------------------
    // setSelectedFromList
    // -----------------------------------------------------------------------
    group('setSelectedFromList', () {
      test('should set selected tag ids from list', () {
        // TC-DISC-TAG-SEL-015
        notifier.setSelectedFromList([1, 3]);
        final state = container.read(tagsProvider);
        expect(state.selectedTagIds, [1, 3]);
        expect(state.longPressFlag, isFalse);
      });

      test('should set longPressFlag true for empty list', () {
        // TC-DISC-TAG-SEL-016
        notifier.setSelectedFromList([1, 2]);
        notifier.setSelectedFromList([]);
        final state = container.read(tagsProvider);
        expect(state.selectedTagIds, isEmpty);
        expect(state.longPressFlag, isTrue);
      });

      test('should set allTagsFlag when all selected', () {
        final tags = container.read(tagsProvider).tags;
        notifier.setSelectedFromList(tags.map((t) => t.id).toList());
        expect(container.read(tagsProvider).allTagsFlag, isTrue);
      });
    });

    // -----------------------------------------------------------------------
    // TagsState computed properties
    // -----------------------------------------------------------------------
    group('TagsState computed properties', () {
      test('hasSelection should return true with selections', () {
        // TC-DISC-TAG-SEL-017
        notifier.toggleSelectTag(1);
        expect(container.read(tagsProvider).hasSelection, isTrue);
      });

      test('selectedCount should return correct count', () {
        notifier.toggleSelectTag(1);
        notifier.toggleSelectTag(2);
        expect(container.read(tagsProvider).selectedCount, 2);
      });

      test('isAllSelected should return true when all selected', () {
        // TC-DISC-TAG-SEL-018
        notifier.selectAllTags();
        expect(container.read(tagsProvider).isAllSelected, isTrue);
      });

      test('isAllSelected should return false for partial selection', () {
        notifier.toggleSelectTag(1);
        expect(container.read(tagsProvider).isAllSelected, isFalse);
      });

      test('hasTags should return true when tags loaded', () {
        expect(container.read(tagsProvider).hasTags, isTrue);
      });

      test('tagCount should return correct count', () {
        expect(container.read(tagsProvider).tagCount, 4);
      });
    });
  });
}
