import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:makhzanflow/core/sync/pending_ops_queue.dart';
import 'package:makhzanflow/core/sync/sync_service.dart';
import 'package:makhzanflow/core/sync/sync_state.dart';

export 'sync_state.dart';

/// Owns replay state; the engine lives in [SyncService] (SRP).
/// Wired as [SyncService.onSyncRequested] in service_locator (single point).
class SyncCubit extends Cubit<SyncState> {
  final PendingOpsQueue _queue;
  final SyncService _service;

  SyncCubit({
    required PendingOpsQueue queue,
    required SyncService service,
  })  : _queue = queue,
        _service = service,
        super(const SyncIdle());

  Future<void> refreshCounts() async {
    if (state is Syncing) return;
    emit(SyncIdle(
      pendingCount: (await _queue.pending()).length,
      reviewCount: (await _queue.needsReview()).length,
    ));
  }

  Future<void> syncNow() async {
    if (state is Syncing) return;
    final pending = await _queue.pending();
    if (pending.isEmpty) {
      await refreshCounts();
      return;
    }
    emit(Syncing(processed: 0, total: pending.length));
    final result = await _service.syncNow();
    emit(SyncDone(
      synced: result.synced,
      conflicts: result.conflicts,
      failed: result.failed,
      paused: result.paused,
    ));
    await refreshCounts();
  }
}
