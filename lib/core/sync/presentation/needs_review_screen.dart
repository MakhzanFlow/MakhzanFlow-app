import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:makhzanflow/core/constants/app_strings.dart';
import 'package:makhzanflow/core/di/service_locator.dart';
import 'package:makhzanflow/core/error/failures.dart';
import 'package:makhzanflow/core/error/merge_retry.dart';
import 'package:makhzanflow/core/sync/pending_op.dart';
import 'package:makhzanflow/core/sync/pending_ops_queue.dart';
import 'package:makhzanflow/core/sync/sync_cubit.dart';
import 'package:makhzanflow/core/sync/sync_service.dart';
import 'package:makhzanflow/core/theme/mf_tokens.dart';
import 'package:makhzanflow/core/widgets/app_snackbar.dart';
import 'package:makhzanflow/shared/widgets/version_conflict_dialog.dart';

/// Lists replay ops parked with `409 VERSION_CONFLICT` (spec US3).
/// Each card shows the entity, conflicting fields, and both values;
/// "Use server" discards the local attempt. "Keep mine" retry lands in US4.
class NeedsReviewScreen extends StatefulWidget {
  const NeedsReviewScreen({super.key});

  @override
  State<NeedsReviewScreen> createState() => _NeedsReviewScreenState();
}

class _NeedsReviewScreenState extends State<NeedsReviewScreen> {
  List<NeedsReviewOp> _items = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    final items = await sl<PendingOpsQueue>().needsReview();
    if (!mounted) return;
    setState(() {
      _items = items;
      _loading = false;
    });
  }

  Future<void> _discard(NeedsReviewOp item) async {
    await sl<PendingOpsQueue>().removeFromReview(item.base.id);
    await _afterChange();
  }

  Future<void> _afterChange() async {
    if (mounted && sl.isRegistered<SyncCubit>()) {
      context.read<SyncCubit>().refreshCounts();
    }
    await _reload();
  }

  /// Merge "Keep mine" (guide §6): retries the parked op with the fresh server
  /// version via [withMergeRetry]; a second 409 refreshes the parked payload
  /// and loops the dialog (max rounds), then asks for a manual retry.
  Future<void> _resolveWithMine(NeedsReviewOp item) async {
    try {
      await withMergeRetry<void>(
        version: serverVersionOf(_asConflict(item)),
        action: (v) => sl<SyncService>().retryWithVersion(item, v).then(
              (r) => r.fold(
                (failure) {
                  if (failure is VersionConflictFailure) throw failure;
                  throw _ResolveAborted(failure.message);
                },
                (_) {},
              ),
            ),
        onConflict: (c) => _showMerge(item, c),
      );
      if (!mounted) return;
      AppSnackbar.success(context, AppStrings.syncedCount(1));
    } on _ResolveAborted catch (e) {
      if (!mounted) return;
      AppSnackbar.error(context, e.message);
    } on VersionConflictFailure {
      if (!mounted) return;
      AppSnackbar.error(context, AppStrings.retryManually);
    } finally {
      await _afterChange();
    }
  }

  Future<int?> _showMerge(
    NeedsReviewOp item,
    VersionConflictFailure conflict,
  ) async {
    final choice = await showVersionConflictDialog(
      context,
      rows: _rowsFor(
        attempted: conflict.attempted ?? item.attempted,
        current: conflict.current ?? item.current,
      ),
    );
    if (choice != MergeChoice.mine) return null;
    return serverVersionOf(conflict);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? MFTokens.backgroundDark : MFTokens.backgroundLight;
    final textSecondary =
        isDark ? MFTokens.textSecondaryDark : MFTokens.textSecondaryLight;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text(AppStrings.needsReviewTitle),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
              ? Center(
                  child: Text(
                    AppStrings.needsReviewEmpty,
                    style: TextStyle(color: textSecondary, fontFamily: 'Cairo'),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(MFTokens.sp16),
                  itemCount: _items.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: MFTokens.sp12),
                  itemBuilder: (context, index) => _ReviewCard(
                    item: _items[index],
                    onDiscard: _discard,
                    onKeepMine: _resolveWithMine,
                  ),
                ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final NeedsReviewOp item;
  final Future<void> Function(NeedsReviewOp) onDiscard;
  final Future<void> Function(NeedsReviewOp) onKeepMine;

  const _ReviewCard({
    required this.item,
    required this.onDiscard,
    required this.onKeepMine,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final card = isDark ? MFTokens.surfaceDark : MFTokens.surfaceLight;
    final textPrimary =
        isDark ? MFTokens.textPrimaryDark : MFTokens.textPrimaryLight;
    final textSecondary =
        isDark ? MFTokens.textSecondaryDark : MFTokens.textSecondaryLight;
    final rows = _rowsFor(attempted: item.attempted, current: item.current);
    return Container(
      padding: const EdgeInsets.all(MFTokens.sp16),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(MFTokens.radiusLG),
        border: Border.all(
          color: isDark ? MFTokens.borderDark : MFTokens.borderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${item.entity} • ${item.entityId}',
            style: TextStyle(
              color: textPrimary,
              fontFamily: 'Cairo',
              fontWeight: FontWeight.w700,
              fontSize: MFTokens.fontMD,
            ),
          ),
          const SizedBox(height: MFTokens.sp8),
          for (final row in rows)
            Padding(
              padding: const EdgeInsets.only(bottom: MFTokens.sp4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${AppStrings.conflictMine} (${row.label}): ${row.mine}',
                      style: TextStyle(
                        color: textSecondary,
                        fontFamily: 'Cairo',
                        fontSize: MFTokens.fontSM,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: MFTokens.sp8),
                  Expanded(
                    child: Text(
                      '${AppStrings.conflictServer}: ${row.server}',
                      textAlign: TextAlign.end,
                      style: TextStyle(
                        color: textPrimary,
                        fontFamily: 'Cairo',
                        fontSize: MFTokens.fontSM,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: MFTokens.sp12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => onDiscard(item),
                  child: Text(AppStrings.useServer),
                ),
              ),
              const SizedBox(width: MFTokens.sp8),
              Expanded(
                child: FilledButton(
                  onPressed: () => onKeepMine(item),
                  child: Text(AppStrings.keepMine),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Builds Merge dialog rows from attempted vs server maps (shared by the card
/// preview and the dialog so both show identical fields).
List<ConflictFieldRow> _rowsFor({
  required Map<String, dynamic> attempted,
  required Map<String, dynamic> current,
}) {
  return {
    ...attempted.keys,
    ...current.keys,
  }
      .where((k) => k != 'id' && k != 'version')
      .map((field) => ConflictFieldRow(
            label: field,
            mine: '${attempted[field] ?? '—'}',
            server: '${current[field] ?? '—'}',
          ))
      .toList();
}

VersionConflictFailure _asConflict(NeedsReviewOp item) =>
    VersionConflictFailure(
      '',
      entity: item.entity,
      id: item.entityId,
      current: item.current,
      attempted: item.attempted,
    );

/// Non-conflict failure during "Keep mine" resolution — aborts the retry loop.
class _ResolveAborted implements Exception {
  final String message;
  const _ResolveAborted(this.message);
}
