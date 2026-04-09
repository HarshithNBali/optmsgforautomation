import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../model/plan_list_model.dart';
import '../../../services/api_service.dart';
import '../plans/plans_provider.dart';

final changeSubscriptionProvider =
FutureProvider.autoDispose<({PlanListModel plans, String currentPlanType})>((ref) async {
  /// 1️⃣ Get current plan
  String currentPlanType = '';

  final paymentResp = await ApiService().post('user/payment-list', {});
  if (paymentResp['success'] == true && paymentResp['data'] != null) {
    final data = paymentResp['data'] as Map<String, dynamic>;
    final list = data['paymentList'] as List?;
    if (list != null && list.isNotEmpty) {
      final plan = list[0]['plan'] as Map<String, dynamic>?;
      currentPlanType = plan?['type'] ?? plan?['title'] ?? '';
    }
  }

  /// 2️⃣ Get plans
  final resp = await ApiService().get('plan/list');
  if (resp['success'] != true) {
    throw resp['message'] ?? 'Failed to load plans';
  }
  final model = PlanListModel.fromJson(resp);

  /// sorting
  model.data.plans.sort((a, b) => planRank(a.title).compareTo(planRank(b.title)));

  return (plans: model, currentPlanType: currentPlanType);
});

final cancelMembershipProvider =
FutureProvider.autoDispose<void>((ref) async {
  final resp = await ApiService().get('plan/cancel-subscription');

  if (!resp['success']) {
    throw resp['message'];
  }
});
