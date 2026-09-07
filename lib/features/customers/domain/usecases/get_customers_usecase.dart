import 'package:fpdart/fpdart.dart';
import 'package:makhzanflow/core/error/failures.dart';
import '../entities/customer.dart';
import '../repositories/customer_repository.dart';

class GetCustomersUseCase {
  final CustomerRepository repository;

  GetCustomersUseCase(this.repository);

  Future<Either<Failure, List<Customer>>> call({
    String? query,
    String? filter,
    String? sort,
    String? order,
    int? limit,
    int? offset,
    required String companyId,
  }) {
    return repository.listCustomers(
      query: query,
      filter: filter,
      sort: sort,
      order: order,
      limit: limit,
      offset: offset,
      companyId: companyId,
    );
  }
}
