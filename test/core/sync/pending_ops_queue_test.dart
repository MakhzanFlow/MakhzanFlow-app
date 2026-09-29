import 'package:flutter_test/flutter_test.dart';
import 'package:makhzanflow/core/sync/pending_op.dart';
import 'package:makhzanflow/core/sync/pending_ops_queue.dart';
import 'package:shared_preferences/shared_preferences.dart';

PendingOp _op(String id, {int version = 5}) => PendingOp(
      id: id,
      createdAt: DateTime.utc(2026, 9, 28, 10, 0, int.parse(id)),
      opType: PendingOpType.productPricing,
      method: 'PUT',
      path: '/products/abc',
      body: {'price': 55.0, 'stock': 80, 'version': version},
      companyId: 'company-1',
    );

Future<PendingOpsQueue> _queue() async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  return PendingOpsQueue(prefs: prefs);
}

void main() {
  group('PendingOpsQueue', () {
    test('enqueue persists ops in FIFO order', () async {
      final queue = await _queue();
      await queue.enqueue(_op('1'));
      await queue.enqueue(_op('2'));

      final pending = await queue.pending();
      expect(pending.map((e) => e.id), ['1', '2']);
    });

    test('queue survives reload (new instance, same prefs)', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      await PendingOpsQueue(prefs: prefs).enqueue(_op('1'));

      final reloaded = await PendingOpsQueue(prefs: prefs).pending();
      expect(reloaded.map((e) => e.id), ['1']);
    });

    test('cap drops oldest with overflow signal', () async {
      final queue = await _queue();
      var overflowed = false;
      for (var i = 0; i < PendingOpsQueue.cap + 1; i++) {
        final dropped = await queue.enqueue(_op('$i'));
        if (dropped) overflowed = true;
      }
      expect(overflowed, isTrue);
      final pending = await queue.pending();
      expect(pending.length, PendingOpsQueue.cap);
      expect(pending.first.id, '1');
    });

    test('remove + recordAttempt work', () async {
      final queue = await _queue();
      await queue.enqueue(_op('1'));
      await queue.recordAttempt('1');
      var pending = await queue.pending();
      expect(pending.single.attempts, 1);
      await queue.remove('1');
      pending = await queue.pending();
      expect(pending, isEmpty);
    });

    test('needs-review round-trips with payloads', () async {
      final queue = await _queue();
      final review = NeedsReviewOp(
        base: _op('9'),
        current: const {'price': 60.0, 'version': 6},
        attempted: const {'price': 55.0},
        conflictedAt: DateTime.utc(2026, 9, 28),
        entity: 'product',
        entityId: 'abc',
      );
      await queue.parkForReview(review);
      final items = await queue.needsReview();
      expect(items.single.current['price'], 60.0);
      expect(items.single.attempted['price'], 55.0);
      await queue.removeFromReview('9');
      expect(await queue.needsReview(), isEmpty);
    });
  });
}
