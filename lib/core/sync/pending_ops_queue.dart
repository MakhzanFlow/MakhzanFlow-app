import 'dart:convert';

import 'package:makhzanflow/core/constants/app_constants.dart';
import 'package:makhzanflow/core/sync/pending_op.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// FIFO store for offline mutations + parked replay conflicts.
///
/// Persistence is a JSON list in SharedPreferences (no object DB — payloads are
/// small request bodies; image binaries are never enqueued). Depends on
/// [SharedPreferences] by constructor injection so tests use mock values.
class PendingOpsQueue {
  static int get cap => AppConstants.pendingOpsCap;
  static int get maxAttempts => AppConstants.maxSyncAttempts;

  final SharedPreferences _prefs;

  const PendingOpsQueue({required SharedPreferences prefs}) : _prefs = prefs;

  Future<List<PendingOp>> pending() async => _readActive();

  Future<List<NeedsReviewOp>> needsReview() async => _readReview();

  /// Returns true when the cap forced a drop-oldest.
  Future<bool> enqueue(PendingOp op) async {
    final ops = _readActive();
    var dropped = false;
    if (ops.length >= cap) {
      ops.removeAt(0);
      dropped = true;
    }
    ops.add(op);
    await _prefs.setString(AppConstants.pendingOpsKey, _encode(ops));
    return dropped;
  }

  Future<void> remove(String id) async {
    final ops = _readActive()..removeWhere((e) => e.id == id);
    await _prefs.setString(AppConstants.pendingOpsKey, _encode(ops));
  }

  Future<void> recordAttempt(String id) async {
    final ops = _readActive()
        .map((e) => e.id == id ? e.withAttempt() : e)
        .toList();
    await _prefs.setString(AppConstants.pendingOpsKey, _encode(ops));
  }

  Future<void> parkForReview(NeedsReviewOp item) async {
    await remove(item.base.id);
    final items = _readReview()..add(item);
    await _prefs.setString(
      AppConstants.needsReviewKey,
      jsonEncode(items.map((e) => e.toJson()).toList()),
    );
  }

  Future<void> removeFromReview(String id) async {
    final items = _readReview()..removeWhere((e) => e.base.id == id);
    await _prefs.setString(
      AppConstants.needsReviewKey,
      jsonEncode(items.map((e) => e.toJson()).toList()),
    );
  }

  List<PendingOp> _readActive() {
    final raw = _prefs.getString(AppConstants.pendingOpsKey);
    if (raw == null || raw.isEmpty) return [];
    return (jsonDecode(raw) as List)
        .map((e) => PendingOp.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  List<NeedsReviewOp> _readReview() {
    final raw = _prefs.getString(AppConstants.needsReviewKey);
    if (raw == null || raw.isEmpty) return [];
    return (jsonDecode(raw) as List)
        .map((e) => NeedsReviewOp.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  String _encode(List<PendingOp> ops) =>
      jsonEncode(ops.map((e) => e.toJson()).toList());
}
