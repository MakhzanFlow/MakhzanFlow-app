import 'package:makhzanflow/core/error/failures.dart';

/// Merge-retry budget: initial attempt + this many conflict rounds before
/// asking the operator to retry manually.
const int kMaxMergeRounds = 2;

/// Runs [action] with [version]; on [VersionConflictFailure] asks [onConflict]
/// (shows the Merge UI, returns the fresh server version or null on
/// use-server/dismiss) and retries with the chosen values, up to
/// [kMaxMergeRounds] rounds. Re-throws when the user cancels or rounds run out.
Future<T> withMergeRetry<T>({
  required Future<T> Function(int version) action,
  required int version,
  required Future<int?> Function(VersionConflictFailure conflict) onConflict,
  int maxRounds = kMaxMergeRounds,
}) async {
  var currentVersion = version;
  for (var round = 0; ; round++) {
    try {
      return await action(currentVersion);
    } on VersionConflictFailure catch (conflict) {
      if (round >= maxRounds) rethrow;
      final retryVersion = await onConflict(conflict);
      if (retryVersion == null) rethrow;
      currentVersion = retryVersion;
    }
  }
}

/// Extracts the fresh server version from a conflict payload.
/// Falls back to [fallback] (defensive: backend always sends it).
int serverVersionOf(VersionConflictFailure conflict, {int fallback = 1}) {
  final raw = conflict.current?['version'];
  if (raw is num) return raw.toInt();
  return fallback;
}
