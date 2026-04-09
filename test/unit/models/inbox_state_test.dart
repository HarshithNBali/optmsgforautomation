import 'package:flutter_test/flutter_test.dart';
import 'package:optmsg/screens/email/inbox_riverpod/inbox_state.dart';
import 'package:optmsg/model/inbox_list_model.dart';

import '../../factories/test_data_factories.dart';

void main() {
  group('InboxState', () {
    test('default constructor should have sensible defaults', () {
      const state = InboxState();

      expect(state.isLoading, true);
      expect(state.isFetching, false);
      expect(state.isSearch, false);
      expect(state.items, isEmpty);
      expect(state.selectedEmailIds, isEmpty);
      expect(state.currentPage, 1);
      expect(state.searchKey, '');
      expect(state.emailType, 'inbox');
      expect(state.inboxList, isNull);
      expect(state.userData, isNull);
      expect(state.errorMessage, isNull);
      expect(state.badgeCount, 0);
    });

    group('computed properties', () {
      test('hasEmails should reflect items list', () {
        const empty = InboxState();
        expect(empty.hasEmails, false);

        final email = Emails.fromJson(makeInboxEmailJson());
        final withEmails = InboxState(items: [email]);
        expect(withEmails.hasEmails, true);
      });

      test('hasSelection should reflect selectedEmailIds', () {
        const noSelection = InboxState();
        expect(noSelection.hasSelection, false);

        const withSelection = InboxState(selectedEmailIds: [1, 2]);
        expect(withSelection.hasSelection, true);
      });

      test('selectedCount should return count of selected IDs', () {
        const state = InboxState(selectedEmailIds: [1, 2, 3]);
        expect(state.selectedCount, 3);
      });

      test('isAllSelected should be true when all items are selected', () {
        final email1 = Emails.fromJson(makeInboxEmailJson(id: 1));
        final email2 = Emails.fromJson(makeInboxEmailJson(id: 2));

        final state = InboxState(
          items: [email1, email2],
          selectedEmailIds: [1, 2],
        );
        expect(state.isAllSelected, true);

        final partial = state.copyWith(selectedEmailIds: [1]);
        expect(partial.isAllSelected, false);
      });

      test('isAllSelected should be false when items is empty', () {
        const state = InboxState(selectedEmailIds: []);
        expect(state.isAllSelected, false);
      });

      test('hasActiveFilters should detect tag or search filters', () {
        const noFilter = InboxState();
        expect(noFilter.hasActiveFilters, false);

        const withSearch = InboxState(searchKey: 'hello');
        expect(withSearch.hasActiveFilters, true);

        const withTag = InboxState(tagIdFilter: [1]);
        expect(withTag.hasActiveFilters, true);
      });

      test('canLoadMore should check inboxList.data.nextPage', () {
        const noList = InboxState();
        expect(noList.canLoadMore, false);

        final withNextPage = InboxState(
          inboxList: InboxListModel.fromJson(
            makeInboxListJson(nextPage: true),
          ),
        );
        expect(withNextPage.canLoadMore, true);

        final noNextPage = InboxState(
          inboxList: InboxListModel.fromJson(
            makeInboxListJson(nextPage: false),
          ),
        );
        expect(noNextPage.canLoadMore, false);
      });

      test('isReadingPaneActive should check selectedEmailId', () {
        const inactive = InboxState();
        expect(inactive.isReadingPaneActive, false);

        const active = InboxState(selectedEmailIdForReadingPane: 42);
        expect(active.isReadingPaneActive, true);
      });
    });

    test('copyWith should create a modified copy', () {
      const original = InboxState();
      final modified = original.copyWith(
        isLoading: false,
        currentPage: 3,
        searchKey: 'test',
      );

      expect(modified.isLoading, false);
      expect(modified.currentPage, 3);
      expect(modified.searchKey, 'test');
      // Other fields unchanged
      expect(modified.emailType, original.emailType);
    });
  });
}
