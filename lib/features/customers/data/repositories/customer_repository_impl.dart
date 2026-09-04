import 'package:fpdart/fpdart.dart';
import 'package:makhzanflow/core/error/failures.dart';
import '../../domain/entities/customer.dart';
import '../../domain/entities/customer_filter_counts.dart';
import '../../domain/entities/customer_summary.dart';
import '../../domain/repositories/customer_repository.dart';
import '../datasources/customer_remote_data_source.dart';
import '../models/create_customer_request_dto.dart';
import '../models/update_customer_request_dto.dart';

class CustomerRepositoryImpl implements CustomerRepository {
  final CustomerRemoteDataSource dataSource;

  CustomerRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, List<Customer>>> listCustomers({
    String? query,
    String? filter,
    int? limit,
    int? offset,
    required String companyId,
  }) async {
    final result = await dataSource.listCustomers(
      query: query,
      filter: filter,
      limit: limit,
      offset: offset,
      companyId: companyId,
    );
    return result.map((models) => models.map((m) => m.toEntity()).toList());
  }

  @override
  Future<Either<Failure, CustomerFilterCounts>> getCustomerFilterCounts({
    String? query,
    required String companyId,
  }) async {
    final result = await dataSource.getFilterCounts(
      query: query,
      companyId: companyId,
    );
    return result.map((model) => model.toEntity());
  }

  @override
  Future<Either<Failure, Customer>> getCustomer(
    String id,
    String companyId,
  ) async {
    final result = await dataSource.getCustomer(id, companyId);
    return result.map((model) => model.toEntity());
  }

  @override
  Future<Either<Failure, Customer>> createCustomer({
    required String name,
    String? nameOfficial,
    String? phone,
    String? address,
    double totalDebt = 0,
    String? imageUrl,
    required String companyId,
  }) async {
    if (name.trim().isEmpty) {
      return Left(ServerFailure('يرجى إدخال اسم العميل'));
    }
    final dto = CreateCustomerRequestDto(
      name: name,
      nameOfficial: nameOfficial,
      phone: phone,
      address: address,
      openingBalance: totalDebt > 0 ? totalDebt : null,
    );
    final result = await dataSource.createCustomer(dto, companyId);
    return result.map((model) => model.toEntity());
  }

  @override
  Future<Either<Failure, Customer>> updateCustomer({
    required String id,
    required String name,
    String? nameOfficial,
    String? phone,
    String? address,
    String? imageUrl,
    required String companyId,
  }) async {
    if (name.trim().isEmpty) {
      return Left(ServerFailure('يرجى إدخال اسم العميل'));
    }
    final dto = UpdateCustomerRequestDto(
      name: name,
      nameOfficial: nameOfficial,
      phone: phone,
      address: address,
    );
    final result = await dataSource.updateCustomer(id, dto, companyId);
    return result.map((model) => model.toEntity());
  }

  @override
  Future<Either<Failure, String>> uploadCustomerImage(
    String filePath,
    String customerId,
  ) async {
    return dataSource.uploadImage(filePath, customerId);
  }

  // ──────── Phase 12: Summary, Debt ────────

  @override
  Future<Either<Failure, CustomerSummary>> getSummary(
    String companyId,
  ) async {
    final result = await dataSource.getSummary(companyId);
    return result.map((dto) => CustomerSummary(
      total: dto.total,
      withDebt: dto.withDebt,
      zeroDebt: dto.zeroDebt,
      creditBalance: dto.creditBalance,
    ));
  }

  @override
  Future<Either<Failure, List<Customer>>> getDebtors(
    String companyId, {
    int? limit,
    int? offset,
  }) async {
    final result = await dataSource.getDebtors(
      companyId,
      limit: limit,
      offset: offset,
    );
    return result.map((models) => models.map((m) => m.toEntity()).toList());
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getCustomerDebt(
    String customerId,
    String companyId,
  ) async {
    return dataSource.getCustomerDebt(customerId, companyId);
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getCustomerInvoices(
    String customerId,
    String companyId, {
    int? limit,
    int? offset,
  }) async {
    return dataSource.getCustomerInvoices(
      customerId,
      companyId,
      limit: limit,
      offset: offset,
    );
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getCustomerPayments(
    String customerId,
    String companyId, {
    int? limit,
    int? offset,
  }) async {
    return dataSource.getCustomerPayments(
      customerId,
      companyId,
      limit: limit,
      offset: offset,
    );
  }
}
