import '../../domain/entities/payment.dart';

/// DTO for one row of `GET /api/payments`:
/// `{ id, company_id, invoice_id, amount, method, reference_number, notes,
///    created_at, invoices: { invoice_number, status, customer_id,
///    customers: { id, name } } }`
class PaymentModel extends Payment {
  const PaymentModel({
    required super.id,
    required super.companyId,
    required super.invoiceId,
    required super.amount,
    required super.method,
    super.referenceNumber,
    super.notes,
    super.createdAt,
    super.invoiceNumber,
    super.invoiceStatus,
    super.customerId,
    super.customerName,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    final invoices = json['invoices'] as Map<String, dynamic>?;
    final customers = invoices?['customers'] as Map<String, dynamic>?;
    DateTime? createdAt;
    final rawCreated = json['created_at'];
    if (rawCreated is String && rawCreated.isNotEmpty) {
      createdAt = DateTime.tryParse(rawCreated);
    }
    return PaymentModel(
      id: json['id'] as String? ?? '',
      companyId: json['company_id'] as String? ?? '',
      invoiceId: json['invoice_id'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      method: json['method'] as String? ?? 'cash',
      referenceNumber: json['reference_number'] as String?,
      notes: json['notes'] as String?,
      createdAt: createdAt,
      invoiceNumber: invoices?['invoice_number'] as String?,
      invoiceStatus: invoices?['status'] as String?,
      customerId: customers?['id'] as String? ??
          invoices?['customer_id'] as String?,
      customerName: customers?['name'] as String?,
    );
  }

  Payment toEntity() => Payment(
        id: id,
        companyId: companyId,
        invoiceId: invoiceId,
        amount: amount,
        method: method,
        referenceNumber: referenceNumber,
        notes: notes,
        createdAt: createdAt,
        invoiceNumber: invoiceNumber,
        invoiceStatus: invoiceStatus,
        customerId: customerId,
        customerName: customerName,
      );
}
