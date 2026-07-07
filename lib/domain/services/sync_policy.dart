import '../entities/sync_operation.dart';

class SyncPolicy {
  const SyncPolicy();

  List<SyncOperation> pushOrder(List<SyncOperation> operations) {
    final sorted = List<SyncOperation>.of(operations)
      ..sort((a, b) => a.queuedAt.compareTo(b.queuedAt));
    return sorted;
  }

  Set<String> adoptableRemoteIds(
    Set<String> remoteIds,
    List<SyncOperation> pending,
  ) {
    final protected = pending
        .where((op) => !op.applied)
        .map((op) => op.entityId)
        .toSet();
    return remoteIds.difference(protected);
  }
}
