import 'package:fpdart/fpdart.dart';
import 'package:makhzanflow/core/error/failures.dart';
import '../entities/product.dart';
import '../entities/inventory_movement.dart';
import '../entities/product_input.dart';

abstract class ProductRepository {
  Future<Either<Failure, List<Product>>> listProducts({
    required String companyId,
    String? query,
    int? limit,
    int? offset,
    String? sortColumn,
    bool ascending = false,
  });

  Future<Either<Failure, Product>> getProduct(
    String id,
    String companyId,
  );

  Future<Either<Failure, Product>> createProduct(
    ProductInput input,
    String userId,
    String companyId,
  );

  /// Gated write: [version] (from the last GET) is sent when price/stock
  /// keys are present. Null version = metadata-only LWW edit.
  Future<Either<Failure, Product>> updateProduct(
    String id,
    ProductInput input,
    String userId,
    String companyId, {
    int? version,
  });

  Future<Either<Failure, void>> deleteProduct(
    String id,
    String companyId,
  );

  Future<Either<Failure, String>> uploadProductImage(
    String filePath,
    String productId,
  );

  Future<Either<Failure, Product>> updateQuantity({
    required String productId,
    required int delta,
    String? note,
    required String userId,
    required String companyId,
    int? version,
  });

  Future<Either<Failure, List<InventoryMovement>>> getMovements(
    String productId,
    String companyId,
  );
}
