import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:makhzanflow/core/api/api_response.dart';
import 'package:makhzanflow/core/constants/error_messages.dart';
import 'package:makhzanflow/core/error/failures.dart';
import 'package:makhzanflow/core/sync/connectivity_monitor.dart';
import 'package:makhzanflow/core/sync/create_image_uploader.dart';
import 'package:makhzanflow/core/sync/pending_op.dart';
import 'package:makhzanflow/core/sync/pending_ops_queue.dart';
import 'package:makhzanflow/core/sync/sync_result.dart';

/// Replays the offline queue one-by-one over the shared [Dio] instance
/// (same interceptors: JWT, `x-company-id`, language).
///
/// Per-op outcome:
/// - 2xx → dropped from the queue.
/// - 409 + `VERSION_CONFLICT` → parked to needs-review (never auto-resolved).
/// - 401 → replay pauses; queue retained for after re-login.
/// - Transient (timeouts, connection loss, 5xx) → attempts++, stays queued;
///   dropped + counted as failed after [PendingOpsQueue.maxAttempts].
/// - Other 4xx → dropped + counted as failed (replay could never succeed).
class SyncService {
  final PendingOpsQueue _queue;
  final Dio _dio;
  final ConnectivityMonitor _monitor;
  final List<PendingCreateImageUploader> _imageUploaders;
  StreamSubscription<bool>? _subscription;
  bool _syncing = false;

  /// Called on every offline→online transition. Wired to `SyncCubit.syncNow`.
  Future<void> Function()? onSyncRequested;

  SyncService({
    required PendingOpsQueue queue,
    required Dio dio,
    required ConnectivityMonitor monitor,
    List<PendingCreateImageUploader> imageUploaders = const [],
  })  : _queue = queue,
        _dio = dio,
        _monitor = monitor,
        _imageUploaders = imageUploaders;

  void start() {
    _subscription ??= _monitor.onStatusChanged.listen((online) {
      if (online) onSyncRequested?.call();
    });
  }

  Future<void> stop() async {
    await _subscription?.cancel();
    _subscription = null;
  }

  /// Retries one parked conflict with an explicit version (Merge "Keep mine").
  /// 2xx removes the item; a fresh 409 refreshes the parked payload so the
  /// dialog can loop with newest data; other failures surface as-is.
  Future<Either<Failure, void>> retryWithVersion(
    NeedsReviewOp item,
    int version,
  ) async {
    final op = item.base;
    try {
      final response = await _dio.request(
        op.path,
        data: {...op.body, 'version': version},
        options: Options(
          method: op.method,
          headers: {'x-company-id': op.companyId},
        ),
      );
      final status = response.statusCode ?? 0;
      if (status >= 200 && status < 300) {
        await _queue.removeFromReview(op.id);
        await _uploadPendingImage(op, response.data);
        return const Right(null);
      }
      if (status == 401) {
        return Left(UnauthorizedFailure(ErrorMessages.unauthorized));
      }
      return Left(ServerFailure(ErrorMessages.unexpectedError));
    } on DioException catch (e) {
      final failure = mapDioExceptionToFailure(e);
      if (failure is VersionConflictFailure) {
        await _queue.parkForReview(NeedsReviewOp(
          base: op,
          current: failure.current ?? const {},
          attempted: failure.attempted ?? Map.of(op.body),
          conflictedAt: DateTime.now().toUtc(),
          entity: failure.entity,
          entityId: failure.id,
        ));
      }
      return Left(failure);
    } catch (_) {
      return Left(ServerFailure(ErrorMessages.unexpectedError));
    }
  }

