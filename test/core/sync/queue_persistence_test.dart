import 'package:flutter_test/flutter_test.dart';
import 'package:makhzanflow/core/sync/pending_op.dart';
import 'package:makhzanflow/core/sync/pending_ops_queue.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// T014: mixed active + needs-review payloads survive a full reload.
void main() {
  test('active and review queues persist across reload', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final queue = PendingOpsQueue(prefs: prefs);

    await queue.enqueue(PendingOp.createNew(
      opType: PendingOpType.invoicePayment,
      method: 'POST',
      path: '/invoices/inv-1/payments',
      body: const {'amount': 50.0, 'method': 'cash', 'version': 3},
      companyId: 'co-1',
    ));
    await queue.parkForReview(NeedsReviewOp(
      base: PendingOp.createNew(
        opType: PendingOpType.productPricing,
        method: 'PUT',
        path: '/products/p1',
        body: const {'price': 55.0, 'version': 5},
        companyId: 'co-1',
      ),
      current: const {'price': 60.0, 'version': 6},
      attempted: const {'price': 55.0},
      conflictedAt: DateTime.utc(2026, 9, 28),
      entity: 'product',
      entityId: 'p1',
    ));

    // Simulate restart: brand-new queue over the same prefs.
    final reloaded = PendingOpsQueue(prefs: prefs);
    final pending = await reloaded.pending();
    final review = await reloaded.needsReview();

    expect(pending.single.body['version'], 3);
    expect(review.single.current['version'], 6);
    expect(review.single.entityId, 'p1');
  });
}
