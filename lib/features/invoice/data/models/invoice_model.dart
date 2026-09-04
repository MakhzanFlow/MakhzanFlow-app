import 'package:makhzanflow/features/invoice/data/models/invoice_item_model.dart';
import 'package:makhzanflow/features/invoice/data/models/payment_model.dart';
import 'package:makhzanflow/features/invoice/domain/entities/invoice.dart';
import 'package:makhzanflow/features/invoice/domain/entities/invoice_status.dart';

class InvoiceModel {
  final String id;
  final String customerId;
  final String? customerName;
  final String? createdBy;
  final String? createdByName;
  final List<InvoiceItemModel> items;
  final List<PaymentModel> payments;
  final double subtotal;
  final String? discountType;
  final double discountValue;
  final double discountAmount;
  final double taxAmount;
  final double totalAmount;
  final double remainingAmount;
  final String paymentStatus;
  final String? invoiceNumber;
  final DateTime? dueDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const InvoiceModel({
    required this.id,
    required this.customerId,
    this.customerName,
    this.createdBy,
    this.createdByName,
    this.items = const [],
    this.payments = const [],
    required this.subtotal,
    this.discountType,
    this.discountValue = 0,
    this.discountAmount = 0,
    this.taxAmount = 0,
    required this.totalAmount,
    this.remainingAmount = 0,
    this.paymentStatus = 'debt',
    this.invoiceNumber,
    this.dueDate,
    this.createdAt,
    this.updatedAt,
  });

