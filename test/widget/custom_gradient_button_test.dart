import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:optmsg/constant/app_colors_extension.dart';
import 'package:optmsg/widgets/button_form_field.dart';

void main() {
  group('CustomGradientButton', () {
    testWidgets('should render button text', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: const [AppColorsExtension.light]),
          home: Scaffold(
            body: CustomGradientButton(
              text: 'Login',
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.text('Login'), findsOneWidget);
    });

    testWidgets('should call onPressed when tapped', (tester) async {
      bool pressed = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: const [AppColorsExtension.light]),
          home: Scaffold(
            body: CustomGradientButton(
              text: 'Submit',
              onPressed: () => pressed = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Submit'));
      expect(pressed, true);
    });

    testWidgets('should not respond to tap when onPressed is null',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: const [AppColorsExtension.light]),
          home: const Scaffold(
            body: CustomGradientButton(
              text: 'Disabled',
              onPressed: null,
            ),
          ),
        ),
      );

      expect(find.text('Disabled'), findsOneWidget);
      // Tap should not crash
      await tester.tap(find.text('Disabled'));
    });

    testWidgets('should show spinner when isLoading is true', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: const [AppColorsExtension.light]),
          home: Scaffold(
            body: CustomGradientButton(
              text: 'Loading',
              onPressed: () {},
              isLoading: true,
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      // Text should not be visible when loading
      expect(find.text('Loading'), findsNothing);
    });

    testWidgets('should show text when isLoading is false', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: const [AppColorsExtension.light]),
          home: Scaffold(
            body: CustomGradientButton(
              text: 'Ready',
              onPressed: () {},
              isLoading: false,
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('Ready'), findsOneWidget);
    });

    testWidgets('should display leadingIcon when provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: const [AppColorsExtension.light]),
          home: Scaffold(
            body: CustomGradientButton(
              text: 'With Icon',
              onPressed: () {},
              leadingIcon: const Icon(Icons.send),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.send), findsOneWidget);
      expect(find.text('With Icon'), findsOneWidget);
    });
  });
}
