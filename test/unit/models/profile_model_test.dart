import 'package:flutter_test/flutter_test.dart';
import 'package:optmsg/model/profile_model.dart';

import '../../factories/test_data_factories.dart';

void main() {
  group('MyProfile', () {
    test('should parse valid JSON', () {
      final json = makeProfileJson(
        firstName: 'Jane',
        lastName: 'Doe',
        userName: 'janedoe',
      );
      final profile = MyProfile.fromJson(json);

      expect(profile.success, true);
      expect(profile.message, 'Profile fetched');
      expect(profile.data.firstName, 'Jane');
      expect(profile.data.lastName, 'Doe');
      expect(profile.data.userName, 'janedoe');
    });

    test('should parse all data fields', () {
      final json = makeProfileJson(
        id: 42,
        countryCode: '+44',
        mobile: '7700900000',
        isSubscribed: false,
        isNotification: false,
        isBiomatrix: true,
        isDeviceBiometrics: true,
      );
      final data = MyProfile.fromJson(json).data;

      expect(data.id, 42);
      expect(data.countryCode, '+44');
      expect(data.mobile, '7700900000');
      expect(data.isSubscribed, false);
      expect(data.isNotification, false);
      expect(data.isBiomatrix, true);
      expect(data.isDeviceBiometrics, true);
    });

    test('should roundtrip through toJson/fromJson', () {
      final original = MyProfile.fromJson(makeProfileJson(id: 99));
      final restored = MyProfile.fromJson(original.toJson());

      expect(restored.data.id, 99);
      expect(restored.data.firstName, original.data.firstName);
      expect(restored.success, original.success);
    });
  });
}
