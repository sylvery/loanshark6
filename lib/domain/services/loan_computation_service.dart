import '../entities/loan.dart';
import '../entities/payment.dart';
import '../entities/value_objects.dart';
import 'schedule_generator.dart';

class LoanComputationService {
  const LoanComputationService(this._scheduleGenerator);

  final ScheduleGenerator _scheduleGenerator;

  LoanSchedule scheduleFor(Loan loan) => _scheduleGenerator.generate(loan.terms);

  Money totalPaid(List<Payment> payments) =>
      payments.fold(Money.zero, (sum, p) => sum + p.amount);

  Money outstanding(LoanSchedule schedule, List<Payment> payments) {
    final paid = totalPaid(payments);
    final remaining = schedule.totalRepayable - paid;
    return remaining.amount < 0 ? Money.zero : remaining;
  }

  List<ScheduledInstallment> withPaidFlags(
    LoanSchedule schedule,
    List<Payment> payments,
  ) {
    var remaining = totalPaid(payments);
    return schedule.installments.map((installment) {
      if (remaining >= installment.amountDue) {
        remaining = remaining - installment.amountDue;
        return installment.markPaid();
      }
      return installment;
    }).toList();
  }

  LoanStatus status(
    Loan loan,
    LoanSchedule schedule,
    List<Payment> payments,
    DateTime now,
  ) {
    if (loan.writtenOff) return LoanStatus.writtenOff;
    final flagged = withPaidFlags(schedule, payments);
    if (flagged.every((i) => i.isPaid)) return LoanStatus.paid;
    final overdue =
        flagged.any((i) => !i.isPaid && i.dueDate.isBefore(now));
    return overdue ? LoanStatus.overdue : LoanStatus.active;
  }
}
