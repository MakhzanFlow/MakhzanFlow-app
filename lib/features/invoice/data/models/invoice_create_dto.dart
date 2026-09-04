import 'invoice_item_dto.dart';

/// DTO aligned with POST /invoices validation schema (createInvoiceSchema).
/// REST format: { customer_id, discount_amount, tax_amount, due_date, items, payment }
class InvoiceCreateDto {
  final String customerId;
  final double discountAmount;
  final double taxAmount;
  final String? dueDate; // YYYY-MM-DD | null
  final List<InvoiceItemDto> items;
  final InvoiceInitialPaymentDto? payment;

  const InvoiceCreateDto({
    required this.customerId,
    this.discountAmount = 0,
    this.taxAmount = 0,
    this.dueDate,
    required this.items,
    this.payment,
  });

  Map<String, dynamic> toJson() {
    return {
      'customer_id': customerId,
      'discount_amount': discountAmount,
      'tax_amount': taxAmount,
      if (dueDate != null && dueDate!.isNotEmpty) 'due_date': dueDate,
      'items': items.map((e) => e.toJson()).toList(),
      if (payment != null) 'payment': payment!.toJson(),
    };
  }
}

/// Nested payment object for invoice creation.
class InvoiceInitialPaymentDto {
  final double amount;
  final String method; // cash | card | bank_transfer | other
  final String? referenceNumber;
  final String? notes;

  const InvoiceInitialPaymentDto({
    required this.amount,
    this.method = 'cash',
    this.referenceNumber,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'method': method,
      if (referenceNumber != null) 'reference_number': referenceNumber,
      if (notes != null) 'notes': notes,
    };
  }

  factory InvoiceInitialPaymentDto.fromJson(Map<String, dynamic> json) {
    return InvoiceInitialPaymentDto(
      amount: (json['amount'] as num).toDouble(),
      method: json['method'] as String? ?? 'cash',
      referenceNumber: json['reference_number'] as String?,
      notes: json['notes'] as String?,
    );
  }
}
