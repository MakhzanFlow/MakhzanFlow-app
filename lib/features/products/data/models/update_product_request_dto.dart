/// Request body for `PUT /products/:id` — all fields optional.
class UpdateProductRequestDto {
  final String? name;
  final String? sku;
  final String? barcode;
  final double? price;
  final int? stock;
  final int? minStock;
  final DateTime? expiryDate;
  final bool? isActive;

  const UpdateProductRequestDto({
    this.name,
    this.sku,
    this.barcode,
    this.price,
    this.stock,
    this.minStock,
    this.expiryDate,
    this.isActive,
  });

  Map<String, dynamic> toJson() => {
        if (name != null) 'name': name,
        if (sku != null) 'sku': sku,
        if (barcode != null) 'barcode': barcode,
        if (price != null) 'price': price,
        if (stock != null) 'stock': stock,
        if (minStock != null) 'min_stock': minStock,
        if (expiryDate != null) 'expiry_date': _dateKey(expiryDate!),
        if (isActive != null) 'is_active': isActive,
      };

  static String _dateKey(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';
}
