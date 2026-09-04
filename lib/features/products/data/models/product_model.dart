import '../../domain/entities/product.dart';

class ProductModel {
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

  const ProductModel({
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

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as String,
      name: json['name'] as String,
      imageUrl: json['image_url'] as String?,
      quantity: (json['stock'] ?? json['quantity']) as int,
      price: (json['price'] as num).toDouble(),
      sku: (json['sku'] as String?) ?? '',
      barcode: json['barcode'] as String?,
      minStock: (json['min_stock'] as num?)?.toInt() ?? 0,
      createdBy: (json['created_by'] as String?) ?? '',
      expirationDate: _parseDate(json, 'expiry_date', 'expiration_date'),
      createdAt: _parseDate(json, 'created_at'),
      updatedAt: _parseDate(json, 'updated_at'),
    );
  }

  static DateTime? _parseDate(
    Map<String, dynamic> json,
    String key, [
    String? fallbackKey,
  ]) {
    final value = json[key] ?? (fallbackKey != null ? json[fallbackKey] : null);
    return value != null ? DateTime.tryParse(value as String) : null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image_url': imageUrl,
      'quantity': quantity,
      'price': price,
      'sku': sku,
      'barcode': barcode,
      'min_stock': minStock,
      'created_by': createdBy,
      'expiration_date': expirationDate?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'name': name,
      if (imageUrl != null) 'image_url': imageUrl,
      'quantity': quantity,
      'price': price,
      'sku': sku,
      if (barcode != null) 'barcode': barcode,
      'min_stock': minStock,
      'created_by': createdBy,
      if (expirationDate != null)
        'expiration_date': expirationDate!.toIso8601String(),
    };
  }

  Map<String, dynamic> toUpdateJson() {
    final data = <String, dynamic>{
      'name': name,
      'price': price,
      'quantity': quantity,
      'sku': sku,
      'min_stock': minStock,
    };
    if (imageUrl != null) data['image_url'] = imageUrl;
    if (barcode != null) data['barcode'] = barcode;
    if (expirationDate != null) {
      data['expiration_date'] = expirationDate!.toIso8601String();
    } else {
      data['expiration_date'] = null;
    }
    return data;
  }

  Product toEntity() {
    return Product(
      id: id,
      name: name,
      imageUrl: imageUrl,
      quantity: quantity,
      price: price,
      sku: sku,
      barcode: barcode,
      minStock: minStock,
      createdBy: createdBy,
      expirationDate: expirationDate,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory ProductModel.fromEntity(Product entity) {
    return ProductModel(
      id: entity.id,
      name: entity.name,
      imageUrl: entity.imageUrl,
      quantity: entity.quantity,
      price: entity.price,
      sku: entity.sku,
      barcode: entity.barcode,
      minStock: entity.minStock,
      createdBy: entity.createdBy,
      expirationDate: entity.expirationDate,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
