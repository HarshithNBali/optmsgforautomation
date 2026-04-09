// Implements: TC-DISC-RPP-001..008
// Source: lib/widgets/reading_pane_placeholder.dart
// Coverage target: 90%+
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:optmsg/widgets/reading_pane_placeholder.dart';

import '../helpers/test_helpers.dart';

void main() {
  group('ReadingPanePlaceholder', () {
    testWidgets('should render icon, title, and default subtitle', (tester) async {
      // TC-DISC-RPP-001
      await tester.pumpWidget(makeTestableWidget(
        const ReadingPanePlaceholder(
          icon: Icons.mail_outline,
          title: 'Test Title',
        ),
      ));

      expect(find.byIcon(Icons.mail_outline), findsOneWidget);
      expect(find.text('Test Title'), findsOneWidget);
      expect(find.text('You have not selected anything'), findsOneWidget);
    });

    testWidgets('should render custom subtitle', (tester) async {
      // TC-DISC-RPP-002
      await tester.pumpWidget(makeTestableWidget(
        const ReadingPanePlaceholder(
          icon: Icons.person,
          title: 'Custom',
          subtitle: 'Custom subtitle',
        ),
      ));

      expect(find.text('Custom subtitle'), findsOneWidget);
    });

    testWidgets('.inbox() should show mail icon and inbox text', (tester) async {
      // TC-DISC-RPP-003
      await tester.pumpWidget(makeTestableWidget(
        const ReadingPanePlaceholder.inbox(),
      ));

      expect(find.byIcon(Icons.mail_outline), findsOneWidget);
      expect(find.text('Select a message to read'), findsOneWidget);
    });

    testWidgets('.draft() should show mail icon and draft text', (tester) async {
      // TC-DISC-RPP-004
      await tester.pumpWidget(makeTestableWidget(
        const ReadingPanePlaceholder.draft(),
      ));

      expect(find.byIcon(Icons.mail_outline), findsOneWidget);
      expect(find.text('Select a draft to edit'), findsOneWidget);
    });

    testWidgets('.contacts() should show person icon and contacts text', (tester) async {
      // TC-DISC-RPP-005
      await tester.pumpWidget(makeTestableWidget(
        const ReadingPanePlaceholder.contacts(),
      ));

      expect(find.byIcon(Icons.person_outline), findsOneWidget);
      expect(find.text('Select a contact to view details'), findsOneWidget);
    });

    testWidgets('should have 64px icon size', (tester) async {
      // TC-DISC-RPP-006
      await tester.pumpWidget(makeTestableWidget(
        const ReadingPanePlaceholder.inbox(),
      ));

      final icon = tester.widget<Icon>(find.byIcon(Icons.mail_outline));
      expect(icon.size, 64);
    });
  });
}
