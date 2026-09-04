/// Request body for `POST /products`:
/// `{ name, sku?, barcode?, price, stock, min_stock, expiry_date?, is_active? }`
class CreateProductRequestDto {
  final String name;
  final String? sku;
  final String? barcode;
  final double price;
  final int stock;
  final int minStock;
  final DateTime? expiryDate;
  final bool? isActive;

  const CreateProductRequestDto({
    required this.name,
    this.sku,
    this.barcode,
    required this.price,
    required this.stock,
    required this.minStock,
    this.expiryDate,
    this.isActive,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        if (sku != null) 'sku': sku,
        if (barcode != null) 'barcode': barcode,
        'price': price,
        'stock': stock,
        'min_stock': minStock,
        if (expiryDate != null) 'expiry_date': _dateKey(expiryDate!),
        if (isActive != null) 'is_active': isActive,
      };

  static String _dateKey(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';
}
