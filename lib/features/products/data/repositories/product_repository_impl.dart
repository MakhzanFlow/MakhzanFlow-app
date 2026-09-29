import 'package:fpdart/fpdart.dart';
import 'package:makhzanflow/core/error/failures.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/inventory_movement.dart';
import '../../domain/entities/product_input.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_remote_data_source.dart';
import '../models/adjust_stock_request_dto.dart';
import '../models/create_product_request_dto.dart';
import '../models/update_product_request_dto.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource dataSource;

  ProductRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, List<Product>>> listProducts({
    required String companyId,
    String? query,
    int? limit,
    int? offset,
    String? sortColumn,
    bool ascending = false,
  }) async {
    final result = await dataSource.listProducts(
      companyId: companyId,
      query: query,
      limit: limit,
      offset: offset,
      sortColumn: sortColumn,
      ascending: ascending,
    );
    return result.map((models) => models.map((m) => m.toEntity()).toList());
  }

  @override
  Future<Either<Failure, Product>> getProduct(String id, String companyId) async {
    final result = await dataSource.getProduct(id, companyId);
    return result.map((model) => model.toEntity());
  }

  @override
  Future<Either<Failure, Product>> createProduct(
    ProductInput input,
    String userId,
    String companyId,
  ) async {
    final validationError = input.validate();
    if (validationError != null) {
      return Left(ValidationFailure(validationError));
    }
    final dto = CreateProductRequestDto(
      name: input.name,
      sku: input.sku,
      barcode: input.barcode,
      price: input.price,
      stock: input.quantity,
      minStock: input.minStock,
      expiryDate: input.expirationDate,
    );
    final result = await dataSource.createProduct(dto, userId, companyId);
    return result.map((model) => model.toEntity());
  }

  @override
  Future<Either<Failure, Product>> updateProduct(
    String id,
    ProductInput input,
    String userId,
    String companyId, {
    int? version,
  }) async {
    final validationError = input.validate();
    if (validationError != null) {
      return Left(ValidationFailure(validationError));
    }
    final dto = UpdateProductRequestDto(
      name: input.name,
      sku: input.sku,
      barcode: input.barcode,
      price: input.price,
      stock: input.quantity,
      minStock: input.minStock,
      expiryDate: input.expirationDate,
      version: version,
    );
    final result = await dataSource.updateProduct(id, dto, userId, companyId);
    return result.map((model) => model.toEntity());
  }

  @override
  Future<Either<Failure, void>> deleteProduct(String id, String companyId) {
    return dataSource.deleteProduct(id, companyId);
  }

  @override
  Future<Either<Failure, String>> uploadProductImage(
    String filePath,
    String productId,
  ) {
    return dataSource.uploadImage(filePath, productId);
  }

  @override
  Future<Either<Failure, Product>> updateQuantity({
    required String productId,
    required int delta,
    String? note,
    required String userId,
    required String companyId,
    int? version,
  }) async {
    final dto = AdjustStockRequestDto(
      quantityChange: delta,
      reason: note ?? '',
      version: version,
    );

    final updated = await dataSource.updateQuantityTransaction(
      dto,
      productId: productId,
      companyId: companyId,
    );
    return updated.fold(
      (failure) async => Left<Failure, Product>(failure),
      (_) async {
        final result = await dataSource.getProduct(productId, companyId);
        return result.map((model) => model.toEntity());
      },
    );
  }

  @override
  Future<Either<Failure, List<InventoryMovement>>> getMovements(
    String productId,
    String companyId,
  ) async {
    final result = await dataSource.getMovements(productId, companyId);
    return result.map(
      (models) => models.map((m) => m.toEntity()).toList(),
    );
  }
}
