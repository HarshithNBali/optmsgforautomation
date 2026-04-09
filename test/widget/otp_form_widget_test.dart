import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:optmsg/constant/app_colors_extension.dart';
import 'package:optmsg/screens/auth/enterOtp/widgets/otp_form_widget.dart';
import 'package:optmsg/widgets/button_form_field.dart';
import 'package:pinput/pinput.dart';

void main() {
  group('OtpFormWidget', () {
    late GlobalKey<FormState> formKey;
    late TextEditingController otpController;
    late FocusNode focusNode;

    setUp(() {
      formKey = GlobalKey<FormState>();
      otpController = TextEditingController();
      focusNode = FocusNode();
    });

    tearDown(() {
      otpController.dispose();
      focusNode.dispose();
    });

    Widget buildWidget({
      VoidCallback? onSubmit,
      VoidCallback? onResend,
      bool isLoading = false,
      int resendCooldownSeconds = 0,
    }) {
      return MaterialApp(
        theme: ThemeData(extensions: const [AppColorsExtension.light]),
        home: Scaffold(
          body: SingleChildScrollView(
            child: OtpFormWidget(
              formKey: formKey,
              otpController: otpController,
              focusNode: focusNode,
              formattedPhone: '(+1) 555-123-4567',
              onSubmit: onSubmit ?? () {},
              onResend: onResend ?? () {},
              isLoading: isLoading,
              resendCooldownSeconds: resendCooldownSeconds,
              showIcon: false,
            ),
          ),
        ),
      );
    }

    testWidgets('should render verify title and phone number', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(buildWidget());

      expect(find.text('Verify Account'), findsOneWidget);
      expect(find.text('(+1) 555-123-4567'), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('should render pin input', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(buildWidget());

      expect(find.byType(Pinput), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('should render submit button', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(buildWidget());

      expect(find.byType(CustomGradientButton), findsOneWidget);
      expect(find.text('Submit'), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('should render resend area with cooldown', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(buildWidget(resendCooldownSeconds: 30));

      // ClickableText uses RichText spans — verify it renders
      expect(find.byType(RichText), findsWidgets);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('should render resend area without cooldown', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(buildWidget(resendCooldownSeconds: 0));

      expect(find.byType(RichText), findsWidgets);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('should disable submit when isLoading', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      bool submitted = false;

      await tester.pumpWidget(buildWidget(
        isLoading: true,
        onSubmit: () => submitted = true,
      ));

      await tester.tap(find.text('Submit'));
      expect(submitted, false);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  });
}
