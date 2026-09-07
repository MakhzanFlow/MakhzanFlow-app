import 'package:fpdart/fpdart.dart';
import 'package:makhzanflow/core/error/failures.dart';
import '../entities/weekly_sales_point.dart';
import '../repositories/dashboard_repository.dart';

class GetDashboardSalesUseCase {
  const GetDashboardSalesUseCase(this._repository);

  final DashboardRepository _repository;

  Future<Either<Failure, List<WeeklySalesPoint>>> call({
    required String companyId,
    required String range,
  }) => _repository.getSales(companyId: companyId, range: range);
}
