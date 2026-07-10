import 'package:intl/intl.dart';

import '../../entities/loan.dart';
import '../../entities/payment.dart';
import '../../entities/penalty_policy.dart';
import '../../entities/value_objects.dart';
import '../services/loan_computation_service.dart';

class MonthlyTrend {
  const MonthlyTrend({
    required this.label,
    required this.disbursed,
    required this.collected,
  });

  final String label;
  final Money disbursed;
  final Money collected;
}

class PortfolioAnalytics {
  const PortfolioAnalytics({
    required this.totalDisbursed,
    required this.totalCollected,
    required this.totalOutstanding,
    required this.arrearsOutstanding,
    required this.par30Outstanding,
    required this.expectedToDate,
    required this.collectedToDate,
    required this.collectionRate,
    required this.par30Ratio,
    required this.statusCounts,
    required this.loanCount,
  });

  final Money totalDisbursed;
  final Money totalCollected;
  final Money totalOutstanding;
  final Money arrearsOutstanding;
  final Money par30Outstanding;
  final Money expectedToDate;
  final Money collectedToDate;
  final double collectionRate;
  final double par30Ratio;
  final Map<LoanStatus, int> statusCounts;
  final int loanCount;
}

class PortfolioAnalyticsService {
  const PortfolioAnalyticsService(this._computation);

  final LoanComputationService _computation;

  PortfolioAnalytics compute(
    List<Loan> loans,
    List<Payment> payments,
    PenaltyPolicy policy,
    DateTime now,
  ) {
    final statusCounts = {
      for (final status in LoanStatus.values) status: 0,
    };
    var totalDisbursed = Money.zero;
    var totalCollected = Money.zero;
    var totalOutstanding = Money.zero;
    var arrearsOutstanding = Money.zero;
    var par30Outstanding = Money.zero;
    var expectedToDate = Money.zero;

    for (final payment in payments) {
      totalCollected += payment.amount;
    }

    for (final loan in loans) {
      totalDisbursed += loan.principal;
      final schedule = _computation.scheduleFor(loan);
      final loanPayments =
          payments.where((p) => p.loanId == loan.id).toList();
      final status =
          _computation.status(loan, schedule, loanPayments, now);
      statusCounts[status] = (statusCounts[status] ?? 0) + 1;

      for (final installment in schedule.installments) {
        if (!installment.dueDate.isAfter(now)) {
          expectedToDate += installment.amountDue;
        }
      }

      if (status.isOpen) {
        final outstanding = _computation.outstandingWithPenalty(
          loan,
          schedule,
          loanPayments,
          now,
          policy,
        );
        totalOutstanding += outstanding;
        if (status == LoanStatus.overdue) {
          arrearsOutstanding += outstanding;
          if (_daysOverdue(schedule, loanPayments, now) > 30) {
            par30Outstanding += outstanding;
          }
        }
      }
    }

    final collectionRate = expectedToDate.amount <= 0
        ? 0.0
        : (totalCollected.amount / expectedToDate.amount).clamp(0.0, 1.0);
    final par30Ratio = totalOutstanding.amount <= 0
        ? 0.0
        : (par30Outstanding.amount / totalOutstanding.amount).clamp(0.0, 1.0);

    return PortfolioAnalytics(
      totalDisbursed: totalDisbursed,
      totalCollected: totalCollected,
      totalOutstanding: totalOutstanding,
      arrearsOutstanding: arrearsOutstanding,
      par30Outstanding: par30Outstanding,
      expectedToDate: expectedToDate,
      collectedToDate: totalCollected,
      collectionRate: collectionRate,
      par30Ratio: par30Ratio,
      statusCounts: statusCounts,
      loanCount: loans.length,
    );
  }

  int _daysOverdue(
    LoanSchedule schedule,
    List<Payment> payments,
    DateTime now,
  ) {
    final flagged = _computation.withPaidFlags(schedule, payments);
    DateTime? earliest;
    for (final installment in flagged) {
      if (!installment.isPaid && installment.dueDate.isBefore(now)) {
        if (earliest == null || installment.dueDate.isBefore(earliest)) {
          earliest = installment.dueDate;
        }
      }
    }
    if (earliest == null) {
      return 0;
    }
    final start = DateTime(earliest.year, earliest.month, earliest.day);
    return now.difference(start).inDays;
  }

  List<MonthlyTrend> monthlyTrends(
    List<Loan> loans,
    List<Payment> payments, {
    int months = 12,
  }) {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month - (months - 1), 1);
    final disbursedByMonth = <String, Money>{};
    final collectedByMonth = <String, Money>{};

    for (final loan in loans) {
      if (!loan.startDate.isBefore(start)) {
        final key = _monthYear(loan.startDate);
        disbursedByMonth[key] = (disbursedByMonth[key] ?? Money.zero) +
            loan.principal;
      }
    }
    for (final payment in payments) {
      if (!payment.paidAt.isBefore(start)) {
        final key = _monthYear(payment.paidAt);
        collectedByMonth[key] = (collectedByMonth[key] ?? Money.zero) +
            payment.amount;
      }
    }

    final trends = <MonthlyTrend>[];
    for (var i = 0; i < months; i++) {
      final date = DateTime(start.year, start.month + i, 1);
      final key = _monthYear(date);
      trends.add(
        MonthlyTrend(
          label: key,
          disbursed: disbursedByMonth[key] ?? Money.zero,
          collected: collectedByMonth[key] ?? Money.zero,
        ),
      );
    }
    return trends;
  }

  static String _monthYear(DateTime date) =>
      DateFormat('MMM yyyy').format(date);
}
