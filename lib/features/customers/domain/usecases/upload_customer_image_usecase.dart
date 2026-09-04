import 'package:fpdart/fpdart.dart';
import 'package:makhzanflow/core/error/failures.dart';
import '../repositories/customer_repository.dart';

class UploadCustomerImageUseCase {
  final CustomerRepository repository;

  UploadCustomerImageUseCase(this.repository);

  Future<Either<Failure, String>> call(String filePath, String customerId) {
    return repository.uploadCustomerImage(filePath, customerId);
  }
}
