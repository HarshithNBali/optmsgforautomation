import 'package:flutter_test/flutter_test.dart';
import 'package:optmsg/model/login_model.dart';
import 'package:optmsg/screens/auth/auth_riverpod/auth_notifier.dart';

import '../../factories/test_data_factories.dart';

void main() {
  group('isSubscriptionValid', () {
    LoginModel makeLogin({
      bool? isFreeUser,
      int? subscriptionEndDate,
      bool isSubscribed = true,
    }) {
      return LoginModel.fromJson(makeLoginJson(
        userJson: makeUserJson(
          isFreeUser: isFreeUser,
          subscriptionEndDate: subscriptionEndDate,
          isSubscribed: isSubscribed,
        ),
      ));
    }

    test('should return true for paid (non-free) users', () {
      final login = makeLogin(isFreeUser: false);
      expect(isSubscriptionValid(login), true);
    });

    test('should return true for null isFreeUser (treated as paid)', () {
      final login = makeLogin(isFreeUser: null);
      expect(isSubscriptionValid(login), true);
    });

    test('should return true for free user with future end date (seconds)', () {
      // Far future: 2030-01-01 in seconds
      final futureSeconds =
          DateTime(2030, 1, 1).millisecondsSinceEpoch ~/ 1000;
      final login = makeLogin(
        isFreeUser: true,
        subscriptionEndDate: futureSeconds,
      );
      expect(isSubscriptionValid(login), true);
    });

    test('should return true for free user with future end date (milliseconds)',
        () {
      // Far future: 2030-01-01 in milliseconds
      final futureMs = DateTime(2030, 1, 1).millisecondsSinceEpoch;
      final login = makeLogin(
        isFreeUser: true,
        subscriptionEndDate: futureMs,
      );
      expect(isSubscriptionValid(login), true);
    });

    test('should return false for free user with past end date', () {
      // Past: 2020-01-01 in seconds
      final pastSeconds =
          DateTime(2020, 1, 1).millisecondsSinceEpoch ~/ 1000;
      final login = makeLogin(
        isFreeUser: true,
        subscriptionEndDate: pastSeconds,
      );
      expect(isSubscriptionValid(login), false);
    });

    test('should return false for free user with null end date', () {
      final login = makeLogin(
        isFreeUser: true,
        subscriptionEndDate: null,
      );
      expect(isSubscriptionValid(login), false);
    });

    test('should return false for free user with zero end date', () {
      final login = makeLogin(
        isFreeUser: true,
        subscriptionEndDate: 0,
      );
      expect(isSubscriptionValid(login), false);
    });

    test('should correctly detect seconds vs milliseconds threshold', () {
      // The threshold is 10,000,000,000
      // Below = seconds, multiply by 1000
      // Above = already milliseconds

      // A value just below threshold (in seconds, ~2286 year)
      final login1 = makeLogin(
        isFreeUser: true,
        subscriptionEndDate: 9999999999,
      );
      // This is year ~2286 in seconds → converted to ms → far future
      expect(isSubscriptionValid(login1), true);

      // A value just at threshold (in milliseconds, ~1970 April)
      final login2 = makeLogin(
        isFreeUser: true,
        subscriptionEndDate: 10000000000,
      );
      // This is April 1970 in ms → past
      expect(isSubscriptionValid(login2), false);
    });
  });
}
