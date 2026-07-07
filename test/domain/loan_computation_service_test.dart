import 'package:bookinman/domain/entities/loan.dart';
import 'package:bookinman/domain/entities/payment.dart';
import 'package:bookinman/domain/entities/value_objects.dart';
import 'package:bookinman/domain/services/interest_calculator.dart';
import 'package:bookinman/domain/services/loan_computation_service.dart';
import 'package:bookinman/domain/services/schedule_generator.dart';
import 'package:flutter_test/flutter_test.dart';

Loan _sampleLoan() => Loan(
      id: 'l1',
      customerId: 'c1',
      principal: Money(1000, 'PGK'),
      interestRatePerFortnightPercent: 5,
      repaymentFrequency: RepaymentFrequency.weekly,
      startDate: DateTime(2024, 1, 1),
      endDate: DateTime(2024, 1, 29),
      createdAt: DateTime(2024, 1, 1),
    );

void main() {
  group('LoanComputationService', () {
    final service = LoanComputationService(
      ScheduleGenerator(const InterestCalculator()),
    );

    test('marks loan paid when fully repaid', () {
      final loan = _sampleLoan();
      final schedule = service.scheduleFor(loan);
      final payments = [
        Payment(
          id: 'p1',
          loanId: 'l1',
          amount: schedule.totalRepayable,
          paidAt: DateTime(2024, 2, 1),
          createdAt: DateTime(2024, 2, 1),
        ),
      ];

      expect(
        service.status(loan, schedule, payments, DateTime(2024, 2, 1)),
        LoanStatus.paid,
      );
      expect(service.outstanding(schedule, payments).amount, 0);
    });

    test('marks loan overdue when an installment is past due unpaid', () {
      final loan = _sampleLoan();
      final schedule = service.scheduleFor(loan);
      final payments = <Payment>[];

      expect(
        service.status(loan, schedule, payments, DateTime(2024, 1, 10)),
        LoanStatus.overdue,
      );
      expect(service.outstanding(schedule, payments).amount, closeTo(1100, 0.001));
    });

    test('marks loan active before first due date', () {
      final loan = _sampleLoan();
      final schedule = service.scheduleFor(loan);
      final payments = <Payment>[];

      expect(
        service.status(loan, schedule, payments, DateTime(2024, 1, 1)),
        LoanStatus.active,
      );
    });

    test('flags installments paid in order', () {
      final loan = _sampleLoan();
      final schedule = service.scheduleFor(loan);
      final per = schedule.installments.first.amountDue;
      final payments = [
        Payment(
          id: 'p1',
          loanId: 'l1',
          amount: per,
          paidAt: DateTime(2024, 1, 2),
          createdAt: DateTime(2024, 1, 2),
        ),
      ];

      final flagged = service.withPaidFlags(schedule, payments);
      expect(flagged.first.isPaid, isTrue);
      expect(flagged[1].isPaid, isFalse);
    });
  });
}
