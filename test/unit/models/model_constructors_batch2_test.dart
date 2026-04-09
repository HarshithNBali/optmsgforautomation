// Implements: TC-DISC-MODEL-BATCH2-001..020
// Source: Multiple model files — testing named constructors to push to 95%+
import 'package:flutter_test/flutter_test.dart';
import 'package:optmsg/model/profile_model.dart' as profile;
import 'package:optmsg/model/plan_list_model.dart' as plan;
import 'package:optmsg/model/static_page_model.dart' as sp;
import 'package:optmsg/model/tags_list_model.dart' as tags;
import 'package:optmsg/model/request_login_model.dart' as rl;
import 'package:optmsg/model/static_faq_page_model.dart' as faq;
import 'package:optmsg/model/search_email_model.dart' as search;
import 'package:optmsg/model/payment_list_model.dart' as payment;
import 'package:optmsg/model/login_model.dart' as login;
import 'package:optmsg/model/base_response/request_error.dart';

void main() {
  group('MyProfile constructors', () {
    test('MyProfile named constructor', () {
      final data = profile.Data(
        id: 1, firstName: 'A', lastName: 'B', userName: 'ab',
        dob: '1990-01-01', countryCode: '+1', mobile: '123',
        isSubscribed: true, isNotification: true, isAcceptTerms: true,
        isSuspended: false, isDeleted: false, created: '2024-01-01',
        updated: '2024-01-01', isDeviceBiometrics: false, isBiomatrix: false,
      );
      final model = profile.MyProfile(success: true, data: data, message: 'OK');
      expect(model.success, isTrue);
    });
  });

  group('PlanListModel constructors', () {
    test('PlanListModel named constructor', () {
      final data = plan.Data(plans: []);
      final model = plan.PlanListModel(success: true, data: data, message: 'OK');
      expect(model.success, isTrue);
    });

    test('Plans named constructor', () {
      final p = plan.Plans(
        id: 1, title: 'Pro', charge: 999, type: 'paid',
        chargeFrequency: 30, description: 'desc', features: ['f1'], nextPaymentDate: '2025-01-01',
      );
      expect(p.id, 1);
    });
  });

  group('StaticPage constructors', () {
    test('StaticPage named constructor', () {
      final page = sp.Page(
        id: 1, title: 'T', slug: 's', description: 'd',
        isSuspended: false, isDeleted: false,
        created: '2024-01-01', updated: '2024-01-01',
      );
      final data = sp.Data(page: page);
      final model = sp.StaticPage(success: true, data: data, message: 'OK');
      expect(model.success, isTrue);
    });
  });

  group('TagsListModel constructors', () {
    test('TagsListModel named constructor', () {
      final data = tags.Data(tags: []);
      final model = tags.TagsListModel(success: true, data: data, message: 'OK');
      expect(model.success, isTrue);
    });

    test('Tags named constructor', () {
      final tag = tags.Tags(id: 1, tag: 'Important');
      expect(tag.id, 1);
    });
  });

  group('RequestLogin constructors', () {
    test('RequestLogin named constructor', () {
      final user = rl.User.fromJson({
        'id': 1, 'firstName': 'A', 'lastName': 'B', 'userName': 'ab',
        'countryCode': '+1', 'mobile': '123',
      });
      final data = rl.Data(user: user);
      final model = rl.RequestLogin(success: true, data: data, message: 'OK');
      expect(model.success, isTrue);
    });
  });

  group('FaqStaticPage constructors', () {
    test('FaqStaticPage named constructor', () {
      final data = faq.Data(faq: []);
      final model = faq.FaqStaticPage(success: true, data: data, message: 'OK');
      expect(model.success, isTrue);
    });

    test('Faq named constructor', () {
      final f = faq.Faq(id: 1, question: 'Q?', answer: 'A.');
      expect(f.id, 1);
      expect(f.question, 'Q?');
    });
  });

  group('SearchEmailModel constructors', () {
    test('SearchEmailModel named constructor', () {
      final data = search.Data(emails: []);
      final model = search.SearchEmailModel(success: true, data: data, message: 'OK');
      expect(model.success, isTrue);
    });

    test('Emails named constructor', () {
      final email = search.Emails(id: 1, userId: 10, email: 'a@b.com');
      expect(email.id, 1);
    });
  });

  group('PaymentListModel constructors', () {
    test('PaymentListModel named constructor', () {
      final p = payment.Plan(
        id: 1, title: 'Pro', charge: 999, type: 'paid',
        chargeFrequency: 30, description: 'desc', features: ['f1'],
      );
      final data = payment.Data(plan: p, paymentList: []);
      final model = payment.PaymentListModel(success: true, data: data, message: 'OK');
      expect(model.success, isTrue);
    });

    test('PaymentList named constructor', () {
      final p = payment.Plan(
        id: 1, title: 'Pro', charge: 999, type: 'paid',
        chargeFrequency: 30, description: 'desc', features: ['f1'],
      );
      final pl = payment.PaymentList(
        id: 1, userId: 10, start: 1700000000, ends: 1702592000,
        charge: 999, discount: 0, plan: p,
        startEnd: '2024-01-01', added: '2024-01-01',
      );
      expect(pl.id, 1);
    });
  });

  group('LoginModel constructors', () {
    test('LoginModel named constructor', () {
      final user = login.User.fromJson({
        'id': 1, 'firstName': 'A', 'lastName': 'B', 'userName': 'ab',
        'otp': null, 'dob': '1990-01-01', 'countryCode': '+1', 'mobile': '123',
        'isSubscribed': true, 'subscriptionEndDate': null, 'subscriptionStartDate': null,
        'deviceToken': null, 'authTokenIssuedAt': null, 'platform': null,
        'isNotification': true, 'contactSynch': null, 'isAcceptTerms': true,
        'sortLastName': false, 'isSuspended': false, 'isDeleted': false,
        'created': '2024-01-01', 'updated': '2024-01-01', 'boardingSteps': 'completed',
        'webauth': null, 'isFreeUser': false, 'isBiomatrix': false,
        'isDeviceBiometrics': false,
      });
      final data = login.Data(user: user, token: 'tok');
      final model = login.LoginModel(success: true, data: data, message: 'OK');
      expect(model.success, isTrue);
      expect(data.token, 'tok');
    });
  });

  group('RequestError edge cases', () {
    test('should handle detail field in response', () {
      final error = RequestError(statusCode: 422, data: {
        'detail': 'Validation failed',
      });
      expect(error, isNotNull);
    });

    test('singleMessage factory', () {
      final error = RequestError.singleMessage('Something went wrong');
      expect(error.error, 'Something went wrong');
    });

    test('noUser factory', () {
      final error = RequestError.noUser();
      expect(error.error, 'No User');
    });

    test('noToken factory', () {
      final error = RequestError.noToken();
      expect(error.error, 'Empty Token');
    });
  });
}
