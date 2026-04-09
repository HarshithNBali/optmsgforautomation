import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:optmsg/screens/auth/auth_riverpod/auth_notifier.dart';
import 'package:optmsg/screens/contacts/add_contact_riverpod/add_contact_notifier.dart';
import 'package:optmsg/screens/subscription/subscription_riverpod/subscription_notifier.dart';
import 'package:optmsg/model/auth/auth_state.dart';

import '../../helpers/riverpod_test_helpers.dart';

class _FakeAuthNotifier extends AuthNotifier {
  final Map<String, dynamic>? _fakeUserData;
  _FakeAuthNotifier(this._fakeUserData);

  @override
  AuthState build() {
    if (_fakeUserData != null) return AuthState.authenticated(_fakeUserData);
    return AuthState.unauthenticated();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late RiverpodTestSetup setup;

  setUp(() {
    setup = RiverpodTestSetup();
    when(() => setup.mockStorageService.readObjectData(any()))
        .thenAnswer((_) async => null);
    when(() => setup.mockStorageService.readData(any()))
        .thenAnswer((_) async => null);
  });

  // ===== AddContactNotifier =====
  group('AddContactNotifier', () {
    late ProviderContainer container;

    setUp(() async {
      container = ProviderContainer(overrides: setup.serviceOverrides);
      container.read(authProvider);
      await Future.delayed(Duration.zero);
    });

    tearDown(() => container.dispose());

    test('build should return AddContactState with emailFieldCount=1', () {
      final state = container.read(addContactProvider);
      expect(state.emailFieldCount, 1);
      expect(state.isLoading, false);
    });

    test('should have one email controller after build', () {
      final notifier = container.read(addContactProvider.notifier);
      expect(notifier.emailControllers, hasLength(1));
    });

    test('updateEmailControllers add should increase field count', () {
      final notifier = container.read(addContactProvider.notifier);
      notifier.updateEmailControllers('add', 0);

      final state = container.read(addContactProvider);
      expect(state.emailFieldCount, 2);
      expect(notifier.emailControllers, hasLength(2));
    });

    test('updateEmailControllers remove should decrease field count', () {
      final notifier = container.read(addContactProvider.notifier);
      notifier.updateEmailControllers('add', 0);
      notifier.updateEmailControllers('remove', 1);

      final state = container.read(addContactProvider);
      expect(state.emailFieldCount, 1);
      expect(notifier.emailControllers, hasLength(1));
    });
  });

  // ===== SubscriptionNotifier =====
  group('SubscriptionNotifier', () {
    test('build should return default SubscriptionState', () async {
      final container = ProviderContainer(
        overrides: [
          ...setup.serviceOverrides,
          authProvider.overrideWith(() => _FakeAuthNotifier(<String, dynamic>{
                'user': <String, dynamic>{'isFreeUser': true},
              })),
        ],
      );
      addTearDown(container.dispose);
      await Future.delayed(Duration.zero);

      final state = container.read(subscriptionProvider);
      expect(state.data, isEmpty);
      expect(state.isLoading, false);
      expect(state.isFreeUser, false);
    });

    // init() calls AppCache().getSubscriptionCacheData() which uses its own
    // inline SecureStorageService — not mockable without refactoring AppCache.
    // Test state mutation directly instead.

    test('remainingDays should compute from state data', () async {
      final container = ProviderContainer(
        overrides: [
          ...setup.serviceOverrides,
          authProvider.overrideWith(() => _FakeAuthNotifier(<String, dynamic>{
                'user': <String, dynamic>{'isFreeUser': true},
              })),
        ],
      );
      addTearDown(container.dispose);
      await Future.delayed(Duration.zero);

      final notifier = container.read(subscriptionProvider.notifier);
      final futureDate = DateTime.now().add(const Duration(days: 30));
      final endMs = futureDate.millisecondsSinceEpoch;
      notifier.state = notifier.state.copyWith(data: {
        'ends': endMs ~/ 1000, // seconds
      });

      expect(notifier.remainingDays, greaterThanOrEqualTo(29));
    });

    test('status should return Active for future end date', () async {
      final futureDate = DateTime.now().add(const Duration(days: 30));
      final container = ProviderContainer(
        overrides: [
          ...setup.serviceOverrides,
          authProvider.overrideWith(() => _FakeAuthNotifier(<String, dynamic>{
                'user': <String, dynamic>{
                  'isFreeUser': false,
                  'isSubscribed': true,
                  'subscriptionEndDate': futureDate.millisecondsSinceEpoch ~/ 1000,
                },
              })),
        ],
      );
      addTearDown(container.dispose);
      await Future.delayed(Duration.zero);

      final notifier = container.read(subscriptionProvider.notifier);
      notifier.state = notifier.state.copyWith(data: {
        'ends': futureDate.millisecondsSinceEpoch ~/ 1000,
      });

      expect(notifier.status(), 'Active');
    });

    test('status should return Expired for past end date', () async {
      final pastDate = DateTime.now().subtract(const Duration(days: 30));
      final container = ProviderContainer(
        overrides: [
          ...setup.serviceOverrides,
          authProvider.overrideWith(() => _FakeAuthNotifier(<String, dynamic>{
                'user': <String, dynamic>{
                  'isFreeUser': true,
                  'subscriptionEndDate': pastDate.millisecondsSinceEpoch ~/ 1000,
                },
              })),
        ],
      );
      addTearDown(container.dispose);
      await Future.delayed(Duration.zero);

      final notifier = container.read(subscriptionProvider.notifier);
      notifier.state = notifier.state.copyWith(data: {
        'ends': pastDate.millisecondsSinceEpoch ~/ 1000,
      });

      expect(notifier.status(), 'Expired');
    });
  });
}
