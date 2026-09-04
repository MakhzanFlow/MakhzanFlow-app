import 'package:equatable/equatable.dart';

class ProductInput extends Equatable {
  final String name;
  final String? sku;
  final String? barcode;
  final double price;
  final int quantity;
  final int minStock;
  final String? imageUrl;
  final DateTime? expirationDate;

  const ProductInput({
    required this.name,
    this.sku,
    this.barcode,
    required this.price,
    required this.quantity,
    required this.minStock,
    this.imageUrl,
    this.expirationDate,
  });

  String? validate() {
    if (name.trim().isEmpty) return 'يرجى إدخال اسم المنتج';
    if (price < 0) return 'السعر غير صالح';
    if (quantity < 0) return 'الكمية غير صالحة';
    if (minStock < 0) return 'الحد الأدنى للمخزون غير صالح';
    return null;
  }

  @override
  List<Object?> get props => [
    name,
    sku,
    barcode,
    price,
    quantity,
    minStock,
    imageUrl,
    expirationDate,
  ];
}
