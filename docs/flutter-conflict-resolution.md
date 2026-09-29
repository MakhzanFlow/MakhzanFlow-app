# Flutter — Conflict Resolution & Offline Sync (shipped behavior)

> Backend contract: gated writes send `version` from the last GET; stale versions return
> `409` + `code: "VERSION_CONFLICT"` with `data: { current, attempted }`.
> Missing version returns `400` (programmer error — debug assert, never a dialog).
> Spec: `specs/011-offline-queue-sync-conflicts/` (git-ignored local planning dir).

## 1. Version-conflict channel (single parse point)

`lib/core/api/api_response.dart::mapDioExceptionToFailure` maps `409` + `code ==
"VERSION_CONFLICT"` to `VersionConflictFailure(entity, id, current, attempted)`
(`lib/core/error/failures.dart`); entity/id come from `errors[0]` meta (`record`/`''`
fallback). Any other 409 stays `ConflictFailure`. All data sources return
`Either<Failure, …>` (products migrated off `TaskEither<String, …>`), so UI matches on
`failure is VersionConflictFailure` — no thrown-exception side channel.

## 2. Gated vs LWW writes

| Write | Version sent | Conflict UI |
|---|---|---|
| Product price/stock PUT | `version` (only when price/stock keys present) | Merge dialog |
| Stock adjust | `version` from product cursor (`AdjustStockRequestDto`) | Merge dialog |
| Invoice add-payment (`AddPaymentDto.version`, required) | loaded invoice version; local copy incl. version replaced on success | Merge dialog |
| Invoice cancel (`POST …/cancel {version}`) | loaded invoice version | Merge dialog |
| Customer update, product metadata (name/SKU/barcode/image) | never (`Customer.version` is an informational cursor, never serialized) | none — server `updated_at` wins |

Retry helper: `withMergeRetry` (`lib/core/error/merge_retry.dart`) caps Keep-mine retries
at 3 rounds, then manual-retry guidance. Generic Arabic RTL dialog:
`lib/shared/widgets/version_conflict_dialog.dart` (360dp-safe), wired in add/edit product,
product details (adjust), add-payment, invoice details (cancel), and the needs-review list.

## 3. Offline queue (non-financial, add-new-only)

- FIFO `PendingOpsQueue`, cap 100 (drop-oldest + `AppStrings.queueOverflow` notice),
  persisted as JSON in SharedPreferences (`mf_pending_ops_v1` / `mf_needs_review_v1`).
- **Only connection-loss failures enqueue** (`enqueue_guard.dart`); validation/auth/conflict
  surface immediately; reads never queue.
- **Queueable for replay** (`PendingOpType.isQueueableOffline`): `productCreate`,
  `customerCreate`, `stockAdjust`, `productDelete` only. Money-moving ops (payments, cancels,
  invoice creates, price changes) and edits to existing products/customers require
  connectivity and refuse offline with a clear Arabic message.
- `SyncService` replays one-by-one over the shared Dio client (JWT + `x-company-id`
  injected at replay time, never persisted): 2xx drops, transient backoff (max 5 attempts),
  401 pauses for re-login, `409 VERSION_CONFLICT` parks to needs-review (never
  auto-resolved), other 4xx drop + count failed. `SyncService.retryWithVersion` powers
  Merge "Keep mine" from the review list.
- Offline reads: GET cache (`mf_get_cache_v1`, 50 entries, company-scoped) +
  `OfflineBanner`; offline launch restores session/company/user snapshots
  (`mf_last_user_v1`) and re-validates on reconnect.

## 4. Manual checklist

- [ ] Airplane mode → create product/customer + adjust stock → restart → reconnect → applied in order, "تمت مزامنة N" shown
- [ ] Two devices, same price → second sees Merge (both values); Keep mine → 200 + bumped version
- [ ] Double payment → exactly one charge; customer collision → silent LWW
- [ ] `flutter test` green + `flutter analyze` clean on touched files
