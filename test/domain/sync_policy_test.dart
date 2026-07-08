import 'package:bookinman/domain/entities/sync_operation.dart';
import 'package:bookinman/domain/services/sync_policy.dart';
import 'package:flutter_test/flutter_test.dart';

SyncOperation _op(String id, SyncOperationType type, DateTime at, {bool applied = false}) =>
    SyncOperation(
      id: id,
      entity: 'loan',
      entityId: id,
      type: type,
      queuedAt: at,
      deviceId: 'dev-1',
      applied: applied,
    );

void main() {
  group('SyncPolicy', () {
    final policy = const SyncPolicy();

    test('pushOrder sorts operations chronologically', () {
      final late = _op('b', SyncOperationType.update, DateTime(2024, 2, 1));
      final early = _op('a', SyncOperationType.create, DateTime(2024, 1, 1));
      final ordered = policy.pushOrder([late, early]);
      expect(ordered.first.entityId, 'a');
      expect(ordered.last.entityId, 'b');
    });

    test('adoptableRemoteIds excludes entities with pending local ops', () {
      final pending = [
        _op('loan-1', SyncOperationType.update, DateTime(2024, 1, 1)),
      ];
      final remote = {'loan-1', 'loan-2', 'loan-3'};
      final adoptable = policy.adoptableRemoteIds(remote, pending);
      expect(adoptable, {'loan-2', 'loan-3'});
    });

    test('adoptableRemoteIds includes entities whose local op is applied', () {
      final pending = [
        _op('loan-1', SyncOperationType.update, DateTime(2024, 1, 1), applied: true),
      ];
      final remote = {'loan-1', 'loan-2'};
      final adoptable = policy.adoptableRemoteIds(remote, pending);
      expect(adoptable, {'loan-1', 'loan-2'});
    });
  });
}
