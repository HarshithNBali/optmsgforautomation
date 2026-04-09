// Implements: TC-DISC-POPUP-001..005
// Source: lib/widgets/pop_up_modal.dart
// Coverage target: Push from 88.2% to 95%+
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:optmsg/widgets/pop_up_modal.dart';
import 'package:optmsg/widgets/text_form_field.dart';

import '../helpers/test_helpers.dart';

void main() {
  group('CustomPopupModal', () {
    testWidgets('should render title and subtitle', (tester) async {
      // TC-DISC-POPUP-001
      await tester.pumpWidget(makeTestableWidget(
        CustomPopupModal(
          title: 'Confirm',
          subtitle: 'Are you sure?',
          onPressedButton1: () {},
          onPressedButton2: () {},
          textButton1: 'Cancel',
          textButton2: 'OK',
        ),
      ));

      expect(find.text('Confirm'), findsOneWidget);
      expect(find.text('Are you sure?'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('OK'), findsOneWidget);
    });

    testWidgets('should call onPressedButton1 when first button tapped', (tester) async {
      // TC-DISC-POPUP-002
      bool button1Pressed = false;
      await tester.pumpWidget(makeTestableWidget(
        CustomPopupModal(
          title: 'Test',
          subtitle: 'Sub',
          onPressedButton1: () => button1Pressed = true,
          onPressedButton2: () {},
          textButton1: 'Cancel',
          textButton2: 'OK',
        ),
      ));

      await tester.tap(find.text('Cancel'));
      expect(button1Pressed, isTrue);
    });

    testWidgets('should call onPressedButton2 when second button tapped', (tester) async {
      // TC-DISC-POPUP-003
      bool button2Pressed = false;
      await tester.pumpWidget(makeTestableWidget(
        CustomPopupModal(
          title: 'Test',
          subtitle: 'Sub',
          onPressedButton1: () {},
          onPressedButton2: () => button2Pressed = true,
          textButton1: 'Cancel',
          textButton2: 'Confirm',
        ),
      ));

      await tester.tap(find.text('Confirm'));
      expect(button2Pressed, isTrue);
    });

    testWidgets('should render with formField when provided', (tester) async {
      // TC-DISC-POPUP-004 — covers uncovered lines 106-107
      await tester.pumpWidget(makeTestableWidget(
        CustomPopupModal(
          title: 'Input',
          subtitle: 'Enter value',
          onPressedButton1: () {},
          onPressedButton2: () {},
          textButton1: 'Cancel',
          textButton2: 'Submit',
          formField1: SimpleTextFormField(
            controller: TextEditingController(),
            labelText: 'Enter here',
          ),
        ),
      ));

      expect(find.text('Enter here'), findsOneWidget);
    });

    testWidgets('should render without icon by default', (tester) async {
      // TC-DISC-POPUP-005
      await tester.pumpWidget(makeTestableWidget(
        CustomPopupModal(
          title: 'No Icon',
          subtitle: 'No SVG here',
          onPressedButton1: () {},
          onPressedButton2: () {},
          textButton1: 'A',
          textButton2: 'B',
        ),
      ));

      // No SvgPicture should be rendered
      expect(find.text('No Icon'), findsOneWidget);
    });
  });
}
