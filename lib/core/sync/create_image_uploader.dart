import 'package:makhzanflow/core/sync/pending_op.dart';

/// Uploads a queued local image after its create op replays (DIP: the core
/// [SyncService] depends on this abstraction, features provide the endpoint
/// knowledge). Implementations must be best-effort and never throw.
abstract class PendingCreateImageUploader {
  bool supports(PendingOpType type);

  /// Uploads [imagePath] for the record created as [serverId].
  /// Returns true on success.
  Future<bool> upload({
    required String serverId,
    required String imagePath,
    required String companyId,
  });
}
