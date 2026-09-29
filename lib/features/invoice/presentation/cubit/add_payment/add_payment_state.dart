import 'package:makhzanflow/core/error/failures.dart';
import 'package:makhzanflow/features/invoice/domain/entities/invoice.dart';

sealed class AddPaymentState {}

class AddPaymentInitial extends AddPaymentState {}

class AddPaymentLoading extends AddPaymentState {}

class AddPaymentLoaded extends AddPaymentState {
  final List<Invoice> invoices;
  final String? selectedInvoiceId;
  final String amount;
  final String customerName;
  final String companyId;
  final double? maxAmount;
  final String? amountError;

  AddPaymentLoaded({
    required this.invoices,
    this.selectedInvoiceId,
    this.amount = '',
    required this.customerName,
    required this.companyId,
    this.maxAmount,
    this.amountError,
  });

  static const _sentinel = Object();

  AddPaymentLoaded copyWith({
    List<Invoice>? invoices,
    String? selectedInvoiceId,
    String? amount,
    String? customerName,
    String? companyId,
    double? maxAmount,
    Object? amountError = _sentinel,
    bool clearSelection = false,
    bool clearMax = false,
  }) {
    return AddPaymentLoaded(
      invoices: invoices ?? this.invoices,
      selectedInvoiceId: clearSelection ? null : (selectedInvoiceId ?? this.selectedInvoiceId),
      amount: amount ?? this.amount,
      customerName: customerName ?? this.customerName,
      companyId: companyId ?? this.companyId,
      maxAmount: clearMax ? null : (maxAmount ?? this.maxAmount),
      amountError: amountError == _sentinel ? this.amountError : amountError as String?,
    );
  }
}

class AddPaymentSubmitting extends AddPaymentState {}

class AddPaymentSuccess extends AddPaymentState {
  final String invoiceId;
  AddPaymentSuccess({required this.invoiceId});
}

class AddPaymentError extends AddPaymentState {
  final Failure failure;
  AddPaymentError({required this.failure});
}
