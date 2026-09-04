import 'package:fpdart/fpdart.dart';
import '../models/adjust_stock_request_dto.dart';
import '../models/create_product_request_dto.dart';
import '../models/update_product_request_dto.dart';
import '../models/product_model.dart';
import '../models/inventory_movement_model.dart';

abstract class ProductRemoteDataSource {
  TaskEither<String, List<ProductModel>> listProducts({
    required String companyId,
    String? query,
    int? limit,
    int? offset,
    String? sortColumn,
    bool ascending = false,
  });

  TaskEither<String, ProductModel> getProduct(
    String id,
    String companyId,
  );

  TaskEither<String, ProductModel> createProduct(
    CreateProductRequestDto dto,
    String userId,
    String companyId,
  );

  TaskEither<String, ProductModel> updateProduct(
    String id,
    UpdateProductRequestDto dto,
    String userId,
    String companyId,
  );

  TaskEither<String, void> deleteProduct(
    String id,
    String companyId,
  );

  TaskEither<String, String> uploadImage(String filePath, String productId);

  TaskEither<String, Map<String, dynamic>> updateQuantityTransaction(
    AdjustStockRequestDto dto, {
    required String productId,
    required String companyId,
  });

  TaskEither<String, List<InventoryMovementModel>> getMovements(
    String productId,
    String companyId,
  );
}
