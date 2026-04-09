// Implements: TC-DISC-MODEL-CTOR-001..020
// Source: Multiple model files — testing named constructors and toJson roundtrips
// Coverage target: Push models from 88-94% to 95%+
import 'package:flutter_test/flutter_test.dart';
import 'package:optmsg/model/contact_list_model.dart' as contact;
import 'package:optmsg/model/notification_list_model.dart' as notif;
import 'package:optmsg/model/view_draft_model.dart' as vd;
import 'package:optmsg/model/draft_list_modal.dart' as draft;

void main() {
  // -------------------------------------------------------------------------
  // ContactListModel — named constructors
  // -------------------------------------------------------------------------
  group('ContactListModel constructors', () {
    test('ContactListModel named constructor', () {
      // TC-DISC-MODEL-CTOR-001
      final data = contact.Data(contacts: [], nextPage: false);
      final model = contact.ContactListModel(
        success: true,
        data: data,
        message: 'OK',
      );
      expect(model.success, isTrue);
      expect(model.data.contacts, isEmpty);
      expect(model.data.nextPage, isFalse);
    });

    test('Contacts named constructor', () {
      // TC-DISC-MODEL-CTOR-002
      final c = contact.Contacts(
        id: 1,
        firstName: 'John',
        lastName: 'Doe',
        company: 'Acme',
        emails: [],
      );
      expect(c.id, 1);
      expect(c.firstName, 'John');
      expect(c.company, 'Acme');
      expect(c.initials, isNull);
    });

    test('Emails named constructor', () {
      // TC-DISC-MODEL-CTOR-003
      final email = contact.Emails(id: 1, email: 'test@test.com');
      expect(email.id, 1);
      expect(email.email, 'test@test.com');
    });
  });

  // -------------------------------------------------------------------------
  // NotificationListModel — named constructors
  // -------------------------------------------------------------------------
  group('NotificationListModel constructors', () {
    test('NotificationListModel named constructor', () {
      // TC-DISC-MODEL-CTOR-004
      final data = notif.Data(notifications: []);
      final model = notif.NotificationListModel(
        success: true,
        data: data,
        message: 'OK',
      );
      expect(model.success, isTrue);
      expect(model.data.notifications, isEmpty);
    });

    test('Data named constructor', () {
      // TC-DISC-MODEL-CTOR-005
      final data = notif.Data(notifications: []);
      expect(data.notifications, isEmpty);
    });

    test('Info named constructor', () {
      // TC-DISC-MODEL-CTOR-006
      final info = notif.Info(emailId: 42);
      expect(info.emailId, 42);
    });

    test('Notifications copyWith', () {
      // TC-DISC-MODEL-CTOR-007
      final notification = notif.Notifications.fromJson({
        'id': 1,
        'type': 'email',
        'title': 'Test',
        'body': 'Body',
        'userId': 1,
        'info': {'senderName': 'Sender'},
        'isRead': false,
        'isDeleted': false,
        'created': '2024-01-01T00:00:00.000Z',
        'updated': '2024-01-01T00:00:00.000Z',
      });

      final updated = notification.copyWith(isRead: true);
      expect(updated.isRead, isTrue);
      expect(updated.id, 1);
    });
  });

  // -------------------------------------------------------------------------
  // ViewDraftModel — named constructors + toJson
  // -------------------------------------------------------------------------
  group('ViewDraftModel constructors', () {
    test('ViewDraftModel fromJson and toJson', () {
      // TC-DISC-MODEL-CTOR-008
      final json = {
        'success': true,
        'message': 'OK',
        'data': {
          'email': {
            'id': 1,
            'senderId': 10,
            'subject': 'Draft Subject',
            'message': '<p>Draft</p>',
            'isDeleted': false,
            'created': '2024-01-01T00:00:00.000Z',
            'updated': '2024-01-01T00:00:00.000Z',
            'attachments': [],
            'sender': {'id': 1, 'firstName': 'A', 'lastName': 'B', 'created': '2024-01-01'},
            'receivers': [],
          },
        },
      };
      final model = vd.ViewDraftModel.fromJson(json);
      expect(model.success, isTrue);

      final output = model.toJson();
      expect(output['success'], isTrue);
    });

    test('ViewDraftModel named constructor', () {
      // TC-DISC-MODEL-CTOR-009
      final email = vd.Email.fromJson({
        'id': 1,
        'senderId': 10,
        'subject': 'Test',
        'message': 'Body',
        'isDeleted': false,
        'created': '2024-01-01',
        'updated': '2024-01-01',
        'attachments': [],
        'sender': {'id': 1, 'firstName': 'A', 'lastName': 'B', 'created': '2024-01-01'},
        'receivers': [],
      });
      final data = vd.Data(email: email);
      final model = vd.ViewDraftModel(
        success: true,
        data: data,
        message: 'OK',
      );
      expect(model.success, isTrue);
    });

    test('Data toJson with email', () {
      // TC-DISC-MODEL-CTOR-010
      final json = {
        'email': {
          'id': 1,
          'senderId': 10,
          'subject': 'Test',
          'message': 'Body',
          'isDeleted': false,
          'created': '2024-01-01',
          'updated': '2024-01-01',
          'attachments': [
            {'id': 1, 'type': 'pdf', 'path': '/doc.pdf', 'draftId': 1},
          ],
          'sender': {'id': 1, 'firstName': 'A', 'lastName': 'B', 'created': '2024-01-01'},
          'receivers': [],
        },
      };
      final data = vd.Data.fromJson(json);
      final output = data.toJson();
      expect(output['email'], isMap);
    });

    test('Attachments roundtrip', () {
      // TC-DISC-MODEL-CTOR-011
      final att = vd.Attachments.fromJson({
        'id': 1,
        'type': 'pdf',
        'path': '/doc.pdf',
        'draftId': 5,
      });
      expect(att.id, 1);
      final output = att.toJson();
      expect(output['path'], '/doc.pdf');
    });

    test('Receiver named constructor', () {
      // TC-DISC-MODEL-CTOR-012
      final receiver = vd.Receiver(
        firstName: 'John',
        lastName: 'Doe',
      );
      expect(receiver.firstName, 'John');
      expect(receiver.lastName, 'Doe');
    });

    test('Sender named constructor', () {
      // TC-DISC-MODEL-CTOR-013
      final sender = vd.Sender(
        id: 5,
        firstName: 'Test',
        lastName: 'Sender',
        created: '2024-01-01',
      );
      expect(sender.id, 5);
    });
  });

  // -------------------------------------------------------------------------
  // DraftListModel — named constructors + toJson
  // -------------------------------------------------------------------------
  group('DraftListModel constructors', () {
    test('DraftListModel named constructor', () {
      // TC-DISC-MODEL-CTOR-016
      final data = draft.Data(emails: [], nextPage: false);
      final model = draft.DraftListModel(
        success: true,
        data: data,
        message: 'OK',
      );
      expect(model.success, isTrue);
    });

    test('DraftListModel toJson roundtrip', () {
      // TC-DISC-MODEL-CTOR-017
      final json = {
        'success': true,
        'message': 'OK',
        'data': {
          'emails': [
            {
              'id': 1,
              'senderId': 10,
              'subject': 'Draft',
              'message': 'Body',
              'isDeleted': false,
              'created': '2024-01-01',
              'updated': '2024-01-01',
              'attachments': [],
            },
          ],
          'nextPage': false,
        },
      };
      final model = draft.DraftListModel.fromJson(json);
      final output = model.toJson();
      expect(output['success'], isTrue);
    });

    test('Emails named constructor', () {
      // TC-DISC-MODEL-CTOR-018
      final email = draft.Emails(
        id: 1,
        senderId: 10,
        subject: 'Test',
        message: 'Body',
        isDeleted: false,
        created: '2024-01-01',
        updated: '2024-01-01',
        attachments: [],
      );
      expect(email.id, 1);
    });

    test('Attachments named constructor and toJson', () {
      // TC-DISC-MODEL-CTOR-019
      final att = draft.Attachments(
        id: 1,
        type: 'image',
        path: '/img.png',
        draftId: 5,
      );
      expect(att.id, 1);
      final output = att.toJson();
      expect(output['type'], 'image');
    });
  });
}
