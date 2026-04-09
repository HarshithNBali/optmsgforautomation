// Implements: TC-DISC-CACHE-001..020
// Source: lib/common/app_manger/app_cache.dart
// Coverage target: 95%+ (critical — used by auth, routing, email detail)
import 'package:flutter_test/flutter_test.dart';
import 'package:optmsg/common/app_manger/app_cache.dart';

void main() {
  late AppCache cache;

  setUp(() {
    cache = AppCache();
    cache.clear(); // Reset singleton state between tests
  });

  group('AppCache', () {
    // -----------------------------------------------------------------------
    // Singleton
    // -----------------------------------------------------------------------
    test('should return same instance', () {
      // TC-DISC-CACHE-001
      final a = AppCache();
      final b = AppCache();
      expect(identical(a, b), isTrue);
    });

    // -----------------------------------------------------------------------
    // Getters/Setters — simple in-memory fields
    // -----------------------------------------------------------------------
    group('simple getters/setters', () {
      test('tabName defaults to empty string', () {
        expect(cache.tabName, '');
      });

      test('setTabName updates tabName', () {
        cache.setTabName('inbox');
        expect(cache.tabName, 'inbox');
      });

      test('lastNavigation defaults to empty string', () {
        expect(cache.lastNavigation, '');
      });

      test('setLastNavigationName updates lastNavigation', () {
        cache.setLastNavigationName('/inbox');
        expect(cache.lastNavigation, '/inbox');
      });

      test('currentNavigation defaults to empty string', () {
        expect(cache.currentNavigation, '');
      });

      test('setCurrentNavigationName updates currentNavigation', () {
        cache.setCurrentNavigationName('/settings');
        expect(cache.currentNavigation, '/settings');
      });

      test('isAllMailSaved defaults to false', () {
        expect(cache.isAllMailSaved, isFalse);
      });

      test('setIsAllMailSaved updates isAllMailSaved', () {
        cache.setIsAllMailSaved(true);
        expect(cache.isAllMailSaved, isTrue);
      });

      test('isCheckout defaults to null', () {
        expect(cache.isCheckout, isNull);
      });

      test('setIsCheckout updates isCheckout', () {
        cache.setIsCheckout('true');
        expect(cache.isCheckout, 'true');
      });

      test('subscriptionPage defaults to empty string', () {
        expect(cache.subscriptionPage, '');
      });

      test('setSubscriptionPage updates subscriptionPage', () {
        cache.setSubscriptionPage('pro');
        expect(cache.subscriptionPage, 'pro');
      });

      test('signupInProgress defaults to empty string', () {
        expect(cache.signupInProgress, '');
      });

      test('setSignupInProgress updates signupInProgress', () {
        cache.setSignupInProgress('true');
        expect(cache.signupInProgress, 'true');
      });

      test('hasPasskeyEnrolled defaults to false', () {
        expect(cache.hasPasskeyEnrolled, isFalse);
      });

      test('setHasPasskeyEnrolled updates hasPasskeyEnrolled', () {
        cache.setHasPasskeyEnrolled(true);
        expect(cache.hasPasskeyEnrolled, isTrue);
      });

      test('hasCompletedOnboarding defaults to false', () {
        expect(cache.hasCompletedOnboarding, isFalse);
      });

      test('setHasCompletedOnboarding updates hasCompletedOnboarding', () {
        cache.setHasCompletedOnboarding(true);
        expect(cache.hasCompletedOnboarding, isTrue);
      });

      test('isPasskeyPageOpen defaults to false', () {
        expect(cache.isPasskeyPageOpen, isFalse);
      });

      test('setIsPasskeyPageOpen updates isPasskeyPageOpen', () {
        cache.setIsPasskeyPageOpen(true);
        expect(cache.isPasskeyPageOpen, isTrue);
      });

      test('mailto defaults to null', () {
        expect(cache.mailto, isNull);
      });

      test('setMailto updates mailto', () {
        cache.setMailto('test@example.com');
        expect(cache.mailto, 'test@example.com');
      });

      test('themeModePref defaults to system', () {
        expect(cache.themeModePref, 'system');
      });

      test('setThemeModePref updates themeModePref', () {
        cache.setThemeModePref('dark');
        expect(cache.themeModePref, 'dark');
      });
    });

    // -----------------------------------------------------------------------
    // Query Params (transient, in-memory only)
    // -----------------------------------------------------------------------
    group('queryParms', () {
      test('getQueryParms returns null by default', () async {
        // TC-DISC-CACHE-010
        final result = await cache.getQueryParms();
        expect(result, isNull);
      });

      test('setQueryParms stores non-empty map', () async {
        await cache.setQueryParms({'key': 'value'});
        final result = await cache.getQueryParms();
        expect(result, {'key': 'value'});
      });

      test('setQueryParms stores null for empty map', () async {
        // TC-DISC-CACHE-011
        await cache.setQueryParms({'key': 'value'});
        await cache.setQueryParms({});
        final result = await cache.getQueryParms();
        expect(result, isNull);
      });

      test('setQueryParms creates a copy of the map', () async {
        final original = {'key': 'value'};
        await cache.setQueryParms(original);
        original['key'] = 'modified';
        final result = await cache.getQueryParms();
        expect(result!['key'], 'value'); // not modified
      });
    });

    // -----------------------------------------------------------------------
    // Email Detail Cache (LRU)
    // -----------------------------------------------------------------------
    group('email detail cache (LRU)', () {
      test('getEmailDetail returns null for uncached email', () {
        // TC-DISC-CACHE-012
        expect(cache.getEmailDetail(999), isNull);
      });

      test('putEmailDetail stores and retrieves data', () {
        // TC-DISC-CACHE-013
        final data = {'id': 1, 'subject': 'Test'};
        cache.putEmailDetail(1, data);
        expect(cache.getEmailDetail(1), data);
      });

      test('getEmailDetail moves entry to MRU position', () {
        // TC-DISC-CACHE-014
        cache.putEmailDetail(1, {'id': 1});
        cache.putEmailDetail(2, {'id': 2});
        cache.putEmailDetail(3, {'id': 3});

        // Access 1, making it MRU
        cache.getEmailDetail(1);

        // Fill cache to capacity (10 items total)
        for (int i = 4; i <= 11; i++) {
          cache.putEmailDetail(i, {'id': i});
        }

        // 2 should be evicted (was LRU after 1 was accessed)
        expect(cache.getEmailDetail(2), isNull);
        // 1 should still be cached (was MRU)
        expect(cache.getEmailDetail(1), isNotNull);
      });

      test('putEmailDetail evicts LRU when at capacity', () {
        // TC-DISC-CACHE-015
        // Fill to capacity (10 items)
        for (int i = 1; i <= 10; i++) {
          cache.putEmailDetail(i, {'id': i});
        }

        // Adding 11th should evict the first (LRU)
        cache.putEmailDetail(11, {'id': 11});
        expect(cache.getEmailDetail(1), isNull);
        expect(cache.getEmailDetail(11), isNotNull);
      });

      test('putEmailDetail refreshes position for existing key', () {
        // TC-DISC-CACHE-016
        cache.putEmailDetail(1, {'id': 1, 'v': 'old'});
        cache.putEmailDetail(2, {'id': 2});
        cache.putEmailDetail(1, {'id': 1, 'v': 'new'}); // refresh position

        // Fill to evict
        for (int i = 3; i <= 11; i++) {
          cache.putEmailDetail(i, {'id': i});
        }

        // 2 was LRU (1 was refreshed), so 2 should be evicted
        expect(cache.getEmailDetail(2), isNull);
        // 1 should still be there with new data
        final result = cache.getEmailDetail(1);
        expect(result, isNotNull);
        expect(result!['v'], 'new');
      });

      test('invalidateEmailDetail removes specific entry', () {
        // TC-DISC-CACHE-017
        cache.putEmailDetail(1, {'id': 1});
        cache.putEmailDetail(2, {'id': 2});

        cache.invalidateEmailDetail(1);

        expect(cache.getEmailDetail(1), isNull);
        expect(cache.getEmailDetail(2), isNotNull);
      });

      test('invalidateEmailDetail is no-op for missing key', () {
        cache.invalidateEmailDetail(999); // should not throw
      });
    });

    // -----------------------------------------------------------------------
    // clear()
    // -----------------------------------------------------------------------
    group('clear', () {
      test('should reset all in-memory state', () {
        // TC-DISC-CACHE-018
        cache.setTabName('inbox');
        cache.setLastNavigationName('/inbox');
        cache.setCurrentNavigationName('/settings');
        cache.setIsAllMailSaved(true);
        cache.setIsCheckout('true');
        cache.setSubscriptionPage('pro');
        cache.setSignupInProgress('true');
        cache.setHasPasskeyEnrolled(true);
        cache.setHasCompletedOnboarding(true);
        cache.setIsPasskeyPageOpen(true);
        cache.setMailto('a@b.com');
        cache.putEmailDetail(1, {'id': 1});

        cache.clear();

        expect(cache.tabName, '');
        expect(cache.lastNavigation, '');
        expect(cache.currentNavigation, '');
        expect(cache.isAllMailSaved, isFalse);
        expect(cache.isCheckout, isNull);
        expect(cache.subscriptionPage, '');
        expect(cache.signupInProgress, '');
        expect(cache.hasPasskeyEnrolled, isFalse);
        expect(cache.hasCompletedOnboarding, isFalse);
        expect(cache.isPasskeyPageOpen, isFalse);
        expect(cache.mailto, isNull);
        expect(cache.getEmailDetail(1), isNull);
      });
    });
  });
}
