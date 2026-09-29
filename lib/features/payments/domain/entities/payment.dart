import 'package:equatable/equatable.dart';

/// A single payment row from `GET /api/payments`.
class Payment extends Equatable {
  final String id;
  final String companyId;
  final String invoiceId;
  final double amount;
  final String method;
  final String? referenceNumber;
  final String? notes;
  final DateTime? createdAt;
  final String? invoiceNumber;
  final String? invoiceStatus;
  final String? customerId;
  final String? customerName;

  const Payment({
    required this.id,
    required this.companyId,
    required this.invoiceId,
    required this.amount,
    required this.method,
    this.referenceNumber,
    this.notes,
    this.createdAt,
    this.invoiceNumber,
    this.invoiceStatus,
    this.customerId,
    this.customerName,
  });

  @override
  List<Object?> get props => [
        id,
        companyId,
        invoiceId,
        amount,
        method,
        referenceNumber,
        notes,
        createdAt,
        invoiceNumber,
        invoiceStatus,
        customerId,
        customerName,
      ];
}
