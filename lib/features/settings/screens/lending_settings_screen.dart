import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/lending/lending_providers.dart';
import '../../domain/entities/penalty_policy.dart';

class LendingSettingsScreen extends ConsumerStatefulWidget {
  const LendingSettingsScreen({super.key});

  @override
  ConsumerState<LendingSettingsScreen> createState() =>
      _LendingSettingsScreenState();
}

class _LendingSettingsScreenState
    extends ConsumerState<LendingSettingsScreen> {
  late final TextEditingController _flat;
  late final TextEditingController _rate;
  late final TextEditingController _grace;

  @override
  void initState() {
    super.initState();
    final p = ref.read(penaltyPolicyControllerProvider);
    _flat = TextEditingController(text: p.flatAmount.toString());
    _rate = TextEditingController(text: p.ratePerFortnightPercent.toString());
    _grace = TextEditingController(text: p.graceDays.toString());
  }

  @override
  void dispose() {
    _flat.dispose();
    _rate.dispose();
    _grace.dispose();
    super.dispose();
  }

  void _save(PenaltyPolicy current) {
    final policy = current.copyWith(
      flatAmount: double.tryParse(_flat.text) ?? 0,
      ratePerFortnightPercent: double.tryParse(_rate.text) ?? 0,
      graceDays: int.tryParse(_grace.text) ?? 0,
    );
    ref.read(penaltyPolicyControllerProvider.notifier).update(policy);
  }

  @override
  Widget build(BuildContext context) {
    final policy = ref.watch(penaltyPolicyControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Lending & Penalty Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            title: const Text('Enable late penalties'),
            value: policy.enabled,
            onChanged: (v) =>
                ref.read(penaltyPolicyControllerProvider.notifier).update(
                      policy.copyWith(enabled: v),
                    ),
          ),
          const Divider(),
          TextFormField(
            controller: _flat,
            decoration: const InputDecoration(
              labelText: 'Flat penalty (PGK) per fortnight overdue',
            ),
            keyboardType: TextInputType.number,
            enabled: policy.enabled,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _rate,
            decoration: const InputDecoration(
              labelText: 'Penalty rate (% of principal) per fortnight',
            ),
            keyboardType: TextInputType.number,
            enabled: policy.enabled,
          ),
          const SizedBox(height: 12),
          ListTile(
            title: const Text('Grace period (days)'),
            subtitle: Slider(
              value: policy.graceDays.toDouble(),
              min: 0,
              max: 14,
              divisions: 14,
              label: '${policy.graceDays}',
              onChanged: policy.enabled
                  ? (v) => ref
                      .read(penaltyPolicyControllerProvider.notifier)
                      .update(policy.copyWith(graceDays: v.round()))
                  : null,
            ),
            trailing: Text('${policy.graceDays}'),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: policy.enabled ? () => _save(policy) : null,
            child: const Text('Save penalty policy'),
          ),
        ],
      ),
    );
  }
}
