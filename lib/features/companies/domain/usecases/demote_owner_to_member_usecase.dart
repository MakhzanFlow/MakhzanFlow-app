import 'package:fpdart/fpdart.dart';
import 'package:makhzanflow/core/error/failures.dart';
import 'package:makhzanflow/features/companies/domain/repositories/company_repository.dart';

class DemoteOwnerToMemberUseCase {
  final CompanyRepository _repository;
  DemoteOwnerToMemberUseCase(this._repository);
  Future<Either<Failure, void>> call(
    String companyId,
    String userId,
    Map<String, dynamic> permissions,
  ) =>
      _repository.demoteOwnerToMember(companyId, userId, permissions);
}
