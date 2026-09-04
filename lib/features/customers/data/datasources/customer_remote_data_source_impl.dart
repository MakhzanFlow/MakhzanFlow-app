import 'dart:io';
import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:makhzanflow/core/api/api_client.dart';
import 'package:makhzanflow/core/api/api_response.dart';
import 'package:makhzanflow/core/constants/api_endpoints.dart';
import 'package:makhzanflow/core/constants/error_messages.dart';
import 'package:makhzanflow/core/error/failures.dart';
import 'package:makhzanflow/features/customers/data/datasources/customer_remote_data_source.dart';
import 'package:makhzanflow/features/customers/data/models/customer_model.dart';
import 'package:makhzanflow/features/customers/data/models/customer_filter_counts_model.dart';
import 'package:makhzanflow/features/customers/data/models/create_customer_request_dto.dart';
import 'package:makhzanflow/features/customers/data/models/update_customer_request_dto.dart';
import 'package:makhzanflow/features/customers/data/models/customer_summary_response_dto.dart';

class CustomerRemoteDataSourceImpl implements CustomerRemoteDataSource {
  final ApiClient _apiClient;

  CustomerRemoteDataSourceImpl({required ApiClient apiClient})
      : _apiClient = apiClient;

  // ──────── Phase 11: CRUD & Search ────────

  @override
  Future<Either<Failure, List<CustomerModel>>> listCustomers({
    String? query,
    String? filter,
    int? limit,
    int? offset,
    required String companyId,
  }) async {
    try {
      final response = await _apiClient.dio.get(
        ApiEndpoints.customers,
        queryParameters: {
          if (query != null && query.trim().isNotEmpty) 'search': query,
          if (filter != null && filter != 'all') 'debt_status': filter,
          'page': offset != null && limit != null && limit > 0
              ? (offset ~/ limit) + 1
              : 1,
          'limit': limit ?? 20,
        },
      );
      final data = _dataList(response);
      return Right(data.map(CustomerModel.fromJson).toList());
    } on DioException catch (e) {
      return Left(mapDioExceptionToFailure(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CustomerFilterCountsModel>> getFilterCounts({
    String? query,
    required String companyId,
  }) async {
    try {
      final response = await _apiClient.dio.get(
        ApiEndpoints.customersSummary,
        queryParameters: {
          if (query != null && query.trim().isNotEmpty) 'search': query,
        },
      );
      final data = _dataOrThrow(response);
      return Right(CustomerFilterCountsModel.fromJson(data));
    } on DioException catch (e) {
      return Left(mapDioExceptionToFailure(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CustomerModel>> getCustomer(
    String id,
    String companyId,
  ) async {
    try {
      final response = await _apiClient.dio.get(
        ApiEndpoints.customerById(id),
      );
      return Right(CustomerModel.fromJson(_dataOrThrow(response)));
    } on DioException catch (e) {
      return Left(mapDioExceptionToFailure(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CustomerModel>> createCustomer(
    CreateCustomerRequestDto dto,
    String companyId,
  ) async {
    try {
      final response = await _apiClient.dio.post(
        ApiEndpoints.customers,
        data: dto.toJson(),
      );
      return Right(CustomerModel.fromJson(_dataOrThrow(response)));
    } on DioException catch (e) {
      return Left(mapDioExceptionToFailure(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CustomerModel>> updateCustomer(
    String id,
    UpdateCustomerRequestDto dto,
    String companyId,
  ) async {
    try {
      final response = await _apiClient.dio.put(
        ApiEndpoints.customerById(id),
        data: dto.toJson(),
      );
      return Right(CustomerModel.fromJson(_dataOrThrow(response)));
    } on DioException catch (e) {
      return Left(mapDioExceptionToFailure(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> uploadImage(
    String filePath,
    String customerId,
  ) async {
    try {
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          filePath,
          filename: '${DateTime.now().millisecondsSinceEpoch}_'
              '${filePath.split(Platform.pathSeparator).last}',
        ),
      });
      final response = await _apiClient.dio.post(
        ApiEndpoints.customerImage(customerId),
        data: formData,
      );
      final data = _dataOrThrow(response);
      final url = data['image_url'] as String?;
      if (url == null || url.isEmpty) {
        return Left(ServerFailure(ErrorMessages.unexpectedError));
      }
      return Right(url);
    } on DioException catch (e) {
      return Left(mapDioExceptionToFailure(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  // ──────── Phase 12: Summary, Debt, Image ────────

  @override
  Future<Either<Failure, CustomerSummaryResponseDto>> getSummary(
    String companyId,
  ) async {
    try {
      final response = await _apiClient.dio.get(
        ApiEndpoints.customersSummary,
      );
      return Right(
        CustomerSummaryResponseDto.fromJson(_dataOrThrow(response)),
      );
    } on DioException catch (e) {
      return Left(mapDioExceptionToFailure(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CustomerModel>>> getDebtors(
    String companyId, {
    int? limit,
    int? offset,
  }) async {
    try {
      final response = await _apiClient.dio.get(
        ApiEndpoints.customersDebtors,
        queryParameters: {
          'page': offset != null && limit != null && limit > 0
              ? (offset ~/ limit) + 1
              : 1,
          'limit': limit ?? 20,
        },
      );
      final data = _dataList(response);
      return Right(data.map(CustomerModel.fromJson).toList());
    } on DioException catch (e) {
      return Left(mapDioExceptionToFailure(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getCustomerDebt(
    String customerId,
    String companyId,
  ) async {
    try {
      final response = await _apiClient.dio.get(
        ApiEndpoints.customerDebt(customerId),
      );
      return Right(_dataOrThrow(response));
    } on DioException catch (e) {
      return Left(mapDioExceptionToFailure(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getCustomerInvoices(
    String customerId,
    String companyId, {
    int? limit,
    int? offset,
  }) async {
    try {
      final response = await _apiClient.dio.get(
        ApiEndpoints.customerInvoices(customerId),
        queryParameters: {
          'page': offset != null && limit != null && limit > 0
              ? (offset ~/ limit) + 1
              : 1,
          'limit': limit ?? 20,
        },
      );
      return Right(_dataList(response));
    } on DioException catch (e) {
      return Left(mapDioExceptionToFailure(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getCustomerPayments(
    String customerId,
    String companyId, {
    int? limit,
    int? offset,
  }) async {
    try {
      final response = await _apiClient.dio.get(
        ApiEndpoints.customerPayments(customerId),
        queryParameters: {
          'page': offset != null && limit != null && limit > 0
              ? (offset ~/ limit) + 1
              : 1,
          'limit': limit ?? 20,
        },
      );
      return Right(_dataList(response));
    } on DioException catch (e) {
      return Left(mapDioExceptionToFailure(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  // ──────── Helpers ────────

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
