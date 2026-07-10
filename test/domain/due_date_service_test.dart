import 'package:bookinman/domain/entities/loan.dart';
import 'package:bookinman/domain/entities/value_objects.dart';
import 'package:bookinman/domain/services/due_date_service.dart';
import 'package:bookinman/domain/services/loan_computation_service.dart';
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
  group('DueDateService', () {
    final service = DueDateService(
      LoanComputationService(ScheduleGenerator(const InterestCalculator())),
    );
    final now = DateTime(2024, 6, 15);

    test('nextDueDate returns earliest unpaid future installment', () {
      final schedule = _schedule([
        _inst(DateTime(2024, 6, 10), paid: true),
        _inst(DateTime(2024, 6, 20)),
        _inst(DateTime(2024, 6, 25)),
      ]);
      expect(service.nextDueDate(schedule, now), DateTime(2024, 6, 20));
    });

    test('nextDueDate is null when all paid', () {
      final schedule = _schedule([
        _inst(DateTime(2024, 6, 10), paid: true),
        _inst(DateTime(2024, 6, 12), paid: true),
      ]);
      expect(service.nextDueDate(schedule, now), isNull);
    });

    test('overdue lists only past unpaid installments', () {
      final schedule = _schedule([
        _inst(DateTime(2024, 6, 10), paid: true),
        _inst(DateTime(2024, 6, 12)),
        _inst(DateTime(2024, 6, 20)),
      ]);
      final overdue = service.overdue(schedule, now);
      expect(overdue.length, 1);
      expect(overdue.first.dueDate, DateTime(2024, 6, 12));
    });

    test('upcoming within window excludes past and far-future', () {
      final schedule = _schedule([
        _inst(DateTime(2024, 6, 17)),
        _inst(DateTime(2024, 6, 30)),
        _inst(DateTime(2024, 6, 10), paid: true),
      ]);
      final upcoming = service.upcoming(schedule, now, withinDays: 3);
      expect(upcoming.length, 1);
      expect(upcoming.first.dueDate, DateTime(2024, 6, 17));
    });

    test('nextDueDateFor builds schedule from a loan', () {
      final loan = Loan(
        id: 'l1',
        customerId: 'c1',
        principal: Money(1000, 'PGK'),
        interestRatePerFortnightPercent: 5,
        repaymentFrequency: RepaymentFrequency.weekly,
        startDate: DateTime(2024, 6, 1),
        endDate: DateTime(2024, 6, 29),
        createdAt: DateTime(2024, 6, 1),
      );
      final next = service.nextDueDateFor(loan, DateTime(2024, 6, 2));
      expect(next, DateTime(2024, 6, 8));
    });
  });
}
