import 'dart:io';
import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:makhzanflow/core/api/api_client.dart';
import 'package:makhzanflow/core/api/api_response.dart';
import 'package:makhzanflow/core/constants/api_endpoints.dart';
import 'package:makhzanflow/core/constants/error_messages.dart';
import 'package:makhzanflow/features/products/data/datasources/product_remote_data_source.dart';
import 'package:makhzanflow/features/products/data/models/adjust_stock_request_dto.dart';
import 'package:makhzanflow/features/products/data/models/create_product_request_dto.dart';
import 'package:makhzanflow/features/products/data/models/inventory_movement_model.dart';
import 'package:makhzanflow/features/products/data/models/product_model.dart';
import 'package:makhzanflow/features/products/data/models/update_product_request_dto.dart';

/// REST implementation of [ProductRemoteDataSource] backed by the Express API.
class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final ApiClient _apiClient;

  ProductRemoteDataSourceImpl({required ApiClient apiClient})
    : _apiClient = apiClient;

  @override
  TaskEither<String, List<ProductModel>> listProducts({
    required String companyId,
    String? query,
    int? limit,
    int? offset,
    String? sortColumn,
    bool ascending = false,
  }) {
    return TaskEither.tryCatch(() async {
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
      return data.map(ProductModel.fromJson).toList();
    }, (error, stackTrace) => _toMessage(error, stackTrace));
  }

  @override
  TaskEither<String, ProductModel> getProduct(String id, String companyId) {
    return TaskEither.tryCatch(() async {
      final response = await _apiClient.dio.get(ApiEndpoints.productById(id));
      return ProductModel.fromJson(_dataOrThrow(response));
    }, (error, stackTrace) => _toMessage(error, stackTrace));
  }

  @override
  TaskEither<String, ProductModel> createProduct(
    CreateProductRequestDto dto,
    String userId,
    String companyId,
  ) {
    return TaskEither.tryCatch(() async {
      final response = await _apiClient.dio.post(
        ApiEndpoints.products,
        data: dto.toJson(),
      );
      return ProductModel.fromJson(_dataOrThrow(response));
    }, (error, stackTrace) => _toMessage(error, stackTrace));
  }

  @override
  TaskEither<String, ProductModel> updateProduct(
    String id,
    UpdateProductRequestDto dto,
    String userId,
    String companyId,
  ) {
    return TaskEither.tryCatch(() async {
      final response = await _apiClient.dio.put(
        ApiEndpoints.productById(id),
        data: dto.toJson(),
      );
      return ProductModel.fromJson(_dataOrThrow(response));
    }, (error, stackTrace) => _toMessage(error, stackTrace));
  }

  @override
  TaskEither<String, void> deleteProduct(String id, String companyId) {
    return TaskEither.tryCatch(() async {
      await _apiClient.dio.delete(ApiEndpoints.productById(id));
    }, (error, stackTrace) => _toMessage(error, stackTrace));
  }

  @override
  TaskEither<String, String> uploadImage(String filePath, String productId) {
    return TaskEither.tryCatch(() async {
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
        throw StateError(ErrorMessages.unexpectedError);
      }
      return url;
    }, (error, stackTrace) => _toMessage(error, stackTrace));
  }

  @override
  TaskEither<String, Map<String, dynamic>> updateQuantityTransaction(
    AdjustStockRequestDto dto, {
    required String productId,
    required String companyId,
  }) {
    return getProduct(productId, companyId).flatMap((model) {
      final newStock = model.quantity + dto.quantityChange;
      return TaskEither.tryCatch(() async {
        final response = await _apiClient.dio.put(
          ApiEndpoints.productById(productId),
          data: {'stock': newStock},
        );
        return _dataOrThrow(response);
      }, (error, stackTrace) => _toMessage(error, stackTrace));
    });
  }

  @override
  TaskEither<String, List<InventoryMovementModel>> getMovements(
    String productId,
    String companyId,
  ) {
    return TaskEither.tryCatch(() async {
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
      return movements;
    }, (error, stackTrace) => _toMessage(error, stackTrace));
  }

  // ======================= Helpers =======================

  String _toMessage(Object error, StackTrace stackTrace) {
    if (error is DioException) {
      return mapDioExceptionToFailure(error).message;
    }
    if (error is StateError) {
      return error.message;
    }
    return error.toString();
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
