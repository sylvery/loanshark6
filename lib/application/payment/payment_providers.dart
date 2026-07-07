import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/payment.dart';
import '../../domain/ports/payment_repository.dart';
import '../providers/core_providers.dart';

final paymentsByLoanProvider =
    StreamProvider.autoDispose.family<List<Payment>, String>((ref, loanId) {
  return ref.watch(paymentRepositoryProvider).watchByLoan(loanId);
});

final paymentActionsProvider = Provider((ref) {
  final repo = ref.watch(paymentRepositoryProvider);
  return PaymentActions(repo);
});

class PaymentActions {
  PaymentActions(this._repository);

  final PaymentRepository _repository;

  Future<void> record(Payment payment) => _repository.create(payment);
  Future<void> delete(String id) => _repository.delete(id);
}
