/// DTO aligned with POST /invoices/:id/payments validation schema (addPaymentSchema).
/// REST format: { amount, method, reference_number, notes, version? }
/// invoiceId is kept for routing (path param) but NOT serialized into body.
class AddPaymentDto {
  final String invoiceId;
  final double amount;
  final String method; // cash | card | bank_transfer | other
  final String? referenceNumber;
  final String? notes;
  /// Invoice version from the last GET — gates the payment write.
  final int? version;

  const AddPaymentDto({
    required this.invoiceId,
    required this.amount,
    this.method = 'cash',
    this.referenceNumber,
    this.notes,
    this.version,
  });

  /// Body payload only — invoiceId is used as URL param in data source.
  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'method': method,
      if (referenceNumber != null) 'reference_number': referenceNumber,
      if (notes != null) 'notes': notes,
      if (version != null) 'version': version,
    };
  }

  factory AddPaymentDto.fromJson(Map<String, dynamic> json) {
    return AddPaymentDto(
      invoiceId: json['invoice_id'] as String? ?? '',
      amount: (json['amount'] as num).toDouble(),
      method: json['method'] as String? ?? 'cash',
      referenceNumber: json['reference_number'] as String?,
      notes: json['notes'] as String?,
      version: (json['version'] as num?)?.toInt(),
    );
  }
}
