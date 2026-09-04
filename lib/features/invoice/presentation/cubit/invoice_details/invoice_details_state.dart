import 'package:makhzanflow/core/error/failures.dart';
import 'package:makhzanflow/features/invoice/domain/entities/invoice.dart';

sealed class InvoiceDetailsState {}

class InvoiceDetailsInitial extends InvoiceDetailsState {}

class InvoiceDetailsLoading extends InvoiceDetailsState {}

class InvoiceDetailsLoaded extends InvoiceDetailsState {
  final Invoice invoice;
  InvoiceDetailsLoaded({required this.invoice});
}

class InvoiceDetailsError extends InvoiceDetailsState {
  final Failure failure;
  InvoiceDetailsError({required this.failure});
}

class InvoiceDetailsCanceling extends InvoiceDetailsState {
  final Invoice invoice;
  InvoiceDetailsCanceling({required this.invoice});
}

class InvoiceDetailsCanceled extends InvoiceDetailsState {
  final Invoice invoice;
  InvoiceDetailsCanceled({required this.invoice});
}
