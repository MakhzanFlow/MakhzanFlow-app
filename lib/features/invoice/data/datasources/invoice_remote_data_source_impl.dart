import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:makhzanflow/core/api/api_client.dart';
import 'package:makhzanflow/core/api/api_response.dart';
import 'package:makhzanflow/core/constants/api_endpoints.dart';
import 'package:makhzanflow/core/constants/error_messages.dart';
import 'package:makhzanflow/core/error/failures.dart';
import 'package:makhzanflow/features/invoice/data/datasources/invoice_remote_data_source.dart';
import 'package:makhzanflow/features/invoice/data/models/add_payment_dto.dart';
import 'package:makhzanflow/features/invoice/data/models/invoice_create_dto.dart';
import 'package:makhzanflow/features/invoice/data/models/invoice_model.dart';
import 'package:makhzanflow/features/invoice/domain/entities/invoice_status.dart';

class InvoiceRemoteDataSourceImpl implements InvoiceRemoteDataSource {
  final ApiClient _apiClient;

  InvoiceRemoteDataSourceImpl({required ApiClient apiClient}) : _apiClient = apiClient;

  @override
  Future<Either<Failure, InvoiceModel>> createInvoice(
    InvoiceCreateDto inputDto,
  ) async {
    try {
      final response = await _apiClient.dio.post(
        ApiEndpoints.invoices,
        data: inputDto.toJson(),
      );
      final data = _dataOrThrow(response);
      return Right(InvoiceModel.fromJson(data));
    } on DioException catch (e) {
      return Left(_mapDioError(e));
    } catch (_) {
      return Left(ServerFailure(ErrorMessages.unexpectedError));
    }
  }

  @override
  Future<Either<Failure, InvoiceModel>> addPayment(AddPaymentDto inputDto) async {
    try {
      final response = await _apiClient.dio.post(
        ApiEndpoints.invoicePayments(inputDto.invoiceId),
        data: inputDto.toJson(),
      );
      final data = _dataOrThrow(response);
      return Right(InvoiceModel.fromJson(data));
    } on DioException catch (e) {
      return Left(_mapDioError(e));
    } catch (_) {
      return Left(ServerFailure(ErrorMessages.unexpectedError));
    }
  }

  @override
  Future<Either<Failure, InvoiceModel>> getInvoice(
    String id,
    String companyId,
  ) async {
    // companyId is not sent as query param — tenant isolation is enforced
    // server-side via x-company-id header injected by AuthInterceptor.
    // Keep param for backward-compat callers but assert non-empty in debug.
    assert(companyId.isNotEmpty, 'getInvoice called with empty companyId');
    try {
      final response = await _apiClient.dio.get(
        ApiEndpoints.invoiceById(id),
      );
      final data = _dataOrThrow(response);
      return Right(InvoiceModel.fromJson(data));
    } on DioException catch (e) {
      return Left(_mapDioError(e));
    } catch (_) {
      return Left(ServerFailure(ErrorMessages.unexpectedError));
    }
  }

