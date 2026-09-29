import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:makhzanflow/core/api/offline_cache_interceptor.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _MockAdapter extends Mock implements HttpClientAdapter {}

ResponseBody _jsonBody(Map<String, dynamic> json, int status) =>
    ResponseBody.fromString(
      jsonEncode(json),
      status,
      headers: {Headers.contentTypeHeader: [Headers.jsonContentType]},
    );

Dio _dioWith(HttpClientAdapter adapter, SharedPrefsGetCache cache) {
  final dio = Dio(BaseOptions(baseUrl: 'https://x.test'));
  dio.interceptors.add(OfflineCacheInterceptor(cache: cache));
  dio.httpClientAdapter = adapter;
  return dio;
}

Future<SharedPrefsGetCache> _cache() async {
  SharedPreferences.setMockInitialValues({});
  return SharedPrefsGetCache(prefs: await SharedPreferences.getInstance());
}

void main() {
  setUpAll(() {
    registerFallbackValue(RequestOptions(path: ''));
    registerFallbackValue(Stream<List<int>>.empty());
  });

  group('SharedPrefsGetCache', () {
    test('round-trips an entry', () async {
      final cache = await _cache();
      await cache.save('k1', {'status': 200, 'data': {'a': 1}});
      expect((await cache.load('k1'))?['data'], {'a': 1});
      expect(await cache.load('missing'), isNull);
    });

    test('evicts oldest past the cap', () async {
      final cache = await _cache();
      for (var i = 0; i < SharedPrefsGetCache.cap + 5; i++) {
        await cache.save('k$i', {'status': 200, 'data': i});
      }
      expect(await cache.load('k0'), isNull);
      expect((await cache.load('k${SharedPrefsGetCache.cap + 4}'))?['data'],
          SharedPrefsGetCache.cap + 4);
    });
  });

  group('OfflineCacheInterceptor', () {
    test('serves cached GET on connection loss', () async {
      final cache = await _cache();
      final adapter = _MockAdapter();
      final dio = _dioWith(adapter, cache);

      when(() => adapter.fetch(any(), any(), any()))
          .thenAnswer((_) async => _jsonBody({'data': {'v': 1}}, 200));
      final first = await dio.get('/products');
      expect(first.data, {'data': {'v': 1}});

      when(() => adapter.fetch(any(), any(), any())).thenAnswer((inv) {
        throw DioException(
          requestOptions: inv.positionalArguments.first as RequestOptions,
          type: DioExceptionType.connectionError,
        );
      });
      final second = await dio.get('/products');
      expect(second.data, {'data': {'v': 1}});
      expect(second.requestOptions.extra['offlineCache'], isTrue);
    });

    test('passes the error through with no cache', () async {
      final cache = await _cache();
      final adapter = _MockAdapter();
      final dio = _dioWith(adapter, cache);

      when(() => adapter.fetch(any(), any(), any())).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/nope'),
          type: DioExceptionType.connectionError,
        ),
      );
      expect(() => dio.get('/nope'), throwsA(isA<DioException>()));
    });

    test('never caches POST', () async {
      final cache = await _cache();
      final adapter = _MockAdapter();
      final dio = _dioWith(adapter, cache);

      when(() => adapter.fetch(any(), any(), any()))
          .thenAnswer((_) async => _jsonBody({'data': {'ok': true}}, 200));
      await dio.post('/products', data: {'name': 'x'});
      expect(await cache.load('POST:https://x.test/products'), isNull);
    });
  });
}
