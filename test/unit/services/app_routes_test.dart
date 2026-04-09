// Implements: TC-DISC-ROUTES-001..012
// Source: lib/router/app_routes.dart
// Coverage target: 95%+ (critical — routing layer)
import 'package:flutter_test/flutter_test.dart';
import 'package:optmsg/router/app_routes.dart';

void main() {
  group('AppRoutes', () {
    // -----------------------------------------------------------------------
    // Static route constants
    // -----------------------------------------------------------------------
    group('static route constants', () {
      test('should have correct auth routes', () {
        // TC-DISC-ROUTES-001
        expect(AppRoutes.login, '/login');
        expect(AppRoutes.signup, '/signup');
        expect(AppRoutes.enterOtp, '/enter-otp');
        expect(AppRoutes.enterOtpProfile, '/enter-otp-profile');
        expect(AppRoutes.setupProfile, '/setup-profile');
        expect(AppRoutes.forgotUsername, '/forgot-username');
        expect(AppRoutes.usernameSuccess, '/username-success');
        expect(AppRoutes.addPassKey, '/add-passkey');
        expect(AppRoutes.successOtp, '/success-otp');
        expect(AppRoutes.webOtpToken, '/web-otp');
      });

      test('should have correct main routes', () {
        // TC-DISC-ROUTES-002
        expect(AppRoutes.home, '/');
        expect(AppRoutes.inbox, '/inbox');
        expect(AppRoutes.archive, '/archive');
        expect(AppRoutes.sent, '/sent');
        expect(AppRoutes.drafts, '/drafts');
        expect(AppRoutes.trash, '/trash');
        expect(AppRoutes.spam, '/spam');
      });

      test('should have correct email routes', () {
        expect(AppRoutes.compose, '/compose');
        expect(AppRoutes.inboxEmail, '/inbox/email');
        expect(AppRoutes.archiveEmail, '/archive/email');
        expect(AppRoutes.sentEmail, '/sent/email');
        expect(AppRoutes.draftsEmail, '/drafts/email');
        expect(AppRoutes.trashEmail, '/trash/email');
        expect(AppRoutes.spamEmail, '/spam/email');
      });

      test('should have correct contact routes', () {
        expect(AppRoutes.contacts, '/contacts');
        expect(AppRoutes.viewContactriverpod, '/contacts/view-contact');
        expect(AppRoutes.editContactriverpod, '/contacts/edit-contact');
        expect(AppRoutes.addContactriverpod, '/contacts/add-contact');
      });

      test('should have correct settings routes', () {
        expect(AppRoutes.settings, '/settings');
        expect(AppRoutes.profile, '/settings/profile');
        expect(AppRoutes.account, '/settings/account');
      });

      test('should have correct subscription routes', () {
        expect(AppRoutes.plans, '/plans');
        expect(AppRoutes.checkout, '/checkout');
        expect(AppRoutes.paymentSuccess, '/payment-success');
        expect(AppRoutes.processingPayment, '/processing-payment');
      });
    });

    // -----------------------------------------------------------------------
    // Path builder methods
    // -----------------------------------------------------------------------
    group('viewEmailPath', () {
      test('should default to inbox folder', () {
        // TC-DISC-ROUTES-003
        expect(AppRoutes.viewEmailPath('123'), '/inbox/email?id=123');
      });

      test('should use inbox for Inbox type', () {
        expect(AppRoutes.viewEmailPath('1', 'Inbox'), '/inbox/email?id=1');
      });

      test('should use archive for Archive type', () {
        // TC-DISC-ROUTES-004
        expect(
            AppRoutes.viewEmailPath('1', 'Archive'), '/archive/email?id=1');
      });

      test('should use sent for Sent type', () {
        expect(AppRoutes.viewEmailPath('1', 'Sent'), '/sent/email?id=1');
      });

      test('should use drafts for Drafts type', () {
        expect(
            AppRoutes.viewEmailPath('1', 'Drafts'), '/drafts/email?id=1');
      });

      test('should use drafts for Draft type (singular)', () {
        expect(
            AppRoutes.viewEmailPath('1', 'Draft'), '/drafts/email?id=1');
      });

      test('should use trash for Trash type', () {
        expect(AppRoutes.viewEmailPath('1', 'Trash'), '/trash/email?id=1');
      });

      test('should use spam for Spam type', () {
        expect(AppRoutes.viewEmailPath('1', 'Spam'), '/spam/email?id=1');
      });

      test('should default to inbox for unknown type', () {
        // TC-DISC-ROUTES-005
        expect(
            AppRoutes.viewEmailPath('1', 'Unknown'), '/inbox/email?id=1');
      });

      test('should be case insensitive', () {
        expect(
            AppRoutes.viewEmailPath('1', 'ARCHIVE'), '/archive/email?id=1');
        expect(AppRoutes.viewEmailPath('1', 'sent'), '/sent/email?id=1');
      });
    });

    group('replyPath', () {
      test('should build reply path with id', () {
        // TC-DISC-ROUTES-006
        expect(AppRoutes.replyPath(42), '/reply/42');
      });
    });

    group('forwardPath', () {
      test('should build forward path with id', () {
        // TC-DISC-ROUTES-007
        expect(AppRoutes.forwardPath(7), '/forward/7');
      });
    });

    group('composeWithTo', () {
      test('should build compose path with email', () {
        // TC-DISC-ROUTES-008
        expect(AppRoutes.composeWithTo('test@example.com'),
            '/compose?to=test@example.com');
      });
    });

    group('tagEmailsPath', () {
      test('should build tag emails path with id', () {
        // TC-DISC-ROUTES-009
        expect(AppRoutes.tagEmailsPath(5), '/tags?id=5');
      });
    });

    group('viewContactriverpodPath', () {
      test('should build view contact path with id', () {
        // TC-DISC-ROUTES-010
        expect(AppRoutes.viewContactriverpodPath(10),
            '/contacts/view-contact?id=10');
      });
    });

    group('editContactriverpodPath', () {
      test('should build edit contact path with id', () {
        // TC-DISC-ROUTES-011
        expect(AppRoutes.editContactriverpodPath(3),
            '/contacts/edit-contact?id=3');
      });
    });

    group('staticPagePath', () {
      test('should build static page path with slug and module', () {
        // TC-DISC-ROUTES-012
        expect(AppRoutes.staticPagePath('privacy-policy', 'help'),
            '/help/privacy-policy');
        expect(AppRoutes.staticPagePath('terms', 'signup'), '/signup/terms');
      });
    });
  });
}
