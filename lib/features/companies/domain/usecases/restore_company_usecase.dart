import 'package:fpdart/fpdart.dart';
import 'package:makhzanflow/core/error/failures.dart';
import 'package:makhzanflow/features/companies/domain/repositories/company_repository.dart';

/// Undoes a company archive: `POST /companies/:id/restore` (owner only).
class RestoreCompanyUseCase {
  final CompanyRepository _repository;
  RestoreCompanyUseCase(this._repository);
  Future<Either<Failure, void>> call(String companyId) =>
      _repository.restoreCompany(companyId);
}
