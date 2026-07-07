import '../entities/loan.dart';
import '../entities/value_objects.dart';
import 'loan_computation_service.dart';

class DueDateService {
  const DueDateService(this._computation);

  final LoanComputationService _computation;

  List<ScheduledInstallment> upcoming(
    LoanSchedule schedule,
    DateTime now, {
    int withinDays = 3,
  }) {
    return schedule.installments
        .where((i) =>
            !i.isPaid &&
            !i.dueDate.isBefore(now) &&
            i.dueDate.difference(now).inDays <= withinDays)
        .toList();
  }

  List<ScheduledInstallment> overdue(LoanSchedule schedule, DateTime now) =>
      schedule.installments
          .where((i) => !i.isPaid && i.dueDate.isBefore(now))
          .toList();

  DateTime? nextDueDate(LoanSchedule schedule, DateTime now) {
    final future = schedule.installments
        .where((i) => !i.isPaid && !i.dueDate.isBefore(now));
    if (future.isEmpty) return null;
    return future
        .map((i) => i.dueDate)
        .reduce((a, b) => a.isBefore(b) ? a : b);
  }

  DateTime? nextDueDateFor(Loan loan, DateTime now) =>
      nextDueDate(_computation.scheduleFor(loan), now);
}
