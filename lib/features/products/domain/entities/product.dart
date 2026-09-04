import 'package:equatable/equatable.dart';

class Product extends Equatable {
  final String id;
  final String name;
  final String? imageUrl;
  final int quantity;
  final double price;
  final String sku;
  final String? barcode;
  final int minStock;
  final String createdBy;
  final DateTime? expirationDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Product({
    required this.id,
    required this.name,
    this.imageUrl,
    required this.quantity,
    required this.price,
    required this.sku,
    this.barcode,
    required this.minStock,
    required this.createdBy,
    this.expirationDate,
    this.createdAt,
    this.updatedAt,
  });

  Product copyWith({
    String? id,
    String? name,
    String? imageUrl,
    int? quantity,
    double? price,
    String? sku,
    String? barcode,
    int? minStock,
    String? createdBy,
    DateTime? expirationDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      sku: sku ?? this.sku,
      barcode: barcode ?? this.barcode,
      minStock: minStock ?? this.minStock,
      createdBy: createdBy ?? this.createdBy,
      expirationDate: expirationDate ?? this.expirationDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    imageUrl,
    quantity,
    price,
    sku,
    barcode,
    minStock,
    createdBy,
    expirationDate,
    createdAt,
    updatedAt,
  ];
}
