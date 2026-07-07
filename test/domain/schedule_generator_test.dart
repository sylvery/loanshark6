import 'package:bookinman/domain/entities/loan.dart';
import 'package:bookinman/domain/entities/value_objects.dart';
import 'package:bookinman/domain/services/interest_calculator.dart';
import 'package:bookinman/domain/services/schedule_generator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ScheduleGenerator', () {
    final calculator = const InterestCalculator();
    final generator = ScheduleGenerator(calculator);

    test('generates installments with correct totals and cadence', () {
      final terms = LoanTerms(
        principal: Money(1000, 'PGK'),
        interestRatePerFortnightPercent: 5,
        repaymentFrequency: RepaymentFrequency.weekly,
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 1, 29),
      );

      final schedule = generator.generate(terms);

      expect(schedule.totalInterest.amount, closeTo(100, 0.001));
      expect(schedule.totalRepayable.amount, closeTo(1100, 0.001));
      expect(schedule.installments.length, 4);
      expect(
        schedule.installments.first.amountDue.amount,
        closeTo(275, 0.001),
      );
      expect(
        schedule.installments[1].dueDate,
        DateTime(2024, 1, 8),
      );
    });

    test('bi-weekly cadence aligns to fortnight due dates', () {
      final terms = LoanTerms(
        principal: Money(2000, 'PGK'),
        interestRatePerFortnightPercent: 10,
        repaymentFrequency: RepaymentFrequency.biWeekly,
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 2, 12),
      );

      final schedule = generator.generate(terms);

      expect(schedule.totalInterest.amount, closeTo(600, 0.001));
      expect(schedule.installments.length, 3);
      expect(schedule.installments[1].dueDate, DateTime(2024, 1, 15));
      expect(schedule.installments[2].dueDate, DateTime(2024, 1, 29));
    });
  });
}
