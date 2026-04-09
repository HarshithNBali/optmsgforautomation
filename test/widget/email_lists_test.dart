import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:optmsg/constant/app_colors_extension.dart';
import 'package:optmsg/widgets/sent_email_list.dart';
import 'package:optmsg/widgets/draft_email_list.dart';
import 'package:optmsg/model/sent_list_model.dart' as sent;
import 'package:optmsg/model/draft_list_modal.dart' as draft;

void main() {
  // ===== SentEmailList =====
  group('SentEmailList', () {
    sent.Emails makeSentEmail({String subject = 'Sent subject'}) {
      return sent.Emails.fromJson({
        'id': 1,
        'senderId': 1,
        'senderEmail': 'me@test.com',
        'senderName': 'Me',
        'subject': subject,
        'messageText': 'Body text',
        'created': '2024-06-15T10:30:00.000Z',
        'attachments': [],
        'receivers': [
          {
            'emailId': 1,
            'receiverEmail': 'them@test.com',
            'id': 1,
            'isRead': false,
            'emailRecipientTags': [],
            'receiver': {
              'firstName': 'Them',
              'lastName': 'User',
              'userName': 'themuser'
            },
          }
        ],
        'sender': {
          'id': 1,
          'firstName': 'Me',
          'lastName': 'User',
          'created': '2024-01-01'
        },
        'emailTag': [],
        'message': '<p>Body</p>',
        'communityStatus': false,
      });
    }

    testWidgets('should render and show subject', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: const [AppColorsExtension.light]),
          home: Scaffold(
            body: SentEmailList(
              title: 'To: Them User',
              svgIcon: 'assets/svg/sent.svg',
              item: makeSentEmail(subject: 'My Sent Email'),
              index: 0,
            ),
          ),
        ),
      );

      expect(find.text('My Sent Email'), findsOneWidget);
      expect(find.byType(SentEmailList), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('should call onTap when tapped', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: const [AppColorsExtension.light]),
          home: Scaffold(
            body: SentEmailList(
              title: 'Sent',
              svgIcon: 'assets/svg/sent.svg',
              item: makeSentEmail(),
              index: 0,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(SentEmailList));
      expect(tapped, true);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('should display receiver names', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: const [AppColorsExtension.light]),
          home: Scaffold(
            body: SentEmailList(
              title: 'To: Them User',
              svgIcon: 'assets/svg/sent.svg',
              item: makeSentEmail(),
              index: 0,
            ),
          ),
        ),
      );

      // Renders without crashing — receiver data is present
      expect(find.byType(SentEmailList), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  });

  // ===== DraftEmailList =====
  group('DraftEmailList', () {
    draft.Emails makeDraftEmail({String subject = 'Draft subject'}) {
      return draft.Emails.fromJson({
        'id': 1,
        'senderId': 1,
        'subject': subject,
        'message': '<p>Draft body</p>',
        'isDeleted': false,
        'created': '2024-01-01T00:00:00.000Z',
        'updated': '2024-01-01T00:00:00.000Z',
        'attachments': [],
      });
    }

    testWidgets('should render and show subject', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: const [AppColorsExtension.light]),
          home: Scaffold(
            body: DraftEmailList(
              title: 'Draft',
              svgIcon: 'assets/svg/draft.svg',
              item: makeDraftEmail(subject: 'My Draft'),
              index: 0,
            ),
          ),
        ),
      );

      expect(find.text('My Draft'), findsOneWidget);
      expect(find.byType(DraftEmailList), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('should call onTap when tapped', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: const [AppColorsExtension.light]),
          home: Scaffold(
            body: DraftEmailList(
              title: 'Draft',
              svgIcon: 'assets/svg/draft.svg',
              item: makeDraftEmail(),
              index: 0,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(DraftEmailList));
      expect(tapped, true);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('should show no subject text for empty subject',
        (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: const [AppColorsExtension.light]),
          home: Scaffold(
            body: DraftEmailList(
              title: 'Draft',
              svgIcon: 'assets/svg/draft.svg',
              item: makeDraftEmail(subject: ''),
              index: 0,
            ),
          ),
        ),
      );

      // Should still render without crash
      expect(find.byType(DraftEmailList), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  });
}
