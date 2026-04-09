// Implements: TC-DISC-MODEL-BATCH3-001..020
// Source: view_email_model.dart, inbox_list_model.dart — named constructors
// Coverage target: Push from 94% to 97%+
import 'package:flutter_test/flutter_test.dart';
import 'package:optmsg/model/view_email_model.dart' as ve;
import 'package:optmsg/model/inbox_list_model.dart' as inbox;
import 'package:optmsg/model/sent_list_model.dart' as sent;

void main() {
  // -------------------------------------------------------------------------
  // ViewEmailModel — all nested class constructors
  // -------------------------------------------------------------------------
  group('ViewEmailModel constructors', () {
    test('ViewEmailModel named constructor', () {
      final email = ve.Email.fromJson({
        'id': 1, 'senderId': 10, 'senderEmail': 'a@b.com',
        'subject': 'S', 'message': 'M', 'messageText': 'M',
        's3Key': null, 'messageId': null,
        'isArchive': false, 'isTrash': false, 'contentHeight': null,
        'isDeleted': false, 'created': '2024-01-01', 'updated': '2024-01-01',
        'attachments': [], 'sender': {'id': 1, 'firstName': 'A', 'lastName': 'B'},
        'receivers': [], 'emailTag': [],
      });
      final data = ve.Data(email: email);
      final model = ve.ViewEmailModel(success: true, data: data, message: 'OK');
      expect(model.success, isTrue);
      expect(model.data.email.id, 1);
    });

    test('Data named constructor', () {
      final email = ve.Email.fromJson({
        'id': 1, 'senderId': 10, 'senderEmail': 'a@b.com',
        'subject': 'S', 'message': 'M', 'isArchive': false, 'isTrash': false,
        'isDeleted': false, 'created': '2024-01-01', 'updated': '2024-01-01',
        'attachments': [], 'sender': null, 'receivers': [], 'emailTag': [],
      });
      final data = ve.Data(email: email, url: 'https://example.com');
      expect(data.url, 'https://example.com');
    });

    test('Receivers named constructor', () {
      final receiver = ve.Receiver(id: 1, firstName: 'John', lastName: 'Doe');
      final r = ve.Receivers(
        id: 1, emailId: 100, receiverEmail: 'a@b.com',
        type: 'to', isRead: false, isTrash: false, isArchive: false,
        isDeleted: false, receiver: receiver,
      );
      expect(r.id, 1);
      expect(r.receiverEmail, 'a@b.com');
    });

    test('EmailRecipientTags named constructor', () {
      final tag = ve.Tag(
        id: 1, userId: 10, tag: 'Work',
        isSuspended: false, isDeleted: false,
        created: '2024-01-01', updated: '2024-01-01',
      );
      final ert = ve.EmailRecipientTags(
        id: 1, tagId: 1, emailRecipientsId: 100, tag: tag,
      );
      expect(ert.id, 1);
      expect(ert.tag.tag, 'Work');
    });

    test('Tag named constructor', () {
      final tag = ve.Tag(
        id: 5, userId: 1, tag: 'Urgent',
        isSuspended: false, isDeleted: false,
        created: '2024-01-01', updated: '2024-01-01',
      );
      expect(tag.id, 5);
      expect(tag.tag, 'Urgent');
    });

    test('Receiver named constructor', () {
      final r = ve.Receiver(id: 1, firstName: 'A', lastName: 'B');
      expect(r.firstName, 'A');
    });

    test('Sender named constructor', () {
      final s = ve.Sender(id: 1, firstName: 'X', lastName: 'Y', created: '2024-01-01');
      expect(s.id, 1);
    });

    test('EmailTags named constructor', () {
      final et = ve.EmailTags(
        id: 1, userId: 10, tag: 'Personal',
        isSuspended: false, isDeleted: false,
        created: '2024-01-01', updated: '2024-01-01',
      );
      expect(et.tag, 'Personal');
    });

    test('Attachments named constructor', () {
      final att = ve.Attachments(id: 1, type: 'pdf', path: '/doc.pdf', emailId: 10, size: 1024);
      expect(att.id, 1);
      expect(att.size, 1024);
    });
  });

  // -------------------------------------------------------------------------
  // InboxListModel — all nested class constructors
  // -------------------------------------------------------------------------
  group('InboxListModel constructors', () {
    test('InboxListModel named constructor', () {
      final data = inbox.Data(emails: [], nextPage: false);
      final model = inbox.InboxListModel(success: true, data: data, message: 'OK');
      expect(model.success, isTrue);
    });

    test('Data named constructor', () {
      final data = inbox.Data(emails: [], nextPage: true);
      expect(data.nextPage, isTrue);
      expect(data.emails, isEmpty);
    });

    test('Email named constructor', () {
      final sender = inbox.Sender(id: 1, firstName: 'A', lastName: 'B');
      final email = inbox.Email(
        id: 1, senderEmail: 'a@b.com', subject: 'S', message: 'M',
        created: '2024-01-01', attachments: [], sender: sender,
      );
      expect(email.id, 1);
      expect(email.subject, 'S');
    });

    test('Attachments named constructor', () {
      final att = inbox.Attachments(id: 1, type: 'image', path: '/img.png');
      expect(att.id, 1);
    });

    test('Sender named constructor', () {
      final s = inbox.Sender(id: 5, firstName: 'Test', lastName: 'User');
      expect(s.id, 5);
    });

    test('EmailRecipientTags named constructor', () {
      final tag = inbox.Tag(id: 1, tag: 'Important');
      final ert = inbox.EmailRecipientTags(
        id: 1, tagId: 1, emailRecipientsId: 100, tag: tag,
      );
      expect(ert.tagId, 1);
    });

    test('Tag named constructor', () {
      final tag = inbox.Tag(id: 3, tag: 'Personal');
      expect(tag.id, 3);
      expect(tag.tag, 'Personal');
    });
  });

  // -------------------------------------------------------------------------
  // SentListModel — remaining uncovered constructors
  // -------------------------------------------------------------------------
  group('SentListModel remaining constructors', () {
    test('SentListModel named constructor', () {
      final data = sent.Data(emails: [], nextPage: false);
      final model = sent.SentListModel(success: true, data: data, message: 'OK');
      expect(model.success, isTrue);
    });

    test('Data named constructor', () {
      final data = sent.Data(emails: [], nextPage: true);
      expect(data.nextPage, isTrue);
    });

    test('Receiver named constructor', () {
      final r = sent.Receiver(firstName: 'A', lastName: 'B', userName: 'ab');
      expect(r.firstName, 'A');
    });

    test('EmailRecipientTags named constructor', () {
      final tag = sent.Tag(
        id: 1, userId: 10, tag: 'Work',
        isSuspended: false, isDeleted: false,
        created: '2024-01-01', updated: '2024-01-01',
      );
      final ert = sent.EmailRecipientTags(
        id: 1, tagId: 1, emailRecipientsId: 100, tag: tag,
      );
      expect(ert.id, 1);
    });

    test('Tag named constructor', () {
      final tag = sent.Tag(
        id: 5, userId: 1, tag: 'Urgent',
        isSuspended: false, isDeleted: false,
        created: '2024-01-01', updated: '2024-01-01',
      );
      expect(tag.id, 5);
    });
  });
}
