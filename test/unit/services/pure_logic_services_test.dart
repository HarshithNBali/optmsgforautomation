import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:optmsg/common/responsive/breakpoints.dart';
import 'package:optmsg/repositories/end_point/end_point.dart';
import 'package:optmsg/services/count_notifier.dart';
import 'package:optmsg/common/app_manger/app_cache.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  // ===== AppBreakpoints (static pure functions) =====
  group('AppBreakpoints', () {
    group('width-based classification', () {
      test('isMobile should return true for width < 600', () {
        expect(AppBreakpoints.isMobile(599), true);
        expect(AppBreakpoints.isMobile(400), true);
        expect(AppBreakpoints.isMobile(0), true);
      });

      test('isMobile should return false for width >= 600', () {
        expect(AppBreakpoints.isMobile(600), false);
        expect(AppBreakpoints.isMobile(1024), false);
      });

      test('isTablet should return true for width 600-1023', () {
        expect(AppBreakpoints.isTablet(600), true);
        expect(AppBreakpoints.isTablet(800), true);
        expect(AppBreakpoints.isTablet(1023), true);
      });

      test('isTablet should return false for width < 600 or >= 1024', () {
        expect(AppBreakpoints.isTablet(599), false);
        expect(AppBreakpoints.isTablet(1024), false);
      });

      test('isDesktop should return true for width >= 1024', () {
        expect(AppBreakpoints.isDesktop(1024), true);
        expect(AppBreakpoints.isDesktop(1440), true);
        expect(AppBreakpoints.isDesktop(2560), true);
      });

      test('isDesktop should return false for width < 1024', () {
        expect(AppBreakpoints.isDesktop(1023), false);
        expect(AppBreakpoints.isDesktop(600), false);
      });

      test('isLargeDesktop should return true for width >= 1440', () {
        expect(AppBreakpoints.isLargeDesktop(1440), true);
        expect(AppBreakpoints.isLargeDesktop(2560), true);
      });

      test('isLargeDesktop should return false for width < 1440', () {
        expect(AppBreakpoints.isLargeDesktop(1439), false);
        expect(AppBreakpoints.isLargeDesktop(1024), false);
      });

      test('canShowReadingPane should return true for width >= 600', () {
        expect(AppBreakpoints.canShowReadingPane(600), true);
        expect(AppBreakpoints.canShowReadingPane(599), false);
      });
    });

    group('getDeviceType', () {
      test('should return mobile for width < 600', () {
        expect(AppBreakpoints.getDeviceType(400), DeviceType.mobile);
      });

      test('should return tablet for width 600-1023', () {
        expect(AppBreakpoints.getDeviceType(800), DeviceType.tablet);
      });

      test('should return desktop for width >= 1024', () {
        expect(AppBreakpoints.getDeviceType(1200), DeviceType.desktop);
      });
    });

    group('constants', () {
      test('breakpoint constants should have expected values', () {
        expect(AppBreakpoints.mobile, 600.0);
        expect(AppBreakpoints.tablet, 600.0);
        expect(AppBreakpoints.desktop, 1024.0);
        expect(AppBreakpoints.largeDesktop, 1440.0);
        expect(AppBreakpoints.readingPane, 600.0);
        expect(AppBreakpoints.minHeightForReadingPane, 500.0);
      });

      test('UI layout constants should be positive', () {
        expect(AppBreakpoints.authFormWidthNarrow, greaterThan(0));
        expect(AppBreakpoints.authFormWidthMedium, greaterThan(0));
        expect(AppBreakpoints.authFormWidthWide, greaterThan(0));
        expect(AppBreakpoints.formWidthDesktop, greaterThan(0));
        expect(AppBreakpoints.splitPaneMinWidth, greaterThan(0));
        expect(AppBreakpoints.splitPaneMaxWidth, greaterThan(0));
        expect(AppBreakpoints.popupMaxWidth, greaterThan(0));
      });
    });

    group('DeviceType enum', () {
      test('should have all expected values', () {
        expect(DeviceType.values, hasLength(3));
        expect(DeviceType.values, contains(DeviceType.mobile));
        expect(DeviceType.values, contains(DeviceType.tablet));
        expect(DeviceType.values, contains(DeviceType.desktop));
      });
    });
  });

  // ===== EndPoints =====
  group('EndPoints', () {
    test('api should return /api', () {
      expect(EndPoints.api, '/api');
    });

    test('base should return a non-empty host', () {
      expect(EndPoints.base, isNotEmpty);
    });

    test('baseUrl should be a valid HTTPS URL', () {
      expect(EndPoints.baseUrl, startsWith('https://'));
    });

    test('endpoint paths should not start with /', () {
      // Endpoints should not have leading slash to avoid double slash
      expect(EndPoints.userVerify.path, isNot(startsWith('/')));
      expect(EndPoints.login.path, isNot(startsWith('/')));
      expect(EndPoints.getInboxEmails.path, isNot(startsWith('/')));
      expect(EndPoints.logout.path, isNot(startsWith('/')));
    });

    test('auth endpoints should start with auth/', () {
      expect(EndPoints.userVerify.path, startsWith('auth/'));
      expect(EndPoints.login.path, startsWith('auth/'));
      expect(EndPoints.resenOTP.path, startsWith('auth/'));
      expect(EndPoints.verifyOTP.path, startsWith('auth/'));
    });

    test('email endpoints should start with email/', () {
      expect(EndPoints.getInboxEmails.path, startsWith('email/'));
      expect(EndPoints.getDraftEmail.path, startsWith('email/'));
      expect(EndPoints.getTagsList.path, startsWith('email/'));
      expect(EndPoints.getSentMails.path, startsWith('email/'));
    });

    test('user endpoints should start with user/', () {
      expect(EndPoints.logout.path, startsWith('user/'));
      expect(EndPoints.getProfile.path, startsWith('user/'));
      expect(EndPoints.editProfile.path, startsWith('user/'));
      expect(EndPoints.paymentList.path, startsWith('user/'));
    });

    test('contact endpoints should start with contact/', () {
      expect(EndPoints.contactUpload.path, startsWith('contact/'));
      expect(EndPoints.getContactList.path, startsWith('contact/'));
      expect(EndPoints.addContact.path, startsWith('contact/'));
    });

    test('status code constants should be correct', () {
      expect(EndPoints.success, 'success');
      expect(EndPoints.code, 200);
      expect(EndPoints.insert, 201);
    });

    test('EndPoint has base and path', () {
      final ep = EndPoints.login;
      expect(ep.base, isNotEmpty);
      expect(ep.path, isNotEmpty);
    });
  });

  // ===== CountNotifier =====
  group('CountNotifier', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state should have zero counts', () {
      final state = container.read(countProvider);
      expect(state.inboxCount, 0);
      expect(state.draftCount, 0);
      expect(state.archiveCount, 0);
      expect(state.trashCount, 0);
      expect(state.isUpdateDialogVisible, false);
      expect(state.newNotification, 'no');
    });

    test('CountState copyWith should work', () {
      const state = CountState();
      final modified = state.copyWith(inboxCount: 5, draftCount: 3);
      expect(modified.inboxCount, 5);
      expect(modified.draftCount, 3);
      expect(modified.archiveCount, 0);
    });

    test('updateUpdateDialogState should set flag', () {
      container.read(countProvider.notifier).updateUpdateDialogState();
      expect(container.read(countProvider).isUpdateDialogVisible, true);
    });

    test('updatePopUpDismissState should set flag', () {
      container.read(countProvider.notifier).updatePopUpDismissState();
      expect(container.read(countProvider).isUpdatePopUpDismiss, true);
    });
  });

  // ===== AppCache =====
  group('AppCache', () {
    late AppCache cache;

    setUp(() {
      cache = AppCache();
      cache.clear(); // Reset between tests
    });

    test('should be a singleton', () {
      expect(identical(AppCache(), AppCache()), true);
    });

    test('clear should reset all in-memory values', () {
      cache.setIsCheckout('true');
      cache.setSubscriptionPage('pro');
      cache.setSignupInProgress('true');
      cache.setHasPasskeyEnrolled(true);
      cache.setHasCompletedOnboarding(true);
      cache.setIsPasskeyPageOpen(true);
      cache.setMailto('test@example.com');
      cache.setTabName('inbox');
      cache.setIsAllMailSaved(true);
      cache.putEmailDetail(1, {'id': 1});

      cache.clear();

      expect(cache.isCheckout, isNull);
      expect(cache.subscriptionPage, '');
      expect(cache.signupInProgress, '');
      expect(cache.hasPasskeyEnrolled, false);
      expect(cache.hasCompletedOnboarding, false);
      expect(cache.isPasskeyPageOpen, false);
      expect(cache.mailto, isNull);
      expect(cache.tabName, '');
      expect(cache.isAllMailSaved, false);
      expect(cache.getEmailDetail(1), isNull);
    });

    group('email detail LRU cache', () {
      test('putEmailDetail and getEmailDetail should work', () {
        cache.putEmailDetail(1, {'subject': 'Hello'});
        final result = cache.getEmailDetail(1);
        expect(result, isNotNull);
        expect(result!['subject'], 'Hello');
      });

      test('getEmailDetail should return null for missing key', () {
        expect(cache.getEmailDetail(999), isNull);
      });

      test('invalidateEmailDetail should remove entry', () {
        cache.putEmailDetail(1, {'subject': 'Hello'});
        cache.invalidateEmailDetail(1);
        expect(cache.getEmailDetail(1), isNull);
      });

      test('should evict oldest entry when cache is full', () {
        // Fill cache to max (10 entries)
        for (int i = 1; i <= 10; i++) {
          cache.putEmailDetail(i, {'id': i});
        }

        // Add one more — should evict id=1
        cache.putEmailDetail(11, {'id': 11});

        expect(cache.getEmailDetail(1), isNull);
        expect(cache.getEmailDetail(11), isNotNull);
        expect(cache.getEmailDetail(2), isNotNull);
      });

      test('getEmailDetail should promote to MRU', () {
        for (int i = 1; i <= 10; i++) {
          cache.putEmailDetail(i, {'id': i});
        }

        // Access id=1 to promote it
        cache.getEmailDetail(1);

        // Add id=11 — should evict id=2 (now the LRU), not id=1
        cache.putEmailDetail(11, {'id': 11});

        expect(cache.getEmailDetail(1), isNotNull);
        expect(cache.getEmailDetail(2), isNull);
      });
    });

    group('setters and getters', () {
      test('setTabName / tabName', () {
        cache.setTabName('drafts');
        expect(cache.tabName, 'drafts');
      });

      test('setLastNavigationName / lastNavigation', () {
        cache.setLastNavigationName('inbox');
        expect(cache.lastNavigation, 'inbox');
      });

      test('setCurrentNavigationName / currentNavigation', () {
        cache.setCurrentNavigationName('settings');
        expect(cache.currentNavigation, 'settings');
      });

      test('setIsAllMailSaved / isAllMailSaved', () {
        cache.setIsAllMailSaved(true);
        expect(cache.isAllMailSaved, true);
      });

      test('setQueryParms / getQueryParms', () async {
        await cache.setQueryParms({'key': 'value'});
        final result = await cache.getQueryParms();
        expect(result, isNotNull);
        expect(result!['key'], 'value');
      });

      test('setQueryParms with empty map should set null', () async {
        await cache.setQueryParms({'key': 'value'});
        await cache.setQueryParms({});
        final result = await cache.getQueryParms();
        expect(result, isNull);
      });
    });
  });
}
