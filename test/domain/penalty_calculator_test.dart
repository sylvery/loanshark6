import 'package:bookinman/domain/entities/loan.dart';
import 'package:bookinman/domain/entities/penalty_policy.dart';
import 'package:bookinman/domain/entities/value_objects.dart';
import 'package:bookinman/domain/services/loan_computation_service.dart';
import 'package:bookinman/domain/services/penalty_calculator.dart';
import 'package:bookinman/domain/services/schedule_generator.dart';
import 'package:flutter_test/flutter_test.dart';

ScheduledInstallment _inst(DateTime due, {bool paid = false}) => ScheduledInstallment(
      index: 0,
      dueDate: due,
      amountDue: Money(100, 'PGK'),
      principalComponent: Money(100, 'PGK'),
      interestComponent: Money(0, 'PGK'),
      isPaid: paid,
    );

LoanSchedule _schedule(List<ScheduledInstallment> installments) => LoanSchedule(
      installments: installments,
      totalInterest: Money(0, 'PGK'),
      totalRepayable: Money(0, 'PGK'),
    );

void main() {
  group('PenaltyCalculator', () {
    final calc = const PenaltyCalculator();

    test('overdueFortnights respects grace period', () {
      final due = DateTime(2024, 6, 1);
      final now = DateTime(2024, 6, 20);
      expect(calc.overdueFortnights(due, now, 0), 2);
      expect(calc.overdueFortnights(due, now, 5), 1);
      expect(calc.overdueFortnights(due, now, 30), 0);
    });

    test('compute sums flat and percentage components', () {
      final policy = PenaltyPolicy(
        enabled: true,
        flatAmount: 10,
        ratePerFortnightPercent: 5,
      );
      final penalty = calc.compute(Money(1000, 'PGK'), policy, 2);
      expect(penalty.amount, closeTo(120, 0.001));
    });

    test('penaltyForLoan returns zero when disabled', () {
      final loan = Loan(
        id: 'l1',
        customerId: 'c1',
        principal: Money(1000, 'PGK'),
        interestRatePerFortnightPercent: 0,
        repaymentFrequency: RepaymentFrequency.weekly,
        startDate: DateTime(2024, 6, 1),
        endDate: DateTime(2024, 6, 30),
        createdAt: DateTime(2024, 6, 1),
      );
      final schedule = _schedule([
        _inst(DateTime(2024, 6, 10), paid: false),
      ]);
      final penalty = calc.penaltyForLoan(
        loan,
        schedule,
        const [],
        DateTime(2024, 6, 20),
        const PenaltyPolicy(enabled: false),
      );
      expect(penalty.amount, 0);
    });
  });

  group('LoanComputationService.allocations', () {
    final service = LoanComputationService(
      ScheduleGenerator(const InterestCalculator()),
    );

    test('allocates payment to interest before principal', () {
      final schedule = _schedule([
        _inst(DateTime(2024, 6, 10)),
      ]);
      final payment = Payment(
        id: 'p1',
        loanId: 'l1',
        amount: Money(150, 'PGK'),
        paidAt: DateTime(2024, 6, 5),
        createdAt: DateTime(2024, 6, 5),
      );
      final alloc = service.allocations(schedule, [payment]);
      expect(alloc.first.paidInterest.amount, 0);
      expect(alloc.first.paidPrincipal.amount, 150);
      expect(alloc.first.isPaid, isTrue);
    });

    test('marks installment unpaid when partial', () {
      final schedule = _schedule([
        _inst(DateTime(2024, 6, 10)),
      ]);
      final payment = Payment(
        id: 'p1',
        loanId: 'l1',
        amount: Money(50, 'PGK'),
        paidAt: DateTime(2024, 6, 5),
        createdAt: DateTime(2024, 6, 5),
      );
      final alloc = service.allocations(schedule, [payment]);
      expect(alloc.first.isPaid, isFalse);
      expect(alloc.first.paidPrincipal.amount, 50);
    });
  });
}
