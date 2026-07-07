import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/customer.dart';
import '../../domain/ports/customer_repository.dart';
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
  return CustomerActions(repo);
});

class CustomerActions {
  CustomerActions(this._repository);

  final CustomerRepository _repository;

  Future<void> create(Customer customer) => _repository.create(customer);
  Future<void> update(Customer customer) => _repository.update(customer);
  Future<void> delete(String id) => _repository.delete(id);
}
