import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:makhzanflow/core/constants/app_strings.dart';
import 'package:makhzanflow/core/error/failures.dart';
import 'package:makhzanflow/core/sync/enqueue_guard.dart';
import 'package:makhzanflow/features/invoice/domain/usecases/add_payment_usecase.dart';
import 'package:makhzanflow/features/invoice/domain/usecases/get_invoices_usecase.dart';
import 'add_payment_state.dart';

export 'add_payment_state.dart';

class AddPaymentCubit extends Cubit<AddPaymentState> {
  final GetInvoicesUseCase _getInvoicesUseCase;
  final AddPaymentUseCase _addPaymentUseCase;

  AddPaymentCubit({
    required GetInvoicesUseCase getInvoicesUseCase,
    required AddPaymentUseCase addPaymentUseCase,
  })  : _getInvoicesUseCase = getInvoicesUseCase,
        _addPaymentUseCase = addPaymentUseCase,
        super(AddPaymentInitial());

  Future<void> loadUnpaidInvoices({
    required String customerId,
    required String customerName,
    required String companyId,
  }) async {
    emit(AddPaymentLoading());

    final result = await _getInvoicesUseCase(
      companyId: companyId,
      statusFilter: ['debt', 'partial'],
      customerId: customerId,
    );

    result.fold(
      (failure) => emit(AddPaymentError(failure: failure)),
      (invoices) => emit(
        AddPaymentLoaded(
          invoices: invoices,
          customerName: customerName,
          companyId: companyId,
        ),
      ),
    );
  }

  void selectInvoice(String invoiceId) {
    final current = state;
    if (current is! AddPaymentLoaded) return;

    final invoice = current.invoices.where((i) => i.id == invoiceId).firstOrNull;
    final maxAmount = invoice?.remainingAmount;

    String? error;
    final parsed = double.tryParse(current.amount);
    if (parsed != null && maxAmount != null && parsed > maxAmount) {
      error = 'المبلغ يتجاوز المبلغ المتبقي (${_formatAmount(maxAmount)})';
    }

    emit(current.copyWith(
      selectedInvoiceId: invoiceId,
      maxAmount: maxAmount,
      amountError: error,
    ));
  }
  void updateAmount(String amount) {
    final current = state;
    if (current is! AddPaymentLoaded) return;

    String? error;
    final parsed = double.tryParse(amount);
    if (parsed != null && current.maxAmount != null && parsed > current.maxAmount!) {
      error = 'المبلغ يتجاوز المبلغ المتبقي (${_formatAmount(current.maxAmount!)})';
    }

    emit(current.copyWith(amount: amount, amountError: error));
  }

  /// Adopts the fresh server version for one invoice after a Merge "Keep mine"
  /// choice, so the next [submit] retries against current data (guide §5).
  void refreshInvoiceVersion(String invoiceId, int version) {
    final current = state;
    if (current is! AddPaymentLoaded) return;
    emit(current.copyWith(
      invoices: current.invoices
          .map((i) => i.id == invoiceId ? i.copyWith(version: version) : i)
          .toList(),
    ));
  }

  bool get canSubmit {
    final current = state;
    if (current is! AddPaymentLoaded) return false;
    final parsed = double.tryParse(current.amount);
    return parsed != null &&
        parsed > 0 &&
        current.selectedInvoiceId != null &&
        current.amountError == null;
  }

  Future<void> submit() async {
    final current = state;
    if (current is! AddPaymentLoaded) return;

    final parsed = double.tryParse(current.amount);
    if (parsed == null || parsed <= 0) {
      emit(AddPaymentError(
        failure: const ServerFailure('يرجى إدخال مبلغ صحيح'),
      ));
      return;
    }

    if (current.selectedInvoiceId == null) {
      emit(AddPaymentError(
        failure: const ServerFailure('يرجى اختيار فاتورة'),
      ));
      return;
    }

    if (current.amountError != null) {
      emit(AddPaymentError(
        failure: ServerFailure(current.amountError!),
      ));
      return;
    }
    emit(AddPaymentSubmitting());

    final invoiceId = current.selectedInvoiceId!;
    final result = await _addPaymentUseCase(
      invoiceId: invoiceId,
      amount: parsed,
      version: current.invoices
          .where((i) => i.id == invoiceId)
          .firstOrNull
          ?.version,
    );

    await result.fold(
      (failure) async {
        // Payments move money: online-only, never queued. Surface a clear
        // message instead of the raw connection error.
        if (shouldEnqueueFailure(failure)) {
          emit(AddPaymentError(
            failure: ServerFailure(AppStrings.onlineRequired),
          ));
          return;
        }
        emit(AddPaymentError(failure: failure));
      },
      (_) async => emit(AddPaymentSuccess(invoiceId: current.selectedInvoiceId!)),
    );
  }

  String _formatAmount(double amount) {
    if (amount == amount.truncateToDouble()) {
      return amount.toInt().toString();
    }
    return amount.toStringAsFixed(2);
  }
}