  @override
  Future<Either<Failure, List<InvoiceModel>>> getInvoices({
    required String companyId,
    List<String>? statusFilter,
    String? customerId,
    int? limit,
    int? offset,
    String? search,
    String? sort,
    String? order,
    String? startDate,
    String? endDate,
  }) async {
    assert(companyId.isNotEmpty, 'getInvoices called with empty companyId');
    try {
      final isMultiStatus = statusFilter != null && statusFilter.length > 1;
      final status = isMultiStatus ? null : _mapStatusFilter(statusFilter);

      // Single-status path: one page fetch with server filtering (correct pagination)
      if (!isMultiStatus) {
        final page = _pageFromOffset(offset, limit);
        final response = await _apiClient.dio.get(
          ApiEndpoints.invoices,
          queryParameters: {
            'page': page,
            'limit': limit ?? 20,
            if (search != null && search.trim().isNotEmpty) 'search': search,
            if (status != null) 'status': status,
            if (customerId != null && customerId.isNotEmpty) 'customer_id': customerId,
            if (startDate != null) 'start_date': startDate,
            if (endDate != null) 'end_date': endDate,
            if (sort != null) 'sort': sort,
            if (order != null) 'order': order,
          },
        );
        final list = _dataList(response);
        var models = list.map(InvoiceModel.fromJson).toList();
        // Non-aligned offset handling: skip offset%limit within the fetched page
        if (offset != null && limit != null && limit > 0) {
          final offsetInPage = offset % limit;
          if (offsetInPage != 0) {
            models = models.skip(offsetInPage).toList();
          }
        }
        return Right(models);
      }

      // Multi-status path: backend only supports single status, so fetch
      // unfiltered pages and apply client-side filtering with correct
      // cross-page offset/limit handling.
      // ignore: unnecessary_cast
      final allowed = (statusFilter as List<String>).toSet();
      final effectiveLimit = limit ?? 20;
      final effectiveOffset = offset ?? 0;
      final List<InvoiceModel> collected = [];
      int currentPage = 1;
      int filteredSkipped = 0;
      bool hasMore = true;
      int attempts = 0;
      const maxAttempts = 10;

      while (collected.length < effectiveLimit && hasMore && attempts < maxAttempts) {
        attempts++;
        final response = await _apiClient.dio.get(
          ApiEndpoints.invoices,
          queryParameters: {
            'page': currentPage,
            'limit': effectiveLimit,
            if (search != null && search.trim().isNotEmpty) 'search': search,
            if (customerId != null && customerId.isNotEmpty) 'customer_id': customerId,
            if (startDate != null) 'start_date': startDate,
            if (endDate != null) 'end_date': endDate,
            if (sort != null) 'sort': sort,
            if (order != null) 'order': order,
          },
        );
        final rawList = _dataList(response);
        if (rawList.isEmpty) {
          hasMore = false;
          break;
        }
        var pageModels = rawList.map(InvoiceModel.fromJson).toList();
        pageModels = pageModels.where((m) => allowed.contains(m.paymentStatus)).toList();

        // Skip offset in filtered stream
        if (filteredSkipped < effectiveOffset) {
          final toSkip = effectiveOffset - filteredSkipped;
          if (pageModels.length <= toSkip) {
            filteredSkipped += pageModels.length;
            if (rawList.length < effectiveLimit) hasMore = false;
            currentPage++;
            continue;
          } else {
            pageModels = pageModels.sublist(toSkip);
            filteredSkipped = effectiveOffset;
          }
        }

        final needed = effectiveLimit - collected.length;
        if (pageModels.length > needed) {
          collected.addAll(pageModels.take(needed));
          break;
        } else {
          collected.addAll(pageModels);
        }

        if (rawList.length < effectiveLimit) hasMore = false;
        currentPage++;
      }

      return Right(collected);
    } on DioException catch (e) {
      return Left(_mapDioError(e));
    } catch (_) {
      return Left(ServerFailure(ErrorMessages.unexpectedError));
    }
  }

  @override
  Future<Either<Failure, InvoiceModel>> cancelInvoice(
    String id,
    String companyId,
  ) async {
    assert(companyId.isNotEmpty, 'cancelInvoice called with empty companyId');
    try {
      final response = await _apiClient.dio.post(
        ApiEndpoints.invoiceCancel(id),
      );
      final data = _dataOrThrow(response);
      return Right(InvoiceModel.fromJson(data));
    } on DioException catch (e) {
      return Left(_mapDioError(e));
    } catch (_) {
      return Left(ServerFailure(ErrorMessages.unexpectedError));
    }
  }

  // ======================= Helpers =======================

  int _pageFromOffset(int? offset, int? limit) {
    if (offset != null && offset > 0 && limit != null && limit > 0) {
      return (offset ~/ limit) + 1;
    }
    return 1;
  }

  /// Maps legacy statusFilter values (debt, partial, paid, canceled) to backend enum.
  /// Returns null for no filter. Caller handles multi-value via client-side filtering.
  String? _mapStatusFilter(List<String>? filter) {
    if (filter == null || filter.isEmpty) return null;
    if (filter.length != 1) return null;
    final raw = filter.first.trim().toLowerCase();
    // Direct backend values
    if (['pending', 'paid', 'partially_paid', 'canceled'].contains(raw)) {
      return raw;
    }
    // Legacy app values
    final status = InvoiceStatusX.fromApi(raw);
    return status.apiValue;
  }

  Failure _mapDioError(DioException e) {
    final base = mapDioExceptionToFailure(e);
    final backendMessage = _messageFromResponse(e.response);
    final translated = _translateBackendMessage(backendMessage ?? '');
    if (translated != null) {
      return switch (base) {
        UnauthorizedFailure() => UnauthorizedFailure(translated),
        ForbiddenFailure() => ForbiddenFailure(translated),
        NotFoundFailure() => NotFoundFailure(translated),
        ConflictFailure() => ConflictFailure(translated),
        RateLimitFailure() => RateLimitFailure(translated),
        ValidationFailure() => ValidationFailure(translated),
        NetworkFailure() => NetworkFailure(translated),
        _ => ServerFailure(translated),
      };
    }
    return base;
  }

