import 'package:fpdart/fpdart.dart';
import 'package:makhzanflow/core/error/failures.dart';
import '../models/payment_model.dart';

/// Filters for `GET /api/payments`.
class PaymentQuery {
  final int page;
  final int limit;
  final String? search;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? sort;
  final String? order;

  const PaymentQuery({
    this.page = 1,
    this.limit = 20,
    this.search,
    this.startDate,
    this.endDate,
    this.sort,
    this.order,
  });

  Map<String, dynamic> toQueryParameters() => {
        'page': page,
        'limit': limit,
        if (search != null && search!.trim().isNotEmpty) 'search': search,
        if (startDate != null)
          'start_date': startDate!.toIso8601String().split('T').first,
        if (endDate != null)
          'end_date': endDate!.toIso8601String().split('T').first,
        if (sort != null && sort!.isNotEmpty) 'sort': sort,
        if (order != null && order!.isNotEmpty) 'order': order,
      };
}

abstract class PaymentRemoteDataSource {
  Future<Either<Failure, List<PaymentModel>>> getPayments(PaymentQuery query);
}
