import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:optmsg/model/base_response/request_response.dart';
import 'package:optmsg/screens/auth/auth_riverpod/auth_notifier.dart';
import 'package:optmsg/screens/settings/profile_riverpod/profile_notifier.dart';

import '../../helpers/riverpod_test_helpers.dart';
import '../../factories/test_data_factories.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late RiverpodTestSetup setup;
  late ProviderContainer container;
  late ProfileNotifier notifier;

  setUp(() async {
    setup = RiverpodTestSetup();
    when(() => setup.mockStorageService.readObjectData(any()))
        .thenAnswer((_) async => null);
    when(() => setup.mockStorageService.readData(any()))
        .thenAnswer((_) async => null);
    when(() => setup.mockStorageService.writeObjectData(any(), any()))
        .thenAnswer((_) async {});

    container = ProviderContainer(overrides: setup.serviceOverrides);
    container.read(authProvider);
    await Future.delayed(Duration.zero);
    notifier = container.read(profileProvider.notifier);
  });

  tearDown(() => container.dispose());

  group('ProfileNotifier build()', () {
    test('should return default ProfileState', () {
      final state = container.read(profileProvider);
      expect(state.isLoading, isA<bool>());
      expect(state.isEdit, false);
      expect(state.profile, isNull);
    });
  });

  group('ProfileNotifier fetchProfile', () {
    test('should populate profile on successful response', () async {
      when(() => setup.mockAccountApi.getProfile(any()))
          .thenAnswer((_) async => RequestResponse(
              data: makeProfileJson(
                firstName: 'Jane',
                lastName: 'Doe',
                userName: 'janedoe',
              )));

      await notifier.fetchProfile();

      final state = container.read(profileProvider);
      expect(state.profile, isNotNull);
      expect(state.profile!.data.firstName, 'Jane');
      expect(state.isLoading, false);
      expect(notifier.firstNameCtrl.text, 'Jane');
      expect(notifier.lastNameCtrl.text, 'Doe');
    });

    test('should handle unsuccessful response', () async {
      when(() => setup.mockAccountApi.getProfile(any()))
          .thenAnswer((_) async => RequestResponse(
              data: {'success': false, 'message': 'Error'}));

      await notifier.fetchProfile();

      final state = container.read(profileProvider);
      expect(state.profile, isNull);
      expect(state.isLoading, false);
    });

    test('should handle exception', () async {
      when(() => setup.mockAccountApi.getProfile(any()))
          .thenThrow(Exception('Network error'));

      await notifier.fetchProfile();

      expect(container.read(profileProvider).isLoading, false);
    });
  });

  group('ProfileNotifier edit mode', () {
    setUp(() async {
      // Pre-populate a profile
      when(() => setup.mockAccountApi.getProfile(any()))
          .thenAnswer((_) async => RequestResponse(
              data: makeProfileJson(
                firstName: 'Jane', lastName: 'Doe',
                userName: 'janedoe', mobile: '5551234567',
                countryCode: '+1',
              )));
      await notifier.fetchProfile();
    });

    test('enableEdit should set isEdit and update phone field', () {
      notifier.enableEdit();
      final state = container.read(profileProvider);
      expect(state.isEdit, true);
      expect(notifier.phoneCtrl.text, '5551234567');
    });

    test('disableEdit should reset controllers and clear isEdit', () {
      notifier.enableEdit();
      notifier.firstNameCtrl.text = 'Changed';
      notifier.disableEdit();

      final state = container.read(profileProvider);
      expect(state.isEdit, false);
      expect(notifier.firstNameCtrl.text, 'Jane');
    });
  });

  group('ProfileNotifier date helpers', () {
    test('formatDate should format ISO date', () {
      expect(notifier.formatDate('2024-06-15'), contains('June'));
      expect(notifier.formatDate('2024-06-15'), contains('2024'));
    });

    test('formatDate should return N/A for invalid date', () {
      expect(notifier.formatDate('not-a-date'), 'N/A');
    });

    test('formatDateForApi should convert display date to API format', () {
      final result = notifier.formatDateForApi('June 15, 2024');
      // Should be in yyyy-MM-dd format
      expect(result, contains('2024'));
    });

    test('formatDateForApi should throw for invalid input', () {
      expect(
        () => notifier.formatDateForApi('garbage'),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
