import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:optmsg/constant/app_colors_extension.dart';
import 'package:optmsg/screens/auth/login/widgets/login_form_widget.dart';
import 'package:optmsg/services/form_validation.dart';
import 'package:optmsg/widgets/button_form_field.dart';
import 'package:optmsg/widgets/text_form_field.dart';

void main() {
  group('LoginFormWidget', () {
    late GlobalKey<FormState> formKey;
    late TextEditingController controller;
    late FormValidationService validation;

    setUp(() {
      formKey = GlobalKey<FormState>();
      controller = TextEditingController();
      validation = FormValidationService();
    });

    tearDown(() {
      controller.dispose();
    });

    Widget buildWidget({
      VoidCallback? onLogin,
      VoidCallback? onForgot,
      bool isLoading = false,
    }) {
      return MaterialApp(
        theme: ThemeData(extensions: const [AppColorsExtension.light]),
        home: Scaffold(
          body: SingleChildScrollView(
            child: LoginFormWidget(
              formKey: formKey,
              userNameController: controller,
              formValidation: validation,
              onLogin: onLogin ?? () {},
              onForgot: onForgot ?? () {},
              isLoading: isLoading,
            ),
          ),
        ),
      );
    }

    testWidgets('should render username field and login button', (tester) async {
      await tester.pumpWidget(buildWidget());

      expect(find.byType(CustomTextFormField), findsOneWidget);
      expect(find.byType(CustomGradientButton), findsOneWidget);
      expect(find.text('Login'), findsOneWidget);
    });

    testWidgets('should render forgot username link', (tester) async {
      await tester.pumpWidget(buildWidget());

      expect(find.text('Forgot Username?'), findsOneWidget);
    });

    testWidgets('should render email domain suffix', (tester) async {
      await tester.pumpWidget(buildWidget());

      // emailExtension is environment-dependent (@staging.optmsg.com or @optmsg.com)
      expect(find.textContaining('optmsg.com'), findsOneWidget);
    });

    testWidgets('should call onLogin when button is tapped with valid input',
        (tester) async {
      bool loginCalled = false;

      await tester.pumpWidget(buildWidget(
        onLogin: () => loginCalled = true,
      ));

      // Enter valid username
      await tester.enterText(find.byType(TextFormField), 'testuser');
      await tester.pump();

      // Tap login button
      await tester.tap(find.text('Login'));
      await tester.pump();

      // onLogin should be called (form validation passes)
      // Note: the actual form validation is handled by the parent screen,
      // not LoginFormWidget itself — the button just calls onLogin directly
      expect(loginCalled, true);
    });

    testWidgets('should call onForgot when forgot link is tapped',
        (tester) async {
      bool forgotCalled = false;

      await tester.pumpWidget(buildWidget(
        onForgot: () => forgotCalled = true,
      ));

      await tester.tap(find.text('Forgot Username?'));
      expect(forgotCalled, true);
    });

    testWidgets('should disable button when isLoading is true',
        (tester) async {
      bool loginCalled = false;

      await tester.pumpWidget(buildWidget(
        onLogin: () => loginCalled = true,
        isLoading: true,
      ));

      // Button text still shows (LoginFormWidget sets onPressed: null, not isLoading on the button)
      expect(find.text('Login'), findsOneWidget);

      // Tapping should not trigger onLogin (button's onPressed is null)
      await tester.tap(find.text('Login'));
      expect(loginCalled, false);
    });

    testWidgets('should accept only valid username characters',
        (tester) async {
      await tester.pumpWidget(buildWidget());

      // Enter text with special characters — only [a-zA-Z0-9_.-] allowed
      await tester.enterText(find.byType(TextFormField), 'user@name!');
      await tester.pump();

      // The input formatter should strip invalid characters
      expect(controller.text, 'username');
    });

    testWidgets('should validate empty username on form submit',
        (tester) async {
      await tester.pumpWidget(buildWidget());

      // Trigger validation without entering text
      formKey.currentState!.validate();
      await tester.pump();

      // Should show validation error
      expect(find.text('Please enter username'), findsOneWidget);
    });
  });
}
