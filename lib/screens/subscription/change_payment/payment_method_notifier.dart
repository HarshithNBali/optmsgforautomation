import 'dart:async';

import 'package:optmsg/common/utilites/logger.dart';
import 'package:optmsg/common/utilites/stripe_url_validator.dart';
import 'package:optmsg/screens/subscription/change_payment/payment_method_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:optmsg/screens/auth/auth_riverpod/auth_notifier.dart';

import '../../../services/api_service.dart';
import '../../../services/common_service.dart';
import '../../../services/socket_service.dart';
import '../../../services/storage_service.dart';
import 'package:optmsg/webPackerHandler/mobile_check_out.dart'
    if (dart.library.js_interop) 'package:optmsg/webPackerHandler/web_check_out.dart';

final paymentMethodProvider =
    NotifierProvider.autoDispose<PaymentMethodNotifier, PaymentMethodState>(
        PaymentMethodNotifier.new);

class PaymentMethodNotifier extends Notifier<PaymentMethodState> {
  final SecureStorageService secureStorageService = SecureStorageService();

  StreamSubscription? _addCardSub;
  Timer? _addCardTimeout;
  String token = "";
  bool _disposed = false;

  @override
  PaymentMethodState build() {
    _disposed = false;
    ref.onDispose(() {
      _disposed = true;
      _addCardSub?.cancel();
      _addCardTimeout?.cancel();
    });
    _init();
    return const PaymentMethodState();
  }

  Future<void> _init() async {
    await userToken();
    if (_disposed) return;
    await getCards();
    if (_disposed) return;
    _setupSocket();
  }

  void _setupSocket() {
    _addCardSub =
        SocketService().onEvent('addCardSuccess').listen((newMessage) async {
      if (_disposed) return;
      if (newMessage['token'] != token) return;
      _addCardTimeout?.cancel();
      printLog("addCardSuccess", newMessage);
      state = state.copyWith(isLoading: false);

      if (newMessage['success'] == true) {
        await getCards();
      } else {
        CommonService.animatedToast(
            'Something went wrong please try again.', 'error');
      }
    });
  }

  Future<void> userToken() async {
    final userData = ref.read(authProvider).userData ?? {};
    token = userData['token'] ?? "";
  }

  // ================= GET CARDS =================

  Future<void> getCards() async {
    state = state.copyWith(isLoading: true);

    try {
      final resp = await ApiService().get('plan/list-card');
      if (_disposed) return;
      if (resp['data'] != null && resp['success']) {
        final list = resp['data']['list']['data'] as List;
        final cards = List<Map<String, dynamic>>.from(list);

        state = state.copyWith(
          isLoading: false,
          cardData: cards,
          showNoData: cards.isEmpty,
        );
      } else {
        state = state.copyWith(isLoading: false);
        CommonService.animatedToast(resp['message'], 'error');
      }
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }

  // ================= DELETE =================

  Future<void> deleteCard(String id) async {
    state = state.copyWith(isLoading: true);

    try {
      final resp = await ApiService()
          .post('plan/delete-card-stripe', {'paymentMethodId': id});
      if (_disposed) return;
      if (resp['success']) {
        CommonService.animatedToast('Card Deleted', 'success');
        await getCards();
      } else {
        state = state.copyWith(isLoading: false);
        CommonService.animatedToast(resp['message'], 'error');
      }
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }

  // ================= ADD =================

  Future<void> addCard() async {
    if (state.cardData.isNotEmpty) {
      CommonService.animatedToast(
          'First please remove previous card then new one', 'warning');
      // Bug 13: Close pre-opened popup on early return
      CheckOutImp().closeAndClearPendingTab();
      return;
    }

    state = state.copyWith(isLoading: true);

    try {
      final resp = await ApiService().get('plan/list-add-card-url');
      if (_disposed) return;
      if (resp['success']) {
        final String? url = resp['data']['url'] as String?;
        if (!isValidStripeUrl(url)) {
          state = state.copyWith(isLoading: false);
          CommonService.animatedToast('Something went wrong', 'error');
          printLog('PaymentMethodNotifier addCard',
              'Rejected invalid URL: $url');
          CheckOutImp().closeAndClearPendingTab();
          return;
        }

        const windowFeatures =
            "width=500,height=500,menubar=no,toolbar=no,location=no";

        CheckOutImp().addNewCard(url!, windowFeatures);
        // H8: Timeout so spinner doesn't persist if socket event never arrives
        _addCardTimeout?.cancel();
        _addCardTimeout = Timer(const Duration(seconds: 30), () {
          if (!_disposed && state.isLoading) {
            state = state.copyWith(isLoading: false);
          }
        });
      } else {
        state = state.copyWith(isLoading: false);
        CommonService.animatedToast(resp['message'], 'error');
        CheckOutImp().closeAndClearPendingTab();
      }
    } catch (_) {
      state = state.copyWith(isLoading: false);
      CheckOutImp().closeAndClearPendingTab();
    }
  }
}
