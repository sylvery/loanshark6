enum SyncOperationType { create, update, delete }

class SyncOperation {
  const SyncOperation({
    required this.id,
    required this.entity,
    required this.entityId,
    required this.type,
    required this.queuedAt,
    required this.deviceId,
    this.applied = false,
  });

  final String id;
  final String entity;
  final String entityId;
  final SyncOperationType type;
  final DateTime queuedAt;
  final String deviceId;
  final bool applied;

  SyncOperation markApplied() => SyncOperation(
        id: id,
        entity: entity,
        entityId: entityId,
        type: type,
        queuedAt: queuedAt,
        deviceId: deviceId,
        applied: true,
      );
}
