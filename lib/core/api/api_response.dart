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
/// The backend failure envelope is `{ success:false, message, errors:[] }`
/// where `errors` is a list of `{ field, message }` or plain strings.
/// `errors[]` is folded into [ValidationFailure.fieldErrors] and the first
/// entry is used as the message fallback when `message` is absent.
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
      final parsed = _parseErrorBody(e.response);
      return switch (status) {
        400 => ValidationFailure(parsed.message, parsed.fieldErrors),
        401 => UnauthorizedFailure(parsed.message),
        403 => ForbiddenFailure(parsed.message),
        404 => NotFoundFailure(parsed.message),
        409 => ConflictFailure(parsed.message),
        429 => RateLimitFailure(parsed.message),
        _ => ServerFailure(parsed.message),
      };
    case DioExceptionType.unknown:
      return NetworkFailure(ErrorMessages.connectionFailed);
  }
}

({String message, Map<String, String> fieldErrors}) _parseErrorBody(
  Response<dynamic>? response,
) {
  var message = ErrorMessages.unexpectedError;
  final fieldErrors = <String, String>{};
  try {
    final data = response?.data;
    if (data is Map<String, dynamic>) {
      final msg = data['message'];
      if (msg is String && msg.isNotEmpty) message = msg;
      final errors = data['errors'];
      if (errors is List && errors.isNotEmpty) {
        var firstFallback = '';
        for (final entry in errors) {
          if (entry is Map) {
            final field = entry['field']?.toString();
            final entryMsg = entry['message']?.toString();
            if (field != null &&
                field.isNotEmpty &&
                entryMsg != null &&
                entryMsg.isNotEmpty) {
              fieldErrors[field] = entryMsg;
              firstFallback = firstFallback.isEmpty ? entryMsg : firstFallback;
            } else if (entryMsg != null && entryMsg.isNotEmpty) {
              firstFallback = firstFallback.isEmpty ? entryMsg : firstFallback;
            }
          } else if (entry is String && entry.isNotEmpty) {
            firstFallback = firstFallback.isEmpty ? entry : firstFallback;
          }
        }
        // No top-level message — use the first detail entry.
        if (message == ErrorMessages.unexpectedError &&
            firstFallback.isNotEmpty) {
          message = firstFallback;
        }
      }
    }
  } catch (_) {
    // Fall through to defaults
  }
  return (message: message, fieldErrors: fieldErrors);
}
