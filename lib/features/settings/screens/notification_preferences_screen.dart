import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../application/notifications/notification_providers.dart';
import '../../domain/entities/reminder_policy.dart';

class NotificationPreferencesScreen extends ConsumerStatefulWidget {
  const NotificationPreferencesScreen({super.key});

  @override
  ConsumerState<NotificationPreferencesScreen> createState() =>
      _NotificationPreferencesScreenState();
}

class _NotificationPreferencesScreenState
    extends ConsumerState<NotificationPreferencesScreen> {
  @override
  Widget build(BuildContext context) {
    final policy = ref.watch(reminderPolicyControllerProvider);
    final scheduled = ref.watch(schedulerControllerProvider).scheduledCount;

    return Scaffold(
      appBar: AppBar(title: const Text('Notification Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            title: const Text('Enable reminders'),
            value: policy.enabled,
            onChanged: (v) => _update(policy.copyWith(enabled: v)),
          ),
          SwitchListTile(
            title: const Text('Daily digest'),
            subtitle: const Text('One summary per day instead of per-loan'),
            value: policy.dailyDigest,
            onChanged: policy.enabled
                ? (v) => _update(policy.copyWith(dailyDigest: v))
                : null,
          ),
          const Divider(),
          _NumberTile(
            label: 'Remind days before due',
            value: policy.preDueDays,
            min: 0,
            max: 7,
            enabled: policy.enabled && !policy.dailyDigest,
            onChanged: (v) => _update(policy.copyWith(preDueDays: v)),
          ),
          _NumberTile(
            label: 'Re-alert every (days) when overdue',
            value: policy.overdueRealertDays,
            min: 1,
            max: 14,
            enabled: policy.enabled && !policy.dailyDigest,
            onChanged: (v) => _update(policy.copyWith(overdueRealertDays: v)),
          ),
          const SizedBox(height: 16),
          Text(
            scheduled > 0
                ? '$scheduled reminder(s) scheduled.'
                : 'No reminders scheduled.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  void _update(ReminderPolicy policy) {
    ref.read(reminderPolicyControllerProvider.notifier).update(policy);
  }
}

class _NumberTile extends StatelessWidget {
  const _NumberTile({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.enabled,
    required this.onChanged,
  });

  final String label;
  final int value;
  final int min;
  final int max;
  final bool enabled;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(label),
      subtitle: Slider(
        value: value.toDouble(),
        min: min.toDouble(),
        max: max.toDouble(),
        divisions: max - min,
        label: '$value',
        onChanged: enabled ? (v) => onChanged(v.round()) : null,
      ),
      trailing: Text('$value'),
    );
  }
}
