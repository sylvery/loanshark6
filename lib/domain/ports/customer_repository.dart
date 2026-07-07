import '../entities/customer.dart';

abstract class CustomerRepository {
  Future<List<Customer>> getAll({String? ownerId});
  Future<Customer?> getById(String id);
  Future<Customer> create(Customer customer);
  Future<Customer> update(Customer customer);
  Future<void> delete(String id);
  Stream<List<Customer>> watchAll({String? ownerId});
}
