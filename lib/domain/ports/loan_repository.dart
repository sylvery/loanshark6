import '../entities/loan.dart';

abstract class LoanRepository {
  Future<List<Loan>> getAll({String? ownerId});
  Future<List<Loan>> getByCustomer(String customerId);
  Future<Loan?> getById(String id);
  Future<Loan> create(Loan loan);
  Future<Loan> update(Loan loan);
  Future<void> delete(String id);
  Stream<List<Loan>> watchAll({String? ownerId});
}
