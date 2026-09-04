import 'package:fpdart/fpdart.dart';
import 'package:makhzanflow/core/error/failures.dart';
import 'package:makhzanflow/features/companies/domain/repositories/company_repository.dart';

class InviteMemberUseCase {
  final CompanyRepository _repository;

  InviteMemberUseCase(this._repository);

  Future<Either<Failure, void>> call(String companyId, String userEmail) {
    return _repository.inviteMember(companyId, userEmail);
  }
}
