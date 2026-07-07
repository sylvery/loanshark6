import '../entities/loan.dart';
import '../entities/value_objects.dart';
import 'interest_calculator.dart';

class ScheduleGenerator {
  const ScheduleGenerator(this._interestCalculator);

  final InterestCalculator _interestCalculator;

  int installmentCount(LoanTerms terms) {
    final days = terms.endDate.difference(terms.startDate).inDays;
    if (days <= 0) return 1;
    return (days / terms.repaymentFrequency.days).ceil();
  }

  LoanSchedule generate(LoanTerms terms) {
    final totalInterest = _interestCalculator.totalInterest(
      terms.principal,
      terms.interestRatePerFortnightPercent,
      terms.startDate,
      terms.endDate,
    );
    final totalRepayable = terms.principal + totalInterest;
    final count = installmentCount(terms);

    final perInstallment = totalRepayable * (1 / count);
    final principalPer = terms.principal * (1 / count);
    final interestPer = totalInterest * (1 / count);

    final installments = <ScheduledInstallment>[];
    for (var i = 0; i < count; i++) {
      final dueDate = terms.startDate.add(
        Duration(days: terms.repaymentFrequency.days * i),
      );
      installments.add(
        ScheduledInstallment(
          index: i,
          dueDate: dueDate,
          amountDue: perInstallment,
          principalComponent: principalPer,
          interestComponent: interestPer,
        ),
      );
    }

    return LoanSchedule(
      installments: installments,
      totalInterest: totalInterest,
      totalRepayable: totalRepayable,
    );
  }
}
