import 'package:fpdart/fpdart.dart';
import 'package:makhzanflow/core/error/failures.dart';
import 'package:makhzanflow/features/invoice/domain/repositories/invoice_repository.dart';

class AddPaymentUseCase {
  final InvoiceRepository repository;

  AddPaymentUseCase(this.repository);

  Future<Either<Failure, String>> call({
    required String invoiceId,
    required double amount,
    String method = 'cash',
    String? referenceNumber,
    String? notes,
  }) {
    return repository.addPayment(
      invoiceId: invoiceId,
      amount: amount,
      method: method,
      referenceNumber: referenceNumber,
      notes: notes,
    );
  }
}
