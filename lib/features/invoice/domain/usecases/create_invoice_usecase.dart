import 'package:fpdart/fpdart.dart';
import 'package:makhzanflow/core/error/failures.dart';
import 'package:makhzanflow/features/invoice/domain/repositories/invoice_repository.dart';

class CreateInvoiceUseCase {
  final InvoiceRepository repository;

  CreateInvoiceUseCase(this.repository);

  Future<Either<Failure, String>> call({
    required String customerId,
    required List<Map<String, dynamic>> items,
    double paidNow = 0,
    String discountType = 'fixed',
    double discountValue = 0,
    double? discountAmount,
    double? taxAmount,
    String? dueDate,
    String paymentMethod = 'cash',
    String? referenceNumber,
    String? notes,
  }) {
    return repository.createInvoice(
      customerId: customerId,
      items: items,
      paidNow: paidNow,
      discountType: discountType,
      discountValue: discountValue,
      discountAmount: discountAmount,
      taxAmount: taxAmount,
      dueDate: dueDate,
      paymentMethod: paymentMethod,
      referenceNumber: referenceNumber,
      notes: notes,
    );
  }
}
