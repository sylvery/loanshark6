import 'package:bookinman/domain/entities/loan.dart';
import 'package:bookinman/domain/entities/payment.dart';
import 'package:bookinman/domain/entities/penalty_policy.dart';
import 'package:bookinman/domain/entities/value_objects.dart';
import 'package:bookinman/domain/services/interest_calculator.dart';
import 'package:bookinman/domain/services/loan_computation_service.dart';
import 'package:bookinman/domain/services/portfolio_analytics_service.dart';
import 'package:bookinman/domain/services/schedule_generator.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';

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

PortfolioAnalyticsService _service() => PortfolioAnalyticsService(
      LoanComputationService(ScheduleGenerator(const InterestCalculator())),
    );

void main() {
  group('PortfolioAnalyticsService', () {
    test('aggregates disbursed, collected and status counts', () {
      final service = _service();
      final loan = _sampleLoan();
      final payments = [
        Payment(
          id: 'p1',
          loanId: 'l1',
          amount: Money(200, 'PGK'),
          paidAt: DateTime(2024, 1, 5),
          createdAt: DateTime(2024, 1, 5),
        ),
      ];

      final analytics = service.compute(
        [loan],
        payments,
        const PenaltyPolicy(),
        DateTime(2024, 1, 5),
      );

      expect(analytics.totalDisbursed.amount, 1000);
      expect(analytics.totalCollected.amount, 200);
      expect(analytics.statusCounts[LoanStatus.active], 1);
      expect(analytics.loanCount, 1);
    });

    test('overdue loan contributes to arrears but not PAR30 within grace', () {
      final service = _service();
      final analytics = service.compute(
        [_sampleLoan()],
        [],
        const PenaltyPolicy(),
        DateTime(2024, 1, 10),
      );

      expect(analytics.statusCounts[LoanStatus.overdue], 1);
      expect(analytics.arrearsOutstanding.amount, greaterThan(0));
      expect(analytics.par30Outstanding.amount, 0);
      expect(analytics.par30Ratio, 0);
    });

    test('loans over 30 days overdue are counted in PAR30', () {
      final service = _service();
      final analytics = service.compute(
        [_sampleLoan()],
        [],
        const PenaltyPolicy(),
        DateTime(2024, 3, 1),
      );

      expect(analytics.arrearsOutstanding.amount, greaterThan(0));
      expect(
        analytics.par30Outstanding.amount,
        analytics.totalOutstanding.amount,
      );
      expect(analytics.par30Ratio, 1);
    });

    test('monthlyTrends returns one entry per month up to now', () {
      final service = _service();
      final now = DateTime.now();
      final loan = _sampleLoan().copyWith(
        id: 'm1',
        startDate: DateTime(now.year, now.month, 15),
      );
      final payment = Payment(
        id: 'p1',
        loanId: 'm1',
        amount: Money(200, 'PGK'),
        paidAt: DateTime(now.year, now.month, 20),
        createdAt: DateTime.now(),
      );

      final trends = service.monthlyTrends([loan], [payment], months: 12);

      expect(trends.length, 12);
      final latest = trends.last;
      expect(latest.label, DateFormat('MMM yyyy').format(now));
      expect(latest.disbursed.amount, 1000);
      expect(latest.collected.amount, 200);
    });
  });
}
