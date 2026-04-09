import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:optmsg/model/auth/auth_state.dart';
import 'package:optmsg/screens/auth/auth_riverpod/auth_notifier.dart';
import 'package:optmsg/screens/auth/passKey/passkey_notifier.dart';
import 'package:optmsg/screens/subscription/checkout/checkout_notifier.dart';
import 'package:optmsg/screens/subscription/checkout/checkout_state.dart';
import 'package:optmsg/services/session_refresh_mutex.dart';

import '../../helpers/riverpod_test_helpers.dart';

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

  setUp(() {
    setup = RiverpodTestSetup();
    when(() => setup.mockStorageService.readObjectData(any()))
        .thenAnswer((_) async => null);
    when(() => setup.mockStorageService.readData(any()))
        .thenAnswer((_) async => null);
    when(() => setup.mockStorageService.writeData(any(), any()))
        .thenAnswer((_) async {});
    when(() => setup.mockStorageService.writeObjectData(any(), any()))
        .thenAnswer((_) async {});
    SessionRefreshMutex.passkeyFlowInProgress = false;
  });

  // ===== PasskeyNotifier =====
  group('PasskeyNotifier', () {
    late ProviderContainer container;

    setUp(() async {
      container = ProviderContainer(
        overrides: [
          ...setup.serviceOverrides,
          authProvider.overrideWith(() => _FakeAuthNotifier({
                'user': {
                  'firstName': 'Jane',
                  'lastName': 'Doe',
                  'userName': 'janedoe',
                  'boardingSteps': 'completed',
                }
              })),
        ],
      );
      await Future.delayed(Duration.zero);
    });

    tearDown(() {
      container.dispose();
      SessionRefreshMutex.passkeyFlowInProgress = false;
    });

    test('build should return default PasskeyState', () {
      final state = container.read(passkeyProvider);
      expect(state.isLoading, isA<bool>());
      expect(state.isEnabled, false);
      expect(state.isEnabling, false);
    });

    test('_init should settle to non-loading state', () async {
      await Future.delayed(const Duration(milliseconds: 100));

      final state = container.read(passkeyProvider);
      expect(state.isLoading, false);
      expect(state.passkeySupported, false);
    });

    test('_init should read hasCompletedOnboarding from storage', () async {
      when(() => setup.mockStorageService.readData('hasCompletedOnboarding'))
          .thenAnswer((_) async => 'true');

      // Need fresh container for this stub to take effect
      final c2 = ProviderContainer(
        overrides: [
          ...setup.serviceOverrides,
          authProvider.overrideWith(() => _FakeAuthNotifier({'user': {}})),
        ],
      );
      addTearDown(c2.dispose);
      await Future.delayed(Duration.zero);
      c2.read(passkeyProvider);
      await Future.delayed(const Duration(milliseconds: 100));

      expect(c2.read(passkeyProvider).hasCompletedOnboarding, true);
    });

    test('disposal should clear passkeyFlowInProgress', () {
      // Test in isolation — create a fresh container, read the provider,
      // then dispose and verify the flag is cleared.
      final c = ProviderContainer(
        overrides: [
          ...setup.serviceOverrides,
          authProvider.overrideWith(() => _FakeAuthNotifier({'user': {}})),
        ],
      );
      c.read(passkeyProvider);
      SessionRefreshMutex.passkeyFlowInProgress = true;

      c.dispose();

      expect(SessionRefreshMutex.passkeyFlowInProgress, false);
    });
  });

  // ===== CheckoutNotifier =====
  group('CheckoutNotifier', () {
    late ProviderContainer container;

    setUp(() async {
      container = ProviderContainer(overrides: setup.serviceOverrides);
      container.read(authProvider);
      await Future.delayed(Duration.zero);
    });

    tearDown(() => container.dispose());

    test('build should return default CheckoutState', () {
      final state = container.read(checkoutProvider);
      expect(state.isLoading, false);
      expect(state.selectedPlan, isNull);
      expect(state.grandTotal, 0);
      expect(state.promoCode, '');
      expect(state.paymentStatus, isNull);
    });

    test('CheckoutState copyWith should work', () {
      final modified = const CheckoutState().copyWith(
        isLoading: true,
        grandTotal: 9.99,
        promoCode: 'SAVE10',
        isPromoApplied: true,
        planType: 'monthly',
      );
      expect(modified.isLoading, true);
      expect(modified.grandTotal, 9.99);
      expect(modified.promoCode, 'SAVE10');
      expect(modified.isPromoApplied, true);
      expect(modified.planType, 'monthly');
    });

    test('CheckoutState should have all expected defaults', () {
      const state = CheckoutState();
      expect(state.subscriptionPage, '');
      expect(state.isPromoApplied, false);
      expect(state.originalCharge, 0);
      expect(state.discount, 0);
      expect(state.discountType, '');
      expect(state.token, '');
      expect(state.profile, isNull);
      expect(state.errorMessage, isNull);
    });
  });

  // ===== CheckoutNotifier state mutations =====
  group('CheckoutNotifier state mutations', () {
    late ProviderContainer container;
    late CheckoutNotifier notifier;

    setUp(() async {
      container = ProviderContainer(overrides: setup.serviceOverrides);
      container.read(authProvider);
      await Future.delayed(Duration.zero);
      notifier = container.read(checkoutProvider.notifier);
    });

    tearDown(() => container.dispose());

    test('should update selectedPlan', () {
      notifier.state = notifier.state.copyWith(
        selectedPlan: {'id': 1, 'title': 'Pro', 'charge': 999},
      );
      expect(container.read(checkoutProvider).selectedPlan!['title'], 'Pro');
    });

    test('should update promo state', () {
      notifier.state = notifier.state.copyWith(
        isPromoApplied: true,
        promoCode: 'SAVE20',
        discount: 200,
        discountType: 'fixed',
        grandTotal: 799,
      );
      final state = container.read(checkoutProvider);
      expect(state.isPromoApplied, true);
      expect(state.promoCode, 'SAVE20');
      expect(state.discount, 200);
      expect(state.grandTotal, 799);
    });

    test('should update payment status', () {
      notifier.state = notifier.state.copyWith(paymentStatus: 'success');
      expect(container.read(checkoutProvider).paymentStatus, 'success');
    });

    test('should clear error', () {
      notifier.state = notifier.state.copyWith(errorMessage: 'Failed');
      notifier.state = notifier.state.copyWith(errorMessage: null);
      expect(container.read(checkoutProvider).errorMessage, isNull);
    });
  });
}
