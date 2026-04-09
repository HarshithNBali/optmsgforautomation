import 'package:flutter_test/flutter_test.dart';
import 'package:optmsg/model/login_model.dart';

import '../../factories/test_data_factories.dart';

void main() {
  group('LoginModel', () {
    test('should parse valid JSON correctly', () {
      final json = makeLoginJson();
      final model = LoginModel.fromJson(json);

      expect(model.success, true);
      expect(model.message, 'Login successful');
      expect(model.data.token, 'test-jwt-token-123');
      expect(model.data.user.id, 1);
      expect(model.data.user.firstName, 'Test');
      expect(model.data.user.lastName, 'User');
      expect(model.data.user.userName, 'testuser');
    });

    test('should handle missing fields with defaults', () {
      final json = makeLoginJson(
        success: false,
        message: '',
        token: '',
        userJson: {},
      );
      final model = LoginModel.fromJson(json);

      expect(model.success, false);
      expect(model.message, '');
      expect(model.data.token, '');
      expect(model.data.user.id, 0);
      expect(model.data.user.firstName, '');
    });

    test('should roundtrip through toJson/fromJson', () {
      final original = LoginModel.fromJson(makeLoginJson(
        userJson: makeUserJson(id: 42, firstName: 'Jane'),
      ));
      final json = original.toJson();
      final restored = LoginModel.fromJson(json);

      expect(restored.success, original.success);
      expect(restored.message, original.message);
      expect(restored.data.token, original.data.token);
      expect(restored.data.user.id, original.data.user.id);
      expect(restored.data.user.firstName, original.data.user.firstName);
    });

    test('should parse null data gracefully', () {
      final json = {
        'success': false,
        'message': 'Error',
        'data': null,
      };
      // LoginModel.fromJson uses json['data'] ?? {} so null becomes empty map
      final model = LoginModel.fromJson(json);
      expect(model.data.user.id, 0);
      expect(model.data.token, '');
    });
  });

  group('User', () {
    test('should parse all fields from valid JSON', () {
      final json = makeUserJson(
        id: 42,
        firstName: 'Jane',
        lastName: 'Doe',
        userName: 'janedoe',
        countryCode: '+44',
        mobile: '7700900000',
        isSubscribed: true,
        subscriptionEndDate: 1700000000,
        subscriptionStartDate: 1690000000,
        boardingSteps: 'completed',
        isFreeUser: false,
        isBiomatrix: true,
        isDeviceBiometrics: true,
      );
      final user = User.fromJson(json);

      expect(user.id, 42);
      expect(user.firstName, 'Jane');
      expect(user.lastName, 'Doe');
      expect(user.userName, 'janedoe');
      expect(user.countryCode, '+44');
      expect(user.mobile, '7700900000');
      expect(user.isSubscribed, true);
      expect(user.subscriptionEndDate, 1700000000);
      expect(user.subscriptionStartDate, 1690000000);
      expect(user.boardingSteps, 'completed');
      expect(user.isFreeUser, false);
      expect(user.isBiomatrix, true);
      expect(user.isDeviceBiometrics, true);
    });

    test('should default missing fields', () {
      final user = User.fromJson({});

      expect(user.id, 0);
      expect(user.firstName, '');
      expect(user.lastName, '');
      expect(user.userName, '');
      expect(user.isSubscribed, false);
      expect(user.isBiomatrix, false);
      expect(user.isDeviceBiometrics, false);
      expect(user.boardingSteps, 'notification');
      expect(user.otp, isNull);
      expect(user.subscriptionEndDate, isNull);
      expect(user.isFreeUser, isNull);
      expect(user.webauth, isNull);
    });

    test('should roundtrip through toJson/fromJson', () {
      final original = User.fromJson(makeUserJson(id: 99));
      final restored = User.fromJson(original.toJson());

      expect(restored.id, original.id);
      expect(restored.firstName, original.firstName);
      expect(restored.userName, original.userName);
      expect(restored.isSubscribed, original.isSubscribed);
      expect(restored.isBiomatrix, original.isBiomatrix);
    });
  });
}
