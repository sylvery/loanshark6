import '../entities/payment.dart';

abstract class PaymentRepository {
  Future<List<Payment>> getAll({String? ownerId});
  Future<List<Payment>> getByLoan(String loanId);
  Future<Payment?> getById(String id);
  Future<Payment> create(Payment payment);
  Future<void> delete(String id);
  Stream<List<Payment>> watchByLoan(String loanId);
}
