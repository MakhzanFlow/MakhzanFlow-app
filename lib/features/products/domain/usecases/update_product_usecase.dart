import 'package:fpdart/fpdart.dart';
import 'package:makhzanflow/core/error/failures.dart';
import '../entities/product.dart';
import '../entities/product_input.dart';
import '../repositories/product_repository.dart';

class UpdateProductUseCase {
  final ProductRepository repository;

  UpdateProductUseCase(this.repository);

  Future<Either<Failure, Product>> call(
    String id,
    ProductInput input,
    String userId,
    String companyId, {
    int? version,
  }) {
    return repository.updateProduct(id, input, userId, companyId,
        version: version);
  }
}
