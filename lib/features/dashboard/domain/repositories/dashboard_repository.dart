import 'package:fpdart/fpdart.dart';
import 'package:makhzanflow/core/error/failures.dart';
import '../entities/dashboard_stats.dart';
import '../entities/weekly_sales_point.dart';

/// Abstract contract for fetching aggregated dashboard data for a company.
abstract interface class DashboardRepository {
  /// Fetches all KPIs, weekly chart data, and recent activity for [companyId].
  Future<Either<Failure, DashboardStats>> getDashboardStats(String companyId);

  /// Fetches daily sales points for the selected dashboard range.
  Future<Either<Failure, List<WeeklySalesPoint>>> getSales({
    required String companyId,
    required String range,
  });
}
