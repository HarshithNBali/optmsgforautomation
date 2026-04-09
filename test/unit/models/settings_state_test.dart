import 'package:flutter_test/flutter_test.dart';
import 'package:optmsg/screens/settings/setting_riverpod/setting_state.dart';

void main() {
  group('SettingsState', () {
    test('default constructor should have sensible defaults', () {
      const state = SettingsState();

      expect(state.isLoading, false);
      expect(state.userData, isNull);
      expect(state.isNotificationSelected, true);
      expect(state.isBiometricSelected, false);
      expect(state.lastNameSorted, true);
      expect(state.syncContact, true);
      expect(state.readingPaneEnabled, true);
      expect(state.showLogoutDialog, false);
    });

    group('computed properties', () {
      test('hasUserData should reflect userData presence', () {
        const noData = SettingsState();
        expect(noData.hasUserData, false);

        const withData = SettingsState(userData: {'user': {'name': 'Test'}});
        expect(withData.hasUserData, true);
      });

      test('userName should extract from nested userData', () {
        const state = SettingsState(
          userData: {
            'user': {'name': 'John Doe'}
          },
        );
        expect(state.userName, 'John Doe');
      });

      test('userName should return empty string when userData is null', () {
        const state = SettingsState();
        expect(state.userName, '');
      });

      test('isNotificationEnabled is alias for isNotificationSelected', () {
        const state = SettingsState(isNotificationSelected: false);
        expect(state.isNotificationEnabled, false);
      });

      test('isBiometricEnabled is alias for isBiometricSelected', () {
        const state = SettingsState(isBiometricSelected: true);
        expect(state.isBiometricEnabled, true);
      });
    });

    test('copyWith should create a modified copy', () {
      const original = SettingsState();
      final modified = original.copyWith(
        isLoading: true,
        isNotificationSelected: false,
        showLogoutDialog: true,
      );

      expect(modified.isLoading, true);
      expect(modified.isNotificationSelected, false);
      expect(modified.showLogoutDialog, true);
      // Unchanged
      expect(modified.isBiometricSelected, original.isBiometricSelected);
      expect(modified.readingPaneEnabled, original.readingPaneEnabled);
    });
  });
}
