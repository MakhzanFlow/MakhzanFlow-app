/// DTO for `GET /dashboard/low-stock` paginated response item.
/// Backend shape: `{ id, name, sku, barcode, price, stock, min_stock, image_url }`
class LowStockProductDto {
  final String id;
  final String name;
  final String? sku;
  final String? barcode;
  final double price;
  final int stock;
  final int minStock;
  final String? imageUrl;

  const LowStockProductDto({
    required this.id,
    required this.name,
    this.sku,
    this.barcode,
    required this.price,
    required this.stock,
    required this.minStock,
    this.imageUrl,
  });

  factory LowStockProductDto.fromJson(Map<String, dynamic> json) {
    // price may be string "12.50" from some backends; handle both
    final priceRaw = json['price'];
    final price = priceRaw is num
        ? priceRaw.toDouble()
        : double.tryParse(priceRaw?.toString() ?? '') ?? 0.0;
    final stockRaw = json['stock'];
    final stock = stockRaw is num ? stockRaw.toInt() : int.tryParse(stockRaw?.toString() ?? '') ?? 0;
    final minStockRaw = json['min_stock'] ?? json['minStock'] ?? json['min-stock'];
    final minStock = minStockRaw is num
        ? minStockRaw.toInt()
        : int.tryParse(minStockRaw?.toString() ?? '') ?? 0;
    return LowStockProductDto(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      sku: json['sku']?.toString(),
      barcode: json['barcode']?.toString(),
      price: price,
      stock: stock,
      minStock: minStock,
      imageUrl: json['image_url']?.toString() ?? json['imageUrl']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        if (sku != null) 'sku': sku,
        if (barcode != null) 'barcode': barcode,
        'price': price,
        'stock': stock,
        'min_stock': minStock,
        if (imageUrl != null) 'image_url': imageUrl,
      };
}