  factory InvoiceModel.fromJson(Map<String, dynamic> json) {
    // Backend customers field is plural "customers" (may be null)
    final customers = json['customers'] as Map<String, dynamic>?;
    final customerAlt = json['customer'] as Map<String, dynamic>?;
    final customerName = customers?['name'] as String? ??
        customerAlt?['name'] as String? ??
        json['customer_name'] as String?;

    // Users field: backend uses "users" (single object)
    final users = json['users'] as Map<String, dynamic>?;
    final createdBy = json['user_id'] as String? ??
        users?['id'] as String? ??
        json['created_by'] as String?;
    final createdByName = users?['name'] as String? ??
        json['created_by_name'] as String? ??
        users?['email'] as String?;

    // Items: backend uses "invoice_items" (full) or may be missing in list view
    final rawItems = json['invoice_items'] as List<dynamic>? ??
        json['items'] as List<dynamic>?;
    final items = rawItems
            ?.map((e) => InvoiceItemModel.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    // Payments: backend uses "payments"
    final rawPayments = json['payments'] as List<dynamic>?;
    final payments = rawPayments
            ?.map((e) => PaymentModel.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    // Amounts
    final totalAmount = (json['total_amount'] as num?)?.toDouble() ?? 0;
    final discountAmount = (json['discount_amount'] as num?)?.toDouble() ?? 0;
    final taxAmount = (json['tax_amount'] as num?)?.toDouble() ?? 0;

    // Subtotal fallback: sum of items or total + discount - tax
    double subtotal;
    if (json['subtotal'] != null) {
      subtotal = (json['subtotal'] as num).toDouble();
    } else if (items.isNotEmpty) {
      subtotal = items.fold(0.0, (s, i) => s + i.totalPrice);
      if (subtotal == 0) {
        subtotal = totalAmount + discountAmount - taxAmount;
      }
    } else {
      subtotal = totalAmount + discountAmount - taxAmount;
    }

    // Discount type/value mapping: backend only has discount_amount (fixed)
    final discountType = json['discount_type'] as String? ?? 'fixed';
    final discountValue = (json['discount_value'] as num?)?.toDouble() ?? discountAmount;

    // Remaining: total - sum(payments) unless backend provides it
    final remainingFromJson = (json['remaining_amount'] as num?)?.toDouble();
    final sumPaid = payments.fold(0.0, (s, p) => s + p.amount);
    final remainingAmount = remainingFromJson ?? (totalAmount - sumPaid).clamp(0, double.infinity).toDouble();

    // Status resolution
    final paymentStatus = _resolvePaymentStatus(json, remainingAmount, totalAmount);

    // Due date parsing: backend may send YYYY-MM-DD or ISO string
    DateTime? dueDate;
    final rawDueDate = json['due_date'];
    if (rawDueDate is String && rawDueDate.isNotEmpty) {
      dueDate = DateTime.tryParse(rawDueDate);
    }

    // CustomerId is required — enforce per business rule.
    final String? rawCustomerId = customers?['id'] as String? ??
        customerAlt?['id'] as String? ??
        json['customer_id'] as String?;
    if (rawCustomerId == null || rawCustomerId.isEmpty) {
      throw StateError('Missing required customer_id in invoice ${json['id']}');
    }

    return InvoiceModel(
      id: json['id'] as String,
      customerId: rawCustomerId,
      customerName: customerName,
      createdBy: createdBy,
      createdByName: createdByName,
      items: items,
      payments: payments,
      subtotal: subtotal,
      discountType: discountType,
      discountValue: discountValue,
      discountAmount: discountAmount,
      taxAmount: taxAmount,
      totalAmount: totalAmount,
      remainingAmount: remainingAmount,
      paymentStatus: paymentStatus,
      invoiceNumber: json['invoice_number'] as String?,
      dueDate: dueDate,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
          : null,
    );
  }

  static String _resolvePaymentStatus(
    Map<String, dynamic> json,
    double remaining,
    double total,
  ) {
    final raw = (json['status'] as String?) ?? (json['payment_status'] as String?);
    if (raw != null) {
      // Map backend enums to legacy values used by app
      switch (raw) {
        case 'paid':
          return 'paid';
        case 'partially_paid':
        case 'partial':
          return 'partial';
        case 'pending':
        case 'debt':
          return 'debt';
        case 'canceled':
          return 'canceled';
      }
      // fallback to raw if unknown
      return raw;
    }
    if (remaining <= 0 && total > 0) return 'paid';
    if (remaining < total && remaining > 0) return 'partial';
    return 'debt';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer_id': customerId,
      if (customerName != null) 'customer_name': customerName,
      if (createdBy != null) 'created_by': createdBy,
      if (createdByName != null) 'created_by_name': createdByName,
      'subtotal': subtotal,
      if (discountType != null) 'discount_type': discountType,
      'discount_value': discountValue,
      'discount_amount': discountAmount,
      'tax_amount': taxAmount,
      'total_amount': totalAmount,
      'remaining_amount': remainingAmount,
      'payment_status': paymentStatus,
      if (invoiceNumber != null) 'invoice_number': invoiceNumber,
      if (dueDate != null) 'due_date': dueDate!.toIso8601String().split('T').first,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
      'invoice_items': items.map((e) => e.toJson()).toList(),
      'payments': payments.map((e) => e.toJson()).toList(),
    };
  }

  Invoice toEntity() {
    return Invoice(
      id: id,
      customerId: customerId,
      customerName: customerName,
      createdBy: createdBy,
      createdByName: createdByName,
      items: items.map((e) => e.toEntity()).toList(),
      payments: payments.map((e) => e.toEntity()).toList(),
      subtotal: subtotal,
      discountType: discountType,
      discountValue: discountValue,
      discountAmount: discountAmount,
      totalAmount: totalAmount,
      remainingAmount: remainingAmount,
      paymentStatus: _parseStatus(paymentStatus),
      createdAt: createdAt,
    );
  }

  static InvoiceStatus _parseStatus(String status) {
    switch (status) {
      case 'paid':
        return InvoiceStatus.paid;
      case 'partial':
      case 'partially_paid':
        return InvoiceStatus.partial;
      case 'canceled':
        return InvoiceStatus.canceled;
      case 'pending':
      case 'debt':
      default:
        return InvoiceStatus.debt;
    }
  }

  factory InvoiceModel.fromEntity(Invoice entity) {
    return InvoiceModel(
      id: entity.id,
      customerId: entity.customerId,
      customerName: entity.customerName,
      createdBy: entity.createdBy,
      createdByName: entity.createdByName,
      items: entity.items.map((e) => InvoiceItemModel.fromEntity(e)).toList(),
      payments: entity.payments.map((e) => PaymentModel.fromEntity(e)).toList(),
      subtotal: entity.subtotal,
      discountType: entity.discountType,
      discountValue: entity.discountValue,
      discountAmount: entity.discountAmount,
      totalAmount: entity.totalAmount,
      remainingAmount: entity.remainingAmount,
      paymentStatus: entity.paymentStatus.name,
      createdAt: entity.createdAt,
    );
  }
}
