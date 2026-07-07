import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/date_helpers.dart';
import '../../domain/entities/penalty_policy.dart';
import '../../domain/entities/value_objects.dart';
import '../../domain/services/loan_computation_service.dart';
import '../lending/lending_providers.dart';
import '../providers/core_providers.dart';

class MonthlyCollection {
  const MonthlyCollection({required this.label, required this.amount});
  final String label;
  final Money amount;
}

class OverdueReportItem {
  const OverdueReportItem({
    required this.customerName,
    required this.phone,
    required this.outstanding,
    required this.loanId,
    required this.customerId,
  });
  final String customerName;
  final String? phone;
  final Money outstanding;
  final String loanId;
  final String customerId;
}

class ReportsData {
  const ReportsData({
    required this.monthlyCollections,
    required this.overdueLoans,
  });
  final List<MonthlyCollection> monthlyCollections;
  final List<OverdueReportItem> overdueLoans;
}

final reportsProvider = FutureProvider.autoDispose<ReportsData>((ref) async {
  final ownerId = ref.watch(ownerIdProvider);
  final loanRepo = ref.watch(loanRepositoryProvider);
  final payRepo = ref.watch(paymentRepositoryProvider);
  final custRepo = ref.watch(customerRepositoryProvider);
  final comp = ref.watch(loanComputationProvider);
  final penaltyPolicy = ref.watch(penaltyPolicyControllerProvider);

  final loans = await loanRepo.getAll(ownerId: ownerId);
  final payments = await payRepo.getAll(ownerId: ownerId);
  final customers = await custRepo.getAll(ownerId: ownerId);
  final customerById = {for (final c in customers) c.id: c};

  final now = DateTime.now();
  final byMonth = <String, Money>{};
  for (final p in payments) {
    final key = DateHelpers.monthYear(p.paidAt);
    byMonth[key] = (byMonth[key] ?? Money.zero) + p.amount;
  }

  final months = List.generate(6, (i) {
    final d = DateTime(now.year, now.month - (5 - i), 1);
    return DateHelpers.monthYear(d);
  });
  final monthly = months
      .map((m) => MonthlyCollection(label: m, amount: byMonth[m] ?? Money.zero))
      .toList();

  final overdue = <OverdueReportItem>[];
  for (final loan in loans) {
    final schedule = comp.scheduleFor(loan);
    final loanPayments = payments.where((p) => p.loanId == loan.id).toList();
    final status = comp.status(loan, schedule, loanPayments, now);
    if (status == LoanStatus.overdue) {
      final customer = customerById[loan.customerId];
      overdue.add(
        OverdueReportItem(
          customerName: customer?.name ?? 'Unknown',
          phone: customer?.phone,
          outstanding: comp.outstandingWithPenalty(
              loan, schedule, loanPayments, now, penaltyPolicy),
          loanId: loan.id,
          customerId: loan.customerId,
        ),
      );
    }
  }

  return ReportsData(monthlyCollections: monthly, overdueLoans: overdue);
});
