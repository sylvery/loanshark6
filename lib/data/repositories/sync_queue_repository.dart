import '../../domain/entities/sync_operation.dart';
import '../../domain/ports/sync_queue_repository.dart';
import '../local/local_db.dart';
import '../local/sync_operation_model.dart';

class SyncQueueRepositoryIsar implements SyncQueueRepository {
  SyncQueueRepositoryIsar(this._db);

  final LocalDb _db;

  @override
  Future<void> enqueue(SyncOperation operation) async {
    final model = SyncOperationModel.fromDomain(operation);
    await _db.isar.writeTxn(() async {
      await _db.isar.syncOperationModels.put(model);
    });
  }

  @override
  Future<List<SyncOperation>> pending() async {
    final models = await _db.isar.syncOperationModels
        .where()
        .filter()
        .appliedEqualTo(false)
        .findAll();
    return models.map((m) => m.toDomain()).toList();
  }

  @override
  Future<void> markApplied(String id) async {
    final model = await _db.isar.syncOperationModels
        .filter()
        .uuidEqualTo(id)
        .findFirst();
    if (model == null) return;
    final updated =
        SyncOperationModel.fromDomain(model.toDomain().markApplied());
    await _db.isar.writeTxn(() async {
      await _db.isar.syncOperationModels.put(updated);
    });
  }

  @override
  Future<void> clearApplied() async {
    final models = await _db.isar.syncOperationModels
        .where()
        .filter()
        .appliedEqualTo(true)
        .findAll();
    await _db.isar.writeTxn(() async {
      await _db.isar.syncOperationModels
          .deleteAll(models.map((m) => m.id).toList());
    });
  }

  @override
  Stream<int> watchPendingCount() {
    return _db.isar.syncOperationModels
        .where()
        .filter()
        .appliedEqualTo(false)
        .watch(fireImmediately: true)
        .map((models) => models.length);
  }
}
