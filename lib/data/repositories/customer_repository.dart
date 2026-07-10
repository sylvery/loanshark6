import '../../domain/entities/customer.dart';
import '../../domain/ports/customer_repository.dart';
import '../local/customer_model.dart';
import '../local/local_db.dart';

class CustomerRepositoryIsar implements CustomerRepository {
  CustomerRepositoryIsar(this._db);

  final LocalDb _db;

  @override
  Future<List<Customer>> getAll({String? ownerId}) async {
    final models = await _db.isar.customerModels.where().findAll();
    return models
        .where((m) => ownerId == null || m.ownerId == ownerId)
        .map((m) => m.toDomain())
        .toList();
  }

  @override
  Future<Customer?> getById(String id) async {
    final model =
        await _db.isar.customerModels.filter().uuidEqualTo(id).findFirst();
    return model?.toDomain();
  }

  @override
  Future<Customer> create(Customer customer) async {
    final model = CustomerModel.fromDomain(customer);
    await _db.isar.writeTxn(() async {
      await _db.isar.customerModels.put(model);
    });
    return model.toDomain();
  }

  @override
  Future<Customer> update(Customer customer) async {
    return create(customer);
  }

  @override
  Future<void> delete(String id) async {
    await _db.isar.writeTxn(() async {
      await _db.isar.customerModels.filter().uuidEqualTo(id).delete();
    });
  }

  @override
  Stream<List<Customer>> watchAll({String? ownerId}) {
    return _db.isar.customerModels.where().watch(fireImmediately: true).map(
          (models) => models
              .where((m) => ownerId == null || m.ownerId == ownerId)
              .map((m) => m.toDomain())
              .toList(),
        );
  }
}