  String? _messageFromResponse(Response<dynamic>? response) {
    try {
      final data = response?.data;
      if (data is Map<String, dynamic>) {
        final msg = data['message'];
        if (msg is String && msg.isNotEmpty) return msg;
        final err = data['error'];
        if (err is String && err.isNotEmpty) return err;
        // Validation details may be array
        final errors = data['errors'];
        if (errors is List && errors.isNotEmpty) {
          final first = errors.first;
          if (first is Map && first['message'] is String) return first['message'] as String;
          if (first is String) return first;
        }
      } else if (data is String && data.isNotEmpty) {
        return data;
      }
    } catch (_) {}
    return null;
  }

  String? _translateBackendMessage(String message) {
    if (message.isEmpty) return null;
    final lower = message.toLowerCase();
    if (lower.contains('permission denied') ||
        lower.contains('access denied') ||
        lower.contains('row-level security') ||
        lower.contains('forbidden')) {
      return ErrorMessages.noPermission;
    }
    if (lower.contains('no active company') || lower.contains('no company selected')) {
      return ErrorMessages.noCompanySelected;
    }
    if (lower.contains('customer not found')) {
      return ErrorMessages.customerNotFound;
    }
    if (lower.contains('invoice must contain at least one item')) {
      return ErrorMessages.addAtLeastOneProduct;
    }
    if (lower.contains('paid amount cannot be negative') ||
        lower.contains('payment amount must be greater than 0')) {
      return ErrorMessages.invalidAmount;
    }
    if (lower.contains('payment cannot exceed invoice total') ||
        lower.contains('payment exceeds remaining') ||
        lower.contains('exceeds remaining amount') ||
        lower.contains('payment amount') && lower.contains('exceeds')) {
      return ErrorMessages.paymentExceedsRemaining;
    }
    if (lower.contains('discount cannot exceed')) {
      return ErrorMessages.validationFailed;
    }
    if (lower.contains('insufficient stock')) {
      final productName = _extractProductName(message);
      if (productName != null && productName.isNotEmpty) {
        return '${ErrorMessages.insufficientStock} ($productName)';
      }
      return ErrorMessages.insufficientStock;
    }
    if (lower.contains('duplicate key')) {
      return ErrorMessages.duplicateData;
    }
    if (lower.contains('foreign key constraint')) {
      if (lower.contains('product')) return ErrorMessages.productHasInvoices;
      if (lower.contains('customer')) return ErrorMessages.customerNotFound;
      return ErrorMessages.customerNotFound;
    }
    if (lower.contains('invoice not found')) {
      return ErrorMessages.invoiceNotFound;
    }
    if (lower.contains('invoice is already canceled') ||
        lower.contains('invoice is canceled') ||
        lower.contains('already canceled')) {
      return ErrorMessages.invoiceCanceled;
    }
    if (lower.contains('invoice is already fully paid') ||
        lower.contains('already fully paid')) {
      return ErrorMessages.invoiceFullyPaid;
    }
    if (lower.contains('product not found')) {
      return ErrorMessages.notFound;
    }
    if (lower.contains('product is inactive') || lower.contains('is inactive')) {
      return ErrorMessages.unsupportedOperation;
    }
    return null;
  }

  String? _extractProductName(String message) {
    final match = RegExp(r'for product\s+(.+)$', caseSensitive: false).firstMatch(message);
    if (match != null) return match.group(1)?.trim().replaceAll('"', '').replaceAll("'", '');
    return null;
  }

  Map<String, dynamic> _dataOrThrow(Response<dynamic> response) {
    final data = _data(response);
    if (data == null) {
      throw StateError(ErrorMessages.unexpectedError);
    }
    return data;
  }

  Map<String, dynamic>? _data(Response<dynamic> response) {
    final body = response.data;
    if (body is Map<String, dynamic>) {
      final data = body['data'];
      if (data is Map<String, dynamic>) return data;
      if (body.containsKey('id')) return body;
    }
    return null;
  }

  List<Map<String, dynamic>> _dataList(Response<dynamic> response) {
    final body = response.data;
    if (body is Map<String, dynamic>) {
      final data = body['data'];
      if (data is List) {
        return data.whereType<Map<String, dynamic>>().toList();
      }
      if (data is Map<String, dynamic> && data['data'] is List) {
        return (data['data'] as List).whereType<Map<String, dynamic>>().toList();
      }
    }
    throw StateError(ErrorMessages.unexpectedError);
  }
}
