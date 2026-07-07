import '../../domain/entities/loan.dart';
import '../../domain/ports/loan_repository.dart';
import '../local/loan_model.dart';
import '../local/local_db.dart';

class LoanRepositoryIsar implements LoanRepository {
  LoanRepositoryIsar(this._db);

  final LocalDb _db;

  @override
  Future<List<Loan>> getAll({String? ownerId}) async {
    final models = await _db.isar.loanModels.where().findAll();
    return models
        .where((m) => ownerId == null || m.ownerId == ownerId)
        .map((m) => m.toDomain())
        .toList();
  }

  @override
  Future<List<Loan>> getByCustomer(String customerId) async {
    final models = await _db.isar.loanModels
        .where()
        .filter()
        .customerIdEqualTo(customerId)
        .findAll();
    return models.map((m) => m.toDomain()).toList();
  }

  @override
  Future<Loan?> getById(String id) async {
    final model = await _db.isar.loanModels.get(id);
    return model?.toDomain();
  }

  @override
  Future<Loan> create(Loan loan) async {
    final model = LoanModel.fromDomain(loan);
    await _db.isar.writeTxn(() async {
      await _db.isar.loanModels.put(model);
    });
    return model.toDomain();
  }

  @override
  Future<Loan> update(Loan loan) async {
    return create(loan);
  }

  @override
  Future<void> delete(String id) async {
    await _db.isar.writeTxn(() async {
      await _db.isar.loanModels.delete(id);
    });
  }

  @override
  Stream<List<Loan>> watchAll({String? ownerId}) {
    return _db.isar.loanModels.where().watch(fireImmediately: true).map(
          (models) => models
              .where((m) => ownerId == null || m.ownerId == ownerId)
              .map((m) => m.toDomain())
              .toList(),
        );
  }
}
