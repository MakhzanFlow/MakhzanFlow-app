import 'package:equatable/equatable.dart';
import 'package:makhzanflow/features/invoice/domain/entities/invoice_item.dart';
import 'package:makhzanflow/features/invoice/domain/entities/invoice_status.dart';
import 'package:makhzanflow/features/invoice/domain/entities/payment.dart';

class Invoice extends Equatable {
  final String id;
  final String customerId; // nullable for walk-in (no customer) invoices
  final String? customerName;
  final String? createdBy;
  final String? createdByName;
  final List<InvoiceItem> items;
  final List<Payment> payments;
  final double subtotal;
  final String? discountType;
  final double discountValue;
  final double discountAmount;
  final double totalAmount;
  final double remainingAmount;
  final InvoiceStatus paymentStatus;
  final DateTime? createdAt;

  const Invoice({
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
    required this.totalAmount,
    this.remainingAmount = 0,
    this.paymentStatus = InvoiceStatus.debt,
    this.createdAt,
  });

  Invoice copyWith({
    String? id,
    String? customerId,
    String? customerName,
    String? createdBy,
    String? createdByName,
    List<InvoiceItem>? items,
    List<Payment>? payments,
    double? subtotal,
    String? discountType,
    double? discountValue,
    double? discountAmount,
    double? totalAmount,
    double? remainingAmount,
    InvoiceStatus? paymentStatus,
    DateTime? createdAt,
  }) {
    return Invoice(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      createdBy: createdBy ?? this.createdBy,
      createdByName: createdByName ?? this.createdByName,
      items: items ?? this.items,
      payments: payments ?? this.payments,
      subtotal: subtotal ?? this.subtotal,
      discountType: discountType ?? this.discountType,
      discountValue: discountValue ?? this.discountValue,
      discountAmount: discountAmount ?? this.discountAmount,
      totalAmount: totalAmount ?? this.totalAmount,
      remainingAmount: remainingAmount ?? this.remainingAmount,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    customerId,
    customerName,
    createdBy,
    createdByName,
    items,
    payments,
    subtotal,
    discountType,
    discountValue,
    discountAmount,
    totalAmount,
    remainingAmount,
    paymentStatus,
    createdAt,
  ];
}
