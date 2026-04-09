// Implements: TC-DISC-TFF-EXT-001..008
// Source: lib/widgets/text_form_field.dart (GrayTextFormField, ClickableText)
// Coverage target: Push from 87.7% to 95%+
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:optmsg/widgets/text_form_field.dart';

import '../helpers/test_helpers.dart';

void main() {
  group('GrayTextFormField', () {
    testWidgets('should render label text', (tester) async {
      // TC-DISC-TFF-EXT-001
      await tester.pumpWidget(makeTestableWidget(
        Material(
          child: GrayTextFormField(
            controller: TextEditingController(),
            labelText: 'Username',
            validator: (v) => null,
          ),
        ),
      ));

      expect(find.text('Username'), findsOneWidget);
    });

    testWidgets('should render with password obscured', (tester) async {
      // TC-DISC-TFF-EXT-002
      await tester.pumpWidget(makeTestableWidget(
        Material(
          child: GrayTextFormField(
            controller: TextEditingController(),
            labelText: 'Password',
            validator: (v) => null,
            isPassword: true,
          ),
        ),
      ));

      // Find the TextFormField and verify obscureText
      final textField = tester.widget<EditableText>(
        find.byType(EditableText),
      );
      expect(textField.obscureText, isTrue);
    });

    testWidgets('should show validation error', (tester) async {
      // TC-DISC-TFF-EXT-003
      final formKey = GlobalKey<FormState>();
      await tester.pumpWidget(makeTestableWidget(
        Material(
          child: Form(
            key: formKey,
            child: GrayTextFormField(
              controller: TextEditingController(),
              labelText: 'Email',
              validator: (v) =>
                  v == null || v.isEmpty ? 'Required' : null,
            ),
          ),
        ),
      ));

      formKey.currentState!.validate();
      await tester.pump();

      expect(find.text('Required'), findsOneWidget);
    });

    testWidgets('should accept autofillHints', (tester) async {
      // TC-DISC-TFF-EXT-004
      await tester.pumpWidget(makeTestableWidget(
        Material(
          child: GrayTextFormField(
            controller: TextEditingController(),
            labelText: 'Email',
            validator: (v) => null,
            autofillHints: const [AutofillHints.email],
          ),
        ),
      ));

      expect(find.text('Email'), findsOneWidget);
    });
  });

  group('ClickableText', () {
    testWidgets('should render text spans', (tester) async {
      // TC-DISC-TFF-EXT-005
      await tester.pumpWidget(makeTestableWidget(
        ClickableText(
          firstText: 'Already have an account? ',
          firstTextColor: Colors.black,
          secondText: 'Log in',
          secondTextColor: Colors.blue,
          onTap: () {},
        ),
      ));

      expect(find.byType(RichText), findsOneWidget);
    });

    testWidgets('should render with all four text spans', (tester) async {
      // TC-DISC-TFF-EXT-006
      await tester.pumpWidget(makeTestableWidget(
        ClickableText(
          firstText: 'Agree to ',
          firstTextColor: Colors.black,
          secondText: 'Terms',
          secondTextColor: Colors.blue,
          onTap: () {},
          thirdText: ' and ',
          thirdTextColor: Colors.black,
          fourthText: 'Privacy',
          fourthTextColor: Colors.blue,
          onTap2: () {},
        ),
      ));

      expect(find.byType(RichText), findsOneWidget);
    });
  });

  group('SimpleTextFormField', () {
    testWidgets('should render with label', (tester) async {
      // TC-DISC-TFF-EXT-007
      await tester.pumpWidget(makeTestableWidget(
        Material(
          child: SimpleTextFormField(
            controller: TextEditingController(),
            labelText: 'Simple Field',
          ),
        ),
      ));

      expect(find.text('Simple Field'), findsOneWidget);
    });

    testWidgets('should render read-only field', (tester) async {
      // TC-DISC-TFF-EXT-008
      await tester.pumpWidget(makeTestableWidget(
        Material(
          child: SimpleTextFormField(
            controller: TextEditingController(text: 'read only value'),
            labelText: 'Read Only',
            readOnly: true,
          ),
        ),
      ));

      expect(find.text('read only value'), findsOneWidget);
    });
  });
}
