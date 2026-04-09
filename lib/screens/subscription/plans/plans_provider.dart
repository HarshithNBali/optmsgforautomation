import 'package:optmsg/model/plan_list_model.dart';
import 'package:optmsg/services/api_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// L-08: Shared plan ranking so sort order is consistent across providers.
int planRank(String title) {
  final t = title.toLowerCase();
  if (t.contains('reader')) return 0;
  if (t.contains('annual')) return 1;
  return 2;
}

class _SelectedPlanTypeNotifier extends Notifier<String> {
  @override
  String build() => 'annual';

  void set(String value) => state = value;
}

final selectedPlanTypeProvider =
    NotifierProvider<_SelectedPlanTypeNotifier, String>(_SelectedPlanTypeNotifier.new);

final plansProvider = FutureProvider.autoDispose<PlanListModel>((ref) async {
  final resp = await ApiService().get('plan/list');

  final model = PlanListModel.fromJson(resp);

  /// sorting — L-08: use shared ranking function
  model.data.plans.sort((a, b) => planRank(a.title).compareTo(planRank(b.title)));

  return model;
});
