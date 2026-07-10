import 'package:isar/isar.dart';

import '../../domain/entities/sync_operation.dart';

part 'sync_operation_model.g.dart';

@Collection()
class SyncOperationModel {
  SyncOperationModel();

  @Id()
  Id id = '';

  late String entity;
  late String entityId;
  late int type;
  late int queuedAt;
  late String deviceId;
  late bool applied;

  SyncOperation toDomain() => SyncOperation(
        id: id,
        entity: entity,
        entityId: entityId,
        type: SyncOperationType.values[type],
        queuedAt: DateTime.fromMillisecondsSinceEpoch(queuedAt),
        deviceId: deviceId,
        applied: applied,
      );

  static SyncOperationModel fromDomain(SyncOperation op) => SyncOperationModel()
    ..id = op.id
    ..entity = op.entity
    ..entityId = op.entityId
    ..type = op.type.index
    ..queuedAt = op.queuedAt.millisecondsSinceEpoch
    ..deviceId = op.deviceId
    ..applied = op.applied;
}
