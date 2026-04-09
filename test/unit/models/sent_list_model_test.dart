// Implements: TC-DISC-SENT-001..015
// Source: lib/model/sent_list_model.dart
// Coverage target: 90%+ (standard)
import 'package:flutter_test/flutter_test.dart';
import 'package:optmsg/model/sent_list_model.dart';

/// Helper to create a full sent email JSON with all nested objects.
Map<String, dynamic> makeSentEmailJson({
  int id = 1,
  int senderId = 10,
  String senderEmail = 'sender@test.com',
  String subject = 'Test Subject',
  String message = '<p>Hello</p>',
  String messageText = 'Hello',
  String created = '2024-06-15T10:30:00.000Z',
  List<Map<String, dynamic>>? attachments,
  List<Map<String, dynamic>>? receivers,
  Map<String, dynamic>? sender,
  List<Map<String, dynamic>>? emailTag,
}) {
  return {
    'id': id,
    'senderId': senderId,
    'senderEmail': senderEmail,
    'senderName': 'Test Sender',
    'subject': subject,
    'messageText': messageText,
    'messageStatus': null,
    'created': created,
    'attachments': attachments ?? [],
    'receivers': receivers ?? [
      {
        'emailId': id,
        'receiverEmail': 'receiver@test.com',
        'id': 100,
        'isRead': false,
        'emailRecipientTags': [],
        'receiver': {
          'firstName': 'John',
          'lastName': 'Doe',
          'userName': 'johndoe',
        },
      }
    ],
    'sender': sender ?? {
      'id': senderId,
      'firstName': 'Test',
      'lastName': 'Sender',
      'created': '2024-01-01T00:00:00.000Z',
    },
    'emailTag': emailTag ?? [],
    'message': message,
    'communityStatus': null,
  };
}

Map<String, dynamic> makeSentListJson({
  bool success = true,
  String message = '',
  List<Map<String, dynamic>>? emails,
  bool nextPage = false,
}) {
  return {
    'success': success,
    'message': message,
    'data': {
      'emails': emails ?? [makeSentEmailJson()],
      'nextPage': nextPage,
    },
  };
}

Map<String, dynamic> makeTagJson({
  int id = 1,
  int userId = 1,
  String tag = 'Important',
  bool isSuspended = false,
  bool isDeleted = false,
  String created = '2024-01-01T00:00:00.000Z',
  String updated = '2024-01-01T00:00:00.000Z',
}) {
  return {
    'id': id,
    'userId': userId,
    'tag': tag,
    'isSuspended': isSuspended,
    'isDeleted': isDeleted,
    'created': created,
    'updated': updated,
  };
}

