import 'package:makhzanflow/features/invoice/domain/entities/payment.dart';

class PaymentModel {
  final String id;
  final String invoiceId;
  final double amount;
  final String? createdBy;
  final String method; // cash | card | bank_transfer | other
  final String? referenceNumber;
  final String? notes;
  final DateTime createdAt;

  const PaymentModel({
    required this.id,
    required this.invoiceId,
    required this.amount,
    this.createdBy,
    this.method = 'cash',
    this.referenceNumber,
    this.notes,
    required this.createdAt,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    final rawCreated = json['created_at'] as String?;
    if (rawCreated == null || rawCreated.isEmpty) {
      throw StateError('Missing created_at in payment ${json['id']}');
    }
    final parsed = DateTime.tryParse(rawCreated);
    if (parsed == null) {
      throw StateError('Invalid created_at: $rawCreated');
    }
    return PaymentModel(
      id: json['id'] as String,
      invoiceId: json['invoice_id'] as String,
      amount: (json['amount'] as num).toDouble(),
      createdBy: json['created_by'] as String? ?? json['user_id'] as String?,
      method: json['method'] as String? ?? 'cash',
      referenceNumber: json['reference_number'] as String?,
      notes: json['notes'] as String?,
      createdAt: parsed,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'invoice_id': invoiceId,
      'amount': amount,
      if (createdBy != null) 'created_by': createdBy,
      'method': method,
      if (referenceNumber != null) 'reference_number': referenceNumber,
      if (notes != null) 'notes': notes,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Payment toEntity() {
    return Payment(
      id: id,
      invoiceId: invoiceId,
      amount: amount,
      createdBy: createdBy,
      createdAt: createdAt,
    );
  }

  factory PaymentModel.fromEntity(Payment entity) {
    return PaymentModel(
      createdBy: entity.createdBy,
      id: entity.id,
      invoiceId: entity.invoiceId,
      amount: entity.amount,
      createdAt: entity.createdAt,
    );
  }
}
