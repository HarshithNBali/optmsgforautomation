import 'package:flutter_test/flutter_test.dart';
import 'package:optmsg/model/payment_list_model.dart' as pay;
import 'package:optmsg/model/forgot_user_name_model.dart';
import 'package:optmsg/common/app_manger/app_environment.dart';
import 'package:optmsg/common/responsive/breakpoints.dart';
import 'package:optmsg/services/common_service.dart';
import 'package:optmsg/services/overlay_manager.dart';
import 'package:optmsg/services/session_refresh_mutex.dart';

void main() {
  // ===== PaymentListModel roundtrip =====
  group('PaymentListModel roundtrip', () {
    Map<String, dynamic> makePlanJson() => {
      'id': 1, 'title': 'Pro', 'charge': 999, 'type': 'paid',
      'chargeFrequency': 30, 'description': 'Pro plan',
      'features': ['Feature A', 'Feature B'],
    };

    test('should roundtrip Plan through toJson/fromJson', () {
      final plan = pay.Plan.fromJson(makePlanJson());
      final restored = pay.Plan.fromJson(plan.toJson());

      expect(restored.id, 1);
      expect(restored.title, 'Pro');
      expect(restored.charge, 999);
      expect(restored.features, hasLength(2));
      expect(restored.stripeProductId, isNull);
    });

    test('should roundtrip PaymentList through toJson/fromJson', () {
      final json = {
        'id': 1, 'userId': 42, 'start': 1700000000, 'ends': 1702592000,
        'charge': 999, 'discount': 0,
        'plan': makePlanJson(),
        'startEnd': '2024-01-01 to 2024-02-01', 'added': '2024-01-01',
      };
      final payment = pay.PaymentList.fromJson(json);
      final restored = pay.PaymentList.fromJson(payment.toJson());

      expect(restored.id, 1);
      expect(restored.userId, 42);
      expect(restored.start, 1700000000);
      expect(restored.ends, 1702592000);
      expect(restored.charge, 999);
      expect(restored.discount, 0);
      expect(restored.plan.title, 'Pro');
    });

    test('should roundtrip full PaymentListModel', () {
      final json = {
        'success': true, 'message': '',
        'data': {
          'plan': makePlanJson(),
          'paymentList': [
            {
              'id': 1, 'userId': 1, 'start': 1700000000, 'ends': 1702592000,
              'charge': 999, 'discount': 100,
              'plan': makePlanJson(),
              'startEnd': '', 'added': '',
            },
            {
              'id': 2, 'userId': 1, 'start': 1702592000, 'ends': 1705184000,
              'charge': 999, 'discount': 0,
              'plan': makePlanJson(),
              'startEnd': '', 'added': '',
            },
          ],
        },
      };
      final model = pay.PaymentListModel.fromJson(json);
      final restored = pay.PaymentListModel.fromJson(model.toJson());

      expect(restored.data.paymentList, hasLength(2));
      expect(restored.data.paymentList[0].discount, 100);
      expect(restored.data.paymentList[1].discount, 0);
    });
  });

  // ===== ForgotUserName roundtrip =====
  group('UserName (ForgotUserName) roundtrip', () {
    test('should roundtrip with userName present', () {
      final json = {
        'success': true, 'message': 'Found',
        'data': {
          'id': 1, 'countryCode': '+1', 'mobile': '555',
          'type': 'forgot', 'otp': '123456', 'validTill': 1700000000,
          'updated': '2024-01-01', 'userName': 'founduser',
        },
      };
      final model = UserName.fromJson(json);
      final restored = UserName.fromJson(model.toJson());

      expect(restored.data.userName, 'founduser');
      expect(restored.data.countryCode, '+1');
      expect(restored.data.otp, '123456');
    });
  });

  // ===== AppEnvironment expanded =====
  group('AppEnvironment expanded', () {
    test('currentWebEnv should set type for dev', () async {
      final env = AppEnvironment.instance;
      final result = await env.currentWebEnv('dev');
      expect(result, AppEnvironmentType.dev);
      expect(env.type, AppEnvironmentType.dev);
    });

    test('currentWebEnv should set type for prod', () async {
      final env = AppEnvironment.instance;
      final result = await env.currentWebEnv('prod');
      expect(result, AppEnvironmentType.prod);
    });

    test('currentWebEnv should set type for stage', () async {
      final env = AppEnvironment.instance;
      final result = await env.currentWebEnv('stage');
      expect(result, AppEnvironmentType.stage);
    });
  });

  // ===== AppBreakpoints expanded =====
  group('AppBreakpoints expanded', () {
    test('mobile boundary at exactly 600', () {
      expect(AppBreakpoints.isMobile(599.9), true);
      expect(AppBreakpoints.isMobile(600.0), false);
    });

    test('tablet boundaries', () {
      expect(AppBreakpoints.isTablet(600.0), true);
      expect(AppBreakpoints.isTablet(1023.9), true);
      expect(AppBreakpoints.isTablet(1024.0), false);
    });

    test('desktop boundary at exactly 1024', () {
      expect(AppBreakpoints.isDesktop(1023.9), false);
      expect(AppBreakpoints.isDesktop(1024.0), true);
    });

    test('largeDesktop boundary at exactly 1440', () {
      expect(AppBreakpoints.isLargeDesktop(1439.9), false);
      expect(AppBreakpoints.isLargeDesktop(1440.0), true);
    });

    test('getDeviceType boundaries', () {
      expect(AppBreakpoints.getDeviceType(0), DeviceType.mobile);
      expect(AppBreakpoints.getDeviceType(599), DeviceType.mobile);
      expect(AppBreakpoints.getDeviceType(600), DeviceType.tablet);
      expect(AppBreakpoints.getDeviceType(1023), DeviceType.tablet);
      expect(AppBreakpoints.getDeviceType(1024), DeviceType.desktop);
      expect(AppBreakpoints.getDeviceType(2560), DeviceType.desktop);
    });

    test('canShowReadingPane', () {
      expect(AppBreakpoints.canShowReadingPane(599), false);
      expect(AppBreakpoints.canShowReadingPane(600), true);
      expect(AppBreakpoints.canShowReadingPane(1024), true);
    });

    test('flex constants', () {
      expect(AppBreakpoints.emailListFlex, 1);
      expect(AppBreakpoints.readingPaneFlex, 2);
    });

    test('isPhysicalTablet before init should return false', () {
      // On non-iOS/Android test platform, should return false
      expect(AppBreakpoints.isPhysicalTablet, false);
    });
  });

  // ===== CommonService expanded =====
  group('CommonService expanded', () {
    final service = CommonService();

    test('formatFileSize edge cases', () {
      expect(service.formatFileSize(0), '0.0 KB');
      expect(service.formatFileSize(1), '0.0 KB');
      expect(service.formatFileSize(1023), '1.0 KB');
      expect(service.formatFileSize(1024), '1.0 KB');
      expect(service.formatFileSize(1024 * 1024), '1.0 MB');
      expect(service.formatFileSize(1024 * 1024 * 5), '5.0 MB');
    });

    test('composeFormatFileSize edge cases', () {
      expect(service.composeFormatFileSize(0), '0.00 KB');
      expect(service.composeFormatFileSize(1024 * 1024), '1.00 MB');
      expect(service.composeFormatFileSize(1024 * 512), '512.00 KB');
    });

    test('isValidEmail edge cases', () {
      expect(CommonService.isValidEmail('a@b.co'), true);
      expect(CommonService.isValidEmail('user+tag@domain.com'), true);
      expect(CommonService.isValidEmail('user@sub.domain.com'), true);
      expect(CommonService.isValidEmail('@domain.com'), false);
      expect(CommonService.isValidEmail('user@'), false);
      expect(CommonService.isValidEmail(''), false);
    });

    test('getFileName edge cases', () {
      expect(service.getFileName('file.txt'), 'file.txt');
      expect(service.getFileName('/a/b/c/file.pdf'), 'file.pdf');
      expect(service.getFileName(''), '');
      expect(service.getFileName('/'), '');
    });

    test('truncateWithEllipsis edge cases', () {
      expect(service.truncateWithEllipsis(0, 'hello'), '...  ');
      expect(service.truncateWithEllipsis(100, 'short'), 'short  ');
    });

    test('capitalize edge cases', () {
      expect(service.capitalize('a'), 'A');
      expect(service.capitalize('ABC'), 'ABC');
      expect(service.capitalize('123'), '123');
    });

    test('undoStatus variations', () {
      expect(service.undoStatus('Archive'), 'Moving to Archive');
      expect(service.undoStatus('Inbox'), 'Moving to Inbox');
      expect(service.undoStatus('Trash', true), 'Permanently Delete');
      expect(service.undoStatus('Trash', false), 'Moving to Trash');
      expect(service.undoStatus('Trash', null), 'Moving to Trash');
    });

    test('formatPhoneNumber edge cases', () {
      expect(service.formatPhoneNumber('+1', ''), '(+1) ');
      expect(service.formatPhoneNumber('+44', '123'), '(+44) 123');
      expect(service.formatPhoneNumber('+1', '123456'), '(+1) 123-456-');
      expect(service.formatPhoneNumber('+1', '1234567890'), '(+1) 123-456-7890');
    });

    test('isOffline should default to false', () {
      expect(CommonService.isOffline, false);
    });
  });

  // ===== SessionRefreshMutex expanded =====
  group('SessionRefreshMutex expanded', () {
    setUp(() {
      SessionRefreshMutex.isLoggedOut = false;
      SessionRefreshMutex.passkeyFlowInProgress = false;
      SessionRefreshMutex.isRefreshing = false;
    });

    test('all flags should be independently settable', () {
      SessionRefreshMutex.isLoggedOut = true;
      SessionRefreshMutex.passkeyFlowInProgress = true;
      SessionRefreshMutex.isRefreshing = true;

      expect(SessionRefreshMutex.isLoggedOut, true);
      expect(SessionRefreshMutex.passkeyFlowInProgress, true);
      expect(SessionRefreshMutex.isRefreshing, true);

      SessionRefreshMutex.isLoggedOut = false;
      expect(SessionRefreshMutex.isLoggedOut, false);
      expect(SessionRefreshMutex.passkeyFlowInProgress, true);
    });
  });

  // ===== OverlayManager / ToastManager =====
  group('ToastManager', () {
    test('overlayStateOrNull should not crash', () {
      // In test env without an overlay, should return null
      expect(ToastManager.overlayStateOrNull, isNull);
    });
  });
}
