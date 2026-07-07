import '../entities/sync_operation.dart';

abstract class SyncQueueRepository {
  Future<void> enqueue(SyncOperation operation);
  Future<List<SyncOperation>> pending();
  Future<void> markApplied(String id);
  Future<void> clearApplied();
  Stream<int> watchPendingCount();
}
