import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:makhzanflow/core/constants/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Bounded last-good GET response store (JSON in SharedPreferences).
/// One map under a single key; insertion-ordered, oldest evicted past [cap].
class SharedPrefsGetCache {
  static int get cap => AppConstants.getCacheCap;

  final SharedPreferences _prefs;

  const SharedPrefsGetCache({required SharedPreferences prefs})
      : _prefs = prefs;

  Future<void> save(String key, Map<String, dynamic> entry) async {
    final all = _readAll();
    all.remove(key);
    all[key] = entry;
    while (all.length > cap) {
      all.remove(all.keys.first);
    }
    try {
      await _prefs.setString(AppConstants.getCacheKey, jsonEncode(all));
    } catch (_) {
      // Best-effort cache: non-encodable payloads are skipped silently.
    }
  }

  Future<Map<String, dynamic>?> load(String key) async {
    final entry = _readAll()[key];
    if (entry is Map<String, dynamic>) return Map<String, dynamic>.from(entry);
    return null;
  }

  Map<String, Map<String, dynamic>> _readAll() {
    try {
      final raw = _prefs.getString(AppConstants.getCacheKey);
      if (raw == null || raw.isEmpty) return {};
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return {};
      return decoded.map<String, Map<String, dynamic>>(
        (k, v) => MapEntry(
          k.toString(),
          v is Map ? Map<String, dynamic>.from(v) : <String, dynamic>{},
        ),
      );
    } catch (_) {
      return {};
    }
  }
}

/// Stale-while-offline Dio interceptor: caches successful GET responses and
/// serves them when the request fails from connection loss. POST/PUT/DELETE
/// are never cached. Served responses carry `extra['offlineCache'] == true`
/// so future UI can mark stale data.
class OfflineCacheInterceptor extends Interceptor {
  final SharedPrefsGetCache _cache;

  const OfflineCacheInterceptor({required SharedPrefsGetCache cache})
      : _cache = cache;

  @override
  void onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) async {
    final options = response.requestOptions;
    if (options.method == 'GET' && response.statusCode == 200) {
      await _cache.save(_key(options), {
        'status': response.statusCode,
        'data': response.data,
      });
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.requestOptions.method == 'GET' && _isConnectionLoss(err)) {
      final cached = await _cache.load(_key(err.requestOptions));
      if (cached != null) {
        final options = err.requestOptions..extra['offlineCache'] = true;
        return handler.resolve(Response(
          requestOptions: options,
          statusCode: cached['status'] as int? ?? 200,
          data: cached['data'],
        ));
      }
    }
    handler.next(err);
  }

  static String _key(RequestOptions options) {
    final company = options.headers['x-company-id']?.toString() ?? '';
    return 'GET:$company|${options.uri}';
  }

  static bool _isConnectionLoss(DioException e) {
    if (e.response != null) return false;
    return switch (e.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout ||
      DioExceptionType.connectionError ||
      DioExceptionType.unknown =>
        true,
      DioExceptionType.cancel ||
      DioExceptionType.badCertificate ||
      DioExceptionType.badResponse ||
      DioExceptionType.transformTimeout =>
        false,
    };
  }
}
