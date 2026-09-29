import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:makhzanflow/core/api/api_client.dart';
import 'package:makhzanflow/core/api/api_response.dart';
import 'package:makhzanflow/core/constants/api_endpoints.dart';
import 'package:makhzanflow/core/error/failures.dart';
import 'activity_log_entry.dart';

/// Fetches the audit trail for one record:
/// `GET /api/activity-logs/:entity/:entityId?page=&limit=`.
/// Read gates are entity-aware server-side (`products.read` etc.).
class ActivityLogDataSource {
  final ApiClient _apiClient;

  ActivityLogDataSource({required ApiClient apiClient})
      : _apiClient = apiClient;

  Future<Either<Failure, List<ActivityLogEntry>>> getLogs({
    required ActivityLogEntity entity,
    required String entityId,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _apiClient.dio.get(
        ApiEndpoints.activityLogs(entity.segment, entityId),
        queryParameters: {'page': page, 'limit': limit},
      );
      final body = response.data;
      if (body is Map<String, dynamic>) {
        final data = body['data'];
        if (data is List) {
          return Right(
            data
                .whereType<Map<String, dynamic>>()
                .map(ActivityLogEntry.fromJson)
                .toList(),
          );
        }
      }
      return const Right([]);
    } on DioException catch (e) {
      return Left(mapDioExceptionToFailure(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
