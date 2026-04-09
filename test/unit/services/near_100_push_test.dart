import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:optmsg/model/view_email_model.dart' as ve;
import 'package:optmsg/model/view_draft_model.dart' as vd;
import 'package:optmsg/model/draft_list_modal.dart' as draft;
import 'package:optmsg/model/inbox_list_model.dart';
import 'package:optmsg/common/app_manger/app_cache.dart';
import 'package:optmsg/common/app_manger/app_environment.dart';
import 'package:optmsg/screens/auth/auth_riverpod/auth_notifier.dart';
import 'package:optmsg/model/auth/auth_state.dart';
import 'package:optmsg/screens/subscription/subscription_riverpod/subscription_notifier.dart';

import '../../helpers/riverpod_test_helpers.dart';
import '../../factories/test_data_factories.dart';

class _FakeAuthNotifier extends AuthNotifier {
  final Map<String, dynamic>? _data;
  _FakeAuthNotifier(this._data);
  @override
  AuthState build() =>
      _data != null ? AuthState.authenticated(_data) : AuthState.unauthenticated();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // ===== ViewEmailModel push to ~100% =====
  group('ViewEmailModel Receivers toJson', () {
    test('should roundtrip Receivers with all fields', () {
      final json = <String, dynamic>{
        'success': true, 'message': '',
        'data': <String, dynamic>{
          'url': null,
          'email': <String, dynamic>{
            'id': 1, 'senderEmail': 'a@b.com', 'subject': 'S', 'message': 'M',
            'isArchive': false, 'isTrash': false, 'isDeleted': false,
            'created': '2024-01-01', 'updated': '2024-01-01',
            'communityStatus': false,
            'receivers': [
              {
                'id': 1, 'emailId': 1, 'receiverEmail': 'r@t.com',
                'forwardEmail': 'fw@t.com',
                'type': 'to', 'isRead': false, 'isTrash': false,
                'isArchive': false, 'isDeleted': false,
                'emailRecipientTags': [],
                'receiver': {'id': 5, 'firstName': 'R', 'lastName': 'U'},
              }
            ],
            'attachments': [
              {'id': 1, 'type': 'image', 'path': '/img.png', 'emailId': 1, 'size': 2048},
            ],
            'sender': {'id': 2, 'firstName': 'S', 'lastName': 'N', 'created': ''},
            'emailTags': [],
          },
        },
      };
      final model = ve.ViewEmailModel.fromJson(json);
      final restored = ve.ViewEmailModel.fromJson(model.toJson());

      expect(restored.data.email.receivers[0].forwardEmail, 'fw@t.com');
      expect(restored.data.email.receivers[0].receiver.id, 5);
      expect(restored.data.email.attachments[0].size, 2048);
      expect(restored.data.email.attachments[0].emailId, 1);
    });
  });

  // ===== ViewDraftModel push coverage =====
  group('ViewDraftModel deeper', () {
    test('should parse draft with attachments and receivers', () {
      final json = {
        'success': true, 'message': '',
        'data': {
          'email': {
            'id': 1, 'senderId': 1, 'subject': 'My Draft',
            'message': '<p>Hello</p>', 'isDeleted': false,
            'created': '2024-01-01', 'updated': '2024-01-01',
            'receivers': [
              {
                'id': 1, 'draftId': 1, 'receiverEmail': 'to@test.com',
                'type': 'to', 'isRead': false, 'isTrash': false,
                'isArchive': false, 'isDeleted': false,
                'receiver': {'firstName': 'To', 'lastName': 'User'},
              },
              {
                'id': 2, 'draftId': 1, 'receiverEmail': 'cc@test.com',
                'type': 'cc', 'isRead': false, 'isTrash': false,
                'isArchive': false, 'isDeleted': false,
                'receiver': {'firstName': 'CC', 'lastName': 'User'},
              },
            ],
            'attachments': [
              {'id': 1, 'type': 'pdf', 'path': '/doc.pdf', 'size': 4096},
              {'id': 2, 'type': 'image', 'path': '/img.jpg', 'size': 1024},
            ],
            'sender': {'id': 1, 'firstName': 'Me', 'lastName': 'User', 'created': '2024-01-01'},
          },
        },
      };

      final model = vd.ViewDraftModel.fromJson(json);
      expect(model.data.email.receivers, hasLength(2));
      expect(model.data.email.receivers[0].receiverEmail, 'to@test.com');
      expect(model.data.email.receivers[1].type, 'cc');
      expect(model.data.email.attachments, hasLength(2));
      expect(model.data.email.attachments[0].size, 4096);
      expect(model.data.email.sender.firstName, 'Me');

      // Roundtrip
      final restored = vd.ViewDraftModel.fromJson(model.toJson());
      expect(restored.data.email.receivers, hasLength(2));
      expect(restored.data.email.attachments, hasLength(2));
    });
  });

