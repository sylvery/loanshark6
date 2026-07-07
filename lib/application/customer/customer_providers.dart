import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/customer.dart';
import '../../domain/entities/sync_operation.dart';
import '../../domain/ports/customer_repository.dart';
import '../../domain/ports/sync_queue_repository.dart';
import '../providers/core_providers.dart';

final customerListProvider =
    StreamProvider.autoDispose<List<Customer>>((ref) {
  final ownerId = ref.watch(ownerIdProvider);
  return ref
      .watch(customerRepositoryProvider)
      .watchAll(ownerId: ownerId);
});

final customerByIdProvider =
    FutureProvider.autoDispose.family<Customer?, String>(
  (ref, id) => ref.watch(customerRepositoryProvider).getById(id),
);

final customerActionsProvider = Provider((ref) {
  final repo = ref.watch(customerRepositoryProvider);
  final queue = ref.watch(syncQueueRepositoryProvider);
  final deviceId = ref.watch(deviceIdProvider);
  return CustomerActions(repo, queue, deviceId);
});

class CustomerActions {
  CustomerActions(this._repository, this._queue, this._deviceId);

  final CustomerRepository _repository;
  final SyncQueueRepository _queue;
  final String _deviceId;

  SyncOperation _op(String entityId, SyncOperationType type) => SyncOperation(
        id: const Uuid().v4(),
        entity: 'customer',
        entityId: entityId,
        type: type,
        queuedAt: DateTime.now(),
        deviceId: _deviceId,
      );

  Future<void> create(Customer customer) async {
    await _repository.create(customer);
    await _queue.enqueue(_op(customer.id, SyncOperationType.create));
  }

  Future<void> update(Customer customer) async {
    await _repository.update(customer);
    await _queue.enqueue(_op(customer.id, SyncOperationType.update));
  }

  Future<void> delete(String id) async {
    await _repository.delete(id);
    await _queue.enqueue(_op(id, SyncOperationType.delete));
  }
}
