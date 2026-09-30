import 'package:equatable/equatable.dart';

class Payment extends Equatable {
  final String id;
  final String invoiceId;
  final double amount;
  final String? createdBy;
  final DateTime createdAt;

  const Payment({
    required this.id,
    required this.invoiceId,
    required this.amount,
    this.createdBy,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, invoiceId, amount, createdBy, createdAt];
}