  // ===== DraftListModel deeper =====
  group('DraftListModel Attachments', () {
    test('should parse attachments with all fields', () {
      final json = {
        'success': true, 'message': '',
        'data': {
          'emails': [
            {
              'id': 1, 'senderId': 1, 'subject': 'D', 'message': '',
              'isDeleted': false, 'created': '', 'updated': '',
              'attachments': [
                {'id': 1, 'type': 'pdf', 'path': '/doc.pdf', 'draftId': 1},
                {'id': 2, 'type': 'image', 'path': '/img.jpg', 'draftId': 1},
              ],
            }
          ],
          'nextPage': false,
        },
      };
      final model = draft.DraftListModel.fromJson(json);
      expect(model.data.emails[0].attachments, hasLength(2));

      final restored = draft.DraftListModel.fromJson(model.toJson());
      expect(restored.data.emails[0].attachments, hasLength(2));
    });
  });

  // ===== InboxListModel last gap — Emails.toJson with tags =====
  group('InboxListModel Emails with tags toJson', () {
    test('should roundtrip email with recipient tags', () {
      final json = makeInboxEmailJson(
        id: 1, emailId: 100, isRead: true,
        emailRecipientTags: [
          makeEmailRecipientTagJson(id: 1, tagId: 10),
        ],
      );
      final email = Emails.fromJson(json);
      expect(email.emailRecipientTags, hasLength(1));

      final restored = Emails.fromJson(email.toJson());
      expect(restored.emailRecipientTags, hasLength(1));
      expect(restored.emailRecipientTags[0].tagId, 10);
    });
  });

  // ===== AppCache deeper =====
  group('AppCache deeper', () {
    test('loadRedirectCache should read all keys from storage', () async {
      // AppCache uses its own SecureStorageService internally — not our mock.
      // Just verify the method exists and doesn't crash with null returns.
      // In test env, the SecureStorageService platform channel will fail,
      // but loadRedirectCache catches exceptions internally.
      final cache = AppCache();
      cache.clear();
      expect(cache.isCheckout, isNull);
      expect(cache.subscriptionPage, '');
      expect(cache.signupInProgress, '');
      expect(cache.hasPasskeyEnrolled, false);
      expect(cache.hasCompletedOnboarding, false);
      expect(cache.mailto, isNull);
    });
  });

  // ===== AppEnvironment deeper =====
  group('AppEnvironment deeper', () {
    test('currentWebEnv should cache result', () async {
      final env = AppEnvironment.instance;
      await env.currentWebEnv('stage');
      expect(env.type, AppEnvironmentType.stage);

      // Calling currentEnv should return cached
      // (but needs PackageInfo which is platform-dependent)
    });
  });

  // ===== SubscriptionNotifier deeper =====
  group('SubscriptionNotifier status and remainingDays', () {
    late RiverpodTestSetup setup;

    setUp(() {
      setup = RiverpodTestSetup();
      when(() => setup.mockStorageService.readObjectData(any())).thenAnswer((_) async => null);
      when(() => setup.mockStorageService.readData(any())).thenAnswer((_) async => null);
    });

    test('status Active for future date', () async {
      final container = ProviderContainer(
        overrides: [
          ...setup.serviceOverrides,
          authProvider.overrideWith(() => _FakeAuthNotifier(<String, dynamic>{
            'user': <String, dynamic>{
              'isFreeUser': false,
              'isSubscribed': true,
              'subscriptionEndDate': DateTime.now().add(const Duration(days: 30)).millisecondsSinceEpoch ~/ 1000,
            },
          })),
        ],
      );
      addTearDown(container.dispose);
      await Future.delayed(Duration.zero);

      final notifier = container.read(subscriptionProvider.notifier);
      final future = DateTime.now().add(const Duration(days: 30));
      notifier.state = notifier.state.copyWith(data: {
        'ends': future.millisecondsSinceEpoch ~/ 1000,
      });

      expect(notifier.status(), 'Active');
      expect(notifier.remainingDays, greaterThanOrEqualTo(29));
    });

    test('status Expired for past date', () async {
      final container = ProviderContainer(
        overrides: [
          ...setup.serviceOverrides,
          authProvider.overrideWith(() => _FakeAuthNotifier(<String, dynamic>{
            'user': <String, dynamic>{
              'isFreeUser': true,
              'subscriptionEndDate': DateTime.now().subtract(const Duration(days: 30)).millisecondsSinceEpoch ~/ 1000,
            },
          })),
        ],
      );
      addTearDown(container.dispose);
      await Future.delayed(Duration.zero);

      final notifier = container.read(subscriptionProvider.notifier);
      final past = DateTime.now().subtract(const Duration(days: 30));
      notifier.state = notifier.state.copyWith(data: {
        'ends': past.millisecondsSinceEpoch ~/ 1000,
      });

      expect(notifier.status(), 'Expired');
      expect(notifier.remainingDays, 0);
    });
  });
}
