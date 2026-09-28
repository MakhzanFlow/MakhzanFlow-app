import 'package:fpdart/fpdart.dart';
import 'package:makhzanflow/core/error/failures.dart';
import '../entities/customer.dart';
import '../repositories/customer_repository.dart';

class UpdateCustomerUseCase {
  final CustomerRepository repository;

  UpdateCustomerUseCase(this.repository);

  Future<Either<Failure, Customer>> call({
    required String id,
    String? name,
    String? nameOfficial,
    String? phone,
    String? address,
    String? imageUrl,
    required String companyId,
  }) {
    return repository.updateCustomer(
      id: id,
      name: name,
      nameOfficial: nameOfficial,
      phone: phone,
      address: address,
      imageUrl: imageUrl,
      companyId: companyId,
    );
  }
}
