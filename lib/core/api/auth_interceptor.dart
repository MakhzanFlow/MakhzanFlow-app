import 'dart:async';

import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import '../constants/api_endpoints.dart';
import '../storage/token_storage.dart';

/// Dio interceptor that injects JWT + company headers and transparently
/// refreshes the access token on 401, retrying the original request.
class AuthInterceptor extends Interceptor {
  final TokenStorage _tokenStorage;
  final Dio _dio;
  bool _isRefreshing = false;
  final List<_PendingRequest> _pendingRequests = [];

  AuthInterceptor(this._tokenStorage, this._dio);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Skip token injection for public auth endpoints.
    if (_isPublicEndpoint(options.path)) {
      return handler.next(options);
    }

    // Resolved per-request: Intl.getCurrentLocale() is not finalized until
    // localizations load, so it must not be captured at construction time.
    final isArabic = Intl.getCurrentLocale().toLowerCase().startsWith('ar');
    options.headers['Accept-Language'] = isArabic ? 'ar' : 'en';

    final accessToken = await _tokenStorage.accessToken;
    if (accessToken != null && accessToken.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }

    final companyId = await _tokenStorage.companyId;
    if (companyId != null && companyId.isNotEmpty) {
      options.headers['x-company-id'] = companyId;
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final statusCode = err.response?.statusCode;

    if (statusCode != 401) {
      return handler.next(err);
    }

    // The refresh call itself failing means the session is dead.
    if (_isRefreshEndpoint(err.requestOptions.path)) {
      await _tokenStorage.clearAll();
      return handler.next(err);
    }

    if (!_isRefreshing) {
      _isRefreshing = true;
      try {
        final refreshToken = await _tokenStorage.refreshToken;
        if (refreshToken == null || refreshToken.isEmpty) {
          await _tokenStorage.clearAll();
          return handler.next(err);
        }

        final newTokens = await _refreshTokens(refreshToken);
        if (newTokens == null) {
          await _tokenStorage.clearAll();
          return handler.next(err);
        }

        // Retry the original request with the fresh token.
        err.requestOptions.headers['Authorization'] =
            'Bearer ${newTokens.accessToken}';
        try {
          final retryResponse = await _dio.fetch(err.requestOptions);
          return handler.resolve(retryResponse);
        } on DioException catch (retryErr) {
          // Only a 401 after a successful refresh means the session is dead.
          // Network errors on the retry must NOT log the user out.
          if (retryErr.response?.statusCode == 401) {
            await _tokenStorage.clearAll();
          }
          return handler.next(retryErr);
        }
      } catch (_) {
        // The refresh call itself failed — session can't be restored.
        await _tokenStorage.clearAll();
        return handler.next(err);
      } finally {
        _isRefreshing = false;
        _flushQueue();
      }
    } else {
      // Refresh already in progress — queue this request and wait.
      final completer = Completer<Response<dynamic>>();
      _pendingRequests.add(_PendingRequest(err.requestOptions, completer));
      try {
        final response = await completer.future;
        return handler.resolve(response);
      } catch (_) {
        return handler.next(err);
      }
    }
  }

  Future<({String accessToken, String refreshToken})?> _refreshTokens(
    String refreshToken,
  ) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.refresh,
      data: {'refreshToken': refreshToken},
      options: Options(
        headers: {'Authorization': null},
      ),
    );

    final data = response.data?['data'];
    if (data is! Map<String, dynamic>) return null;

    final accessToken = data['accessToken'] as String?;
    final newRefreshToken = data['refreshToken'] as String?;
    if (accessToken == null || newRefreshToken == null) return null;

    await _tokenStorage.saveTokens(
      accessToken: accessToken,
      refreshToken: newRefreshToken,
    );

    return (accessToken: accessToken, refreshToken: newRefreshToken);
  }

  void _flushQueue() {
    final pending = List<_PendingRequest>.from(_pendingRequests);
    _pendingRequests.clear();

    for (final request in pending) {
      _tokenStorage.accessToken.then((token) async {
        try {
          if (token != null && token.isNotEmpty) {
            request.requestOptions.headers['Authorization'] = 'Bearer $token';
            final response = await _dio.fetch(request.requestOptions);
            request.completer.complete(response);
          } else {
            request.completer.completeError(StateError('Session expired'));
          }
        } catch (e) {
          request.completer.completeError(e);
        }
      }).catchError((e) {
        request.completer.completeError(e);
      });
    }
  }

  bool _isPublicEndpoint(String path) {
    return path == ApiEndpoints.login ||
        path == ApiEndpoints.register ||
        path == ApiEndpoints.verifyEmail ||
        path == ApiEndpoints.verifyEmailResend ||
        path == ApiEndpoints.refresh;
  }

  bool _isRefreshEndpoint(String path) => path == ApiEndpoints.refresh;
}

class _PendingRequest {
  final RequestOptions requestOptions;
  final Completer<Response<dynamic>> completer;

  _PendingRequest(this.requestOptions, this.completer);
}
