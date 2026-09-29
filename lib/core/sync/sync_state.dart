import 'package:equatable/equatable.dart';

sealed class SyncState extends Equatable {
  const SyncState();

  @override
  List<Object?> get props => [];
}

/// Idle — carries counts for the pending badge / review entry point.
class SyncIdle extends SyncState {
  final int pendingCount;
  final int reviewCount;

  const SyncIdle({this.pendingCount = 0, this.reviewCount = 0});

  @override
  List<Object?> get props => [pendingCount, reviewCount];
}

class Syncing extends SyncState {
  final int processed;
  final int total;

  const Syncing({required this.processed, required this.total});

  @override
  List<Object?> get props => [processed, total];
}

/// One replay pass finished. Auto-returns to [SyncIdle] after consumption.
class SyncDone extends SyncState {
  final int synced;
  final int conflicts;
  final int failed;
  final bool paused;

  const SyncDone({
    this.synced = 0,
    this.conflicts = 0,
    this.failed = 0,
    this.paused = false,
  });

  @override
  List<Object?> get props => [synced, conflicts, failed, paused];
}
