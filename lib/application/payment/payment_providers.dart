import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/payment.dart';
import '../../domain/entities/sync_operation.dart';
import '../../domain/ports/payment_repository.dart';
import '../../domain/ports/sync_queue_repository.dart';
import '../providers/core_providers.dart';

final paymentsByLoanProvider =
    StreamProvider.autoDispose.family<List<Payment>, String>((ref, loanId) {
  return ref.watch(paymentRepositoryProvider).watchByLoan(loanId);
});

final paymentActionsProvider = Provider((ref) {
  final repo = ref.watch(paymentRepositoryProvider);
  final queue = ref.watch(syncQueueRepositoryProvider);
  final deviceId = ref.watch(deviceIdProvider);
  return PaymentActions(repo, queue, deviceId);
});

class PaymentActions {
  PaymentActions(this._repository, this._queue, this._deviceId);

  final PaymentRepository _repository;
  final SyncQueueRepository _queue;
  final String _deviceId;

  SyncOperation _op(String entityId, SyncOperationType type) => SyncOperation(
        id: const Uuid().v4(),
        entity: 'payment',
        entityId: entityId,
        type: type,
        queuedAt: DateTime.now(),
        deviceId: _deviceId,
      );

  Future<void> record(Payment payment) async {
    await _repository.create(payment);
    await _queue.enqueue(_op(payment.id, SyncOperationType.create));
  }

  Future<void> delete(String id) async {
    await _repository.delete(id);
    await _queue.enqueue(_op(id, SyncOperationType.delete));
  }
}
