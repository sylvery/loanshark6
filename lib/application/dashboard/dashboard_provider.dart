import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/date_helpers.dart';
import '../../domain/entities/customer.dart';
import '../../domain/entities/loan.dart';
import '../../domain/entities/payment.dart';
import '../../domain/entities/penalty_policy.dart';
import '../../domain/entities/value_objects.dart';
import '../../domain/services/loan_computation_service.dart';
import '../lending/lending_providers.dart';
import '../providers/core_providers.dart';

class ActivityItem {
  const ActivityItem({
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.at,
  });

  final String title;
  final String subtitle;
  final Money amount;
  final DateTime at;
}

class DashboardSummary {
  const DashboardSummary({
    required this.totalActiveLoans,
    required this.totalOutstanding,
    required this.overdueCount,
    required this.collectedThisMonth,
    required this.recentActivity,
  });

  final int totalActiveLoans;
  final Money totalOutstanding;
  final int overdueCount;
  final Money collectedThisMonth;
  final List<ActivityItem> recentActivity;
}

final dashboardProvider =
    FutureProvider.autoDispose<DashboardSummary>((ref) async {
  final ownerId = ref.watch(ownerIdProvider);
  final loanRepo = ref.watch(loanRepositoryProvider);
  final payRepo = ref.watch(paymentRepositoryProvider);
  final custRepo = ref.watch(customerRepositoryProvider);
  final comp = ref.watch(loanComputationProvider);
  final penaltyPolicy = ref.watch(penaltyPolicyControllerProvider);

  final loans = await loanRepo.getAll(ownerId: ownerId);
  final payments = await payRepo.getAll(ownerId: ownerId);
  final customers = await custRepo.getAll(ownerId: ownerId);
  final nameById = {for (final c in customers) c.id: c.name};

  final now = DateTime.now();
  var activeCount = 0;
  var overdueCount = 0;
  var outstandingTotal = Money.zero;

  for (final loan in loans) {
    final schedule = comp.scheduleFor(loan);
    final loanPayments = payments.where((p) => p.loanId == loan.id).toList();
    final status = comp.status(loan, schedule, loanPayments, now);
    if (status == LoanStatus.overdue) overdueCount++;
    if (status.isOpen) activeCount++;
    outstandingTotal = outstandingTotal +
        comp.outstandingWithPenalty(
            loan, schedule, loanPayments, now, penaltyPolicy);
  }

  final monthStart = DateTime(now.year, now.month, 1);
  final collected = payments
      .where((p) => !p.paidAt.isBefore(monthStart))
      .fold(Money.zero, (sum, p) => sum + p.amount);

  final sortedPayments = List<Payment>.of(payments)
    ..sort((a, b) => b.paidAt.compareTo(a.paidAt));

  final recent = <ActivityItem>[];
  for (final p in sortedPayments.take(8)) {
    final loan = _loanFor(loans, p.loanId);
    final name = loan == null ? 'Unknown' : nameById[loan.customerId] ?? 'Unknown';
    recent.add(
      ActivityItem(
        title: 'Payment from $name',
        subtitle: DateHelpers.format(p.paidAt),
        amount: p.amount,
        at: p.paidAt,
      ),
    );
  }

  return DashboardSummary(
    totalActiveLoans: activeCount,
    totalOutstanding: outstandingTotal,
    overdueCount: overdueCount,
    collectedThisMonth: collected,
    recentActivity: recent,
  );
});

Loan? _loanFor(List<Loan> loans, String id) {
  for (final l in loans) {
    if (l.id == id) return l;
  }
  return null;
}
