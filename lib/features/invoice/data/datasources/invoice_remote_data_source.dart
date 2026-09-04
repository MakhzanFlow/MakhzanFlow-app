import 'package:fpdart/fpdart.dart';
import 'package:makhzanflow/core/error/failures.dart';
import 'package:makhzanflow/features/invoice/data/models/add_payment_dto.dart';
import 'package:makhzanflow/features/invoice/data/models/invoice_create_dto.dart';
import 'package:makhzanflow/features/invoice/data/models/invoice_model.dart';

abstract class InvoiceRemoteDataSource {
  Future<Either<Failure, InvoiceModel>> createInvoice(
    InvoiceCreateDto inputDto,
  );

  Future<Either<Failure, InvoiceModel>> addPayment(
    AddPaymentDto inputDto,
  );

  Future<Either<Failure, InvoiceModel>> getInvoice(
    String id,
    String companyId,
  );

  Future<Either<Failure, List<InvoiceModel>>> getInvoices({
    required String companyId,
    List<String>? statusFilter,
    String? customerId,
    int? limit,
    int? offset,
    String? search,
    String? sort,
    String? order,
    String? startDate,
    String? endDate,
  });

  Future<Either<Failure, InvoiceModel>> cancelInvoice(
    String id,
    String companyId,
  );
}
