import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/notifications/notification_service.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_helpers.dart';
import '../../domain/entities/customer.dart';
import '../../domain/entities/loan_reminder_input.dart';
import '../../domain/entities/reminder_policy.dart';
import '../../domain/entities/value_objects.dart';
import '../../domain/ports/settings_repository.dart';
import '../../domain/services/due_date_service.dart';
import '../../domain/services/notification_schedule_planner.dart';
import '../customer/customer_providers.dart';
import '../loan/loan_providers.dart';

final reminderPolicyControllerProvider =
    StateNotifierProvider<ReminderPolicyController, ReminderPolicy>(
  (ref) => ReminderPolicyController(ref),
);

class ReminderPolicyController extends StateNotifier<ReminderPolicy> {
  ReminderPolicyController(this._ref) : super(const ReminderPolicy()) {
    _load();
  }

  final Ref _ref;

  Future<void> _load() async {
    final policy =
        await _ref.read(settingsRepositoryProvider).getReminderPolicy();
    state = policy;
  }

  Future<void> update(ReminderPolicy policy) async {
    state = policy;
    await _ref.read(settingsRepositoryProvider).setReminderPolicy(policy);
  }
}

final schedulerControllerProvider =
    StateNotifierProvider<SchedulerController, SchedulerState>(
  (ref) => SchedulerController(ref),
);

class SchedulerState {
  const SchedulerState({this.scheduledCount = 0, this.error});
  final int scheduledCount;
  final String? error;
}

class SchedulerController extends StateNotifier<SchedulerState> {
  SchedulerController(this._ref) : super(const SchedulerState());

  final Ref _ref;

  Future<void> reschedule(List<LoanReminderInput> inputs) async {
    final policy = _ref.read(reminderPolicyControllerProvider);
    final service = _ref.read(notificationServiceProvider);
    await service.cancelAll();

    if (!policy.enabled) {
      state = const SchedulerState();
      return;
    }

    final formatter = const CurrencyFormatter();

    if (policy.dailyDigest) {
      final count = inputs.where((i) =>
          i.status == LoanStatus.overdue ||
          (i.nextDueDate != null && !i.nextDueDate!.isBefore(DateTime.now()))).length;
      if (count > 0) {
        await service.scheduleDailyDigest(
          id: 1,
          title: 'BookinMan reminders',
          body: 'You have $count loan(s) due or overdue.',
        );
      }
      state = SchedulerState(scheduledCount: count > 0 ? 1 : 0);
      return;
    }

    final planner = const NotificationSchedulePlanner();
    final dueDateService = const DueDateService(
      LoanComputationService(
        ScheduleGenerator(InterestCalculator()),
      ),
    );
    var id = 100;
    var count = 0;
    for (final input in inputs) {
      if (input.nextDueDate == null) continue;
      final times = planner.scheduledTimes(
        dueDate: input.nextDueDate!,
        policy: policy,
        now: DateTime.now(),
      );
      for (final t in times) {
        await service.scheduleExact(
          id: id++,
          title: 'Loan reminder',
          body:
              '${input.customerName}: ${formatter.format(input.outstanding)} '
              'due ${DateHelpers.format(t)}',
          scheduledDate: t,
        );
        count++;
      }
    }
    state = SchedulerState(scheduledCount: count);
  }
}

final notificationAutoScheduleProvider = Provider<void>((ref) {
  void rescheduleNow() {
    final details = ref.read(allLoanDetailsProvider).valueOrNull;
    if (details == null) return;
    final customers = ref.read(customerListProvider).valueOrNull ?? <Customer>[];
    final nameById = {for (final c in customers) c.id: c.name};
    final inputs = details
        .map(
          (d) => LoanReminderInput(
            loanId: d.loan.id,
            customerName: nameById[d.loan.customerId] ?? 'Unknown',
            outstanding: d.outstanding,
            nextDueDate:
                const DueDateService(LoanComputationService(ScheduleGenerator(InterestCalculator())))
                    .nextDueDate(d.schedule, DateTime.now()),
            status: d.status,
          ),
        )
        .toList();
    ref.read(schedulerControllerProvider.notifier).reschedule(inputs);
  }

  ref.listen(reminderPolicyControllerProvider, (_, __) => rescheduleNow());
  ref.listen(allLoanDetailsProvider, (_, __) => rescheduleNow());
});
