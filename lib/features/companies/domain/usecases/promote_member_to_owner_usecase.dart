import 'package:fpdart/fpdart.dart';
import 'package:makhzanflow/core/error/failures.dart';
import 'package:makhzanflow/features/companies/domain/repositories/company_repository.dart';

class PromoteMemberToOwnerUseCase {
  final CompanyRepository _repository;
  PromoteMemberToOwnerUseCase(this._repository);
  Future<Either<Failure, void>> call(String companyId, String userId) =>
      _repository.promoteMemberToOwner(companyId, userId);
}
