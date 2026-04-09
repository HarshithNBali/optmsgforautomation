import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:optmsg/constant/app_colors_extension.dart';
import 'package:optmsg/model/inbox_list_model.dart';
import 'package:optmsg/widgets/button_form_field.dart';
import 'package:optmsg/screens/subscription/subscription_riverpod/subscription_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:optmsg/model/auth/auth_state.dart';
import 'package:optmsg/screens/auth/auth_riverpod/auth_notifier.dart';
import 'package:optmsg/screens/staticPages/static_pages_notifier.dart';

import '../../factories/test_data_factories.dart';
import '../../helpers/riverpod_test_helpers.dart';

class _FakeAuthNotifier extends AuthNotifier {
  final Map<String, dynamic>? _data;
  _FakeAuthNotifier(this._data);
  @override
  AuthState build() =>
      _data != null ? AuthState.authenticated(_data) : AuthState.unauthenticated();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // ===== InboxListModel deeper coverage =====
  group('InboxListModel Emails toJson roundtrip', () {
    test('should roundtrip Email with all nested objects', () {
      final json = makeInboxEmailJson(
        id: 5, emailId: 500, isRead: true,
        email: makeEmailJson(
          id: 500, subject: 'Full test',
          senderEmail: 'full@test.com',
          sender: makeSenderJson(firstName: 'F', lastName: 'L'),
        ),
        emailRecipientTags: [
          makeEmailRecipientTagJson(id: 1, tagId: 10),
          makeEmailRecipientTagJson(id: 2, tagId: 20),
        ],
      );

      final email = Emails.fromJson(json);
      final restored = Emails.fromJson(email.toJson());

      expect(restored.id, 5);
      expect(restored.emailId, 500);
      expect(restored.isRead, true);
      expect(restored.email.subject, 'Full test');
      expect(restored.email.senderEmail, 'full@test.com');
      expect(restored.emailRecipientTags, hasLength(2));
    });

    test('Attachments should roundtrip', () {
      final json = makeAttachmentJson(id: 42, type: 'pdf', path: '/doc.pdf');
      final att = Attachments.fromJson(json);
      final restored = Attachments.fromJson(att.toJson());
      expect(restored.id, 42);
    });

    test('Sender toJson roundtrip', () {
      final json = makeSenderJson(firstName: 'Alice', lastName: 'Smith');
      final sender = Sender.fromJson(json);
      final restored = Sender.fromJson(sender.toJson());
      expect(restored.firstName, 'Alice');
      expect(restored.lastName, 'Smith');
    });

    test('EmailRecipientTags toJson roundtrip', () {
      final json = makeEmailRecipientTagJson(id: 1, tagId: 10);
      final tag = EmailRecipientTags.fromJson(json);
      final restored = EmailRecipientTags.fromJson(tag.toJson());
      expect(restored.tagId, 10);
      expect(restored.tag.tag, 'Important');
    });

    test('Tag toJson roundtrip', () {
      final json = makeTagJson(id: 5, tag: 'Work');
      final tag = Tag.fromJson(json);
      final restored = Tag.fromJson(tag.toJson());
      expect(restored.id, 5);
      expect(restored.tag, 'Work');
    });
  });

  // ===== CustomGradientButton deeper coverage =====
  group('CustomGradientButton deeper', () {
    testWidgets('should not show text when loading with icon', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: const [AppColorsExtension.light]),
          home: Scaffold(
            body: CustomGradientButton(
              text: 'Submit',
              onPressed: () {},
              isLoading: true,
              leadingIcon: const Icon(Icons.send),
            ),
          ),
        ),
      );

      // When loading, show spinner not text/icon
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Submit'), findsNothing);
    });

    testWidgets('should render with custom text style', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: const [AppColorsExtension.light]),
          home: Scaffold(
            body: CustomGradientButton(
              text: 'Continue',
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.text('Continue'), findsOneWidget);
    });

    testWidgets('should handle rapid taps', (tester) async {
      int tapCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: const [AppColorsExtension.light]),
          home: Scaffold(
            body: CustomGradientButton(
              text: 'Tap Me',
              onPressed: () => tapCount++,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Tap Me'));
      await tester.tap(find.text('Tap Me'));
      await tester.tap(find.text('Tap Me'));

      expect(tapCount, 3);
    });
  });

  // ===== SubscriptionNotifier deeper =====
  group('SubscriptionNotifier deeper', () {
    late RiverpodTestSetup setup;

    setUp(() {
      setup = RiverpodTestSetup();
      when(() => setup.mockStorageService.readObjectData(any())).thenAnswer((_) async => null);
      when(() => setup.mockStorageService.readData(any())).thenAnswer((_) async => null);
    });

    test('remainingDays with no data should return 0', () async {
      final container = ProviderContainer(
        overrides: [
          ...setup.serviceOverrides,
          authProvider.overrideWith(() => _FakeAuthNotifier({'user': {}})),
        ],
      );
      addTearDown(container.dispose);
      await Future.delayed(Duration.zero);

      final notifier = container.read(subscriptionProvider.notifier);
      expect(notifier.remainingDays, 0);
    });

    test('status with no data should return empty or Expired', () async {
      final container = ProviderContainer(
        overrides: [
          ...setup.serviceOverrides,
          authProvider.overrideWith(() => _FakeAuthNotifier({'user': {}})),
        ],
      );
      addTearDown(container.dispose);
      await Future.delayed(Duration.zero);

      final notifier = container.read(subscriptionProvider.notifier);
      final status = notifier.status();
      expect(status == '' || status == 'Expired', true);
    });
  });

  // ===== StaticPagesNotifier deeper =====
  group('StaticPagesNotifier fetchData', () {
    late RiverpodTestSetup setup;

    setUp(() {
      setup = RiverpodTestSetup();
      when(() => setup.mockStorageService.readObjectData(any())).thenAnswer((_) async => null);
      when(() => setup.mockStorageService.readData(any())).thenAnswer((_) async => null);
    });

    test('fetchData with page key should call API', () async {
      when(() => setup.mockApiService.get(any()))
          .thenAnswer((_) async => {
                'success': true,
                'message': 'OK',
                'data': {
                  'page': {
                    'id': 1, 'title': 'Terms', 'slug': 'terms',
                    'description': '<p>Terms content</p>',
                    'isSuspended': false, 'isDeleted': false,
                    'created': '2024-01-01', 'updated': '2024-01-01',
                  }
                },
              });

      final container = ProviderContainer(overrides: setup.serviceOverrides);
      addTearDown(container.dispose);
      container.read(authProvider);
      await Future.delayed(Duration.zero);

      final notifier = container.read(staticPagesProvider.notifier);
      await notifier.fetchData('terms');

      final state = container.read(staticPagesProvider);
      expect(state.fetchAttempted, true);
    });

    test('fetchData with faq key should populate faq list', () async {
      when(() => setup.mockApiService.get(any()))
          .thenAnswer((_) async => {
                'success': true,
                'data': {
                  'faq': [
                    {'id': 1, 'question': 'Q1?', 'answer': 'A1'},
                    {'id': 2, 'question': 'Q2?', 'answer': 'A2'},
                  ]
                },
              });

      final container = ProviderContainer(overrides: setup.serviceOverrides);
      addTearDown(container.dispose);
      container.read(authProvider);
      await Future.delayed(Duration.zero);

      final notifier = container.read(staticPagesProvider.notifier);
      await notifier.fetchData('faq');

      final state = container.read(staticPagesProvider);
      expect(state.faq, hasLength(2));
      expect(state.didDataLoad, true);
    });
  });
}
