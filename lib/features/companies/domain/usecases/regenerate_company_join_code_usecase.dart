import 'package:fpdart/fpdart.dart';
import 'package:makhzanflow/core/error/failures.dart';
import 'package:makhzanflow/features/companies/domain/repositories/company_repository.dart';

class RegenerateCompanyJoinCodeUseCase {
  final CompanyRepository _repository;
  RegenerateCompanyJoinCodeUseCase(this._repository);
  Future<Either<Failure, String>> call(String companyId) =>
      _repository.regenerateCompanyJoinCode(companyId);
}
