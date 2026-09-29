import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:makhzanflow/core/sync/connectivity_monitor.dart';
import 'package:makhzanflow/core/sync/create_image_uploader.dart';
import 'package:makhzanflow/core/sync/pending_op.dart';
import 'package:makhzanflow/core/sync/pending_ops_queue.dart';
import 'package:makhzanflow/core/sync/sync_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeMonitor implements ConnectivityMonitor {
  @override
  Stream<bool> get onStatusChanged => const Stream.empty();

  @override
  Future<bool> get isOnline async => true;
}

class _MockDio extends Mock implements Dio {}

class _RecordingUploader implements PendingCreateImageUploader {
  String? serverId;
  String? imagePath;
  int calls = 0;

  @override
  bool supports(PendingOpType type) =>
      type == PendingOpType.productCreate;

  @override
  Future<bool> upload({
    required String serverId,
    required String imagePath,
    required String companyId,
  }) async {
    calls++;
    this.serverId = serverId;
    this.imagePath = imagePath;
    return true;
  }
}

Response<Map<String, dynamic>> _created(String id) => Response(
      requestOptions: RequestOptions(path: ''),
      statusCode: 201,
      data: {
        'success': true,
        'data': {'id': id, 'name': 'Rice'}
      },
    );

void main() {
  setUpAll(() {
    registerFallbackValue(RequestOptions(path: ''));
    registerFallbackValue(Options());
  });

  Future<File> imageFile() async {
    final file = File(
      '${Directory.systemTemp.path}/pending-img-${DateTime.now().microsecondsSinceEpoch}.jpg',
    );
    await file.writeAsBytes([0, 1, 2, 3]);
    return file;
  }

  group('post-create image upload', () {
    test('uploads queued image with the server id after replay', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final queue = PendingOpsQueue(prefs: prefs);
      final image = await imageFile();
      addTearDown(() async {
        if (await image.exists()) await image.delete();
      });
      await queue.enqueue(PendingOp.createNew(
        opType: PendingOpType.productCreate,
        method: 'POST',
        path: '/products/',
        body: const {'name': 'Rice'},
        companyId: 'co-1',
        imageLocalPath: image.path,
      ));

      final dio = _MockDio();
      when(
        () => dio.request(
          any(),
          data: any(named: 'data'),
          options: any(named: 'options'),
        ),
      ).thenAnswer((_) async => _created('srv-1'));
      final uploader = _RecordingUploader();
      final svc = SyncService(
        queue: queue,
        dio: dio,
        monitor: _FakeMonitor(),
        imageUploaders: [uploader],
      );

      final result = await svc.syncNow();

      expect(result.synced, 1);
      expect(uploader.calls, 1);
      expect(uploader.serverId, 'srv-1');
      expect(uploader.imagePath, image.path);
    });

    test('skips upload without image path', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final queue = PendingOpsQueue(prefs: prefs);
      await queue.enqueue(PendingOp.createNew(
        opType: PendingOpType.productCreate,
        method: 'POST',
        path: '/products/',
        body: const {'name': 'Rice'},
        companyId: 'co-1',
      ));

      final dio = _MockDio();
      when(
        () => dio.request(
          any(),
          data: any(named: 'data'),
          options: any(named: 'options'),
        ),
      ).thenAnswer((_) async => _created('srv-1'));
      final uploader = _RecordingUploader();
      final svc = SyncService(
        queue: queue,
        dio: dio,
        monitor: _FakeMonitor(),
        imageUploaders: [uploader],
      );

      await svc.syncNow();

      expect(uploader.calls, 0);
    });

    test('skips upload when the local file is gone', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final queue = PendingOpsQueue(prefs: prefs);
      await queue.enqueue(PendingOp.createNew(
        opType: PendingOpType.productCreate,
        method: 'POST',
        path: '/products/',
        body: const {'name': 'Rice'},
        companyId: 'co-1',
        imageLocalPath: '/nope/missing.jpg',
      ));

      final dio = _MockDio();
      when(
        () => dio.request(
          any(),
          data: any(named: 'data'),
          options: any(named: 'options'),
        ),
      ).thenAnswer((_) async => _created('srv-1'));
      final uploader = _RecordingUploader();
      final svc = SyncService(
        queue: queue,
        dio: dio,
        monitor: _FakeMonitor(),
        imageUploaders: [uploader],
      );

      final result = await svc.syncNow();

      expect(result.synced, 1);
      expect(uploader.calls, 0);
    });
  });
}
