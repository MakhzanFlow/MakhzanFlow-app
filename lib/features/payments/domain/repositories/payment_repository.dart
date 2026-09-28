import 'package:fpdart/fpdart.dart';
import 'package:makhzanflow/core/error/failures.dart';
import '../entities/payment.dart';
import '../../data/datasources/payment_remote_data_source.dart';

abstract class PaymentRepository {
  Future<Either<Failure, List<Payment>>> getPayments(PaymentQuery query);
}
