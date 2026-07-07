import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/loan.dart';
import '../../domain/entities/payment.dart';
import '../../domain/entities/value_objects.dart';
import '../../domain/ports/loan_repository.dart';
import '../../domain/ports/payment_repository.dart';
import '../../domain/services/loan_computation_service.dart';
import '../providers/core_providers.dart';

final loanListProvider = StreamProvider.autoDispose<List<Loan>>((ref) {
  final ownerId = ref.watch(ownerIdProvider);
  return ref.watch(loanRepositoryProvider).watchAll(ownerId: ownerId);
});

final allLoanDetailsProvider =
    FutureProvider.autoDispose<List<LoanDetail>>((ref) async {
  final loanRepo = ref.watch(loanRepositoryProvider);
  final payRepo = ref.watch(paymentRepositoryProvider);
  final comp = ref.watch(loanComputationProvider);
  final ownerId = ref.watch(ownerIdProvider);
  final now = DateTime.now();

  final loans = await loanRepo.getAll(ownerId: ownerId);
  final details = <LoanDetail>[];
  for (final loan in loans) {
    final payments = await payRepo.getByLoan(loan.id);
    final schedule = comp.scheduleFor(loan);
    final status = comp.status(loan, schedule, payments, now);
    final outstanding = comp.outstanding(schedule, payments);
    final installments = comp.withPaidFlags(schedule, payments);
    details.add(
      LoanDetail(
        loan: loan,
        schedule: schedule,
        status: status,
        outstanding: outstanding,
        payments: payments,
        installments: installments,
      ),
    );
  }
  return details;
});

final loansByCustomerProvider =
    StreamProvider.autoDispose.family<List<Loan>, String>((ref, customerId) {
  final ownerId = ref.watch(ownerIdProvider);
  return ref
      .watch(loanRepositoryProvider)
      .watchAll(ownerId: ownerId)
      .map((list) => list.where((l) => l.customerId == customerId).toList());
});

final loanDetailProvider =
    FutureProvider.autoDispose.family<LoanDetail, String>((ref, loanId) async {
  final loanRepo = ref.watch(loanRepositoryProvider);
  final payRepo = ref.watch(paymentRepositoryProvider);
  final comp = ref.watch(loanComputationProvider);

  final loan = await loanRepo.getById(loanId);
  if (loan == null) throw Exception('Loan not found');
  final payments = await payRepo.getByLoan(loanId);
  final schedule = comp.scheduleFor(loan);
  final status = comp.status(loan, schedule, payments, DateTime.now());
  final outstanding = comp.outstanding(schedule, payments);
  final installments = comp.withPaidFlags(schedule, payments);

  return LoanDetail(
    loan: loan,
    schedule: schedule,
    status: status,
    outstanding: outstanding,
    payments: payments,
    installments: installments,
  );
});

class LoanDetail {
  const LoanDetail({
    required this.loan,
    required this.schedule,
    required this.status,
    required this.outstanding,
    required this.payments,
    required this.installments,
  });

  final Loan loan;
  final LoanSchedule schedule;
  final LoanStatus status;
  final Money outstanding;
  final List<Payment> payments;
  final List<ScheduledInstallment> installments;
}

final customerLoanDetailsProvider =
    FutureProvider.autoDispose.family<List<LoanDetail>, String>(
  (ref, customerId) async {
    final loanRepo = ref.watch(loanRepositoryProvider);
    final payRepo = ref.watch(paymentRepositoryProvider);
    final comp = ref.watch(loanComputationProvider);
    final now = DateTime.now();

    final loans = await loanRepo.getByCustomer(customerId);
    final details = <LoanDetail>[];
    for (final loan in loans) {
      final payments = await payRepo.getByLoan(loan.id);
      final schedule = comp.scheduleFor(loan);
      final status = comp.status(loan, schedule, payments, now);
      final outstanding = comp.outstanding(schedule, payments);
      final installments = comp.withPaidFlags(schedule, payments);
      details.add(
        LoanDetail(
          loan: loan,
          schedule: schedule,
          status: status,
          outstanding: outstanding,
          payments: payments,
          installments: installments,
        ),
      );
    }
    return details;
  },
);

final loanActionsProvider = Provider((ref) {
  final loanRepo = ref.watch(loanRepositoryProvider);
  final payRepo = ref.watch(paymentRepositoryProvider);
  return LoanActions(loanRepo, payRepo);
});

class LoanActions {
  LoanActions(this._loanRepo, this._paymentRepo);

  final LoanRepository _loanRepo;
  final PaymentRepository _paymentRepo;

  Future<void> createLoan(Loan loan) => _loanRepo.create(loan);
  Future<void> updateLoan(Loan loan) => _loanRepo.update(loan);
  Future<void> deleteLoan(String id) => _loanRepo.delete(id);
  Future<void> recordPayment(Payment payment) => _paymentRepo.create(payment);
  Future<void> deletePayment(String id) => _paymentRepo.delete(id);
  Future<void> writeOff(String id, Loan loan) =>
      _loanRepo.update(loan.copyWith(writtenOff: true));
}
