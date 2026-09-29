import 'package:fpdart/fpdart.dart';
import 'package:makhzanflow/core/error/failures.dart';
import '../entities/inventory_movement.dart';
import '../repositories/product_repository.dart';

class GetInventoryMovementsUseCase {
  final ProductRepository repository;

  GetInventoryMovementsUseCase(this.repository);

  Future<Either<Failure, List<InventoryMovement>>> call(
      String productId, String companyId) {
    return repository.getMovements(productId, companyId);
  }
}
