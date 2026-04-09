import 'package:flutter_test/flutter_test.dart';
import 'package:optmsg/model/subscription_status.dart';

void main() {
  group('SubscriptionStatus.fromUserData', () {
    test('returns none for null userData', () {
      expect(SubscriptionStatus.fromUserData(null), SubscriptionStatus.none);
    });

    test('returns none for empty userData', () {
      expect(SubscriptionStatus.fromUserData({}), SubscriptionStatus.none);
    });

    test('returns active for paid subscriber', () {
      final status = SubscriptionStatus.fromUserData({
        'isSubscribed': true,
        'isFreeUser': false,
        'subscriptionEndDate': DateTime(2030).millisecondsSinceEpoch ~/ 1000,
      });
      expect(status, SubscriptionStatus.active);
    });

    test('returns active when isFreeUser is null and isSubscribed is true', () {
      final status = SubscriptionStatus.fromUserData({
        'isSubscribed': true,
        'isFreeUser': null,
      });
      expect(status, SubscriptionStatus.active);
    });

    test('returns freeActive for free user with future end date (seconds)', () {
      final futureSeconds = DateTime(2030).millisecondsSinceEpoch ~/ 1000;
      final status = SubscriptionStatus.fromUserData({
        'isSubscribed': false,
        'isFreeUser': true,
        'subscriptionEndDate': futureSeconds,
      });
      expect(status, SubscriptionStatus.freeActive);
    });

    test('returns freeActive for free user with future end date (milliseconds)',
        () {
      final futureMs = DateTime(2030).millisecondsSinceEpoch;
      final status = SubscriptionStatus.fromUserData({
        'isSubscribed': false,
        'isFreeUser': true,
        'subscriptionEndDate': futureMs,
      });
      expect(status, SubscriptionStatus.freeActive);
    });

    test('returns freeExpired for free user with past end date', () {
      final pastSeconds = DateTime(2020).millisecondsSinceEpoch ~/ 1000;
      final status = SubscriptionStatus.fromUserData({
        'isSubscribed': false,
        'isFreeUser': true,
        'subscriptionEndDate': pastSeconds,
      });
      expect(status, SubscriptionStatus.freeExpired);
    });

    test('returns freeExpired for free user with no end date', () {
      final status = SubscriptionStatus.fromUserData({
        'isSubscribed': false,
        'isFreeUser': true,
      });
      expect(status, SubscriptionStatus.freeExpired);
    });

    test('returns lapsed for previously paid user with past end date', () {
      final pastSeconds = DateTime(2020).millisecondsSinceEpoch ~/ 1000;
      final status = SubscriptionStatus.fromUserData({
        'isSubscribed': false,
        'isFreeUser': false,
        'subscriptionEndDate': pastSeconds,
      });
      expect(status, SubscriptionStatus.lapsed);
    });

    test('returns lapsed when isFreeUser is null with past end date', () {
      final pastSeconds = DateTime(2020).millisecondsSinceEpoch ~/ 1000;
      final status = SubscriptionStatus.fromUserData({
        'isSubscribed': false,
        'isFreeUser': null,
        'subscriptionEndDate': pastSeconds,
      });
      expect(status, SubscriptionStatus.lapsed);
    });

    test('returns none for non-subscribed user with no end date', () {
      final status = SubscriptionStatus.fromUserData({
        'isSubscribed': false,
        'isFreeUser': false,
      });
      expect(status, SubscriptionStatus.none);
    });
  });

  group('SubscriptionStatus helpers', () {
    test('hasAccess is true only for active', () {
      expect(SubscriptionStatus.active.hasAccess, true);
      expect(SubscriptionStatus.freeActive.hasAccess, false);
      expect(SubscriptionStatus.freeExpired.hasAccess, false);
      expect(SubscriptionStatus.lapsed.hasAccess, false);
      expect(SubscriptionStatus.none.hasAccess, false);
    });

    test('isLapsed is true only for lapsed', () {
      expect(SubscriptionStatus.lapsed.isLapsed, true);
      expect(SubscriptionStatus.active.isLapsed, false);
      expect(SubscriptionStatus.none.isLapsed, false);
    });

    test('isFree is true for freeActive and freeExpired', () {
      expect(SubscriptionStatus.freeActive.isFree, true);
      expect(SubscriptionStatus.freeExpired.isFree, true);
      expect(SubscriptionStatus.active.isFree, false);
      expect(SubscriptionStatus.lapsed.isFree, false);
    });

    test('label returns correct display strings', () {
      expect(SubscriptionStatus.active.label, 'Active');
      expect(SubscriptionStatus.freeActive.label, 'Active');
      expect(SubscriptionStatus.freeExpired.label, 'Expired');
      expect(SubscriptionStatus.lapsed.label, 'Expired');
      expect(SubscriptionStatus.none.label, '');
    });
  });
}
