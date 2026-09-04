import 'package:fpdart/fpdart.dart';
import 'package:makhzanflow/core/error/failures.dart';
import 'package:makhzanflow/features/companies/domain/repositories/company_repository.dart';

class RejectJoinRequestUseCase {
  final CompanyRepository _repository;

  RejectJoinRequestUseCase(this._repository);

  Future<Either<Failure, void>> call(String companyId, String requestId) {
    return _repository.rejectJoinRequest(companyId, requestId);
  }
}
