import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:optmsg/widgets/profile_dob_picker.dart';

void main() {
  group('ProfileDobPicker', () {
    testWidgets('should render label text', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;

      final controller = TextEditingController(text: 'June 15, 2024');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProfileDobPicker(
              iconPath: 'assets/svg/calendar.svg',
              labelText: 'Date of Birth',
              editable: false,
              controller: controller,
            ),
          ),
        ),
      );

      expect(find.text('Date of Birth'), findsOneWidget);
      expect(find.text('June 15, 2024'), findsOneWidget);

      controller.dispose();
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('should render in editable mode with calendar icon',
        (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;

      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProfileDobPicker(
              iconPath: 'assets/svg/calendar.svg',
              labelText: 'DOB',
              editable: true,
              controller: controller,
              hintText: 'Select date',
            ),
          ),
        ),
      );

      expect(find.text('DOB'), findsOneWidget);
      // In editable mode, a suffix icon (calendar) should be present
      expect(find.byType(InkWell), findsOneWidget);

      controller.dispose();
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('should render in read-only mode without calendar icon',
        (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;

      final controller = TextEditingController(text: '01/15/1990');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProfileDobPicker(
              iconPath: 'assets/svg/calendar.svg',
              labelText: 'DOB',
              editable: false,
              controller: controller,
            ),
          ),
        ),
      );

      // No InkWell (calendar icon) in non-editable mode
      expect(find.byType(InkWell), findsNothing);

      controller.dispose();
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  });
}
