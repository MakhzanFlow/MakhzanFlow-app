import 'package:makhzanflow/core/sync/pending_op.dart';
import '../../domain/entities/product.dart';

/// Rebuilds an optimistic [Product] from a queued `productCreate` body
/// (built by [CreateProductRequestDto.toJson]). The entity id is the op id
/// (carries the pending prefix) until replay replaces it with the server id.
Product productFromQueueOp(PendingOp op) {
  assert(op.opType == PendingOpType.productCreate);
  final body = op.body;
  DateTime? expiry;
  final rawExpiry = body['expiry_date'];
  if (rawExpiry is String && rawExpiry.isNotEmpty) {
    expiry = DateTime.tryParse(rawExpiry);
  }
  return Product(
    id: op.id,
    name: (body['name'] as String?) ?? '',
    quantity: (body['stock'] as num?)?.toInt() ?? 0,
    price: (body['price'] as num?)?.toDouble() ?? 0,
    sku: (body['sku'] as String?) ?? '',
    barcode: body['barcode'] as String?,
    minStock: (body['min_stock'] as num?)?.toInt() ?? 0,
    createdBy: '',
    expirationDate: expiry,
  );
}
