import 'package:fpdart/fpdart.dart';
import 'package:makhzanflow/core/error/failures.dart';
import '../entities/product.dart';
import '../entities/product_input.dart';
import '../repositories/product_repository.dart';

class CreateProductUseCase {
  final ProductRepository repository;

  CreateProductUseCase(this.repository);

  Future<Either<Failure, Product>> call(
    ProductInput input,
    String userId,
    String companyId,
  ) {
    return repository.createProduct(input, userId, companyId);
  }
}
