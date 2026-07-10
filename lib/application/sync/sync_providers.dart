import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/ports/sync_queue_repository.dart';
import '../providers/core_providers.dart';

final syncStatusProvider = StreamProvider<int>((ref) {
  return ref.watch(syncQueueRepositoryProvider).watchPendingCount();
});

class SyncState {
  const SyncState({this.syncing = false, this.lastSyncedAt, this.error});

  final bool syncing;
  final DateTime? lastSyncedAt;
  final String? error;

  SyncState copyWith({bool? syncing, DateTime? lastSyncedAt, String? error}) =>
      SyncState(
        syncing: syncing ?? this.syncing,
        lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
        error: error,
      );
}

class SyncController extends StateNotifier<SyncState> {
  SyncController(this._ref) : super(const SyncState());

  final Ref _ref;

  Future<void> syncNow() async {
    final uid = _ref.read(ownerIdProvider);
    if (uid == null) return;
    state = state.copyWith(syncing: true, error: null);
    try {
      final service = _ref.read(firestoreSyncProvider);
      await service.pushNow(uid);
      await service.pullNow(uid);
      state = state.copyWith(syncing: false, lastSyncedAt: DateTime.now());
    } catch (e) {
      state = state.copyWith(syncing: false, error: e.toString());
    }
  }
}

final syncControllerProvider =
    StateNotifierProvider<SyncController, SyncState>(
  (ref) => SyncController(ref),
);

final syncAutoRetryProvider = Provider<void>((ref) {
  ref.listen(connectivityProvider, (prev, next) {
    final online = next.valueOrNull ?? false;
    final wasOnline = prev?.valueOrNull ?? false;
    if (online && !wasOnline) {
      ref.read(syncControllerProvider.notifier).syncNow();
    }
  });
});
