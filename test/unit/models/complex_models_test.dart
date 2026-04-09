import 'package:flutter_test/flutter_test.dart';
import 'package:optmsg/model/view_email_model.dart' as ve;
import 'package:optmsg/model/sent_list_model.dart' as sent;
import 'package:optmsg/model/view_draft_model.dart' as vd;

void main() {
  // ===== ViewEmailModel =====
  group('ViewEmailModel', () {
    Map<String, dynamic> makeViewEmailJson() => {
      'success': true,
      'message': 'OK',
      'data': {
        'url': 'https://api.example.com/email/view/1',
        'email': {
          'id': 1,
          'senderId': 2,
          'senderEmail': 'sender@test.com',
          'subject': 'Test Subject',
          'message': '<p>Hello</p>',
          'messageText': 'Hello',
          'isArchive': false,
          'isTrash': false,
          'isDeleted': false,
          'created': '2024-01-01T00:00:00.000Z',
          'updated': '2024-01-01T00:00:00.000Z',
          'receivers': [
            {
              'id': 1, 'emailId': 1, 'receiverEmail': 'receiver@test.com',
              'type': 'to', 'isRead': true, 'isTrash': false, 'isArchive': false,
              'isDeleted': false, 'emailRecipientTags': [],
              'receiver': {'firstName': 'Rx', 'lastName': 'User'},
            },
          ],
          'attachments': [],
          'sender': {'id': 2, 'firstName': 'Sender', 'lastName': 'Name', 'created': '2024-01-01'},
          'emailTags': [],
          'communityStatus': false,
        },
      },
    };

    test('should parse valid JSON', () {
      final model = ve.ViewEmailModel.fromJson(makeViewEmailJson());
      expect(model.success, true);
      expect(model.data.url, contains('api.example.com'));
      expect(model.data.email.id, 1);
      expect(model.data.email.subject, 'Test Subject');
      expect(model.data.email.senderEmail, 'sender@test.com');
      expect(model.data.email.receivers, hasLength(1));
      expect(model.data.email.receivers[0].receiverEmail, 'receiver@test.com');
      expect(model.data.email.sender.firstName, 'Sender');
    });

    test('should handle null optional fields', () {
      final json = <String, dynamic>{
        'success': true, 'message': 'OK',
        'data': <String, dynamic>{
          'url': null,
          'email': <String, dynamic>{
            'id': 1, 'senderId': null, 'senderEmail': '', 'subject': '',
            'message': '', 'messageText': null,
            'isArchive': false, 'isTrash': false, 'isDeleted': false,
            'created': '', 'updated': '',
            'receivers': <Map<String, dynamic>>[],
            'attachments': <Map<String, dynamic>>[],
            'sender': <String, dynamic>{'firstName': 'A', 'lastName': 'B', 'created': ''},
            'emailTags': <Map<String, dynamic>>[],
            'communityStatus': false,
          },
        },
      };
      final model = ve.ViewEmailModel.fromJson(json);
      expect(model.data.url, isNull);
      expect(model.data.email.senderId, isNull);
      expect(model.data.email.messageText, isNull);
    });

    test('should handle null receivers/attachments/tags', () {
      final json = <String, dynamic>{
        'success': true, 'message': '',
        'data': <String, dynamic>{
          'url': null,
          'email': <String, dynamic>{
            'id': 1, 'senderEmail': '', 'subject': '', 'message': '',
            'isArchive': false, 'isTrash': false, 'isDeleted': false,
            'created': '', 'updated': '',
            'receivers': null, 'attachments': null,
            'sender': <String, dynamic>{'firstName': 'A', 'lastName': 'B', 'created': ''},
            'emailTags': null, 'communityStatus': false,
          },
        },
      };
      final model = ve.ViewEmailModel.fromJson(json);
      expect(model.data.email.receivers, isEmpty);
      expect(model.data.email.attachments, isEmpty);
      expect(model.data.email.emailTags, isEmpty);
    });

    test('should roundtrip through toJson/fromJson', () {
      final original = ve.ViewEmailModel.fromJson(makeViewEmailJson());
      final restored = ve.ViewEmailModel.fromJson(original.toJson());
      expect(restored.data.email.id, original.data.email.id);
      expect(restored.data.email.subject, original.data.email.subject);
      expect(restored.data.email.receivers.length,
          original.data.email.receivers.length);
    });
  });

  // ===== SentListModel =====
  group('SentListModel', () {
    Map<String, dynamic> makeSentEmailJson({int? id = 1}) => {
      'id': id,
      'senderId': 1,
      'senderEmail': 'me@test.com',
      'senderName': 'Me',
      'subject': 'Sent email',
      'messageText': 'Body text',
      'messageStatus': null,
      'created': '2024-06-15T10:30:00.000Z',
      'attachments': [],
      'receivers': [
        {
          'emailId': 1, 'receiverEmail': 'them@test.com', 'id': 1,
          'isRead': false,
          'emailRecipientTags': [],
          'receiver': {'firstName': 'Them', 'lastName': 'User', 'userName': 'themuser'},
        }
      ],
      'sender': {'id': 1, 'firstName': 'Me', 'lastName': 'User', 'created': '2024-01-01'},
      'emailTag': [],
      'message': '<p>Body</p>',
      'communityStatus': false,
    };

    test('should parse valid JSON', () {
      final json = {
        'success': true, 'message': 'OK',
        'data': {
          'emails': [makeSentEmailJson()],
          'nextPage': false,
        },
      };
      final model = sent.SentListModel.fromJson(json);
      expect(model.success, true);
      expect(model.data.emails, hasLength(1));
      expect(model.data.emails[0].subject, 'Sent email');
      expect(model.data.emails[0].receivers, hasLength(1));
      expect(model.data.emails[0].receivers![0].receiverEmail, 'them@test.com');
    });

    test('should parse DateTime from created string', () {
      final json = {
        'success': true, 'message': '',
        'data': {'emails': [makeSentEmailJson()], 'nextPage': false},
      };
      final model = sent.SentListModel.fromJson(json);
      expect(model.data.emails[0].created, isA<DateTime>());
    });

    test('should handle multiple emails', () {
      final json = {
        'success': true, 'message': '',
        'data': {
          'emails': [
            makeSentEmailJson(id: 1),
            makeSentEmailJson(id: 2),
            makeSentEmailJson(id: 3),
          ],
          'nextPage': true,
        },
      };
      final model = sent.SentListModel.fromJson(json);
      expect(model.data.emails, hasLength(3));
      expect(model.data.nextPage, true);
    });

    test('should roundtrip', () {
      final json = {
        'success': true, 'message': '',
        'data': {'emails': [makeSentEmailJson()], 'nextPage': false},
      };
      final model = sent.SentListModel.fromJson(json);
      final restored = sent.SentListModel.fromJson(model.toJson());
      expect(restored.data.emails.first.subject, 'Sent email');
    });
  });

  // ===== ViewDraftModel =====
  group('ViewDraftModel', () {
    Map<String, dynamic> makeViewDraftJson() => {
      'success': true,
      'message': 'OK',
      'data': {
        'email': {
          'id': 1,
          'senderId': 1,
          'subject': 'Draft Subject',
          'message': '<p>Draft body</p>',
          'isDeleted': false,
          'created': '2024-01-01T00:00:00.000Z',
          'updated': '2024-01-01T00:00:00.000Z',
          'receivers': [
            {
              'id': 1, 'draftId': 1, 'receiverEmail': 'to@test.com',
              'type': 'to', 'isRead': false, 'isTrash': false,
              'isArchive': false, 'isDeleted': false,
              'receiver': {'firstName': 'To', 'lastName': 'User'},
            },
          ],
          'attachments': [],
          'sender': {'id': 1, 'firstName': 'Me', 'lastName': 'User', 'created': '2024-01-01'},
        },
      },
    };

    test('should parse valid JSON', () {
      final model = vd.ViewDraftModel.fromJson(makeViewDraftJson());
      expect(model.success, true);
      expect(model.data.email.subject, 'Draft Subject');
      expect(model.data.email.receivers, hasLength(1));
      expect(model.data.email.receivers[0].receiverEmail, 'to@test.com');
      expect(model.data.email.sender.firstName, 'Me');
    });

    test('should handle empty attachments and receivers', () {
      final json = makeViewDraftJson();
      json['data']['email']['receivers'] = [];
      json['data']['email']['attachments'] = [];
      final model = vd.ViewDraftModel.fromJson(json);
      expect(model.data.email.receivers, isEmpty);
      expect(model.data.email.attachments, isEmpty);
    });

    test('should roundtrip', () {
      final original = vd.ViewDraftModel.fromJson(makeViewDraftJson());
      final restored = vd.ViewDraftModel.fromJson(original.toJson());
      expect(restored.data.email.subject, original.data.email.subject);
    });
  });
}
