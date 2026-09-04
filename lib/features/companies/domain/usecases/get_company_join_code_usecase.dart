import 'package:fpdart/fpdart.dart';
import 'package:makhzanflow/core/error/failures.dart';
import 'package:makhzanflow/features/companies/domain/repositories/company_repository.dart';

class GetCompanyJoinCodeUseCase {
  final CompanyRepository _repository;
  GetCompanyJoinCodeUseCase(this._repository);
  Future<Either<Failure, String>> call(String companyId) =>
      _repository.getCompanyJoinCode(companyId);
}
