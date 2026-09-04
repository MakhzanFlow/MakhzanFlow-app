import 'package:fpdart/fpdart.dart';
import 'package:makhzanflow/core/error/failures.dart';
import 'package:makhzanflow/features/dashboard/domain/entities/dashboard_stats.dart';
import 'package:makhzanflow/features/dashboard/domain/repositories/dashboard_repository.dart';
import '../datasources/dashboard_remote_data_source.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  const DashboardRepositoryImpl(this._dataSource);

  final DashboardRemoteDataSource _dataSource;

  @override
  Future<Either<Failure, DashboardStats>> getDashboardStats(
      String companyId) async {
    final result = await _dataSource.getDashboardStats(companyId);
    return result.fold(
      (failure) => Left(failure),
      (model) => Right(model),
    );
  }
}
