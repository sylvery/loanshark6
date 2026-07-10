import '../../domain/entities/payment.dart';
import '../../domain/ports/payment_repository.dart';
import '../local/local_db.dart';
import '../local/payment_model.dart';

class PaymentRepositoryIsar implements PaymentRepository {
  PaymentRepositoryIsar(this._db);

  final LocalDb _db;

  @override
  Future<List<Payment>> getAll({String? ownerId}) async {
    final models = await _db.isar.paymentModels.where().findAll();
    return models.map((m) => m.toDomain()).toList();
  }

  @override
  Future<List<Payment>> getByLoan(String loanId) async {
    final models = await _db.isar.paymentModels
        .where()
        .filter()
        .loanIdEqualTo(loanId)
        .findAll();
    return models.map((m) => m.toDomain()).toList();
  }

  @override
  Future<Payment?> getById(String id) async {
    final model =
        await _db.isar.paymentModels.filter().uuidEqualTo(id).findFirst();
    return model?.toDomain();
  }

  @override
  Future<Payment> create(Payment payment) async {
    final model = PaymentModel.fromDomain(payment);
    await _db.isar.writeTxn(() async {
      await _db.isar.paymentModels.put(model);
    });
    return model.toDomain();
  }

  @override
  Future<void> delete(String id) async {
    await _db.isar.writeTxn(() async {
      await _db.isar.paymentModels.filter().uuidEqualTo(id).delete();
    });
  }

  @override
  Stream<List<Payment>> watchByLoan(String loanId) {
    return _db.isar.paymentModels
        .where()
        .filter()
        .loanIdEqualTo(loanId)
        .watch(fireImmediately: true)
        .map((models) => models.map((m) => m.toDomain()).toList());
  }
}
