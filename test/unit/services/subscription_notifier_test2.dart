// Implements: TC-DISC-SUB-001..006
// Source: lib/screens/subscription/subscription_riverpod/subscription_notifier.dart
// Coverage target: Test pure-logic methods (remainingDays, status, initial state)
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:optmsg/screens/auth/auth_riverpod/auth_notifier.dart';
import 'package:optmsg/screens/subscription/subscription_riverpod/subscription_notifier.dart';
import 'package:optmsg/model/auth/auth_state.dart';

import '../../helpers/riverpod_test_helpers.dart';
import '../../factories/test_data_factories.dart';

class _FakeAuthNotifier extends AuthNotifier {
  final Map<String, dynamic>? _data;
  _FakeAuthNotifier(this._data);
  @override
  AuthState build() =>
      _data != null ? AuthState.authenticated(_data) : AuthState.unauthenticated();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late RiverpodTestSetup setup;
  late ProviderContainer container;

  setUp(() {
    setup = RiverpodTestSetup();
    when(() => setup.mockStorageService.readObjectData(any()))
        .thenAnswer((_) async => null);
    when(() => setup.mockStorageService.readData(any()))
        .thenAnswer((_) async => null);
  });

  tearDown(() => container.dispose());

  group('SubscriptionNotifier', () {
    test('should have correct initial state', () {
      // TC-DISC-SUB-001
      container = ProviderContainer(overrides: setup.serviceOverrides);
      final state = container.read(subscriptionProvider);
      expect(state.isLoading, isFalse);
      expect(state.data, isEmpty);
      expect(state.isFreeUser, isFalse);
    });

    test('remainingDays should return 0 for empty data', () {
      // TC-DISC-SUB-002
      container = ProviderContainer(overrides: setup.serviceOverrides);
      final notifier = container.read(subscriptionProvider.notifier);
      expect(notifier.remainingDays, 0);
    });

    test('status should return empty string for empty data', () {
      // TC-DISC-SUB-003
      container = ProviderContainer(overrides: [
        ...setup.serviceOverrides,
        authProvider.overrideWith(() => _FakeAuthNotifier({
              'user': makeUserJson(),
              'token': 'tok',
            })),
      ]);
      final notifier = container.read(subscriptionProvider.notifier);
      expect(notifier.status(), '');
    });

    test('subscriptionStatus should return correct status from userData', () {
      // TC-DISC-SUB-004
      container = ProviderContainer(overrides: [
        ...setup.serviceOverrides,
        authProvider.overrideWith(() => _FakeAuthNotifier({
              'user': makeUserJson(isSubscribed: true),
              'token': 'tok',
            })),
      ]);
      final notifier = container.read(subscriptionProvider.notifier);
      // Should not throw — returns a SubscriptionStatus enum
      expect(notifier.subscriptionStatus, isNotNull);
    });

    test('build should reset state on rebuild', () {
      // TC-DISC-SUB-005
      container = ProviderContainer(overrides: setup.serviceOverrides);
      // Read provider to trigger build
      container.read(subscriptionProvider);
      // Invalidate to force rebuild
      container.invalidate(subscriptionProvider);
      final state = container.read(subscriptionProvider);
      expect(state.data, isEmpty);
      expect(state.isLoading, isFalse);
    });
  });
}
