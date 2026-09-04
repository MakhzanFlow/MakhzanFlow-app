import 'package:dio/dio.dart';

import '../constants/app_constants.dart';
import '../env.dart';
import '../storage/token_storage.dart';
import 'auth_interceptor.dart';

/// Dio wrapper configured from `MakhzanFlowEnv` and `AppConstants`.
/// The refresh call uses a separate, interceptor-free Dio to avoid recursion.
class ApiClient {
  final Dio dio;
  final Dio _refreshDio;

  ApiClient({required TokenStorage tokenStorage})
      : _refreshDio = Dio(),
        dio = Dio() {
    final baseUrl = MakhzanFlowEnv.apiBaseUrl;
    final timeout = Duration(milliseconds: AppConstants.receiveTimeoutMs);

    _refreshDio.options = BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: Duration(milliseconds: AppConstants.connectTimeoutMs),
      receiveTimeout: timeout,
      headers: {'Content-Type': 'application/json'},
    );

    // Accept-Language is resolved per-request in AuthInterceptor because
    // Intl.getCurrentLocale() is not finalized until localizations load.
    dio.options = BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: Duration(milliseconds: AppConstants.connectTimeoutMs),
      receiveTimeout: timeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    dio.interceptors.add(AuthInterceptor(tokenStorage, _refreshDio));
  }
}
