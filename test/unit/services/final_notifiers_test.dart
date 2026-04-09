import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:optmsg/screens/auth/auth_riverpod/auth_notifier.dart';
import 'package:optmsg/screens/auth/web/enterOtp/web_enter_otp_notifier.dart';
import 'package:optmsg/screens/auth/web/enterOtp/web_enter_otp_state.dart';
import 'package:optmsg/screens/subscription/change_payment/payment_method_state.dart';
import 'package:optmsg/screens/notifications/notification_riverpod/notification_state.dart';
import 'package:optmsg/screens/contacts/view_contact_riverpod/view_contact_state.dart';
import 'package:optmsg/screens/contacts/edit_contact_riverpod/edit_contact_state.dart';

import '../../helpers/riverpod_test_helpers.dart';

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
  });

  // ===== WebEnterOtpState =====
  group('WebEnterOtpState', () {
    test('defaults', () {
      const state = WebEnterOtpState();
      expect(state.isLoading, false);
      expect(state.formattedPhoneNumber, '');
      expect(state.countryCode, '+1');
      expect(state.deviceToken, '');
      expect(state.resendCooldownSeconds, 0);
      expect(state.userData, isNull);
    });

    test('copyWith', () {
      final modified = const WebEnterOtpState().copyWith(
        isLoading: true,
        formattedPhoneNumber: '(+1) 555-123-4567',
        resendCooldownSeconds: 30,
      );
      expect(modified.isLoading, true);
      expect(modified.formattedPhoneNumber, '(+1) 555-123-4567');
      expect(modified.resendCooldownSeconds, 30);
    });
  });

  // ===== WebEnterOtpNotifier =====
  group('WebEnterOtpNotifier', () {
    late ProviderContainer container;

    setUp(() async {
      container = ProviderContainer(overrides: setup.serviceOverrides);
      container.read(authProvider);
      await Future.delayed(Duration.zero);
    });

    tearDown(() => container.dispose());

    test('build should return default state', () {
      final state = container.read(webEnterOtpProvider);
      expect(state.isLoading, false);
      expect(state.resendCooldownSeconds, 0);
    });

    test('should have otpController after build', () {
      final notifier = container.read(webEnterOtpProvider.notifier);
      expect(notifier.otpController, isNotNull);
      expect(notifier.otpController.text, '');
    });

    test('should have formKey after build', () {
      final notifier = container.read(webEnterOtpProvider.notifier);
      expect(notifier.formKey, isNotNull);
    });
  });

  // ===== PaymentMethodState =====
  group('PaymentMethodState', () {
    test('defaults', () {
      const state = PaymentMethodState();
      expect(state.isLoading, false);
      expect(state.showNoData, false);
      expect(state.cardData, isEmpty);
    });

    test('copyWith', () {
      final modified = const PaymentMethodState().copyWith(
        isLoading: true,
        cardData: [
          {'last4': '4242', 'brand': 'visa'}
        ],
      );
      expect(modified.isLoading, true);
      expect(modified.cardData, hasLength(1));
      expect(modified.cardData[0]['last4'], '4242');
    });

    test('showNoData flag', () {
      final state = const PaymentMethodState().copyWith(showNoData: true);
      expect(state.showNoData, true);
    });
  });

  // ===== NotificationState =====
  group('NotificationState', () {
    test('defaults', () {
      const state = NotificationState();
      expect(state.items, isEmpty);
      expect(state.isLoading, false);
      expect(state.currentPage, 1);
      expect(state.hasMore, true);
      expect(state.inboxCount, 0);
      expect(state.draftCount, 0);
      expect(state.trashCount, 0);
      expect(state.archiveCount, 0);
      expect(state.newNotification, 'no');
      expect(state.isNewNotification, false);
    });

    test('copyWith', () {
      final modified = const NotificationState().copyWith(
        isLoading: true,
        currentPage: 3,
        hasMore: false,
        inboxCount: 5,
        draftCount: 2,
        trashCount: 1,
        archiveCount: 10,
        newNotification: 'yes',
        isNewNotification: true,
      );
      expect(modified.isLoading, true);
      expect(modified.currentPage, 3);
      expect(modified.hasMore, false);
      expect(modified.inboxCount, 5);
      expect(modified.draftCount, 2);
      expect(modified.trashCount, 1);
      expect(modified.archiveCount, 10);
      expect(modified.newNotification, 'yes');
      expect(modified.isNewNotification, true);
    });
  });

  // ===== ViewContactState expanded =====
  group('ViewContactState expanded', () {
    test('all defaults', () {
      const state = ViewContactState();
      expect(state.isSubmitting, false);
      expect(state.loadingContactDetails, false);
      expect(state.readingPaneEnabled, false);
      expect(state.token, '');
      expect(state.emails, isEmpty);
      expect(state.contact, isNull);
    });

    test('copyWith with all fields', () {
      final modified = const ViewContactState().copyWith(
        isSubmitting: true,
        loadingContactDetails: true,
        readingPaneEnabled: true,
        token: 'jwt-123',
      );
      expect(modified.isSubmitting, true);
      expect(modified.loadingContactDetails, true);
      expect(modified.readingPaneEnabled, true);
      expect(modified.token, 'jwt-123');
    });
  });

  // ===== EditContactState expanded =====
  group('EditContactState expanded', () {
    test('all defaults', () {
      const state = EditContactState();
      expect(state.isLoading, false);
      expect(state.emailFieldCount, 0);
    });

    test('copyWith with loading', () {
      final modified = const EditContactState().copyWith(
        isLoading: true,
        emailFieldCount: 3,
      );
      expect(modified.isLoading, true);
      expect(modified.emailFieldCount, 3);
    });
  });
}
