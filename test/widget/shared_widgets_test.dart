import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:optmsg/constant/app_colors_extension.dart';
import 'package:optmsg/widgets/empty_state.dart';
import 'package:optmsg/widgets/dash_border.dart';
import 'package:optmsg/widgets/toast.dart';
import 'package:optmsg/widgets/pop_up_modal.dart';
import 'package:optmsg/widgets/button_form_field.dart';
import 'package:optmsg/widgets/email_plans.dart';

void main() {
  // ===== EmptyState =====
  group('EmptyState', () {
    testWidgets('inbox variant shows caught up message', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        MaterialApp(theme: ThemeData(extensions: const [AppColorsExtension.light]), home: const Scaffold(body: EmptyState(variant: EmptyStateVariant.inbox))),
      );

      expect(find.textContaining('caught up'), findsOneWidget);
      expect(find.byIcon(Icons.mail_outline), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('custom title overrides default', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: const [AppColorsExtension.light]),
          home: const Scaffold(body: EmptyState(variant: EmptyStateVariant.generic, title: 'No results')),
        ),
      );

      expect(find.text('No results'), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('tags variant shows tags message', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: const [AppColorsExtension.light]),
          home: const Scaffold(body: EmptyState(variant: EmptyStateVariant.tags)),
        ),
      );

      expect(find.text('No tags found'), findsOneWidget);
      expect(find.byIcon(Icons.label_outline), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('notifications variant shows correct message and icon', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: const [AppColorsExtension.light]),
          home: const Scaffold(body: EmptyState(variant: EmptyStateVariant.notifications)),
        ),
      );

      expect(find.text('No notifications yet'), findsOneWidget);
      expect(find.byIcon(Icons.notifications_none), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('contacts variant shows correct message and icon', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: const [AppColorsExtension.light]),
          home: const Scaffold(body: EmptyState(variant: EmptyStateVariant.contacts)),
        ),
      );

      expect(find.text('No contacts found'), findsOneWidget);
      expect(find.byIcon(Icons.person_outline), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('emailDetail variant shows correct message', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: const [AppColorsExtension.light]),
          home: const Scaffold(body: EmptyState(variant: EmptyStateVariant.emailDetail)),
        ),
      );

      expect(find.text('Email not found'), findsOneWidget);
      expect(find.byIcon(Icons.mail_outline), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  });

  // ===== DashedBorder =====
  group('DashedBorder', () {
    testWidgets('should render with specified dimensions', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: const [AppColorsExtension.light]),
          home: const Scaffold(
            body: DashedBorder(height: 2, width: 200),
          ),
        ),
      );

      expect(find.byType(DashedBorder), findsOneWidget);
    });

    testWidgets('should render with custom color', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: const [AppColorsExtension.light]),
          home: const Scaffold(
            body: DashedBorder(height: 2, width: 200, color: Colors.red),
          ),
        ),
      );

      expect(find.byType(DashedBorder), findsOneWidget);
    });
  });

  // ===== CustomToast =====
  group('CustomToast', () {
    testWidgets('should render success toast', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: const [AppColorsExtension.light]),
          home: Scaffold(
            body: CustomToast(
              message: 'Action completed',
              type: 'success',
              closeIcon: () {},
              undoMethod: () {},
            ),
          ),
        ),
      );

      expect(find.text('Action completed'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('should render error toast', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: const [AppColorsExtension.light]),
          home: Scaffold(
            body: CustomToast(
              message: 'Something went wrong',
              type: 'error',
              closeIcon: () {},
              undoMethod: () {},
            ),
          ),
        ),
      );

      expect(find.text('Something went wrong'), findsOneWidget);
    });

    testWidgets('should call closeIcon when close is tapped', (tester) async {
      bool closeCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: const [AppColorsExtension.light]),
          home: Scaffold(
            body: CustomToast(
              message: 'Test',
              type: 'success',
              closeIcon: () => closeCalled = true,
              undoMethod: () {},
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.close));
      expect(closeCalled, true);
    });

    testWidgets('should render undo toast with undo button', (tester) async {
      bool undoCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: const [AppColorsExtension.light]),
          home: Scaffold(
            body: CustomToast(
              message: 'Moved to trash',
              type: 'Undo',
              closeIcon: () {},
              undoMethod: () => undoCalled = true,
            ),
          ),
        ),
      );

      expect(find.text('Moved to trash'), findsOneWidget);
      expect(find.text('Undo'), findsOneWidget);

      await tester.tap(find.text('Undo'));
      expect(undoCalled, true);
    });
  });

  // ===== CustomPopupModal =====
  group('CustomPopupModal', () {
    testWidgets('should render title and subtitle', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: const [AppColorsExtension.light]),
          home: Scaffold(
            body: CustomPopupModal(
              title: 'Delete Account',
              subtitle: 'Are you sure?',
              onPressedButton1: () {},
              onPressedButton2: () {},
              textButton1: 'Cancel',
              textButton2: 'Delete',
            ),
          ),
        ),
      );

      expect(find.text('Delete Account'), findsOneWidget);
      expect(find.text('Are you sure?'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);
    });

    testWidgets('should call button callbacks', (tester) async {
      bool button1Called = false;
      bool button2Called = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: const [AppColorsExtension.light]),
          home: Scaffold(
            body: CustomPopupModal(
              title: 'Confirm',
              subtitle: 'Are you sure?',
              onPressedButton1: () => button1Called = true,
              onPressedButton2: () => button2Called = true,
              textButton1: 'No',
              textButton2: 'Yes',
            ),
          ),
        ),
      );

      await tester.tap(find.text('No'));
      expect(button1Called, true);

      await tester.tap(find.text('Yes'));
      expect(button2Called, true);
    });
  });

  // ===== Plan (email_plans) =====
  group('Plan widget', () {
    testWidgets('should render plan title and price', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: const [AppColorsExtension.light]),
          home: Scaffold(
            body: Plan(
              title: 'Monthly Plan',
              subtitle: 'Best for individuals',
              price: '\$9.99',
              features: const ['Feature 1', 'Feature 2', 'Feature 3'],
              onPressed: () {},
              isSelected: false,
              onSelected: (_) {},
              borderCheck: false,
              page: 'plans',
            ),
          ),
        ),
      );

      expect(find.text('Monthly Plan'), findsOneWidget);
      expect(find.text('Feature 1'), findsOneWidget);
      expect(find.text('Feature 2'), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('non-annual plan should use ElevatedButton', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: const [AppColorsExtension.light]),
          home: Scaffold(
            body: Plan(
              title: 'Monthly Plan',
              subtitle: '',
              price: '\$9.99',
              features: const ['All features'],
              onPressed: () {},
              isSelected: false,
              onSelected: (_) {},
              borderCheck: false,
              page: 'plans',
            ),
          ),
        ),
      );

      expect(find.byType(ElevatedButton), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('Annual Plan should use CustomGradientButton', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: const [AppColorsExtension.light]),
          home: Scaffold(
            body: Plan(
              title: 'Annual Plan',
              subtitle: 'Best value',
              price: '\$99.99',
              features: const ['Feature 1'],
              onPressed: () {},
              isSelected: false,
              onSelected: (_) {},
              borderCheck: false,
              page: 'plans',
            ),
          ),
        ),
      );

      expect(find.byType(CustomGradientButton), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('should call onPressed when button tapped', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      bool pressed = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: const [AppColorsExtension.light]),
          home: Scaffold(
            body: Plan(
              title: 'Monthly Plan',
              subtitle: '',
              price: '\$9.99',
              features: const [],
              onPressed: () => pressed = true,
              isSelected: false,
              onSelected: (_) {},
              borderCheck: false,
              page: 'plans',
            ),
          ),
        ),
      );

      await tester.tap(find.byType(ElevatedButton));
      expect(pressed, true);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  });
}
