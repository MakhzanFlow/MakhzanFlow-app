import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:makhzanflow/core/sync/connectivity_monitor.dart';
import 'package:makhzanflow/core/sync/pending_op.dart';
import 'package:makhzanflow/core/sync/pending_ops_queue.dart';
import 'package:makhzanflow/core/sync/sync_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _MockDio extends Mock implements Dio {}

class _FakeMonitor implements ConnectivityMonitor {
  final _controller = StreamController<bool>.broadcast();
  bool online = true;

  @override
  Stream<bool> get onStatusChanged => _controller.stream;

  @override
  Future<bool> get isOnline async => online;

  void dispose() => _controller.close();
}

Response<Map<String, dynamic>> _ok() => Response(
      requestOptions: RequestOptions(path: ''),
      statusCode: 200,
      data: const {'success': true, 'data': {}},
    );

Future<SyncService> _service({
  required PendingOpsQueue queue,
  required Dio dio,
  ConnectivityMonitor? monitor,
}) async {
  final svc = SyncService(
    queue: queue,
    dio: dio,
    monitor: monitor ?? _FakeMonitor(),
  );
  return svc;
}

PendingOp _op(String id, PendingOpType type) => PendingOp(
      id: id,
      createdAt: DateTime.utc(2026, 9, 28),
      opType: type,
      method: 'PUT',
      path: '/products/p1',
      body: const {'price': 55.0, 'version': 5},
      companyId: 'co-1',
    );

PendingOp _pricing(String id) => _op(id, PendingOpType.productPricing);

void main() {
  setUpAll(() {
    registerFallbackValue(RequestOptions(path: ''));
    registerFallbackValue(Options());
  });

  group('SyncService replay', () {
    test('T022: replays FIFO and drops on 2xx', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final queue = PendingOpsQueue(prefs: prefs);
      await queue.enqueue(_op('1', PendingOpType.productMetadata));
      await queue.enqueue(_op('2', PendingOpType.productMetadata));

      final dio = _MockDio();
      final paths = <String>[];
      when(
        () => dio.request(
          any(),
          data: any(named: 'data'),
          options: any(named: 'options'),
        ),
      ).thenAnswer((inv) async {
        paths.add(inv.positionalArguments.first as String);
        return _ok();
      });

      final svc = await _service(queue: queue, dio: dio);
      final result = await svc.syncNow();

      expect(paths, ['/products/p1', '/products/p1']);
      expect(result.synced, 2);
      expect(await queue.pending(), isEmpty);
    });

    test('T023: transient failure stays queued with attempts++ and         continues',
        () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final queue = PendingOpsQueue(prefs: prefs);
      await queue.enqueue(_op('1', PendingOpType.productMetadata));
      await queue.enqueue(_op('2', PendingOpType.productMetadata));

      final dio = _MockDio();
      var calls = 0;
      when(
        () => dio.request(
          any(),
          data: any(named: 'data'),
          options: any(named: 'options'),
        ),
      ).thenAnswer((_) async {
        calls++;
        if (calls == 1) {
          throw DioException(
            requestOptions: RequestOptions(path: ''),
            type: DioExceptionType.connectionError,
          );
        }
        return _ok();
      });

      final svc = await _service(queue: queue, dio: dio);
      final result = await svc.syncNow();

      expect(result.synced, 1);
      final pending = await queue.pending();
      expect(pending.single.id, '1');
      expect(pending.single.attempts, 1);
    });

    test('financial ops are dropped without replay (online-only policy)',
        () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final queue = PendingOpsQueue(prefs: prefs);
      await queue.enqueue(_pricing('1'));

      final dio = _MockDio();
      final svc = await _service(queue: queue, dio: dio);
      final result = await svc.syncNow();

      verifyNever(() => dio.request(
            any(),
            data: any(named: 'data'),
            options: any(named: 'options'),
          ));
      expect(result.failed, 1);
      expect(await queue.pending(), isEmpty);
    });

    test('T028: 409 VERSION_CONFLICT parks to needs-review', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final queue = PendingOpsQueue(prefs: prefs);
      await queue.enqueue(_op('1', PendingOpType.stockAdjust));

      final dio = _MockDio();
      when(
        () => dio.request(
          any(),
          data: any(named: 'data'),
          options: any(named: 'options'),
        ),
      ).thenThrow(DioException(
        requestOptions: RequestOptions(path: ''),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: ''),
          statusCode: 409,
          data: {
            'success': false,
            'message': 'Product was modified by another user',
            'code': 'VERSION_CONFLICT',
            'errors': [
              {'entity': 'product', 'id': 'p1'}
            ],
            'data': {
              'current': {'price': 60.0, 'version': 6},
              'attempted': {'price': 55.0},
            },
          },
        ),
      ));

      final svc = await _service(queue: queue, dio: dio);
      final result = await svc.syncNow();

      expect(result.conflicts, 1);
      expect(await queue.pending(), isEmpty);
      final review = await queue.needsReview();
      expect(review.single.current['price'], 60.0);
      expect(review.single.entity, 'product');
    });
  });
}
