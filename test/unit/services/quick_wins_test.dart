import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:optmsg/constant/app_colors_extension.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:optmsg/model/auth/auth_state.dart';
import 'package:optmsg/model/view_email_model.dart' as ve;
import 'package:optmsg/screens/auth/auth_riverpod/auth_notifier.dart';
import 'package:optmsg/screens/email/inbox_riverpod/email_detail_notifier.dart';
import 'package:optmsg/screens/email/inbox_riverpod/email_detail_state.dart';
import 'package:optmsg/widgets/web_menu_items.dart';

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

  // ===== ViewEmailModel deeper coverage =====
  group('ViewEmailModel deeper', () {
    Map<String, dynamic> makeFullViewEmailJson() => {
      'success': true, 'message': 'OK',
      'data': {
        'url': 'https://api.test.com/email/view/1',
        'email': {
          'id': 1, 'senderId': 2, 'senderEmail': 'sender@test.com',
          'subject': 'Test Subject', 'message': '<p>Hello</p>',
          'messageText': 'Hello', 'isArchive': false, 'isTrash': false,
          'isDeleted': false, 'created': '2024-01-01', 'updated': '2024-01-01',
          'communityStatus': false,
          'receivers': [
            {
              'id': 1, 'emailId': 1, 'receiverEmail': 'me@test.com',
              'type': 'to', 'isRead': true, 'isTrash': false,
              'isArchive': false, 'isDeleted': false,
              'emailRecipientTags': [
                {'id': 1, 'tagId': 10, 'emailRecipientsId': 1,
                 'tag': {'id': 10, 'userId': 1, 'tag': 'Work',
                         'isSuspended': false, 'isDeleted': false,
                         'created': '2024-01-01', 'updated': '2024-01-01'}},
              ],
              'receiver': {'firstName': 'Me', 'lastName': 'User'},
            },
          ],
          'attachments': [
            {'id': 1, 'type': 'pdf', 'path': '/files/doc.pdf', 'size': 1024},
          ],
          'sender': {'id': 2, 'firstName': 'Sender', 'lastName': 'Name', 'created': '2024-01-01'},
          'emailTags': [
            {'id': 1, 'userId': 1, 'tag': 'Important',
             'isSuspended': false, 'isDeleted': false,
             'created': '2024-01-01', 'updated': '2024-01-01'},
          ],
        },
      },
    };

    test('should parse full email with receivers, attachments, tags', () {
      final model = ve.ViewEmailModel.fromJson(makeFullViewEmailJson());
      expect(model.data.email.receivers, hasLength(1));
      expect(model.data.email.receivers[0].receiverEmail, 'me@test.com');
      expect(model.data.email.receivers[0].emailRecipientTags, hasLength(1));
      expect(model.data.email.receivers[0].emailRecipientTags![0].tag.tag, 'Work');
      expect(model.data.email.attachments, hasLength(1));
      expect(model.data.email.attachments[0].type, 'pdf');
      expect(model.data.email.emailTags, hasLength(1));
      expect(model.data.email.emailTags[0].tag, 'Important');
      expect(model.data.email.communityStatus, false);
    });

    test('should roundtrip full email', () {
      final original = ve.ViewEmailModel.fromJson(makeFullViewEmailJson());
      final restored = ve.ViewEmailModel.fromJson(original.toJson());
      expect(restored.data.email.receivers, hasLength(1));
      expect(restored.data.email.attachments, hasLength(1));
      expect(restored.data.email.emailTags, hasLength(1));
      expect(restored.data.email.subject, 'Test Subject');
    });

    test('Receivers should parse all fields', () {
      final json = makeFullViewEmailJson();
      final model = ve.ViewEmailModel.fromJson(json);
      final receiver = model.data.email.receivers[0];
      expect(receiver.id, 1);
      expect(receiver.emailId, 1);
      expect(receiver.receiverEmail, 'me@test.com');
      expect(receiver.type, 'to');
      expect(receiver.isRead, true);
      expect(receiver.isTrash, false);
      expect(receiver.isArchive, false);
      expect(receiver.isDeleted, false);
    });

    test('Sender should parse all fields', () {
      final model = ve.ViewEmailModel.fromJson(makeFullViewEmailJson());
      expect(model.data.email.sender.id, 2);
      expect(model.data.email.sender.firstName, 'Sender');
      expect(model.data.email.sender.lastName, 'Name');
    });

    test('EmailTags should parse', () {
      final model = ve.ViewEmailModel.fromJson(makeFullViewEmailJson());
      final tag = model.data.email.emailTags[0];
      expect(tag.tag, 'Important');
      expect(tag.userId, 1);
    });

    test('Attachments should parse size', () {
      final model = ve.ViewEmailModel.fromJson(makeFullViewEmailJson());
      expect(model.data.email.attachments[0].size, 1024);
    });
  });

  // ===== EmailDetailNotifier addTags/removeTags =====
  group('EmailDetailNotifier addTags and removeTags', () {
    late RiverpodTestSetup setup;
    late ProviderContainer container;
    late ProviderSubscription<EmailDetailState> sub;

    setUp(() async {
      setup = RiverpodTestSetup();
      when(() => setup.mockStorageService.readObjectData(any())).thenAnswer((_) async => null);
      when(() => setup.mockStorageService.readData(any())).thenAnswer((_) async => null);
      when(() => setup.mockApiService.post(any(), any()))
          .thenAnswer((_) async => {'success': false, 'message': 'init'});

      container = ProviderContainer(
        overrides: [
          ...setup.serviceOverrides,
          authProvider.overrideWith(() => _FakeAuthNotifier({'user': {'id': 1}, 'token': 't'})),
        ],
      );
      await Future.delayed(Duration.zero);
      sub = container.listen(emailDetailProvider(42), (_, _) {});
      await Future.delayed(const Duration(milliseconds: 200));
    });

    tearDown(() {
      sub.close();
      container.dispose();
    });

    test('addTags should call API with correct params', () async {
      when(() => setup.mockApiService.post(any(), any()))
          .thenAnswer((_) async => {'success': true, 'message': 'Tags added'});

      await container.read(emailDetailProvider(42).notifier).addTags([1, 2]);

      verify(() => setup.mockApiService.post('email/emails-tags', {
            'emailIds': [42],
            'tagsId': [1, 2],
            'type': 'add',
          })).called(1);
    });

    test('removeTags should call API with delete type', () async {
      when(() => setup.mockApiService.post(any(), any()))
          .thenAnswer((_) async => {'success': true, 'message': 'Tags removed'});

      await container.read(emailDetailProvider(42).notifier).removeTags([3]);

      verify(() => setup.mockApiService.post('email/emails-tags', {
            'emailIds': [42],
            'tagsId': [3],
            'type': 'delete',
          })).called(1);
    });

    test('addTags should handle API failure', () async {
      when(() => setup.mockApiService.post(any(), any()))
          .thenAnswer((_) async => {'success': false, 'message': 'Failed'});

      await container.read(emailDetailProvider(42).notifier).addTags([1]);

      expect(container.read(emailDetailProvider(42)), isNotNull);
    });
  });

  // ===== WebMenuItems expanded widget tests =====
  group('WebMenuItems expanded', () {
    testWidgets('should show subItems when provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: const [AppColorsExtension.light]),
          home: const Scaffold(
            body: WebMenuItems(
              title: 'Inbox',
              svgIcon: 'assets/svg/inbox.svg',
              subItems: [Text('Sub 1'), Text('Sub 2')],
            ),
          ),
        ),
      );

      expect(find.text('Sub 1'), findsOneWidget);
      expect(find.text('Sub 2'), findsOneWidget);
    });

    testWidgets('should show label count badge', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: const [AppColorsExtension.light]),
          home: const Scaffold(
            body: WebMenuItems(
              title: 'Drafts',
              svgIcon: 'assets/svg/draft.svg',
              labelText: '12',
            ),
          ),
        ),
      );

      expect(find.text('12'), findsOneWidget);
    });

    testWidgets('should show tooltip in collapsed mode', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: const [AppColorsExtension.light]),
          home: const Scaffold(
            body: WebMenuItems(
              title: 'Archive',
              svgIcon: 'assets/svg/archive.svg',
              isCollapsed: true,
            ),
          ),
        ),
      );

      // In collapsed mode, renders without crash
      expect(find.byType(WebMenuItems), findsOneWidget);
    });

    testWidgets('should handle draft mode', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: const [AppColorsExtension.light]),
          home: const Scaffold(
            body: WebMenuItems(
              title: 'New Draft',
              svgIcon: 'assets/svg/draft.svg',
              draft: true,
            ),
          ),
        ),
      );

      expect(find.byType(WebMenuItems), findsOneWidget);
    });
  });
}
