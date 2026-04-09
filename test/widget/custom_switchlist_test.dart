// Implements: TC-DISC-SWITCH-001..006
// Source: lib/widgets/custom_switchlist.dart
// Coverage target: 90%+
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:optmsg/widgets/custom_switchlist.dart';

import '../helpers/test_helpers.dart';

void main() {
  group('CustomSwitchListTile', () {
    testWidgets('should render title text', (tester) async {
      // TC-DISC-SWITCH-001
      await tester.pumpWidget(makeTestableWidget(
        CustomSwitchListTile(
          title: 'Notifications',
          value: false,
          onChanged: (_) {},
        ),
      ));

      expect(find.text('Notifications'), findsOneWidget);
    });

    testWidgets('should render CupertinoSwitch with correct value', (tester) async {
      // TC-DISC-SWITCH-002
      await tester.pumpWidget(makeTestableWidget(
        CustomSwitchListTile(
          title: 'Dark Mode',
          value: true,
          onChanged: (_) {},
        ),
      ));

      final switchWidget = tester.widget<CupertinoSwitch>(
        find.byType(CupertinoSwitch),
      );
      expect(switchWidget.value, isTrue);
    });

    testWidgets('should call onChanged when switch is toggled', (tester) async {
      // TC-DISC-SWITCH-003
      bool? changedValue;
      await tester.pumpWidget(makeTestableWidget(
        CustomSwitchListTile(
          title: 'Test',
          value: false,
          onChanged: (v) => changedValue = v,
        ),
      ));

      await tester.tap(find.byType(CupertinoSwitch));
      expect(changedValue, isTrue);
    });

    testWidgets('should render secondary widget when provided', (tester) async {
      // TC-DISC-SWITCH-004
      await tester.pumpWidget(makeTestableWidget(
        CustomSwitchListTile(
          title: 'With Icon',
          value: false,
          onChanged: (_) {},
          secondary: const Icon(Icons.notifications),
        ),
      ));

      expect(find.byIcon(Icons.notifications), findsOneWidget);
    });

    testWidgets('should not render secondary spacing when no secondary', (tester) async {
      // TC-DISC-SWITCH-005
      await tester.pumpWidget(makeTestableWidget(
        CustomSwitchListTile(
          title: 'No Icon',
          value: false,
          onChanged: (_) {},
        ),
      ));

      // No secondary icon should be present
      expect(find.byIcon(Icons.notifications), findsNothing);
    });

    testWidgets('should apply custom contentPadding', (tester) async {
      // TC-DISC-SWITCH-006
      await tester.pumpWidget(makeTestableWidget(
        CustomSwitchListTile(
          title: 'Padded',
          value: false,
          onChanged: (_) {},
          contentPadding: const EdgeInsets.all(20.0),
        ),
      ));

      final padding = tester.widget<Padding>(find.byType(Padding).first);
      expect(padding.padding, const EdgeInsets.all(20.0));
    });
  });
}
