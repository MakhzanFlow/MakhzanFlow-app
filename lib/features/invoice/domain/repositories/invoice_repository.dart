import 'package:fpdart/fpdart.dart';
import 'package:makhzanflow/core/error/failures.dart';
import 'package:makhzanflow/features/invoice/domain/entities/invoice.dart';

abstract class InvoiceRepository {
  Future<Either<Failure, String>> createInvoice({
    required String customerId,
    required List<Map<String, dynamic>> items,
    double? discountAmount,
    double? taxAmount,
    String? dueDate,
    double paidNow = 0,
    String paymentMethod = 'cash',
    String discountType = 'fixed',
    double discountValue = 0,
    String? referenceNumber,
    String? notes,
  });

  /// Backward compat: original signature without new fields still works via defaults.
  /// Added optional method/referenceNumber/notes for REST addPayment.
  Future<Either<Failure, String>> addPayment({
    required String invoiceId,
    required double amount,
    String method = 'cash',
    String? referenceNumber,
    String? notes,
  });

  Future<Either<Failure, Invoice>> getInvoice(
    String id,
    String companyId,
  );

  Future<Either<Failure, List<Invoice>>> getInvoices({
    required String companyId,
    List<String>? statusFilter,
    String? customerId,
    int? limit,
    int? offset,
  });

  Future<Either<Failure, Invoice>> cancelInvoice(
    String id,
    String companyId,
  );
}
