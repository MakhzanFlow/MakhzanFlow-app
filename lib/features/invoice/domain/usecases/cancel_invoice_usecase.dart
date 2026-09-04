import 'package:fpdart/fpdart.dart';
import 'package:makhzanflow/core/error/failures.dart';
import 'package:makhzanflow/features/invoice/domain/entities/invoice.dart';
import 'package:makhzanflow/features/invoice/domain/repositories/invoice_repository.dart';

class CancelInvoiceUseCase {
  final InvoiceRepository repository;

  CancelInvoiceUseCase(this.repository);

  Future<Either<Failure, Invoice>> call(String id, String companyId) {
    return repository.cancelInvoice(id, companyId);
  }
}
