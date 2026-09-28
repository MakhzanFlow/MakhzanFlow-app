import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:makhzanflow/core/api/api_client.dart';
import 'package:makhzanflow/core/api/api_response.dart';
import 'package:makhzanflow/core/constants/api_endpoints.dart';
import 'package:makhzanflow/core/error/failures.dart';
import '../models/payment_model.dart';
import 'payment_remote_data_source.dart';

/// REST implementation backed by `GET /api/payments` (paginated payment
/// history — replaces client-side stitching of payments from invoices).
class PaymentRemoteDataSourceImpl implements PaymentRemoteDataSource {
  final ApiClient _apiClient;

  PaymentRemoteDataSourceImpl({required ApiClient apiClient})
      : _apiClient = apiClient;

  @override
  Future<Either<Failure, List<PaymentModel>>> getPayments(
    PaymentQuery query,
  ) async {
    try {
      final response = await _apiClient.dio.get(
        ApiEndpoints.payments,
        queryParameters: query.toQueryParameters(),
      );
      final body = response.data;
      if (body is Map<String, dynamic>) {
        final data = body['data'];
        if (data is List) {
          return Right(
            data
                .whereType<Map<String, dynamic>>()
                .map(PaymentModel.fromJson)
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