void main() {
  group('SentListModel', () {
    test('should deserialize from JSON', () {
      // TC-DISC-SENT-001
      final json = makeSentListJson();
      final model = SentListModel.fromJson(json);

      expect(model.success, isTrue);
      expect(model.message, '');
      expect(model.data.emails, hasLength(1));
      expect(model.data.nextPage, isFalse);
    });

    test('should serialize to JSON and roundtrip', () {
      // TC-DISC-SENT-002
      final json = makeSentListJson();
      final model = SentListModel.fromJson(json);
      final output = model.toJson();

      expect(output['success'], isTrue);
      expect(output['data']['nextPage'], isFalse);
    });

    test('should handle empty emails list', () {
      final json = makeSentListJson(emails: []);
      final model = SentListModel.fromJson(json);
      expect(model.data.emails, isEmpty);
    });
  });

  group('Emails (sent)', () {
    test('should deserialize all fields', () {
      // TC-DISC-SENT-003
      final json = makeSentEmailJson(
        id: 42,
        subject: 'Hello World',
        senderId: 5,
      );
      final email = Emails.fromJson(json);

      expect(email.id, 42);
      expect(email.subject, 'Hello World');
      expect(email.senderId, 5);
      expect(email.senderEmail, 'sender@test.com');
      expect(email.senderName, 'Test Sender');
      expect(email.messageText, 'Hello');
      expect(email.created, isNotNull);
      expect(email.receivers, hasLength(1));
      expect(email.sender, isNotNull);
      expect(email.attachments, isEmpty);
      expect(email.emailTag, isEmpty);
    });

    test('should handle null optional fields', () {
      // TC-DISC-SENT-004
      final json = {
        'id': null,
        'senderId': null,
        'senderEmail': null,
        'senderName': null,
        'subject': null,
        'messageText': null,
        'messageStatus': null,
        'created': null,
        'attachments': null,
        'receivers': null,
        'sender': null,
        'emailTag': null,
        'message': null,
        'communityStatus': null,
      };
      final email = Emails.fromJson(json);

      expect(email.id, isNull);
      expect(email.created, isNull);
      expect(email.attachments, isEmpty);
      expect(email.receivers, isEmpty);
      expect(email.sender, isNull);
      expect(email.emailTag, isEmpty);
    });

    test('should serialize to JSON', () {
      // TC-DISC-SENT-005
      final email = Emails.fromJson(makeSentEmailJson());
      final json = email.toJson();

      expect(json['id'], 1);
      expect(json['subject'], 'Test Subject');
      expect(json['receivers'], isList);
      expect(json['sender'], isMap);
    });

    test('copyWith should update specified fields', () {
      // TC-DISC-SENT-006
      final email = Emails.fromJson(makeSentEmailJson());
      final updated = email.copyWith(subject: 'Updated Subject', id: 99);

      expect(updated.subject, 'Updated Subject');
      expect(updated.id, 99);
      expect(updated.senderEmail, email.senderEmail); // unchanged
    });

    test('should parse created date correctly', () {
      final email = Emails.fromJson(makeSentEmailJson(
        created: '2024-06-15T10:30:00.000Z',
      ));
      expect(email.created, isA<DateTime>());
      expect(email.created!.year, 2024);
      expect(email.created!.month, 6);
    });

    test('should handle attachments', () {
      // TC-DISC-SENT-007
      final json = makeSentEmailJson(
        attachments: [
          {'id': 1},
          {'id': 2},
        ],
      );
      final email = Emails.fromJson(json);
      expect(email.attachments, hasLength(2));
      expect(email.attachments![0].id, 1);
    });

    test('should handle emailTag', () {
      // TC-DISC-SENT-008
      final json = makeSentEmailJson(
        emailTag: [
          {
            'id': 1,
            'tagId': 10,
            'emailRecipientsId': null,
            'emailId': 1,
            'tag': makeTagJson(id: 10, tag: 'Work'),
          },
        ],
      );
      final email = Emails.fromJson(json);
      expect(email.emailTag, hasLength(1));
      expect(email.emailTag![0].tagId, 10);
      expect(email.emailTag![0].tag.tag, 'Work');
    });
  });

  group('Receivers', () {
    test('should deserialize from JSON', () {
      // TC-DISC-SENT-009
      final json = {
        'emailId': 1,
        'receiverEmail': 'user@test.com',
        'id': 100,
        'isRead': true,
        'emailRecipientTags': [],
        'receiver': {
          'firstName': 'Jane',
          'lastName': 'Doe',
          'userName': 'janedoe',
        },
      };
      final receiver = Receivers.fromJson(json);

      expect(receiver.emailId, 1);
      expect(receiver.receiverEmail, 'user@test.com');
      expect(receiver.isRead, isTrue);
      expect(receiver.receiver!.firstName, 'Jane');
    });

    test('should serialize to JSON', () {
      final receiver = Receivers.fromJson({
        'emailId': 1,
        'receiverEmail': 'a@b.com',
        'id': 1,
        'isRead': false,
        'emailRecipientTags': [],
        'receiver': {'firstName': 'A', 'lastName': 'B', 'userName': 'ab'},
      });
      final json = receiver.toJson();
      expect(json['emailId'], 1);
      expect(json['receiver'], isMap);
    });

    test('copyWith should update fields', () {
      // TC-DISC-SENT-010
      final receiver = Receivers.fromJson({
        'emailId': 1,
        'receiverEmail': 'a@b.com',
        'id': 1,
        'isRead': false,
        'emailRecipientTags': [],
        'receiver': null,
      });
      final updated = receiver.copyWith(isRead: true);
      expect(updated.isRead, isTrue);
      expect(updated.emailId, 1);
    });

    test('should handle null receiver', () {
      final json = {
        'emailId': 1,
        'receiverEmail': 'a@b.com',
        'id': 1,
        'isRead': false,
        'emailRecipientTags': null,
        'receiver': null,
      };
      final receiver = Receivers.fromJson(json);
      expect(receiver.receiver, isNull);
      expect(receiver.emailRecipientTags, isEmpty);
    });
  });

  group('Receiver', () {
    test('should deserialize and serialize', () {
      // TC-DISC-SENT-011
      final json = {'firstName': 'Jane', 'lastName': 'Doe', 'userName': 'jdoe'};
      final receiver = Receiver.fromJson(json);

      expect(receiver.firstName, 'Jane');
      expect(receiver.lastName, 'Doe');
      expect(receiver.userName, 'jdoe');

      final output = receiver.toJson();
      expect(output['firstName'], 'Jane');
    });
  });

  group('Sender', () {
    test('should deserialize and serialize', () {
      // TC-DISC-SENT-012
      final json = {
        'id': 5,
        'firstName': 'Test',
        'lastName': 'Sender',
        'created': '2024-01-01T00:00:00.000Z',
      };
      final sender = Sender.fromJson(json);

      expect(sender.id, 5);
      expect(sender.firstName, 'Test');

      final output = sender.toJson();
      expect(output['id'], 5);
    });
  });

  group('Attachments (sent)', () {
    test('should deserialize and serialize', () {
      // TC-DISC-SENT-013
      final att = Attachments.fromJson({'id': 42});
      expect(att.id, 42);
      expect(att.toJson(), {'id': 42});
    });
  });

  group('EmailRecipientTags', () {
    test('should deserialize and serialize', () {
      // TC-DISC-SENT-014
      final json = {
        'id': 1,
        'tagId': 10,
        'emailRecipientsId': 100,
        'tag': makeTagJson(id: 10),
      };
      final ert = EmailRecipientTags.fromJson(json);

      expect(ert.id, 1);
      expect(ert.tagId, 10);
      expect(ert.emailRecipientsId, 100);
      expect(ert.tag.id, 10);

      final output = ert.toJson();
      expect(output['tagId'], 10);
      expect(output['tag'], isMap);
    });
  });

  group('EmailTag', () {
    test('should deserialize and serialize', () {
      // TC-DISC-SENT-015
      final json = {
        'id': 1,
        'tagId': 5,
        'emailRecipientsId': null,
        'emailId': 42,
        'tag': makeTagJson(id: 5, tag: 'Urgent'),
      };
      final emailTag = EmailTag.fromJson(json);

      expect(emailTag.id, 1);
      expect(emailTag.tagId, 5);
      expect(emailTag.emailId, 42);
      expect(emailTag.tag.tag, 'Urgent');

      final output = emailTag.toJson();
      expect(output['emailId'], 42);
    });
  });

  group('Tag', () {
    test('should deserialize and serialize', () {
      final json = makeTagJson(id: 3, tag: 'Personal', userId: 7);
      final tag = Tag.fromJson(json);

      expect(tag.id, 3);
      expect(tag.tag, 'Personal');
      expect(tag.userId, 7);
      expect(tag.isSuspended, isFalse);
      expect(tag.isDeleted, isFalse);

      final output = tag.toJson();
      expect(output['id'], 3);
      expect(output['tag'], 'Personal');
    });
  });
}