  Future<SyncResult> syncNow() async {    if (_syncing) return const SyncResult();
    _syncing = true;
    try {
      var synced = 0;
      var conflicts = 0;
      var failed = 0;
      final ops = await _queue.pending();
      for (final op in ops) {
        final outcome = await _replay(op);
        switch (outcome) {
          case _ReplayOutcome.synced:
            synced++;
          case _ReplayOutcome.conflict:
            conflicts++;
          case _ReplayOutcome.failed:
            failed++;
          case _ReplayOutcome.paused:
            return SyncResult(
              synced: synced,
              conflicts: conflicts,
              failed: failed,
              paused: true,
            );
          case _ReplayOutcome.retryLater:
            break;
        }
      }
      return SyncResult(synced: synced, conflicts: conflicts, failed: failed);
    } finally {
      _syncing = false;
    }
  }

  Future<_ReplayOutcome> _replay(PendingOp op) async {
    // Policy guard: only add-new creates, stock movement and deletes may
    // replay from the queue (e.g. entries queued by an older build).
    // Drop anything else loudly instead of sending it.
    if (!op.opType.isQueueableOffline) return _dropAsFailed(op);
    try {
      final response = await _dio.request(
        op.path,
        data: op.body,
        options: Options(
          method: op.method,
          headers: {'x-company-id': op.companyId},
        ),
      );
      final status = response.statusCode ?? 0;
      if (status >= 200 && status < 300) {
        await _queue.remove(op.id);
        await _uploadPendingImage(op, response.data);
        return _ReplayOutcome.synced;
      }
      if (status == 401) return _ReplayOutcome.paused;
      return _dropAsFailed(op);
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      if (status == 401) return _ReplayOutcome.paused;
      if (status == 409) {
        final failure = mapDioExceptionToFailure(e);
        if (failure is VersionConflictFailure) {
          await _queue.parkForReview(NeedsReviewOp(
            base: op,
            current: failure.current ?? const {},
            attempted: failure.attempted ?? Map.of(op.body),
            conflictedAt: DateTime.now().toUtc(),
            entity: failure.entity,
            entityId: failure.id,
          ));
          return _ReplayOutcome.conflict;
        }
        return _dropAsFailed(op);
      }
      if (_isTransient(e)) {
        await _queue.recordAttempt(op.id);
        final refreshed =
            (await _queue.pending()).where((e) => e.id == op.id).firstOrNull;
        if (refreshed != null && refreshed.attempts >= PendingOpsQueue.maxAttempts) {
          await _queue.remove(op.id);
          return _ReplayOutcome.failed;
        }
        return _ReplayOutcome.retryLater;
      }
      return _dropAsFailed(op);
    } catch (_) {
      return _dropAsFailed(op);
    }
  }

  Future<_ReplayOutcome> _dropAsFailed(PendingOp op) async {
    await _queue.remove(op.id);
    return _ReplayOutcome.failed;
  }

  /// Best-effort image upload after a create op replays: the local file must
  /// still exist and a supporting uploader must be registered. Never affects
  /// the replay outcome (the record itself already synced).
  Future<void> _uploadPendingImage(PendingOp op, dynamic responseData) async {
    final imagePath = op.imageLocalPath;
    if (imagePath == null || imagePath.isEmpty) return;
    try {
      if (!await File(imagePath).exists()) return;
    } catch (_) {
      return;
    }
    final serverId = _serverIdOf(responseData);
    if (serverId == null || serverId.isEmpty) return;
    for (final uploader in _imageUploaders) {
      if (!uploader.supports(op.opType)) continue;
      try {
        await uploader.upload(
          serverId: serverId,
          imagePath: imagePath,
          companyId: op.companyId,
        );
      } catch (_) {
        // Best-effort: record is synced, image may be retried manually.
      }
      return;
    }
  }

  static String? _serverIdOf(dynamic data) {
    if (data is Map) {
      final nested = data['data'];
      if (nested is Map && nested['id'] is String) {
        return nested['id'] as String;
      }
      if (data['id'] is String) return data['id'] as String;
    }
    return null;
  }

  static bool _isTransient(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.unknown) {
      return true;
    }
    final status = e.response?.statusCode;
    return status != null && status >= 500;
  }
}

enum _ReplayOutcome { synced, conflict, failed, paused, retryLater }
