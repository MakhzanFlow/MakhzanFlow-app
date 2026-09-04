import 'package:fpdart/fpdart.dart';
import 'package:makhzanflow/core/error/failures.dart';
import 'package:makhzanflow/features/companies/domain/repositories/company_repository.dart';

class GetMemberPermissionsUseCase {
  final CompanyRepository _repository;
  GetMemberPermissionsUseCase(this._repository);
  Future<Either<Failure, Map<String, dynamic>>> call(
    String companyId,
    String userId,
  ) =>
      _repository.getMemberPermissions(companyId, userId);
}
