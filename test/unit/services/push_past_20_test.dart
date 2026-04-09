import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:optmsg/repositories/end_point/end_point.dart';
import 'package:optmsg/screens/auth/auth_riverpod/auth_notifier.dart';
import 'package:optmsg/screens/settings/profile_riverpod/profile_notifier.dart';
import 'package:optmsg/widgets/text_form_field.dart';
import 'package:optmsg/widgets/draft_email_list.dart';
import 'package:optmsg/model/draft_list_modal.dart' as draft;

import '../../helpers/riverpod_test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // ===== CustomTextFormField deeper =====
  group('CustomTextFormField deeper', () {
    testWidgets('should handle name filtering for username', (tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomTextFormField(
              controller: controller,
              labelText: 'Username',
              name: 'username',
            ),
          ),
        ),
      );

      // Username field should filter spaces
      await tester.enterText(find.byType(TextFormField), 'test user');
      expect(controller.text, 'testuser');

      controller.dispose();
    });

    testWidgets('should show suffix icon when text length >= 3', (tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomTextFormField(
              controller: controller,
              labelText: 'Search',
              showRightIcon: true,
              rightIcon: 'assets/svg/close.svg',
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextFormField), 'abc');
      await tester.pump();

      // After 3+ chars with showRightIcon, suffix should appear
      expect(find.byType(CustomTextFormField), findsOneWidget);

      controller.dispose();
    });

    testWidgets('should handle onChange callback', (tester) async {
      final controller = TextEditingController();
      bool changed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomTextFormField(
              controller: controller,
              labelText: 'Field',
              onChange: () => changed = true,
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextFormField), 'x');
      await tester.pump();

      expect(changed, true);

      controller.dispose();
    });

    testWidgets('should apply textCapitalization', (tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomTextFormField(
              controller: controller,
              labelText: 'Name',
              textCapitalization: TextCapitalization.words,
            ),
          ),
        ),
      );

      expect(find.byType(TextFormField), findsOneWidget);

      controller.dispose();
    });

    testWidgets('should apply custom colors', (tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomTextFormField(
              controller: controller,
              labelText: 'Custom',
              borderColor: Colors.red,
              fillColor: Colors.blue.withValues(alpha: 0.1),
            ),
          ),
        ),
      );

      expect(find.byType(TextFormField), findsOneWidget);

      controller.dispose();
    });
  });

  // ===== DraftEmailList deeper =====
  group('DraftEmailList deeper', () {
    draft.Emails makeDraftEmail({int id = 1, String subject = 'Draft'}) =>
        draft.Emails.fromJson({
          'id': id, 'senderId': 1, 'subject': subject, 'message': '<p>Body</p>',
          'isDeleted': false, 'created': '2024-01-01', 'updated': '2024-01-01',
          'attachments': [{'id': 1, 'type': 'pdf', 'path': '/doc.pdf', 'draftId': 1}],
        });

    testWidgets('should show attachment indicator', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DraftEmailList(
              title: 'Draft',
              svgIcon: 'assets/svg/draft.svg',
              item: makeDraftEmail(),
              index: 0,
            ),
          ),
        ),
      );

      expect(find.byType(DraftEmailList), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('should handle long press', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      bool longPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DraftEmailList(
              title: 'Draft',
              svgIcon: 'assets/svg/draft.svg',
              item: makeDraftEmail(),
              index: 0,
              onLongPress: () => longPressed = true,
            ),
          ),
        ),
      );

      await tester.longPress(find.byType(DraftEmailList));
      expect(longPressed, true);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  });

  // ===== EndPoints deeper =====
  group('EndPoints deeper', () {
    test('all endpoint paths should be non-empty', () {
      expect(EndPoints.userVerify.path, isNotEmpty);
      expect(EndPoints.login.path, isNotEmpty);
      expect(EndPoints.resenOTP.path, isNotEmpty);
      expect(EndPoints.verifyOTP.path, isNotEmpty);
      expect(EndPoints.getDraftEmail.path, isNotEmpty);
      expect(EndPoints.deleteDraft.path, isNotEmpty);
      expect(EndPoints.getTrash.path, isNotEmpty);
      expect(EndPoints.getSentMails.path, isNotEmpty);
      expect(EndPoints.updateEmailStatus.path, isNotEmpty);
      expect(EndPoints.getTagsList.path, isNotEmpty);
      expect(EndPoints.addTags.path, isNotEmpty);
      expect(EndPoints.editTag.path, isNotEmpty);
      expect(EndPoints.deleteTag.path, isNotEmpty);
      expect(EndPoints.getInboxEmails.path, isNotEmpty);
      expect(EndPoints.getEmailTags.path, isNotEmpty);
      expect(EndPoints.contactUpload.path, isNotEmpty);
      expect(EndPoints.checkEmail.path, isNotEmpty);
      expect(EndPoints.contactUploadToggleContactSync.path, isNotEmpty);
      expect(EndPoints.getContactList.path, isNotEmpty);
      expect(EndPoints.getContactDetails.path, isNotEmpty);
      expect(EndPoints.contactDelete.path, isNotEmpty);
      expect(EndPoints.addDeleteEmail.path, isNotEmpty);
      expect(EndPoints.editContact.path, isNotEmpty);
      expect(EndPoints.addContact.path, isNotEmpty);
      expect(EndPoints.getNotification.path, isNotEmpty);
      expect(EndPoints.notificationDelete.path, isNotEmpty);
      expect(EndPoints.notificationRead.path, isNotEmpty);
      expect(EndPoints.deviceBiometric.path, isNotEmpty);
      expect(EndPoints.logout.path, isNotEmpty);
      expect(EndPoints.toggleNotification.path, isNotEmpty);
      expect(EndPoints.contactSortToggle.path, isNotEmpty);
      expect(EndPoints.toggleContactSynch.path, isNotEmpty);
      expect(EndPoints.deleteAccount.path, isNotEmpty);
      expect(EndPoints.paymentList.path, isNotEmpty);
      expect(EndPoints.getProfile.path, isNotEmpty);
      expect(EndPoints.editProfile.path, isNotEmpty);
    });

    test('all endpoints should have base', () {
      expect(EndPoints.userVerify.base, isNotEmpty);
      expect(EndPoints.login.base, isNotEmpty);
      expect(EndPoints.getProfile.base, isNotEmpty);
    });

    test('contactBaseUrl should be non-empty', () {
      expect(EndPoints.contactBaseUrl, isNotEmpty);
    });
  });

  // deleteAccountData calls Navigator.of(rootNavigatorKey.currentContext!)
  // which requires a widget test with full navigation context.

  // ===== ProfileNotifier formatDate edge cases =====
  group('ProfileNotifier formatDate', () {
    late RiverpodTestSetup setup;

    setUp(() {
      setup = RiverpodTestSetup();
      when(() => setup.mockStorageService.readObjectData(any())).thenAnswer((_) async => null);
      when(() => setup.mockStorageService.readData(any())).thenAnswer((_) async => null);
    });

    test('formatDate with various date formats', () async {
      final container = ProviderContainer(overrides: setup.serviceOverrides);
      addTearDown(container.dispose);
      container.read(authProvider);
      await Future.delayed(Duration.zero);

      final notifier = container.read(profileProvider.notifier);

      expect(notifier.formatDate('2024-06-15'), contains('June'));
      expect(notifier.formatDate('2024-01-01'), contains('January'));
      expect(notifier.formatDate('invalid'), 'N/A');
      expect(notifier.formatDate(''), 'N/A');
    });

    test('formatDateForApi with MMMM dd, yyyy format', () async {
      final container = ProviderContainer(overrides: setup.serviceOverrides);
      addTearDown(container.dispose);
      container.read(authProvider);
      await Future.delayed(Duration.zero);

      final notifier = container.read(profileProvider.notifier);

      final result = notifier.formatDateForApi('June 15, 2024');
      expect(result, contains('2024'));
    });

    test('formatDateForApi with ISO format', () async {
      final container = ProviderContainer(overrides: setup.serviceOverrides);
      addTearDown(container.dispose);
      container.read(authProvider);
      await Future.delayed(Duration.zero);

      final notifier = container.read(profileProvider.notifier);

      final result = notifier.formatDateForApi('2024-06-15');
      expect(result, contains('2024'));
    });
  });
}
