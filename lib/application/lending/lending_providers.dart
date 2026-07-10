import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/penalty_policy.dart';
import '../../domain/ports/settings_repository.dart';

final penaltyPolicyControllerProvider =
    StateNotifierProvider<PenaltyPolicyController, PenaltyPolicy>(
  (ref) => PenaltyPolicyController(ref),
);

class PenaltyPolicyController extends StateNotifier<PenaltyPolicy> {
  PenaltyPolicyController(this._ref) : super(const PenaltyPolicy()) {
    _load();
  }

  final Ref _ref;

  Future<void> _load() async {
    final policy =
        await _ref.read(settingsRepositoryProvider).getPenaltyPolicy();
    state = policy;
  }

  Future<void> update(PenaltyPolicy policy) async {
    state = policy;
    await _ref.read(settingsRepositoryProvider).setPenaltyPolicy(policy);
  }
}
