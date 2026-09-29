import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:makhzanflow/core/constants/app_strings.dart';
import 'package:makhzanflow/core/error/failures.dart';
import 'package:makhzanflow/core/sync/enqueue_guard.dart';
import 'package:makhzanflow/features/invoice/domain/usecases/cancel_invoice_usecase.dart';
import 'package:makhzanflow/features/invoice/domain/usecases/get_invoice_usecase.dart';
import 'invoice_details_state.dart';

export 'invoice_details_state.dart';

class InvoiceDetailsCubit extends Cubit<InvoiceDetailsState> {
  final GetInvoiceUseCase _getInvoiceUseCase;
  final CancelInvoiceUseCase _cancelInvoiceUseCase;
  String? _lastInvoiceId;

  InvoiceDetailsCubit({
    required GetInvoiceUseCase getInvoiceUseCase,
    required CancelInvoiceUseCase cancelInvoiceUseCase,
  })  : _getInvoiceUseCase = getInvoiceUseCase,
        _cancelInvoiceUseCase = cancelInvoiceUseCase,
        super(InvoiceDetailsInitial());

  Future<void> loadInvoice(String id, String companyId) async {
    _lastInvoiceId = id;
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

    final result =
        await _cancelInvoiceUseCase(invoice.id, companyId, invoice.version);
    await result.fold(
      (failure) async {
        // Cancels move money: online-only, never queued. Surface a clear
        // message instead of the raw connection error.
        if (shouldEnqueueFailure(failure)) {
          emit(InvoiceDetailsError(
            failure: ServerFailure(AppStrings.onlineRequired),
          ));
          return;
        }
        emit(InvoiceDetailsError(failure: failure));
      },
      (canceled) async => emit(InvoiceDetailsCanceled(invoice: canceled)),
    );
  }

  /// Retries a cancel after a Merge "Keep mine" choice: reloads the invoice
  /// (fresh server copy) then cancels with its current version.
  Future<void> retryCancel(String companyId) async {
    final id = _lastInvoiceId;
    if (id == null) return;
    await loadInvoice(id, companyId);
    final current = state;
    if (current is InvoiceDetailsLoaded) {
      await cancelInvoice(companyId);
    }
  }
}
