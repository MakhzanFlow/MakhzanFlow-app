import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:makhzanflow/features/invoice/domain/usecases/cancel_invoice_usecase.dart';
import 'package:makhzanflow/features/invoice/domain/usecases/get_invoice_usecase.dart';
import 'invoice_details_state.dart';

export 'invoice_details_state.dart';

class InvoiceDetailsCubit extends Cubit<InvoiceDetailsState> {
  final GetInvoiceUseCase _getInvoiceUseCase;
  final CancelInvoiceUseCase _cancelInvoiceUseCase;

  InvoiceDetailsCubit({
    required GetInvoiceUseCase getInvoiceUseCase,
    required CancelInvoiceUseCase cancelInvoiceUseCase,
  })  : _getInvoiceUseCase = getInvoiceUseCase,
        _cancelInvoiceUseCase = cancelInvoiceUseCase,
        super(InvoiceDetailsInitial());

  Future<void> loadInvoice(String id, String companyId) async {
    emit(InvoiceDetailsLoading());

    final result = await _getInvoiceUseCase(id, companyId);

    result.fold(
      (failure) => emit(InvoiceDetailsError(failure: failure)),
      (invoice) => emit(InvoiceDetailsLoaded(invoice: invoice)),
    );
  }

  Future<void> cancelInvoice(String companyId) async {
    final current = state;
    final invoice = switch (current) {
      InvoiceDetailsLoaded(:final invoice) => invoice,
      InvoiceDetailsCanceling(:final invoice) => invoice,
      _ => null,
    };
    if (invoice == null) return;

    emit(InvoiceDetailsCanceling(invoice: invoice));

    final result = await _cancelInvoiceUseCase(invoice.id, companyId);

    result.fold(
      (failure) => emit(InvoiceDetailsError(failure: failure)),
      (canceled) => emit(InvoiceDetailsCanceled(invoice: canceled)),
    );
  }
}
