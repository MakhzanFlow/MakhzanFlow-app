import 'package:fpdart/fpdart.dart';
import 'package:makhzanflow/core/error/failures.dart';
import 'package:makhzanflow/features/customers/domain/entities/customer_filter_counts.dart';
import 'package:makhzanflow/features/customers/domain/repositories/customer_repository.dart';

class GetCustomerFilterCountsUseCase {
  final CustomerRepository _customerRepository;

  GetCustomerFilterCountsUseCase(this._customerRepository);

  Future<Either<Failure, CustomerFilterCounts>> call({String? query, required String companyId}) async {
    return _customerRepository.getCustomerFilterCounts(query: query, companyId: companyId);
  }
}
