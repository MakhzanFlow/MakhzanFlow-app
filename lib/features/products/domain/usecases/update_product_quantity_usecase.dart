import 'package:fpdart/fpdart.dart';
import 'package:makhzanflow/core/error/failures.dart';
import '../entities/product.dart';
import '../repositories/product_repository.dart';

class UpdateProductQuantityUseCase {
  final ProductRepository repository;

  UpdateProductQuantityUseCase(this.repository);

  Future<Either<Failure, Product>> call({
    required String productId,
    required int delta,
    String? note,
    required String userId,
    required String companyId,
    int? version,
  }) {
    return repository.updateQuantity(
      productId: productId,
      delta: delta,
      note: note,
      userId: userId,
      companyId: companyId,
      version: version,
    );
  }
}
