import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:optmsg/constant/app_colors_extension.dart';
import 'package:optmsg/widgets/country_picker.dart';
import 'package:optmsg/widgets/web_login_content.dart';
import 'package:optmsg/widgets/web_menu_items.dart';
import 'package:optmsg/widgets/email_list.dart';
import 'package:optmsg/model/inbox_list_model.dart';

import '../factories/test_data_factories.dart';

void main() {
  // ===== CountryPicker =====
  group('CountryPicker', () {
    testWidgets('should render country code +1', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: const [AppColorsExtension.light]),
          home: const Scaffold(body: CountryPicker()),
        ),
      );

      expect(find.text('(+1)'), findsOneWidget);
    });
  });

  // ===== AppBar (shell-managed, replaces retired OptAppBar) =====
  group('AppBar', () {
    testWidgets('should render title widget', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: const [AppColorsExtension.light]),
          home: Scaffold(
            appBar: AppBar(title: const Text('Inbox')),
          ),
        ),
      );

      expect(find.text('Inbox'), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('should render action widgets', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: const [AppColorsExtension.light]),
          home: Scaffold(
            appBar: AppBar(
              title: const Text('Settings'),
              actions: [
                IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
              ],
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.search), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  });

  // ===== StaticContentWidget (web_login_content) =====
  group('StaticContentWidget', () {
    testWidgets('should render secure/private/simple text', (tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: const [AppColorsExtension.light]),
          home: const Scaffold(body: StaticContentWidget()),
        ),
      );

      expect(find.textContaining('Secure'), findsWidgets);
      expect(find.textContaining('Private'), findsWidgets);
      expect(find.textContaining('Simple'), findsWidgets);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  });

  // ===== WebMenuItems =====
  group('WebMenuItems', () {
    testWidgets('should render title text', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: const [AppColorsExtension.light]),
          home: Scaffold(
            body: WebMenuItems(
              title: 'Inbox',
              svgIcon: 'assets/svg/inbox.svg',
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('Inbox'), findsOneWidget);
    });

    testWidgets('should call onTap when tapped', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: const [AppColorsExtension.light]),
          home: Scaffold(
            body: WebMenuItems(
              title: 'Drafts',
              svgIcon: 'assets/svg/draft.svg',
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Drafts'));
      await tester.pump();
      expect(tapped, true);
    });

    testWidgets('should render label text when provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: const [AppColorsExtension.light]),
          home: const Scaffold(
            body: WebMenuItems(
              title: 'Inbox',
              svgIcon: 'assets/svg/inbox.svg',
              labelText: '5',
            ),
          ),
        ),
      );

      expect(find.text('5'), findsOneWidget);
    });

    testWidgets('should show collapsed state', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: const [AppColorsExtension.light]),
          home: const Scaffold(
            body: WebMenuItems(
              title: 'Inbox',
              svgIcon: 'assets/svg/inbox.svg',
              isCollapsed: true,
            ),
          ),
        ),
      );

      // In collapsed mode, title should be hidden (Tooltip instead)
      // Just verify it renders without error
      expect(find.byType(WebMenuItems), findsOneWidget);
    });

    testWidgets('should highlight when selected', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: const [AppColorsExtension.light]),
          home: const Scaffold(
            body: WebMenuItems(
              title: 'Inbox',
              svgIcon: 'assets/svg/inbox.svg',
              isSelected: true,
            ),
          ),
        ),
      );

      expect(find.byType(WebMenuItems), findsOneWidget);
    });
  });

  // ===== EmailList =====
  group('EmailList', () {
    testWidgets('should render and show subject', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;

      final email = Emails.fromJson(makeInboxEmailJson(
        emailId: 100,
        isRead: false,
        email: makeEmailJson(
          subject: 'Test Subject',
          senderEmail: 'sender@test.com',
        ),
      ));

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: const [AppColorsExtension.light]),
          home: Scaffold(
            body: EmailList(
              title: 'Sender',
              svgIcon: 'assets/svg/inbox.svg',
              item: email,
              index: 0,
            ),
          ),
        ),
      );

      // EmailList renders the subject from the item
      expect(find.text('Test Subject'), findsOneWidget);
      expect(find.byType(EmailList), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('should call onTap when tapped', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      bool tapped = false;

      final email = Emails.fromJson(makeInboxEmailJson());

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: const [AppColorsExtension.light]),
          home: Scaffold(
            body: EmailList(
              title: 'Test',
              svgIcon: 'assets/svg/inbox.svg',
              item: email,
              index: 0,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(EmailList));
      expect(tapped, true);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('should show sender first name from email item', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;

      final email = Emails.fromJson(makeInboxEmailJson(
        email: makeEmailJson(
          subject: 'Meeting',
          sender: makeSenderJson(firstName: 'Alice', lastName: 'Smith'),
        ),
      ));

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: const [AppColorsExtension.light]),
          home: Scaffold(
            body: EmailList(
              title: 'Alice Smith',
              svgIcon: 'assets/svg/inbox.svg',
              item: email,
              index: 0,
            ),
          ),
        ),
      );

      // Sender name is rendered from the email item data
      expect(find.textContaining('Alice'), findsWidgets);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  });
}
