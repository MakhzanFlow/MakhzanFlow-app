import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:makhzanflow/core/api/api_client.dart';
import 'package:makhzanflow/core/api/api_response.dart';
import 'package:makhzanflow/core/constants/api_endpoints.dart';
import 'package:makhzanflow/core/constants/error_messages.dart';
import 'package:makhzanflow/core/error/failures.dart';
import '../models/activity_entry_dto.dart';
import '../models/dashboard_stats_model.dart';
import '../models/low_stock_product_dto.dart';
import '../models/monthly_report_entry_dto.dart';
import 'dashboard_remote_data_source.dart';

class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  final ApiClient _apiClient;

  DashboardRemoteDataSourceImpl({required ApiClient apiClient}) : _apiClient = apiClient;

  @override
  Future<Either<Failure, DashboardStatsModel>> getDashboardStats(String companyId) async {
    // companyId is tenant-scoped via x-company-id header; empty string is
    // allowed for backward compat callers. No assert needed.
    try {
      final response = await _apiClient.dio.get(ApiEndpoints.dashboardStats);
      final data = _dataOrThrow(response);
      return Right(DashboardStatsModel.fromJson(data));
    } on DioException catch (e) {
      return Left(mapDioExceptionToFailure(e));
    } catch (_) {
      return Left(ServerFailure(ErrorMessages.unexpectedError));
    }
  }

  @override
  Future<Either<Failure, PaginatedResponse<LowStockProductDto>>> getLowStock({
    required String companyId,
    int page = 1,
    int limit = 20,
    String? search,
    String? sort,
    String? order,
  }) async {
    try {
      final response = await _apiClient.dio.get(
        ApiEndpoints.dashboardLowStock,
        queryParameters: {
          'page': page,
          'limit': limit,
          if (search != null && search.trim().isNotEmpty) 'search': search,
          if (sort != null) 'sort': sort,
          if (order != null) 'order': order,
        },
      );
      final paginated = PaginatedResponse<LowStockProductDto>.fromJson(
        response.data as Map<String, dynamic>,
        (json) => LowStockProductDto.fromJson(json as Map<String, dynamic>),
      );
      return Right(paginated);
    } on DioException catch (e) {
      return Left(mapDioExceptionToFailure(e));
    } catch (_) {
      return Left(ServerFailure(ErrorMessages.unexpectedError));
    }
  }

  @override
  Future<Either<Failure, List<MonthlyReportEntryDto>>> getMonthlyReport({
    required String companyId,
    int months = 12,
    String? from,
    String? to,
  }) async {
    try {
      final response = await _apiClient.dio.get(
        ApiEndpoints.dashboardMonthlyReport,
        queryParameters: {
          'months': months,
          if (from != null && from.isNotEmpty) 'from': from,
          if (to != null && to.isNotEmpty) 'to': to,
        },
      );
      final body = response.data as Map<String, dynamic>;
      final raw = body['data'];
      if (raw is List) {
        final list = raw.whereType<Map<String, dynamic>>().map(MonthlyReportEntryDto.fromJson).toList();
        return Right(list);
      }
      // Fallback: _dataList style
      final dataList = _dataList(response);
      return Right(dataList.map(MonthlyReportEntryDto.fromJson).toList());
    } on DioException catch (e) {
      return Left(mapDioExceptionToFailure(e));
    } catch (_) {
      return Left(ServerFailure(ErrorMessages.unexpectedError));
    }
  }

  @override
  Future<Either<Failure, PaginatedResponse<ActivityEntryDto>>> getActivity({
    required String companyId,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _apiClient.dio.get(
        ApiEndpoints.dashboardActivity,
        queryParameters: {'page': page, 'limit': limit},
      );
      final paginated = PaginatedResponse<ActivityEntryDto>.fromJson(
        response.data as Map<String, dynamic>,
        (json) => ActivityEntryDto.fromJson(json as Map<String, dynamic>),
      );
      return Right(paginated);
    } on DioException catch (e) {
      return Left(mapDioExceptionToFailure(e));
    } catch (_) {
      return Left(ServerFailure(ErrorMessages.unexpectedError));
    }
  }

  // ── Helpers (same pattern as other REST data sources) ──

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
      // Some endpoints may return the object directly (no wrapper)
      if (body.containsKey('productsCount') || body.containsKey('products_count')) {
        return body;
      }
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
    }
    throw StateError(ErrorMessages.unexpectedError);
  }
}
