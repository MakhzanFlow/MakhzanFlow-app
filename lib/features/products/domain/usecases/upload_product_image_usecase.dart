import 'package:fpdart/fpdart.dart';
import 'package:makhzanflow/core/error/failures.dart';
import '../repositories/product_repository.dart';

class UploadProductImageUseCase {
  final ProductRepository repository;

  UploadProductImageUseCase(this.repository);

  Future<Either<Failure, String>> call(String filePath, String productId) {
    return repository.uploadProductImage(filePath, productId);
  }
}
