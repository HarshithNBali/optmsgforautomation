import 'package:flutter_test/flutter_test.dart';
import 'package:optmsg/screens/contacts/add_contact_riverpod/add_contact_state.dart';
import 'package:optmsg/screens/contacts/edit_contact_riverpod/edit_contact_state.dart';
import 'package:optmsg/screens/contacts/view_contact_riverpod/view_contact_state.dart';
import 'package:optmsg/screens/subscription/subscription_riverpod/subscription_state.dart';

void main() {
  group('AddContactState', () {
    test('defaults', () {
      const state = AddContactState();
      expect(state.isLoading, false);
      expect(state.emailFieldCount, 1);
    });

    test('copyWith', () {
      final modified =
          const AddContactState().copyWith(isLoading: true, emailFieldCount: 3);
      expect(modified.isLoading, true);
      expect(modified.emailFieldCount, 3);
    });
  });

  group('EditContactState', () {
    test('defaults', () {
      const state = EditContactState();
      expect(state.isLoading, false);
      expect(state.emailFieldCount, 0);
    });

    test('copyWith', () {
      final modified =
          const EditContactState().copyWith(emailFieldCount: 5);
      expect(modified.emailFieldCount, 5);
    });
  });

  group('ViewContactState', () {
    test('defaults', () {
      const state = ViewContactState();
      expect(state.isSubmitting, false);
      expect(state.loadingContactDetails, false);
      expect(state.readingPaneEnabled, false);
      expect(state.token, '');
      expect(state.emails, isEmpty);
      expect(state.contact, isNull);
    });

    test('copyWith', () {
      final modified = const ViewContactState().copyWith(
        isSubmitting: true,
        token: 'jwt-token',
        readingPaneEnabled: true,
      );
      expect(modified.isSubmitting, true);
      expect(modified.token, 'jwt-token');
      expect(modified.readingPaneEnabled, true);
    });
  });

  group('SubscriptionState', () {
    test('defaults', () {
      const state = SubscriptionState();
      expect(state.data, isEmpty);
      expect(state.isLoading, false);
      expect(state.isFreeUser, false);
    });

    test('copyWith', () {
      final modified = const SubscriptionState().copyWith(
        data: {'plan': 'pro'},
        isFreeUser: true,
      );
      expect(modified.data['plan'], 'pro');
      expect(modified.isFreeUser, true);
    });
  });
}
