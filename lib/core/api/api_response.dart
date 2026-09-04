import 'package:dio/dio.dart';
import '../constants/error_messages.dart';
import '../error/failures.dart';

/// Standard Success Envelope: `{ "success": true, "data": ... }`
class ApiResponse<T> {
  final bool success;
  final T? data;

  const ApiResponse({required this.success, this.data});

  factory ApiResponse.fromJson(Map<String, dynamic> json, T Function(dynamic) fromJson) {
    return ApiResponse(
      success: json['success'] as bool? ?? true,
      data: json['data'] == null ? null : fromJson(json['data']),
    );
  }
}

/// Paginated List Envelope: `{ "success": true, "data": [...], "pagination": {...} }`
class PaginatedResponse<T> {
  final bool success;
  final List<T> items;
  final int? page;
  final int? pageSize;
  final int? total;
  final int? totalPages;

  const PaginatedResponse({
    required this.success,
    this.items = const [],
    this.page,
    this.pageSize,
    this.total,
    this.totalPages,
  });

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic) fromJson,
  ) {
    final pagination = json['pagination'] as Map<String, dynamic>?;
    return PaginatedResponse(
      success: json['success'] as bool? ?? true,
      items: (json['data'] as List?)
              ?.map((e) => fromJson(e))
              .toList() ??
          const [],
      page: pagination?['page'] as int?,
      pageSize: pagination?['pageSize'] as int? ?? pagination?['limit'] as int?,
      total: pagination?['total'] as int?,
      totalPages: pagination?['totalPages'] as int? ?? pagination?['pages'] as int?,
    );
  }
}

/// Maps Dio exceptions to domain Failures based on HTTP status.
Failure mapDioExceptionToFailure(DioException e) {
  switch (e.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
      return NetworkFailure(ErrorMessages.connectionFailed);
    case DioExceptionType.connectionError:
      return NetworkFailure(ErrorMessages.connectionFailed);
    case DioExceptionType.cancel:
      return NetworkFailure(ErrorMessages.unexpectedError);
    case DioExceptionType.badCertificate:
      return ServerFailure(ErrorMessages.unexpectedError);
    case DioExceptionType.transformTimeout:
      return NetworkFailure(ErrorMessages.connectionFailed);
    case DioExceptionType.badResponse:
      final status = e.response?.statusCode;
      final message = _messageFromResponse(e.response);
      return switch (status) {
        400 => ValidationFailure(message),
        401 => UnauthorizedFailure(message),
        403 => ForbiddenFailure(message),
        404 => NotFoundFailure(message),
        409 => ConflictFailure(message),
        429 => RateLimitFailure(message),
        _ => ServerFailure(message),
      };
    case DioExceptionType.unknown:
      return NetworkFailure(ErrorMessages.connectionFailed);
  }
}

String _messageFromResponse(Response<dynamic>? response) {
  try {
    final data = response?.data;
    if (data is Map<String, dynamic>) {
      final message = data['message'];
      if (message is String && message.isNotEmpty) return message;
    }
  } catch (_) {
    // Fall through to default
  }
  return ErrorMessages.unexpectedError;
}
