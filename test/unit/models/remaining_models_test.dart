import 'package:flutter_test/flutter_test.dart';
import 'package:optmsg/model/notification_list_model.dart';
import 'package:optmsg/model/draft_list_modal.dart' as draft;
import 'package:optmsg/model/contact_list_model.dart' as contact;
import 'package:optmsg/model/plan_list_model.dart' as plan;
import 'package:optmsg/model/static_page_model.dart' as sp;
import 'package:optmsg/model/otp_verify_model.dart';
import 'package:optmsg/model/contact_email_details.dart';
import 'package:optmsg/model/tags_list_model.dart';
import 'package:optmsg/model/signed_url_model.dart';
import 'package:optmsg/model/create_account_model.dart';
import 'package:optmsg/model/request_login_model.dart' as rl;
import 'package:optmsg/model/forgot_user_name_model.dart';
import 'package:optmsg/model/static_faq_page_model.dart';
import 'package:optmsg/model/search_email_model.dart' as se;
import 'package:optmsg/model/payment_list_model.dart' as pay;

import '../../factories/test_data_factories.dart';

void main() {
  // ===== NotificationListModel =====
  group('NotificationListModel', () {
    Map<String, dynamic> makeNotificationJson({
      int id = 1,
      String type = 'email',
      String title = 'New message',
      String body = 'You have a new email',
      int userId = 1,
      int? emailId = 100,
      bool? isRead = false,
    }) => {
      'id': id,
      'type': type,
      'title': title,
      'body': body,
      'userId': userId,
      'info': {'emailId': emailId},
      'isRead': isRead,
      'isDeleted': false,
      'created': '2024-01-01T00:00:00.000Z',
      'updated': '2024-01-01T00:00:00.000Z',
    };

    test('should parse valid JSON', () {
      final json = {
        'success': true,
        'message': 'OK',
        'data': {
          'notifications': [makeNotificationJson()]
        },
      };
      final model = NotificationListModel.fromJson(json);
      expect(model.success, true);
      expect(model.data.notifications, hasLength(1));
      expect(model.data.notifications[0].title, 'New message');
      expect(model.data.notifications[0].info.emailId, 100);
    });

    test('should roundtrip', () {
      final json = {
        'success': true,
        'message': 'OK',
        'data': {
          'notifications': [makeNotificationJson(), makeNotificationJson(id: 2)]
        },
      };
      final model = NotificationListModel.fromJson(json);
      final restored = NotificationListModel.fromJson(model.toJson());
      expect(restored.data.notifications, hasLength(2));
    });

    test('Notifications copyWith should work', () {
      final n = Notifications.fromJson(makeNotificationJson(isRead: false));
      final copy = n.copyWith(isRead: true);
      expect(copy.isRead, true);
      expect(copy.id, n.id);
    });
  });

  // ===== DraftListModel =====
  group('DraftListModel', () {
    Map<String, dynamic> makeDraftEmailJson({int id = 1}) => {
      'id': id,
      'senderId': 1,
      'subject': 'Draft subject',
      'message': '<p>Draft body</p>',
      'isDeleted': false,
      'created': '2024-01-01T00:00:00.000Z',
      'updated': '2024-01-01T00:00:00.000Z',
      'attachments': [],
    };

    test('should parse valid JSON', () {
      final json = {
        'success': true,
        'message': 'OK',
        'data': {
          'emails': [makeDraftEmailJson()],
          'nextPage': false,
        },
      };
      final model = draft.DraftListModel.fromJson(json);
      expect(model.success, true);
      expect(model.data.emails, hasLength(1));
      expect(model.data.emails[0].subject, 'Draft subject');
      expect(model.data.nextPage, false);
    });

    test('should roundtrip', () {
      final json = {
        'success': true,
        'message': '',
        'data': {
          'emails': [makeDraftEmailJson()],
          'nextPage': true,
        },
      };
      final model = draft.DraftListModel.fromJson(json);
      final restored = draft.DraftListModel.fromJson(model.toJson());
      expect(restored.data.nextPage, true);
    });
  });

  // ===== ContactListModel =====
  group('ContactListModel', () {
    Map<String, dynamic> makeContactJson({int id = 1}) => {
      'id': id,
      'firstName': 'Jane',
      'lastName': 'Doe',
      'company': 'Acme',
      'phones': null,
      'emails': [
        {'id': 1, 'email': 'jane@test.com'}
      ],
    };

    test('should parse valid JSON', () {
      final json = {
        'success': true,
        'message': 'OK',
        'data': {
          'nextPage': true,
          'contacts': [makeContactJson()],
        },
      };
      final model = contact.ContactListModel.fromJson(json);
      expect(model.success, true);
      expect(model.data.contacts, hasLength(1));
      expect(model.data.contacts[0].firstName, 'Jane');
      expect(model.data.contacts[0].emails, hasLength(1));
      expect(model.data.nextPage, true);
    });

    test('should handle null emails list', () {
      final json = {
        'success': true,
        'message': '',
        'data': {
          'nextPage': false,
          'contacts': [
            {'id': 1, 'firstName': 'Bob', 'lastName': 'Smith', 'company': '', 'phones': null, 'emails': null}
          ],
        },
      };
      final model = contact.ContactListModel.fromJson(json);
      expect(model.data.contacts[0].emails, isNull);
    });

    test('should roundtrip', () {
      final json = {
        'success': true,
        'message': '',
        'data': {'nextPage': false, 'contacts': [makeContactJson()]},
      };
      final model = contact.ContactListModel.fromJson(json);
      final restored = contact.ContactListModel.fromJson(model.toJson());
      expect(restored.data.contacts[0].lastName, 'Doe');
    });
  });

  // ===== PlanListModel =====
  group('PlanListModel', () {
    test('should parse valid JSON', () {
      final json = makePlanListJson(plans: [
        makePlanJson(id: 1, title: 'Free', charge: 0, type: 'free'),
        makePlanJson(id: 2, title: 'Pro', charge: 999),
      ]);
      final model = plan.PlanListModel.fromJson(json);
      expect(model.success, true);
      expect(model.data.plans, hasLength(2));
      expect(model.data.plans[0].title, 'Free');
      expect(model.data.plans[1].charge, 999);
    });

    test('should roundtrip', () {
      final model = plan.PlanListModel.fromJson(makePlanListJson());
      final restored = plan.PlanListModel.fromJson(model.toJson());
      expect(restored.data.plans.first.title, 'Pro Plan');
    });
  });

  // ===== StaticPage =====
  group('StaticPage', () {
    test('should parse valid JSON', () {
      final json = {
        'success': true,
        'message': 'OK',
        'data': {
          'page': {
            'id': 1,
            'title': 'Terms of Service',
            'slug': 'terms',
            'description': '<p>Terms content</p>',
            'isSuspended': false,
            'isDeleted': false,
            'created': '2024-01-01T00:00:00.000Z',
            'updated': '2024-01-01T00:00:00.000Z',
          }
        },
      };
      final model = sp.StaticPage.fromJson(json);
      expect(model.data.page.title, 'Terms of Service');
      expect(model.data.page.slug, 'terms');
    });

    test('should roundtrip', () {
      final json = {
        'success': true,
        'message': '',
        'data': {
          'page': {
            'id': 1, 'title': 'Privacy', 'slug': 'privacy',
            'description': '', 'isSuspended': false, 'isDeleted': false,
            'created': '', 'updated': '',
          }
        },
      };
      final model = sp.StaticPage.fromJson(json);
      final restored = sp.StaticPage.fromJson(model.toJson());
      expect(restored.data.page.title, 'Privacy');
    });
  });

  // ===== OtpVerify =====
  group('OtpVerify', () {
    test('should parse valid JSON', () {
      final json = {
        'success': true,
        'message': 'OTP sent',
        'data': {
          'id': 1, 'countryCode': '+1', 'mobile': '5551234567',
          'isVerified': false, 'type': 'login', 'otp': '123456',
          'validTill': 1700000000, 'created': '', 'updated': '',
        },
      };
      final model = OtpVerify.fromJson(json);
      expect(model.success, true);
      expect(model.data.mobile, '5551234567');
      expect(model.data.otp, '123456');
    });

    test('should roundtrip', () {
      final json = {
        'success': true, 'message': '',
        'data': {
          'id': 1, 'countryCode': '+1', 'mobile': '555', 'isVerified': true,
          'type': 'signup', 'otp': '000000', 'validTill': 0, 'created': '', 'updated': '',
        },
      };
      final model = OtpVerify.fromJson(json);
      final restored = OtpVerify.fromJson(model.toJson());
      expect(restored.data.isVerified, true);
    });
  });

  // ===== ContactEmailDetailsModel =====
  group('ContactEmailDetailsModel', () {
    test('should parse valid JSON', () {
      final json = {
        'success': true,
        'message': 'OK',
        'data': {
          'contacts': [
            {'id': 1, 'email': 'test@example.com', 'isDeleted': false},
          ],
        },
      };
      final model = ContactEmailDetailsModel.fromJson(json);
      expect(model.success, true);
      expect(model.data!.contacts, hasLength(1));
      expect(model.data!.contacts![0].email, 'test@example.com');
    });

    test('should handle null data', () {
      final json = {'success': false, 'message': 'Error', 'data': null};
      final model = ContactEmailDetailsModel.fromJson(json);
      expect(model.data, isNull);
    });

    test('should roundtrip', () {
      final json = {
        'success': true, 'message': '',
        'data': {'contacts': [{'id': 1, 'email': 'a@b.com', 'isDeleted': false}]},
      };
      final model = ContactEmailDetailsModel.fromJson(json);
      final restored = ContactEmailDetailsModel.fromJson(model.toJson());
      expect(restored.data!.contacts![0].email, 'a@b.com');
    });
  });

  // ===== TagsListModel =====
  group('TagsListModel', () {
    test('should parse valid JSON', () {
      final json = {
        'success': true, 'message': '',
        'data': {
          'tags': [
            {'id': 1, 'tag': 'Work'},
            {'id': 2, 'tag': 'Personal'},
          ],
        },
      };
      final model = TagsListModel.fromJson(json);
      expect(model.data.tags, hasLength(2));
      expect(model.data.tags[0].tag, 'Work');
    });

    test('should roundtrip', () {
      final json = {
        'success': true, 'message': '',
        'data': {'tags': [{'id': 1, 'tag': 'Important'}]},
      };
      final model = TagsListModel.fromJson(json);
      final restored = TagsListModel.fromJson(model.toJson());
      expect(restored.data.tags[0].tag, 'Important');
    });
  });

  // ===== SignedUrlModel =====
  group('SignedUrlModel', () {
    test('should parse valid JSON', () {
      final json = {
        'success': true, 'message': '',
        'data': {
          'url': 'https://s3.example.com/file',
          'preview': 'https://s3.example.com/preview',
          'fileName': 'document.pdf',
        },
      };
      final model = SignedUrlModel.fromJson(json);
      expect(model.data.url, contains('s3.example.com'));
      expect(model.data.fileName, 'document.pdf');
    });

    test('should roundtrip', () {
      final json = {
        'success': true, 'message': '',
        'data': {'url': 'u', 'preview': 'p', 'fileName': 'f.txt'},
      };
      final model = SignedUrlModel.fromJson(json);
      final restored = SignedUrlModel.fromJson(model.toJson());
      expect(restored.data.fileName, 'f.txt');
    });
  });

  // ===== CreateAccount =====
  group('CreateAccount', () {
    test('should parse valid JSON', () {
      final json = {
        'success': true, 'message': 'Account created',
        'data': {
          'id': 1, 'userName': 'newuser', 'countryCode': '+1',
          'mobile': '555', 'otp': '123456', 'validTill': 1700000000,
          'updated': '2024-01-01',
        },
      };
      final model = CreateAccount.fromJson(json);
      expect(model.data.userName, 'newuser');
      expect(model.data.otp, '123456');
    });

    test('should roundtrip', () {
      final json = {
        'success': true, 'message': '',
        'data': {
          'id': 1, 'userName': 'u', 'countryCode': '+1',
          'mobile': '5', 'otp': '0', 'validTill': 0, 'updated': '',
        },
      };
      final model = CreateAccount.fromJson(json);
      final restored = CreateAccount.fromJson(model.toJson());
      expect(restored.data.userName, 'u');
    });
  });

  // ===== RequestLogin =====
  group('RequestLogin', () {
    test('should parse valid JSON', () {
      final json = {
        'success': true, 'message': 'OK',
        'data': {
          'user': {
            'id': 1, 'firstName': 'Test', 'lastName': 'User',
            'userName': 'testuser', 'countryCode': '+1', 'mobile': '555',
          },
        },
      };
      final model = rl.RequestLogin.fromJson(json);
      expect(model.data.user.userName, 'testuser');
    });

    test('should roundtrip', () {
      final json = {
        'success': true, 'message': '',
        'data': {
          'user': {
            'id': 1, 'firstName': 'A', 'lastName': 'B',
            'userName': 'ab', 'countryCode': '+1', 'mobile': '5',
          },
        },
      };
      final model = rl.RequestLogin.fromJson(json);
      final restored = rl.RequestLogin.fromJson(model.toJson());
      expect(restored.data.user.firstName, 'A');
    });
  });

  // ===== UserName (ForgotUserName) =====
  group('UserName (ForgotUserName)', () {
    test('should parse valid JSON', () {
      final json = {
        'success': true, 'message': 'OK',
        'data': {
          'id': 1, 'countryCode': '+1', 'mobile': '555',
          'type': 'forgot', 'otp': '123456', 'validTill': 1700000000,
          'updated': '', 'userName': 'founduser',
        },
      };
      final model = UserName.fromJson(json);
      expect(model.data.userName, 'founduser');
      expect(model.data.type, 'forgot');
    });

    test('should handle null userName', () {
      final json = {
        'success': true, 'message': '',
        'data': {
          'id': 1, 'countryCode': '+1', 'mobile': '555',
          'type': 'forgot', 'otp': '0', 'validTill': 0, 'updated': '',
        },
      };
      final model = UserName.fromJson(json);
      expect(model.data.userName, isNull);
    });
  });

  // ===== FaqStaticPage =====
  group('FaqStaticPage', () {
    test('should parse valid JSON', () {
      final json = {
        'success': true, 'message': 'OK',
        'data': {
          'faq': [
            {'id': 1, 'question': 'What is OptMsg?', 'answer': 'A messaging app'},
          ],
        },
      };
      final model = FaqStaticPage.fromJson(json);
      expect(model.success, true);
      expect(model.data!.faq, hasLength(1));
      expect(model.data!.faq![0].question, 'What is OptMsg?');
    });

    test('should handle null data', () {
      final json = {'success': false, 'message': '', 'data': null};
      final model = FaqStaticPage.fromJson(json);
      expect(model.data, isNull);
    });

    test('should roundtrip', () {
      final json = {
        'success': true, 'message': '',
        'data': {'faq': [{'id': 1, 'question': 'Q', 'answer': 'A'}]},
      };
      final model = FaqStaticPage.fromJson(json);
      final restored = FaqStaticPage.fromJson(model.toJson());
      expect(restored.data!.faq![0].answer, 'A');
    });
  });

  // ===== SearchEmailModel =====
  group('SearchEmailModel', () {
    test('should parse valid JSON', () {
      final json = {
        'success': true, 'message': '',
        'data': {
          'emails': [
            {'id': 1, 'userId': 1, 'email': 'test@example.com', 'firstName': 'Test', 'lastName': 'User', 'company': 'Acme'},
          ],
        },
      };
      final model = se.SearchEmailModel.fromJson(json);
      expect(model.data.emails, hasLength(1));
      expect(model.data.emails[0].email, 'test@example.com');
    });

    test('should handle null optional fields', () {
      final json = {
        'success': true, 'message': '',
        'data': {
          'emails': [
            {'id': 1, 'userId': 1, 'email': 'a@b.com'},
          ],
        },
      };
      final model = se.SearchEmailModel.fromJson(json);
      expect(model.data.emails[0].firstName, isNull);
    });

    test('should roundtrip', () {
      final json = {
        'success': true, 'message': '',
        'data': {'emails': [{'id': 1, 'userId': 1, 'email': 'x@y.com', 'firstName': 'X', 'lastName': 'Y', 'company': 'Z'}]},
      };
      final model = se.SearchEmailModel.fromJson(json);
      final restored = se.SearchEmailModel.fromJson(model.toJson());
      expect(restored.data.emails[0].company, 'Z');
    });
  });

  // ===== PaymentListModel =====
  group('PaymentListModel', () {
    test('should parse valid JSON', () {
      final json = {
        'success': true, 'message': '',
        'data': {
          'plan': {
            'id': 1, 'title': 'Pro', 'charge': 999, 'type': 'paid',
            'chargeFrequency': 30, 'description': 'Pro plan', 'features': ['A'],
          },
          'paymentList': [
            {
              'id': 1, 'userId': 1, 'start': 1700000000, 'ends': 1702592000,
              'charge': 999, 'discount': 0,
              'plan': {
                'id': 1, 'title': 'Pro', 'charge': 999, 'type': 'paid',
                'chargeFrequency': 30, 'description': '', 'features': [],
              },
              'startEnd': '', 'added': '',
            },
          ],
        },
      };
      final model = pay.PaymentListModel.fromJson(json);
      expect(model.data.plan.title, 'Pro');
      expect(model.data.paymentList, hasLength(1));
      expect(model.data.paymentList[0].charge, 999);
    });
  });
}
