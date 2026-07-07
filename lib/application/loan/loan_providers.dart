import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/loan.dart';
import '../../domain/entities/payment.dart';
import '../../domain/entities/sync_operation.dart';
import '../../domain/entities/value_objects.dart';
import '../../domain/ports/loan_repository.dart';
import '../../domain/ports/payment_repository.dart';
import '../../domain/ports/sync_queue_repository.dart';
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
  final queue = ref.watch(syncQueueRepositoryProvider);
  final deviceId = ref.watch(deviceIdProvider);
  return LoanActions(loanRepo, payRepo, queue, deviceId);
});

class LoanActions {
  LoanActions(
    this._loanRepo,
    this._paymentRepo,
    this._queue,
    this._deviceId,
  );

  final LoanRepository _loanRepo;
  final PaymentRepository _paymentRepo;
  final SyncQueueRepository _queue;
  final String _deviceId;

  SyncOperation _op(String entity, String entityId, SyncOperationType type) =>
      SyncOperation(
        id: const Uuid().v4(),
        entity: entity,
        entityId: entityId,
        type: type,
        queuedAt: DateTime.now(),
        deviceId: _deviceId,
      );

  Future<void> createLoan(Loan loan) async {
    await _loanRepo.create(loan);
    await _queue.enqueue(_op('loan', loan.id, SyncOperationType.create));
  }

  Future<void> updateLoan(Loan loan) async {
    await _loanRepo.update(loan);
    await _queue.enqueue(_op('loan', loan.id, SyncOperationType.update));
  }

  Future<void> deleteLoan(String id) async {
    await _loanRepo.delete(id);
    await _queue.enqueue(_op('loan', id, SyncOperationType.delete));
  }

  Future<void> recordPayment(Payment payment) async {
    await _paymentRepo.create(payment);
    await _queue.enqueue(_op('payment', payment.id, SyncOperationType.create));
  }

  Future<void> deletePayment(String id) async {
    await _paymentRepo.delete(id);
    await _queue.enqueue(_op('payment', id, SyncOperationType.delete));
  }

  Future<void> writeOff(String id, Loan loan) async {
    await _loanRepo.update(loan.copyWith(writtenOff: true));
    await _queue.enqueue(_op('loan', loan.id, SyncOperationType.update));
  }
}

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
