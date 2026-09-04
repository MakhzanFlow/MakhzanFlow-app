import 'package:fpdart/fpdart.dart';
import 'package:makhzanflow/core/error/failures.dart';
import 'package:makhzanflow/features/companies/domain/entities/join_request.dart';
import 'package:makhzanflow/features/companies/domain/repositories/company_repository.dart';

class GetJoinRequestsUseCase {
  final CompanyRepository _repository;

  GetJoinRequestsUseCase(this._repository);

  Future<Either<Failure, List<JoinRequest>>> call(String companyId) {
    return _repository.getJoinRequests(companyId);
  }
}
