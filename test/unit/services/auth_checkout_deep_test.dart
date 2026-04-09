import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:optmsg/model/auth/auth_state.dart';
import 'package:optmsg/screens/auth/auth_riverpod/auth_notifier.dart';
import 'package:optmsg/services/api_service.dart' show NoInternetException;
import 'package:optmsg/screens/subscription/checkout/checkout_notifier.dart';
import 'package:optmsg/services/session_refresh_mutex.dart';

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
    SessionRefreshMutex.isLoggedOut = false;
  });

  // ===== AuthNotifier userLogin =====
  group('AuthNotifier userLogin', () {
    late ProviderContainer container;

    setUp(() async {
      container = ProviderContainer(overrides: setup.serviceOverrides);
      container.read(authProvider);
      await Future.delayed(Duration.zero);
    });

    tearDown(() => container.dispose());

    test('should write userData to storage on valid subscription', () async {
      when(() => setup.mockApiService.post(any(), any()))
          .thenAnswer((_) async => makeLoginJson(
                success: true,
                userJson: makeUserJson(
                  isSubscribed: true,
                  isFreeUser: false,
                ),
              ));

      final notifier = container.read(authProvider.notifier);
      await notifier.userLogin('test-device-token');

      // userLogin writes userData before the Descope check that throws
      verify(() => setup.mockStorageService.writeObjectData('userData', any())).called(1);
      verify(() => setup.mockStorageService.writeData('isAuthenticated', 'true')).called(1);
    });

    test('should set error state on API failure', () async {
      when(() => setup.mockApiService.post(any(), any()))
          .thenAnswer((_) async => {
                'success': false,
                'message': 'Invalid credentials',
              });

      final notifier = container.read(authProvider.notifier);
      final result = await notifier.userLogin('token');

      expect(result.hasError, true);
      expect(result.errorMessage, 'Invalid credentials');
      expect(result.errorType, AuthErrorType.invalidCredentials);
    });

    test('should set subscriptionInvalid error for invalid subscription', () async {
      when(() => setup.mockApiService.post(any(), any()))
          .thenAnswer((_) async => makeLoginJson(
                success: true,
                userJson: makeUserJson(
                  isFreeUser: true,
                  subscriptionEndDate: 1000, // far past
                ),
              ));

      final notifier = container.read(authProvider.notifier);
      final result = await notifier.userLogin('token');

      expect(result.hasError, true);
      expect(result.errorType, AuthErrorType.subscriptionInvalid);
    });

    test('should set network error type on NoInternetException', () async {
      when(() => setup.mockApiService.post(any(), any()))
          .thenThrow(NoInternetException('No connection'));

      final notifier = container.read(authProvider.notifier);
      final result = await notifier.userLogin('token');

      expect(result.hasError, true);
      expect(result.errorType, AuthErrorType.network);
    });

    test('should set generic error type on other exceptions', () async {
      when(() => setup.mockApiService.post(any(), any()))
          .thenThrow(Exception('Server error'));

      final notifier = container.read(authProvider.notifier);
      final result = await notifier.userLogin('token');

      expect(result.hasError, true);
      expect(result.errorType, AuthErrorType.generic);
    });
  });

  // ===== AuthNotifier otpInit =====
  group('AuthNotifier otpInit', () {
    late ProviderContainer container;

    setUp(() async {
      container = ProviderContainer(overrides: setup.serviceOverrides);
      container.read(authProvider);
      await Future.delayed(Duration.zero);
    });

    tearDown(() => container.dispose());

    test('should populate mobile and formatted phone', () async {
      // Set state with userData containing a mobile number
      final notifier = container.read(authProvider.notifier);
      notifier.setAuthenticated(true, userData: {
        'user': {'mobile': '5551234567'},
      });

      when(() => setup.mockStorageService.readData('countryCode'))
          .thenAnswer((_) async => '+1');

      await notifier.otpInit('fallback');

      final state = container.read(authProvider);
      expect(state.mobile, '5551234567');
      expect(state.countryCode, '+1');
      expect(state.formattedPhone, contains('555'));
    });

    test('should use loginId as fallback when no userData mobile', () async {
      final notifier = container.read(authProvider.notifier);

      when(() => setup.mockStorageService.readData('countryCode'))
          .thenAnswer((_) async => '+44');

      await notifier.otpInit('fallbackId');

      final state = container.read(authProvider);
      expect(state.mobile, 'fallbackId');
      expect(state.countryCode, '+44');
    });

    test('should default countryCode to +1 when storage returns null', () async {
      final notifier = container.read(authProvider.notifier);

      await notifier.otpInit('user123');

      expect(container.read(authProvider).countryCode, '+1');
    });
  });

  // ===== AuthNotifier _clearError =====
  group('AuthNotifier setAuthenticated', () {
    late ProviderContainer container;

    setUp(() async {
      container = ProviderContainer(overrides: setup.serviceOverrides);
      container.read(authProvider);
      await Future.delayed(Duration.zero);
    });

    tearDown(() => container.dispose());

    test('setAuthenticated(true) with userData', () {
      final notifier = container.read(authProvider.notifier);
      notifier.setAuthenticated(true, userData: {'user': {'id': 42}});

      final state = container.read(authProvider);
      expect(state.isAuthenticated, true);
      expect(state.userData, isNotNull);
      expect(state.userData!['user']['id'], 42);
    });

    test('setAuthenticated(false) should clear to unauthenticated', () {
      final notifier = container.read(authProvider.notifier);
      notifier.setAuthenticated(true, userData: {'user': {}});
      notifier.setAuthenticated(false);

      final state = container.read(authProvider);
      expect(state.isAuthenticated, false);
      expect(state.isInitialized, true);
    });
  });

  // ===== CheckoutNotifier initCheckout =====
  group('CheckoutNotifier initCheckout', () {
    late ProviderContainer container;

    setUp(() async {
      container = ProviderContainer(
        overrides: [
          ...setup.serviceOverrides,
          authProvider.overrideWith(() => _FakeAuthNotifier({
                'user': {'id': 1},
                'token': 'jwt-test',
              })),
        ],
      );
      await Future.delayed(Duration.zero);
    });

    tearDown(() => container.dispose());

    test('should load plan from storage and set state', () async {
      when(() => setup.mockStorageService.readObjectData('selected_plan'))
          .thenAnswer((_) async => {
                'id': 1,
                'title': 'Pro Plan',
                'charge': 999,
                'type': 'monthly',
              });
      when(() => setup.mockStorageService.readData('subscriptionPage'))
          .thenAnswer((_) async => 'upgrade');

      final notifier = container.read(checkoutProvider.notifier);
      await notifier.initCheckout();

      final state = container.read(checkoutProvider);
      expect(state.isLoading, false);
      expect(state.selectedPlan, isNotNull);
      expect(state.selectedPlan!['title'], 'Pro Plan');
      expect(state.originalCharge, 999.0);
      expect(state.grandTotal, 999.0);
      expect(state.subscriptionPage, 'upgrade');
      expect(state.planType, 'mo');
    });

    test('should handle null plan gracefully', () async {
      final notifier = container.read(checkoutProvider.notifier);
      await notifier.initCheckout();

      final state = container.read(checkoutProvider);
      expect(state.isLoading, false);
      expect(state.originalCharge, 0.0);
    });

    test('should set planType to yr for annual plans', () async {
      when(() => setup.mockStorageService.readObjectData('selected_plan'))
          .thenAnswer((_) async => {
                'id': 2, 'title': 'Annual', 'charge': 9999, 'type': 'annual',
              });

      final notifier = container.read(checkoutProvider.notifier);
      await notifier.initCheckout();

      expect(container.read(checkoutProvider).planType, 'yr');
    });
  });

  // ===== CheckoutNotifier applyPromo =====
  group('CheckoutNotifier applyPromo', () {
    late ProviderContainer container;
    late CheckoutNotifier notifier;

    setUp(() async {
      container = ProviderContainer(overrides: setup.serviceOverrides);
      container.read(authProvider);
      await Future.delayed(Duration.zero);
      notifier = container.read(checkoutProvider.notifier);
      // Set up a plan with known charge
      notifier.state = notifier.state.copyWith(
        selectedPlan: {'id': 1},
        originalCharge: 1000.0,
        grandTotal: 1000.0,
      );
    });

    tearDown(() => container.dispose());

    test('should reject empty promo code', () async {
      await notifier.applyPromo('');
      expect(container.read(checkoutProvider).isPromoApplied, false);
    });

    test('should reject invalid format', () async {
      await notifier.applyPromo('has spaces!');
      expect(container.read(checkoutProvider).isPromoApplied, false);
    });

    test('should apply flat discount on success', () async {
      when(() => setup.mockApiService.post(any(), any()))
          .thenAnswer((_) async => {
                'success': true,
                'data': {'discountType': 'flat', 'discount': 200},
              });

      await notifier.applyPromo('SAVE200');

      final state = container.read(checkoutProvider);
      expect(state.isPromoApplied, true);
      expect(state.promoCode, 'SAVE200');
      expect(state.discount, 200.0);
      expect(state.grandTotal, 800.0);
    });

    test('should apply percentage discount on success', () async {
      when(() => setup.mockApiService.post(any(), any()))
          .thenAnswer((_) async => {
                'success': true,
                'data': {'discountType': 'percent', 'discount': 10},
              });

      await notifier.applyPromo('SAVE10');

      final state = container.read(checkoutProvider);
      expect(state.isPromoApplied, true);
      expect(state.discount, 100.0); // 10% of 1000
      expect(state.grandTotal, 900.0);
    });

    test('should handle API rejection', () async {
      when(() => setup.mockApiService.post(any(), any()))
          .thenAnswer((_) async => {
                'success': false,
                'message': 'Invalid code',
              });

      await notifier.applyPromo('BADCODE');

      expect(container.read(checkoutProvider).isPromoApplied, false);
    });
  });

  // ===== CheckoutNotifier removePromo =====
  group('CheckoutNotifier removePromo', () {
    test('should clear promo and reset grandTotal', () async {
      final container = ProviderContainer(overrides: setup.serviceOverrides);
      addTearDown(container.dispose);
      container.read(authProvider);
      await Future.delayed(Duration.zero);

      final notifier = container.read(checkoutProvider.notifier);
      notifier.state = notifier.state.copyWith(
        isPromoApplied: true,
        promoCode: 'SAVE10',
        discount: 100,
        originalCharge: 1000,
        grandTotal: 900,
      );

      notifier.removePromo();

      final state = container.read(checkoutProvider);
      expect(state.isPromoApplied, false);
      expect(state.promoCode, '');
      expect(state.discount, 0);
      expect(state.grandTotal, 1000);
    });
  });
}
