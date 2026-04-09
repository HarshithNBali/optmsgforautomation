import 'package:flutter_test/flutter_test.dart';
import 'package:optmsg/screens/settings/profile_riverpod/profile_state.dart';
import 'package:optmsg/screens/helpCenter/help_center_state.dart';
import 'package:optmsg/screens/settings/account_riverpod/account_state.dart';
import 'package:optmsg/screens/tags/tag_riverpod/tags_state.dart';
import 'package:optmsg/screens/email/draft_riverpod/draft_state.dart';

void main() {
  group('ProfileState', () {
    test('defaults', () {
      const state = ProfileState();
      expect(state.isLoading, false);
      expect(state.isEdit, false);
      expect(state.profile, isNull);
    });

    test('hasProfile', () {
      expect(const ProfileState().hasProfile, false);
    });

    test('isEditMode / isViewMode', () {
      const state = ProfileState(isEdit: true);
      expect(state.isEditMode, true);
      expect(state.isViewMode, false);

      expect(const ProfileState().isViewMode, true);
    });

    test('copyWith', () {
      final modified = const ProfileState().copyWith(isLoading: true, isEdit: true);
      expect(modified.isLoading, true);
      expect(modified.isEdit, true);
    });
  });

  group('HelpCenterState', () {
    test('defaults', () {
      const state = HelpCenterState();
      expect(state.isLoading, false);
      expect(state.selectedCategory, '');
      expect(state.searchQuery, '');
      expect(state.expandedItems, isEmpty);
    });

    test('hasSearchQuery', () {
      expect(const HelpCenterState().hasSearchQuery, false);
      expect(const HelpCenterState(searchQuery: 'faq').hasSearchQuery, true);
    });

    test('hasExpandedItems', () {
      expect(const HelpCenterState().hasExpandedItems, false);
      expect(const HelpCenterState(expandedItems: ['a']).hasExpandedItems, true);
    });

    test('hasSelectedCategory', () {
      expect(const HelpCenterState().hasSelectedCategory, false);
      expect(const HelpCenterState(selectedCategory: 'billing').hasSelectedCategory, true);
    });

    test('copyWith', () {
      final modified = const HelpCenterState().copyWith(
        searchQuery: 'test',
        selectedCategory: 'billing',
      );
      expect(modified.searchQuery, 'test');
      expect(modified.selectedCategory, 'billing');
    });
  });

  group('AccountState', () {
    test('defaults', () {
      const state = AccountState();
      expect(state.userData, isNull);
      expect(state.subscriptionDate, '');
      expect(state.isLoading, false);
    });

    test('hasUserData', () {
      expect(const AccountState().hasUserData, false);
      const state = AccountState(userData: {'name': 'Test'});
      expect(state.hasUserData, true);
    });

    test('accountName and accountEmail from userData', () {
      const state = AccountState(
        userData: {'name': 'Test User', 'email': 'test@example.com'},
      );
      expect(state.accountName, 'Test User');
      expect(state.accountEmail, 'test@example.com');
    });

    test('accountName defaults to empty when no userData', () {
      expect(const AccountState().accountName, '');
      expect(const AccountState().accountEmail, '');
    });

    test('hasSubscription', () {
      expect(const AccountState().hasSubscription, false);
      expect(const AccountState(subscriptionDate: '2025-01-01').hasSubscription, true);
    });
  });

  group('TagsState', () {
    test('defaults', () {
      const state = TagsState();
      expect(state.tagsList, isNull);
      expect(state.id, isNull);
      expect(state.isLoading, false);
      expect(state.editFlag, false);
    });

    test('hasTagsList', () {
      expect(const TagsState().hasTagsList, false);
    });

    test('hasTags', () {
      expect(const TagsState().hasTags, false);
    });

    test('tagCount', () {
      expect(const TagsState().tagCount, 0);
    });

    test('isEditMode', () {
      expect(const TagsState().isEditMode, false);
      expect(const TagsState(editFlag: true).isEditMode, true);
    });

    test('hasSelectedId', () {
      expect(const TagsState().hasSelectedId, false);
      expect(const TagsState(id: 5).hasSelectedId, true);
    });

    test('copyWith', () {
      final modified = const TagsState().copyWith(isLoading: true, id: 3);
      expect(modified.isLoading, true);
      expect(modified.id, 3);
    });
  });

  group('DraftState', () {
    test('defaults', () {
      const state = DraftState();
      expect(state.isLoading, false);
      expect(state.isFetching, false);
      expect(state.isSearch, false);
      expect(state.items, isEmpty);
      expect(state.selectedEmailIds, isEmpty);
      expect(state.currentPage, 1);
      expect(state.searchKey, '');
      expect(state.emailType, 'draft');
      expect(state.draftList, isNull);
      expect(state.readingPaneEnabled, false);
    });

    test('hasEmails', () {
      expect(const DraftState().hasEmails, false);
    });

    test('hasSelection', () {
      expect(const DraftState().hasSelection, false);
      expect(const DraftState(selectedEmailIds: [1, 2]).hasSelection, true);
    });

    test('selectedCount', () {
      expect(const DraftState(selectedEmailIds: [1, 2, 3]).selectedCount, 3);
    });

    test('canLoadMore', () {
      expect(const DraftState().canLoadMore, false);
    });

    test('isAllSelected when empty', () {
      expect(const DraftState().isAllSelected, false);
    });

    test('isReadingPaneActive', () {
      expect(const DraftState().isReadingPaneActive, false);
      expect(const DraftState(selectedEmailIdForReadingPane: 1).isReadingPaneActive, true);
    });

    test('copyWith', () {
      final modified = const DraftState().copyWith(
        isLoading: true,
        currentPage: 2,
        searchKey: 'draft',
      );
      expect(modified.isLoading, true);
      expect(modified.currentPage, 2);
      expect(modified.searchKey, 'draft');
    });
  });
}
