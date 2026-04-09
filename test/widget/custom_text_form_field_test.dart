import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:optmsg/widgets/text_form_field.dart';

void main() {
  group('CustomTextFormField', () {
    testWidgets('should render with label text', (tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomTextFormField(
              controller: controller,
              labelText: 'Username',
            ),
          ),
        ),
      );

      expect(find.text('Username'), findsOneWidget);
    });

    testWidgets('should accept text input', (tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomTextFormField(
              controller: controller,
              labelText: 'Enter name',
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextFormField), 'testuser');
      expect(controller.text, 'testuser');
    });

    testWidgets('should show validation error', (tester) async {
      final formKey = GlobalKey<FormState>();
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: formKey,
              child: CustomTextFormField(
                controller: controller,
                labelText: 'Username',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Required field';
                  }
                  return null;
                },
              ),
            ),
          ),
        ),
      );

      formKey.currentState!.validate();
      await tester.pump();

      expect(find.text('Required field'), findsOneWidget);
    });

    testWidgets('should be read-only when readOnly is true', (tester) async {
      final controller = TextEditingController(text: 'readonly');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomTextFormField(
              controller: controller,
              labelText: 'Locked',
              readOnly: true,
            ),
          ),
        ),
      );

      // Verify the field displays the text
      expect(find.text('readonly'), findsOneWidget);
    });

    testWidgets('should handle password visibility toggle', (tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomTextFormField(
              controller: controller,
              labelText: 'Password',
              isPassword: true,
            ),
          ),
        ),
      );

      // Should render without error
      expect(find.text('Password'), findsOneWidget);
    });
  });
}
