// Implements: TC-DISC-EMPTY-001..008
// Source: lib/widgets/empty_state.dart
// Coverage target: 100%
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:optmsg/widgets/empty_state.dart';

import '../helpers/test_helpers.dart';

void main() {
  group('EmptyState', () {
    testWidgets('inbox variant should show mail icon and correct title', (tester) async {
      // TC-DISC-EMPTY-001
      await tester.pumpWidget(makeTestableWidget(
        const EmptyState(variant: EmptyStateVariant.inbox),
      ));

      expect(find.byIcon(Icons.mail_outline), findsOneWidget);
      expect(find.textContaining('caught up'), findsOneWidget);
    });

    testWidgets('notifications variant should show correct icon and title', (tester) async {
      // TC-DISC-EMPTY-002
      await tester.pumpWidget(makeTestableWidget(
        const EmptyState(variant: EmptyStateVariant.notifications),
      ));

      expect(find.byIcon(Icons.notifications_none), findsOneWidget);
      expect(find.text('No notifications yet'), findsOneWidget);
    });

    testWidgets('tags variant should show label icon', (tester) async {
      // TC-DISC-EMPTY-003
      await tester.pumpWidget(makeTestableWidget(
        const EmptyState(variant: EmptyStateVariant.tags),
      ));

      expect(find.byIcon(Icons.label_outline), findsOneWidget);
      expect(find.text('No tags found'), findsOneWidget);
    });

    testWidgets('contacts variant should show person icon', (tester) async {
      // TC-DISC-EMPTY-004
      await tester.pumpWidget(makeTestableWidget(
        const EmptyState(variant: EmptyStateVariant.contacts),
      ));

      expect(find.byIcon(Icons.person_outline), findsOneWidget);
      expect(find.text('No contacts found'), findsOneWidget);
    });

    testWidgets('emailDetail variant should show mail icon', (tester) async {
      await tester.pumpWidget(makeTestableWidget(
        const EmptyState(variant: EmptyStateVariant.emailDetail),
      ));

      expect(find.byIcon(Icons.mail_outline), findsOneWidget);
      expect(find.text('Email not found'), findsOneWidget);
    });

    testWidgets('generic variant should show info icon', (tester) async {
      // TC-DISC-EMPTY-005
      await tester.pumpWidget(makeTestableWidget(
        const EmptyState(variant: EmptyStateVariant.generic),
      ));

      expect(find.byIcon(Icons.info_outline), findsOneWidget);
      expect(find.text('No data found'), findsOneWidget);
    });

    testWidgets('should use custom title when provided', (tester) async {
      // TC-DISC-EMPTY-006
      await tester.pumpWidget(makeTestableWidget(
        const EmptyState(
          variant: EmptyStateVariant.inbox,
          title: 'Custom Empty Title',
        ),
      ));

      expect(find.text('Custom Empty Title'), findsOneWidget);
    });

    testWidgets('should have 64px icon size', (tester) async {
      // TC-DISC-EMPTY-007
      await tester.pumpWidget(makeTestableWidget(
        const EmptyState(variant: EmptyStateVariant.inbox),
      ));

      final icon = tester.widget<Icon>(find.byIcon(Icons.mail_outline));
      expect(icon.size, 64);
    });
  });

  group('EmptyStateVariant', () {
    test('should have 6 variants', () {
      // TC-DISC-EMPTY-008
      expect(EmptyStateVariant.values, hasLength(6));
    });
  });
}
