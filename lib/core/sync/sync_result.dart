import 'package:equatable/equatable.dart';

/// Outcome of one replay pass over the pending queue.
class SyncResult extends Equatable {
  final int synced;
  final int conflicts;
  final int failed;
  final bool paused;

  const SyncResult({
    this.synced = 0,
    this.conflicts = 0,
    this.failed = 0,
    this.paused = false,
  });

  bool get hasWork => synced + conflicts + failed > 0;

  @override
  List<Object?> get props => [synced, conflicts, failed, paused];
}
