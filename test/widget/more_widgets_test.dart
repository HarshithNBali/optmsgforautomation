import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:optmsg/constant/app_colors_extension.dart';
import 'package:optmsg/widgets/footer_button.dart';
import 'package:optmsg/widgets/draggable_divider.dart';
import 'package:optmsg/widgets/button_form_field.dart';
import 'package:optmsg/screens/auth/createAccount/widgets/create_account_form_widget.dart';
import 'package:optmsg/services/form_validation.dart';

void main() {
  // ===== FooterButton =====
  group('FooterButton', () {
    testWidgets('should render two buttons with text', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: const [AppColorsExtension.light]),
          home: Scaffold(
            body: FooterButton(
              button1Color: Colors.white,
              button1TextColor: Colors.black,
              button1BorderColor: Colors.grey,
              button2Color: Colors.blue,
              button2TextColor: Colors.white,
              button2BorderColor: Colors.blue,
              onPressedButton1: () {},
              onPressedButton2: () {},
              textButton1: 'Cancel',
              textButton2: 'Confirm',
            ),
          ),
        ),
      );

      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Confirm'), findsOneWidget);
    });

    testWidgets('should call onPressedButton1 when first button tapped',
        (tester) async {
      bool called = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: const [AppColorsExtension.light]),
          home: Scaffold(
            body: FooterButton(
              button1Color: Colors.white,
              button1TextColor: Colors.black,
              button1BorderColor: Colors.grey,
              button2Color: Colors.blue,
              button2TextColor: Colors.white,
              button2BorderColor: Colors.blue,
              onPressedButton1: () => called = true,
              onPressedButton2: () {},
              textButton1: 'Cancel',
              textButton2: 'OK',
            ),
          ),
        ),
      );

      await tester.tap(find.text('Cancel'));
      expect(called, true);
    });

    testWidgets('should call onPressedButton2 when second button tapped',
        (tester) async {
      bool called = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: const [AppColorsExtension.light]),
          home: Scaffold(
            body: FooterButton(
              button1Color: Colors.white,
              button1TextColor: Colors.black,
              button1BorderColor: Colors.grey,
              button2Color: Colors.red,
              button2TextColor: Colors.white,
              button2BorderColor: Colors.red,
              onPressedButton1: () {},
              onPressedButton2: () => called = true,
              textButton1: 'No',
              textButton2: 'Delete',
            ),
          ),
        ),
      );

      await tester.tap(find.text('Delete'));
      expect(called, true);
    });
  });

  // ===== DraggableDivider =====
  group('DraggableDivider', () {
    testWidgets('should render horizontal divider', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: const [AppColorsExtension.light]),
          home: Scaffold(
            body: Row(
              children: [
                const SizedBox(width: 200, child: Text('Left')),
                DraggableDivider(
                  isHorizontal: true,
                  currentSize: 200,
                  minSize: 100,
                  maxSize: 400,
                  onDragEnd: (_) {},
                ),
                const Expanded(child: Text('Right')),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(DraggableDivider), findsOneWidget);
      expect(find.text('Left'), findsOneWidget);
      expect(find.text('Right'), findsOneWidget);
    });

    testWidgets('should render vertical divider', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: const [AppColorsExtension.light]),
          home: Scaffold(
            body: Column(
              children: [
                const Expanded(child: Text('Top')),
                DraggableDivider(
                  isHorizontal: false,
                  currentSize: 200,
                  minSize: 100,
                  maxSize: 400,
                  onDragEnd: (_) {},
                ),
                const SizedBox(height: 200, child: Text('Bottom')),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(DraggableDivider), findsOneWidget);
    });

    testWidgets('should call onDragEnd after horizontal drag', (tester) async {
      double? finalSize;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: const [AppColorsExtension.light]),
          home: Scaffold(
            body: SizedBox(
              width: 600,
              height: 400,
              child: Row(
                children: [
                  const SizedBox(width: 200),
                  DraggableDivider(
                    isHorizontal: true,
                    currentSize: 200,
                    minSize: 100,
                    maxSize: 400,
                    onDragEnd: (size) => finalSize = size,
                  ),
                  const Expanded(child: SizedBox()),
                ],
              ),
            ),
          ),
        ),
      );

      // Simulate horizontal drag
      final divider = find.byType(DraggableDivider);
      await tester.drag(divider, const Offset(50, 0));
      await tester.pump();

      expect(finalSize, isNotNull);
      expect(finalSize, greaterThan(200));
    });
  });

  // ===== ResizableSplitPane =====
  group('ResizableSplitPane', () {
    testWidgets('should render horizontal split pane', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: const [AppColorsExtension.light]),
          home: const Scaffold(
            body: ResizableSplitPane(
              firstChild: Text('Panel 1'),
              secondChild: Text('Panel 2'),
              isHorizontal: true,
              initialFirstPaneSize: 200,
              minFirstPaneSize: 100,
              maxFirstPaneSize: 400,
            ),
          ),
        ),
      );

      expect(find.text('Panel 1'), findsOneWidget);
      expect(find.text('Panel 2'), findsOneWidget);
      expect(find.byType(DraggableDivider), findsOneWidget);
    });

    testWidgets('should render vertical split pane', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: const [AppColorsExtension.light]),
          home: const Scaffold(
            body: ResizableSplitPane(
              firstChild: Text('Top'),
              secondChild: Text('Bottom'),
              isHorizontal: false,
              initialFirstPaneSize: 200,
              minFirstPaneSize: 100,
              maxFirstPaneSize: 400,
            ),
          ),
        ),
      );

      expect(find.text('Top'), findsOneWidget);
      expect(find.text('Bottom'), findsOneWidget);
    });

    testWidgets('should call onSizeChanged after drag', (tester) async {
      double? newSize;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: const [AppColorsExtension.light]),
          home: Scaffold(
            body: SizedBox(
              width: 800,
              height: 600,
              child: ResizableSplitPane(
                firstChild: const Text('Left'),
                secondChild: const Text('Right'),
                isHorizontal: true,
                initialFirstPaneSize: 300,
                minFirstPaneSize: 100,
                maxFirstPaneSize: 600,
                onSizeChanged: (size) => newSize = size,
              ),
            ),
          ),
        ),
      );

      final divider = find.byType(DraggableDivider);
      await tester.drag(divider, const Offset(50, 0));
      await tester.pump();

      expect(newSize, isNotNull);
    });
  });

  // ===== CreateAccountFormWidget =====
  group('CreateAccountFormWidget', () {
    testWidgets('should render form fields', (tester) async {
      tester.view.physicalSize = const Size(400, 1000);
      tester.view.devicePixelRatio = 1.0;

      final formKey = GlobalKey<FormState>();
      final usernameCtrl = TextEditingController();
      final phoneCtrl = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: const [AppColorsExtension.light]),
          home: Scaffold(
            body: SingleChildScrollView(
              child: CreateAccountFormWidget(
                formKey: formKey,
                userNameController: usernameCtrl,
                phoneController: phoneCtrl,
                formValidation: FormValidationService(),
                isUserNameAvailable: true,
                acceptTerms: false,
                acceptCondition: false,
                onSubmit: () {},
                onLogin: () {},
                onUserNameChanged: () {},
                onAcceptTermsChanged: (_) {},
                onAcceptConditionChanged: (_) {},
              ),
            ),
          ),
        ),
      );

      // Should have form fields
      expect(find.byType(TextFormField), findsWidgets);
      // Should have a submit button
      expect(find.byType(CustomGradientButton), findsOneWidget);

      usernameCtrl.dispose();
      phoneCtrl.dispose();
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  });
}
