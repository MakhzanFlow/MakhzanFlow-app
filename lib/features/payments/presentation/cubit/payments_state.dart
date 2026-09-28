import 'package:equatable/equatable.dart';
import 'package:makhzanflow/core/error/failures.dart';
import '../../domain/entities/payment.dart';

enum PaymentsStatus { initial, loading, success, empty, error }

class PaymentsState extends Equatable {
  final PaymentsStatus status;
  final List<Payment> payments;
  final Failure? failure;
  final String? search;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? sort;
  final String? order;

  const PaymentsState({
    this.status = PaymentsStatus.initial,
    this.payments = const [],
    this.failure,
    this.search,
    this.startDate,
    this.endDate,
    this.sort,
    this.order,
  });

  PaymentsState copyWith({
    PaymentsStatus? status,
    List<Payment>? payments,
    Failure? failure,
    bool clearFailure = false,
    String? search,
    DateTime? startDate,
    DateTime? endDate,
    String? sort,
    String? order,
  }) {
    return PaymentsState(
      status: status ?? this.status,
      payments: payments ?? this.payments,
      failure: clearFailure ? null : failure ?? this.failure,
      search: search ?? this.search,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      sort: sort ?? this.sort,
      order: order ?? this.order,
    );
  }

  @override
  List<Object?> get props =>
      [status, payments, failure, search, startDate, endDate, sort, order];
}
