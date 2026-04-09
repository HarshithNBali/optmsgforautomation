import 'package:flutter_test/flutter_test.dart';
import 'package:optmsg/model/inbox_list_model.dart';

import '../../factories/test_data_factories.dart';

void main() {
  group('InboxListModel', () {
    test('should parse valid JSON correctly', () {
      final json = makeInboxListJson();
      final model = InboxListModel.fromJson(json);

      expect(model.success, true);
      expect(model.message, '');
      expect(model.data, isNotNull);
      expect(model.data!.emails, hasLength(1));
      expect(model.data!.nextPage, false);
    });

    test('should handle null data gracefully', () {
      final json = {
        'success': false,
        'message': 'Unauthorized',
        'data': null,
      };
      final model = InboxListModel.fromJson(json);

      expect(model.success, false);
      expect(model.data, isNull);
      expect(model.message, 'Unauthorized');
    });

    test('should handle missing data key gracefully', () {
      final json = {
        'success': false,
        'message': 'Error',
      };
      final model = InboxListModel.fromJson(json);

      expect(model.data, isNull);
    });

    test('should parse multiple emails', () {
      final json = makeInboxListJson(
        emails: [
          makeInboxEmailJson(id: 1, emailId: 100, isRead: false),
          makeInboxEmailJson(id: 2, emailId: 101, isRead: true),
          makeInboxEmailJson(id: 3, emailId: 102, isRead: false),
        ],
        nextPage: true,
      );
      final model = InboxListModel.fromJson(json);

      expect(model.data!.emails, hasLength(3));
      expect(model.data!.nextPage, true);
      expect(model.data!.emails[0].isRead, false);
      expect(model.data!.emails[1].isRead, true);
    });

    test('should roundtrip through toJson/fromJson', () {
      final original = InboxListModel.fromJson(makeInboxListJson(
        emails: [makeInboxEmailJson(id: 5, emailId: 500)],
      ));
      final json = original.toJson();
      final restored = InboxListModel.fromJson(json);

      expect(restored.success, original.success);
      expect(restored.data!.emails.length, original.data!.emails.length);
      expect(restored.data!.emails.first.id, 5);
    });

    test('should roundtrip with null data', () {
      final original = InboxListModel.fromJson({
        'success': false,
        'message': 'Error',
        'data': null,
      });
      final json = original.toJson();

      expect(json['data'], isNull);
    });
  });

  group('Emails (inbox item)', () {
    test('should parse all fields', () {
      final json = makeInboxEmailJson(
        id: 10,
        emailId: 200,
        receiverId: 5,
        isRead: true,
      );
      final emails = Emails.fromJson(json);

      expect(emails.id, 10);
      expect(emails.emailId, 200);
      expect(emails.receiverId, 5);
      expect(emails.isRead, true);
      expect(emails.email, isNotNull);
      expect(emails.emailRecipientTags, isEmpty);
    });

    test('should parse email recipient tags', () {
      final json = makeInboxEmailJson(
        emailRecipientTags: [
          makeEmailRecipientTagJson(id: 1, tagId: 10),
          makeEmailRecipientTagJson(id: 2, tagId: 20),
        ],
      );
      final emails = Emails.fromJson(json);

      expect(emails.emailRecipientTags, hasLength(2));
      expect(emails.emailRecipientTags[0].tagId, 10);
      expect(emails.emailRecipientTags[1].tagId, 20);
    });

    test('should handle null emailRecipientTags', () {
      final json = makeInboxEmailJson();
      json['emailRecipientTags'] = null;
      final emails = Emails.fromJson(json);

      expect(emails.emailRecipientTags, isEmpty);
    });

    test('copyWith should create modified copy', () {
      final original = Emails.fromJson(makeInboxEmailJson(isRead: false));
      final copy = original.copyWith(isRead: true);

      expect(copy.isRead, true);
      expect(copy.id, original.id);
      expect(copy.emailId, original.emailId);
    });
  });

  group('Email', () {
    test('should parse all fields', () {
      final json = makeEmailJson(
        id: 300,
        senderId: 5,
        senderEmail: 'alice@test.com',
        subject: 'Hello World',
        message: '<p>Content</p>',
        messageText: 'Content',
      );
      final email = Email.fromJson(json);

      expect(email.id, 300);
      expect(email.senderId, 5);
      expect(email.senderEmail, 'alice@test.com');
      expect(email.subject, 'Hello World');
      expect(email.message, '<p>Content</p>');
      expect(email.messageText, 'Content');
      expect(email.attachments, isEmpty);
      expect(email.sender, isNotNull);
    });
  });

  group('Tag', () {
    test('should parse and roundtrip', () {
      final json = makeTagJson(id: 5, tag: 'Work');
      final tag = Tag.fromJson(json);

      expect(tag.id, 5);
      expect(tag.tag, 'Work');

      final restored = Tag.fromJson(tag.toJson());
      expect(restored.id, 5);
      expect(restored.tag, 'Work');
    });
  });

  group('Sender', () {
    test('should parse sender fields', () {
      final json = makeSenderJson(
        firstName: 'Alice',
        lastName: 'Smith',
      );
      final sender = Sender.fromJson(json);

      expect(sender.firstName, 'Alice');
      expect(sender.lastName, 'Smith');
    });
  });
}
