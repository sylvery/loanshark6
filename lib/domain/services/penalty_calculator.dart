import '../entities/loan.dart';
import '../entities/penalty_policy.dart';
import '../entities/value_objects.dart';

class PenaltyCalculator {
  const PenaltyCalculator();

  int overdueFortnights(DateTime dueDate, DateTime now, int graceDays) {
    final overdueDays = now.difference(dueDate).inDays - graceDays;
    if (overdueDays <= 0) return 0;
    return (overdueDays / 14).ceil();
  }

  Money compute(Money principal, PenaltyPolicy policy, int fortnights) {
    if (!policy.enabled || fortnights <= 0) return Money.zero;
    final flat = Money(policy.flatAmount * fortnights, principal.currencyCode);
    final pct =
        principal * (policy.ratePerFortnightPercent / 100) * fortnights;
    return flat + pct;
  }

  Money penaltyForLoan(
    Loan loan,
    LoanSchedule schedule,
    List<Payment> payments,
    DateTime now,
    PenaltyPolicy policy,
  ) {
    if (!policy.enabled) return Money.zero;
    var maxFortnights = 0;
    for (final inst in schedule.installments) {
      if (inst.isPaid) continue;
      if (!inst.dueDate.isBefore(now)) continue;
      final f = overdueFortnights(inst.dueDate, now, policy.graceDays);
      if (f > maxFortnights) maxFortnights = f;
    }
    return compute(loan.principal, policy, maxFortnights);
  }
}
