import 'package:fpdart/fpdart.dart';
import 'package:makhzanflow/core/error/failures.dart';
import '../models/customer_model.dart';
import '../models/customer_filter_counts_model.dart';
import '../models/create_customer_request_dto.dart';
import '../models/update_customer_request_dto.dart';
import '../models/customer_summary_response_dto.dart';

abstract class CustomerRemoteDataSource {
  Future<Either<Failure, List<CustomerModel>>> listCustomers({
    String? query,
    String? filter,
    int? limit,
    int? offset,
    required String companyId,
  });

  Future<Either<Failure, CustomerFilterCountsModel>> getFilterCounts({
    String? query,
    required String companyId,
  });

  Future<Either<Failure, CustomerModel>> getCustomer(
    String id,
    String companyId,
  );

  Future<Either<Failure, CustomerModel>> createCustomer(
    CreateCustomerRequestDto dto,
    String companyId,
  );

  Future<Either<Failure, CustomerModel>> updateCustomer(
    String id,
    UpdateCustomerRequestDto dto,
    String companyId,
  );

  Future<Either<Failure, String>> uploadImage(
    String filePath,
    String customerId,
  );

  Future<Either<Failure, CustomerSummaryResponseDto>> getSummary(
    String companyId,
  );

  Future<Either<Failure, List<CustomerModel>>> getDebtors(
    String companyId, {
    int? limit,
    int? offset,
  });

  Future<Either<Failure, Map<String, dynamic>>> getCustomerDebt(
    String customerId,
    String companyId,
  );

  Future<Either<Failure, List<Map<String, dynamic>>>> getCustomerInvoices(
    String customerId,
    String companyId, {
    int? limit,
    int? offset,
  });

  Future<Either<Failure, List<Map<String, dynamic>>>> getCustomerPayments(
    String customerId,
    String companyId, {
    int? limit,
    int? offset,
  });
}
