// Implements: TC-DISC-SUBSTATUS-001..015
// Source: lib/model/subscription_status.dart
// Coverage target: 100% (pure logic)
import 'package:flutter_test/flutter_test.dart';
import 'package:optmsg/model/subscription_status.dart';

void main() {
  group('SubscriptionStatus', () {
    group('fromUserData', () {
      test('should return none for null userData', () {
        // TC-DISC-SUBSTATUS-001
        expect(SubscriptionStatus.fromUserData(null), SubscriptionStatus.none);
      });

      test('should return active for subscribed non-free user', () {
        // TC-DISC-SUBSTATUS-002
        expect(
          SubscriptionStatus.fromUserData({
            'isSubscribed': true,
            'isFreeUser': false,
            'subscriptionEndDate': 0,
          }),
          SubscriptionStatus.active,
        );
      });

      test('should return active for subscribed user without isFreeUser', () {
        expect(
          SubscriptionStatus.fromUserData({
            'isSubscribed': true,
            'subscriptionEndDate': 0,
          }),
          SubscriptionStatus.active,
        );
      });

      test('should return freeActive for free user with future end date', () {
        // TC-DISC-SUBSTATUS-003
        // Use a timestamp far in the future (2030)
        expect(
          SubscriptionStatus.fromUserData({
            'isSubscribed': false,
            'isFreeUser': true,
            'subscriptionEndDate': 1893456000, // 2030-01-01 in seconds
          }),
          SubscriptionStatus.freeActive,
        );
      });

      test('should return freeExpired for free user with past end date', () {
        // TC-DISC-SUBSTATUS-004
        expect(
          SubscriptionStatus.fromUserData({
            'isSubscribed': false,
            'isFreeUser': true,
            'subscriptionEndDate': 1577836800, // 2020-01-01 in seconds
          }),
          SubscriptionStatus.freeExpired,
        );
      });

      test('should return lapsed for non-subscribed non-free with past end date', () {
        // TC-DISC-SUBSTATUS-005
        expect(
          SubscriptionStatus.fromUserData({
            'isSubscribed': false,
            'isFreeUser': false,
            'subscriptionEndDate': 1577836800, // 2020-01-01
          }),
          SubscriptionStatus.lapsed,
        );
      });

      test('should return none for non-subscribed non-free with no end date', () {
        // TC-DISC-SUBSTATUS-006
        expect(
          SubscriptionStatus.fromUserData({
            'isSubscribed': false,
            'isFreeUser': false,
            'subscriptionEndDate': 0,
          }),
          SubscriptionStatus.none,
        );
      });

      test('should handle millisecond timestamps (>10 billion)', () {
        // TC-DISC-SUBSTATUS-007
        // Timestamp in milliseconds should NOT be multiplied by 1000
        expect(
          SubscriptionStatus.fromUserData({
            'isSubscribed': false,
            'isFreeUser': true,
            'subscriptionEndDate': 1893456000000, // already in milliseconds
          }),
          SubscriptionStatus.freeActive,
        );
      });

      test('should handle missing fields with defaults', () {
        // TC-DISC-SUBSTATUS-008
        expect(
          SubscriptionStatus.fromUserData({}),
          SubscriptionStatus.none,
        );
      });
    });

    group('label', () {
      test('active should return Active', () {
        // TC-DISC-SUBSTATUS-009
        expect(SubscriptionStatus.active.label, 'Active');
      });

      test('freeActive should return Active', () {
        expect(SubscriptionStatus.freeActive.label, 'Active');
      });

      test('freeExpired should return Expired', () {
        expect(SubscriptionStatus.freeExpired.label, 'Expired');
      });

      test('lapsed should return Expired', () {
        expect(SubscriptionStatus.lapsed.label, 'Expired');
      });

      test('none should return empty string', () {
        expect(SubscriptionStatus.none.label, '');
      });
    });

    group('computed properties', () {
      test('hasAccess should only be true for active', () {
        // TC-DISC-SUBSTATUS-010
        expect(SubscriptionStatus.active.hasAccess, isTrue);
        expect(SubscriptionStatus.freeActive.hasAccess, isFalse);
        expect(SubscriptionStatus.lapsed.hasAccess, isFalse);
        expect(SubscriptionStatus.none.hasAccess, isFalse);
      });

      test('isLapsed should only be true for lapsed', () {
        // TC-DISC-SUBSTATUS-011
        expect(SubscriptionStatus.lapsed.isLapsed, isTrue);
        expect(SubscriptionStatus.active.isLapsed, isFalse);
        expect(SubscriptionStatus.freeExpired.isLapsed, isFalse);
      });

      test('isFree should be true for freeActive and freeExpired', () {
        // TC-DISC-SUBSTATUS-012
        expect(SubscriptionStatus.freeActive.isFree, isTrue);
        expect(SubscriptionStatus.freeExpired.isFree, isTrue);
        expect(SubscriptionStatus.active.isFree, isFalse);
        expect(SubscriptionStatus.lapsed.isFree, isFalse);
        expect(SubscriptionStatus.none.isFree, isFalse);
      });
    });

    test('should have 5 values', () {
      expect(SubscriptionStatus.values, hasLength(5));
    });
  });
}
