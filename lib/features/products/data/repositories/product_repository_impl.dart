import 'package:fpdart/fpdart.dart';
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
  TaskEither<String, List<Product>> listProducts({
    required String companyId,
    String? query,
    int? limit,
    int? offset,
    String? sortColumn,
    bool ascending = false,
  }) {
    return dataSource
        .listProducts(
          companyId: companyId,
          query: query,
          limit: limit,
          offset: offset,
          sortColumn: sortColumn,
          ascending: ascending,
        )
        .map((models) => models.map((m) => m.toEntity()).toList());
  }

  @override
  TaskEither<String, Product> getProduct(String id, String companyId) {
    return dataSource.getProduct(id, companyId).map((model) => model.toEntity());
  }

  @override
  TaskEither<String, Product> createProduct(ProductInput input, String userId, String companyId) {
    final validationError = input.validate();
    if (validationError != null) {
      return TaskEither.left(validationError);
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
    return dataSource
        .createProduct(dto, userId, companyId)
        .map((model) => model.toEntity());
  }

  @override
  TaskEither<String, Product> updateProduct(
    String id,
    ProductInput input,
    String userId,
    String companyId,
  ) {
    final validationError = input.validate();
    if (validationError != null) {
      return TaskEither.left(validationError);
    }
    final dto = UpdateProductRequestDto(
      name: input.name,
      sku: input.sku,
      barcode: input.barcode,
      price: input.price,
      stock: input.quantity,
      minStock: input.minStock,
      expiryDate: input.expirationDate,
    );
    return dataSource.updateProduct(id, dto, userId, companyId).map((model) => model.toEntity());
  }

  @override
  TaskEither<String, void> deleteProduct(String id, String companyId) {
    return dataSource.deleteProduct(id, companyId);
  }

  @override
  TaskEither<String, String> uploadProductImage(String filePath, String productId) {
    return dataSource.uploadImage(filePath, productId);
  }

  @override
  TaskEither<String, Product> updateQuantity({
    required String productId,
    required int delta,
    String? note,
    required String userId,
    required String companyId,
  }) {
    final dto = AdjustStockRequestDto(
      quantityChange: delta,
      reason: note ?? '',
    );

    return dataSource
        .updateQuantityTransaction(
          dto,
          productId: productId,
          companyId: companyId,
        )
        .flatMap((_) {
          return dataSource
              .getProduct(productId, companyId)
              .map((model) => model.toEntity());
        });
  }

  @override
  TaskEither<String, List<InventoryMovement>> getMovements(String productId, String companyId) {
    return dataSource
        .getMovements(productId, companyId)
        .map((models) => models.map((m) => m.toEntity()).toList());
  }
}
