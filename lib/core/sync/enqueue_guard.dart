import 'package:makhzanflow/core/constants/error_messages.dart';
import 'package:makhzanflow/core/error/failures.dart';
import 'package:makhzanflow/core/sync/pending_op.dart';
import 'package:makhzanflow/core/sync/pending_ops_queue.dart';

/// Decides whether a failed mutation may enter the offline queue.
/// Only connection-loss failures qualify — validation, auth, conflict and
/// programmer errors must surface immediately, and reads are never queued.
bool shouldEnqueueFailure(Failure failure) =>
    failure is ConnectionLostFailure;

/// String-channel twin for layers still returning plain messages
/// (products, until migrated to `Either<Failure, …>`).
bool shouldEnqueueMessage(String message) =>
    message == ErrorMessages.connectionFailed;

/// Enqueues [op] and reports whether the cap forced a drop-oldest,
/// so callers can pick the right operator notice. Returns false normally.
Future<bool> tryEnqueue(PendingOpsQueue queue, PendingOp op) =>
    queue.enqueue(op);
