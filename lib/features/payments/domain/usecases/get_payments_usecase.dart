import 'package:fpdart/fpdart.dart';
import 'package:makhzanflow/core/error/failures.dart';
import '../../data/datasources/payment_remote_data_source.dart';
import '../entities/payment.dart';
import '../repositories/payment_repository.dart';

class GetPaymentsUseCase {
  final PaymentRepository _repository;

  GetPaymentsUseCase(this._repository);

  Future<Either<Failure, List<Payment>>> call({
    String? search,
    DateTime? startDate,
    DateTime? endDate,
    String? sort,
    String? order,
    int page = 1,
    int limit = 20,
  }) {
    return _repository.getPayments(
      PaymentQuery(
        page: page,
        limit: limit,
        search: search,
        startDate: startDate,
        endDate: endDate,
        sort: sort,
        order: order,
      ),
    );
  }
}
