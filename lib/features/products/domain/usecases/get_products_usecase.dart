import 'package:fpdart/fpdart.dart';
import 'package:makhzanflow/core/error/failures.dart';
import '../entities/product.dart';
import '../repositories/product_repository.dart';

class GetProductsUseCase {
  final ProductRepository repository;

  GetProductsUseCase(this.repository);

  Future<Either<Failure, List<Product>>> call({
    required String companyId,
    String? query,
    int? limit,
    int? offset,
    String? sortColumn,
    bool ascending = false,
  }) {
    return repository.listProducts(
      companyId: companyId,
      query: query,
      limit: limit,
      offset: offset,
      sortColumn: sortColumn,
      ascending: ascending,
    );
  }
}
