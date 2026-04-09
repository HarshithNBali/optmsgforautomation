import 'package:optmsg/model/subscription_status.dart';
import 'package:optmsg/screens/subscription/subscription_riverpod/subscription_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:optmsg/screens/auth/auth_riverpod/auth_notifier.dart';

import '../../../common/app_manger/app_cache.dart';
import '../../../services/api_service.dart';
import '../../../services/common_service.dart';
final subscriptionProvider =
    NotifierProvider<SubscriptionNotifier, SubscriptionState>(
        SubscriptionNotifier.new);

class SubscriptionNotifier extends Notifier<SubscriptionState> {
  bool _disposed = false;

  @override
  SubscriptionState build() {
    _disposed = false;
    _initialized = false;
    ref.onDispose(() => _disposed = true);
    return const SubscriptionState();
  }

  bool _initialized = false;

  Future<void> init(Map<String, dynamic> incoming) async {
    if (_initialized) return;
    _initialized = true;

    Map<String, dynamic> map =
        await AppCache().getSubscriptionCacheData() ?? {};
    final cache = map['listData'];
    final data = (cache ?? incoming) as Map<String, dynamic>;

    if (_disposed) return;
    state = state.copyWith(data: data);
    await _loadUser();
  }

  Future<void> _loadUser() async {
    final data = ref.read(authProvider).userData;
    if (data != null && data['user'] != null) {
      state = state.copyWith(isFreeUser: data['user']['isFreeUser'] == true);
    }
  }

  /// Always-fresh remaining days, computed from current state data.
  int get remainingDays {
    if (state.data.isEmpty || state.data['ends'] == null) return 0;
    final endDate =
        DateTime.fromMillisecondsSinceEpoch(state.data['ends'] * 1000);
    if (endDate.isBefore(DateTime.now())) return 0;
    return endDate.difference(DateTime.now()).inDays;
  }

  /// H-STRIPE-02: Returns the derived subscription status enum.
  SubscriptionStatus get subscriptionStatus {
    final userData = ref.read(authProvider).userData;
    return SubscriptionStatus.fromUserData(userData?['user'] as Map<String, dynamic>?);
  }

  String status() {
    if (state.data.isEmpty) return "";
    return subscriptionStatus.label;
  }

  Future<void> cancelMembership() async {
    state = state.copyWith(isLoading: true);

    try {
      final resp = await ApiService().get('plan/cancel-subscription');
      if (_disposed) return;

      if (resp['success']) {
        CommonService.animatedToast(resp['message'], 'success');
      } else {
        CommonService.animatedToast(resp['message'], 'error');
      }
    } catch (_) {
      if (_disposed) return;
      CommonService.animatedToast("Network error", 'error');
    }

    state = state.copyWith(isLoading: false);
  }
}
