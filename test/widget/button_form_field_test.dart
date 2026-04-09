// Implements: TC-DISC-BTN-001..006
// Source: lib/widgets/button_form_field.dart
// Coverage target: Push from 61.5% to 90%+
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:optmsg/widgets/button_form_field.dart';

import '../helpers/test_helpers.dart';

void main() {
  group('CustomGradientButton', () {
    testWidgets('should render text', (tester) async {
      // TC-DISC-BTN-001
      await tester.pumpWidget(makeTestableWidget(
        CustomGradientButton(
          onPressed: () {},
          text: 'Submit',
        ),
      ));

      expect(find.text('Submit'), findsOneWidget);
    });

    testWidgets('should call onPressed when tapped', (tester) async {
      // TC-DISC-BTN-002
      bool pressed = false;
      await tester.pumpWidget(makeTestableWidget(
        CustomGradientButton(
          onPressed: () => pressed = true,
          text: 'Tap Me',
        ),
      ));

      await tester.tap(find.text('Tap Me'));
      expect(pressed, isTrue);
    });

    testWidgets('should apply custom textStyle', (tester) async {
      // TC-DISC-BTN-003
      await tester.pumpWidget(makeTestableWidget(
        CustomGradientButton(
          onPressed: () {},
          text: 'Styled',
          textStyle: const TextStyle(fontSize: 20, color: Colors.red),
        ),
      ));

      expect(find.text('Styled'), findsOneWidget);
    });
  });

  group('CustomButton', () {
    testWidgets('should render text', (tester) async {
      // TC-DISC-BTN-004
      await tester.pumpWidget(makeTestableWidget(
        CustomButton(
          onPressed: () {},
          text: 'Click',
        ),
      ));

      expect(find.text('Click'), findsOneWidget);
    });

    testWidgets('should call onPressed when tapped', (tester) async {
      // TC-DISC-BTN-005
      bool pressed = false;
      await tester.pumpWidget(makeTestableWidget(
        CustomButton(
          onPressed: () => pressed = true,
          text: 'Press',
        ),
      ));

      await tester.tap(find.text('Press'));
      expect(pressed, isTrue);
    });

    testWidgets('should have ElevatedButton', (tester) async {
      // TC-DISC-BTN-006
      await tester.pumpWidget(makeTestableWidget(
        CustomButton(
          onPressed: () {},
          text: 'Test',
        ),
      ));

      expect(find.byType(ElevatedButton), findsOneWidget);
    });
  });
}
