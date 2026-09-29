import 'dart:io';
import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:makhzanflow/core/api/api_client.dart';
import 'package:makhzanflow/core/api/api_response.dart';
import 'package:makhzanflow/core/constants/api_endpoints.dart';
import 'package:makhzanflow/core/constants/error_messages.dart';
import 'package:makhzanflow/core/error/failures.dart';
import 'package:makhzanflow/features/products/data/datasources/product_remote_data_source.dart';
import 'package:makhzanflow/features/products/data/models/adjust_stock_request_dto.dart';
import 'package:makhzanflow/features/products/data/models/create_product_request_dto.dart';
import 'package:makhzanflow/features/products/data/models/inventory_movement_model.dart';
import 'package:makhzanflow/features/products/data/models/product_model.dart';
import 'package:makhzanflow/features/products/data/models/update_product_request_dto.dart';

/// REST implementation of [ProductRemoteDataSource] backed by the Express API.
/// Errors surface as domain [Failure]s via the central Dio mapper, so 409
/// `VERSION_CONFLICT` payloads reach callers as [VersionConflictFailure].
class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final ApiClient _apiClient;

  ProductRemoteDataSourceImpl({required ApiClient apiClient})
    : _apiClient = apiClient;

  @override
  Future<Either<Failure, List<ProductModel>>> listProducts({
    required String companyId,
    String? query,
    int? limit,
    int? offset,
    String? sortColumn,
    bool ascending = false,
  }) async {
    try {
      final page = offset != null && offset > 0 && limit != null
          ? (offset ~/ limit) + 1
          : 1;
      final response = await _apiClient.dio.get(
        ApiEndpoints.products,
        queryParameters: {
          'page': page,
          'limit': limit ?? 20,
          if (query != null && query.trim().isNotEmpty) 'search': query,
          'sort': sortColumn ?? 'name',
          'order': ascending ? 'asc' : 'desc',
        },
      );
      final data = _dataList(response);
      return Right(data.map(ProductModel.fromJson).toList());
    } on DioException catch (e) {
      return Left(mapDioExceptionToFailure(e));
    } catch (_) {
      return Left(ServerFailure(ErrorMessages.unexpectedError));
    }
  }

  @override
  Future<Either<Failure, ProductModel>> getProduct(
    String id,
    String companyId,
  ) async {
    try {
      final response = await _apiClient.dio.get(ApiEndpoints.productById(id));
      return Right(ProductModel.fromJson(_dataOrThrow(response)));
    } on DioException catch (e) {
      return Left(mapDioExceptionToFailure(e));
    } on StateError catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return Left(ServerFailure(ErrorMessages.unexpectedError));
    }
  }

  @override
  Future<Either<Failure, ProductModel>> createProduct(
    CreateProductRequestDto dto,
    String userId,
    String companyId,
  ) async {
    try {
      final response = await _apiClient.dio.post(
        ApiEndpoints.products,
        data: dto.toJson(),
      );
      return Right(ProductModel.fromJson(_dataOrThrow(response)));
    } on DioException catch (e) {
      return Left(mapDioExceptionToFailure(e));
    } on StateError catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return Left(ServerFailure(ErrorMessages.unexpectedError));
    }
  }

  @override
  Future<Either<Failure, ProductModel>> updateProduct(
    String id,
    UpdateProductRequestDto dto,
    String userId,
    String companyId,
  ) async {
    // Backend §1.3 rejects empty updates with 400 — short-circuit locally.
    if (dto.toJson().isEmpty) {
      return Left(ValidationFailure(ErrorMessages.nothingToUpdate));
    }
    try {
      final response = await _apiClient.dio.put(
        ApiEndpoints.productById(id),
        data: dto.toJson(),
      );
      return Right(ProductModel.fromJson(_dataOrThrow(response)));
    } on DioException catch (e) {
      return Left(mapDioExceptionToFailure(e));
    } on StateError catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return Left(ServerFailure(ErrorMessages.unexpectedError));
    }
  }

  @override
  Future<Either<Failure, void>> deleteProduct(
    String id,
    String companyId,
  ) async {
    try {
      await _apiClient.dio.delete(ApiEndpoints.productById(id));
      return const Right(null);
    } on DioException catch (e) {
      return Left(mapDioExceptionToFailure(e));
    } catch (_) {
      return Left(ServerFailure(ErrorMessages.unexpectedError));
    }
  }

  @override
  Future<Either<Failure, String>> uploadImage(
    String filePath,
    String productId,
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
        ApiEndpoints.productImage(productId),
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
    } on StateError catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return Left(ServerFailure(ErrorMessages.unexpectedError));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> updateQuantityTransaction(
    AdjustStockRequestDto dto, {
    required String productId,
    required String companyId,
  }) async {
    final current = await getProduct(productId, companyId);
    return current.fold(
      (failure) async => Left<Failure, Map<String, dynamic>>(failure),
      (model) async {
        final newStock = model.quantity + dto.quantityChange;
        try {
          final response = await _apiClient.dio.put(
            ApiEndpoints.productById(productId),
            data: {
              'stock': newStock,
              if (dto.version != null) 'version': dto.version,
            },
          );
          return Right(_dataOrThrow(response));
        } on DioException catch (e) {
          return Left(mapDioExceptionToFailure(e));
        } on StateError catch (e) {
          return Left(ServerFailure(e.message));
        } catch (_) {
          return Left(ServerFailure(ErrorMessages.unexpectedError));
        }
      },
    );
  }

  @override
  Future<Either<Failure, List<InventoryMovementModel>>> getMovements(
    String productId,
    String companyId,
  ) async {
    try {
      final response = await _apiClient.dio.get(
        ApiEndpoints.productActivity(productId),
        queryParameters: {'page': 1, 'limit': 20},
      );
      final entries = _dataList(response);
      final movements = <InventoryMovementModel>[];
      for (final entry in entries) {
        if (entry['action'] != 'update') continue;
        final changes = entry['changes'];
        if (changes is! Map<String, dynamic>) continue;
        final oldJson = changes['old'];
        final newJson = changes['new'];
        if (oldJson is! Map<String, dynamic> ||
            newJson is! Map<String, dynamic>) {
          continue;
        }
        final oldStock = (oldJson['stock'] as num?)?.toInt();
        final newStock = (newJson['stock'] as num?)?.toInt();
        if (oldStock == null || newStock == null || oldStock == newStock) {
          continue;
        }
        final delta = newStock - oldStock;
        movements.add(InventoryMovementModel(
          id: entry['id'] as String,
          productId: productId,
          type: delta > 0 ? 'in' : 'out',
          quantity: delta.abs(),
          note: null,
          createdBy: (entry['user_name'] as String?) ?? '',
          createdAt: entry['created_at'] != null
              ? DateTime.tryParse(entry['created_at'] as String)
              : null,
        ));
      }
      return Right(movements);
    } on DioException catch (e) {
      return Left(mapDioExceptionToFailure(e));
    } catch (_) {
      return Left(ServerFailure(ErrorMessages.unexpectedError));
    }
  }

  // ======================= Helpers =======================

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
      if (data is List && data.isNotEmpty && data.first is Map) {
        return Map<String, dynamic>.from(data.first as Map);
      }
    }
    return null;
  }

  List<Map<String, dynamic>> _dataList(Response<dynamic> response) {
    final body = response.data;
    if (body is Map<String, dynamic>) {
      final data = body['data'];
      if (data is List) {
        return data
            .whereType<Map<String, dynamic>>()
            .toList();
      }
    }
    return const [];
  }
}
