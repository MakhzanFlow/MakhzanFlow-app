import 'package:makhzanflow/features/invoice/domain/entities/invoice_item.dart';

class InvoiceItemModel {
  final String? id;
  final String? invoiceId;
  final String productId;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final String productName;
  final String? productImageUrl;

  const InvoiceItemModel({
    this.id,
    this.invoiceId,
    required this.productId,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    required this.productName,
    this.productImageUrl,
  });

  factory InvoiceItemModel.fromJson(Map<String, dynamic> json) {
    // Backend REST shape: { id, invoice_id, product_id, quantity, unit_price, total_price, products: { name, image_url, price } }
    final products = json['products'] as Map<String, dynamic>?;
    return InvoiceItemModel(
      id: json['id'] as String?,
      invoiceId: json['invoice_id'] as String?,
      productId: json['product_id'] as String,
      quantity: (json['quantity'] as num).toInt(),
      unitPrice: (json['unit_price'] as num).toDouble(),
      totalPrice: (json['total_price'] as num).toDouble(),
      productName: (json['product_name'] as String?) ??
          (products?['name'] as String? ?? ''),
      productImageUrl: (json['product_image_url'] as String?) ??
          (products?['image_url'] as String?),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (invoiceId != null) 'invoice_id': invoiceId,
      'product_id': productId,
      'quantity': quantity,
      'unit_price': unitPrice,
      'total_price': totalPrice,
      'product_name': productName,
      if (productImageUrl != null) 'product_image_url': productImageUrl,
    };
  }

  InvoiceItem toEntity() {
    return InvoiceItem(
      productId: productId,
      quantity: quantity,
      unitPrice: unitPrice,
      productName: productName,
      productImageUrl: productImageUrl,
    );
  }

  factory InvoiceItemModel.fromEntity(InvoiceItem entity) {
    return InvoiceItemModel(
      productId: entity.productId,
      quantity: entity.quantity,
      unitPrice: entity.unitPrice,
      totalPrice: entity.total,
      productName: entity.productName,
      productImageUrl: entity.productImageUrl,
    );
  }
}
