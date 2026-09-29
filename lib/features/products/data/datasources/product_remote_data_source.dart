import 'package:fpdart/fpdart.dart';
import 'package:makhzanflow/core/error/failures.dart';
import '../models/adjust_stock_request_dto.dart';
import '../models/create_product_request_dto.dart';
import '../models/update_product_request_dto.dart';
import '../models/product_model.dart';
import '../models/inventory_movement_model.dart';

abstract class ProductRemoteDataSource {
  Future<Either<Failure, List<ProductModel>>> listProducts({
    required String companyId,
    String? query,
    int? limit,
    int? offset,
    String? sortColumn,
    bool ascending = false,
  });

  Future<Either<Failure, ProductModel>> getProduct(
    String id,
    String companyId,
  );

  Future<Either<Failure, ProductModel>> createProduct(
    CreateProductRequestDto dto,
    String userId,
    String companyId,
  );

  Future<Either<Failure, ProductModel>> updateProduct(
    String id,
    UpdateProductRequestDto dto,
    String userId,
    String companyId,
  );

  Future<Either<Failure, void>> deleteProduct(
    String id,
    String companyId,
  );

  Future<Either<Failure, String>> uploadImage(String filePath, String productId);

  Future<Either<Failure, Map<String, dynamic>>> updateQuantityTransaction(
    AdjustStockRequestDto dto, {
    required String productId,
    required String companyId,
  });

  Future<Either<Failure, List<InventoryMovementModel>>> getMovements(
    String productId,
    String companyId,
  );
}
