import 'package:fpdart/fpdart.dart';
import 'package:makhzanflow/core/api/api_response.dart';
import 'package:makhzanflow/core/error/failures.dart';
import '../models/dashboard_stats_model.dart';
import '../models/low_stock_product_dto.dart';
import '../models/monthly_report_entry_dto.dart';
import '../models/activity_entry_dto.dart';

/// Contract for dashboard REST endpoints.
/// Primary endpoint `GET /dashboard/stats` aggregates 7 previous queries.
/// Additional endpoints expose paginated low-stock, monthly report and activity feeds.
abstract interface class DashboardRemoteDataSource {
  /// Primary KPI endpoint — single `GET /dashboard/stats` call.
  /// [companyId] is kept for backward-compat; tenant isolation is enforced
  /// via `x-company-id` header injected by [AuthInterceptor].
  Future<Either<Failure, DashboardStatsModel>> getDashboardStats(String companyId);

  /// `GET /dashboard/low-stock?page=&limit=&search=&sort=&order=`
  Future<Either<Failure, PaginatedResponse<LowStockProductDto>>> getLowStock({
    required String companyId,
    int page = 1,
    int limit = 20,
    String? search,
    String? sort,
    String? order,
  });

  /// `GET /dashboard/monthly-report?months=&from=&to=`
  Future<Either<Failure, List<MonthlyReportEntryDto>>> getMonthlyReport({
    required String companyId,
    int months = 12,
    String? from,
    String? to,
  });

  /// `GET /dashboard/activity?page=&limit=`
  Future<Either<Failure, PaginatedResponse<ActivityEntryDto>>> getActivity({
    required String companyId,
    int page = 1,
    int limit = 20,
  });
}
