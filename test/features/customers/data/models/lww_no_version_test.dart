import 'package:flutter_test/flutter_test.dart';
import 'package:makhzanflow/core/sync/pending_op.dart';
import 'package:makhzanflow/features/customers/data/models/update_customer_request_dto.dart';
import 'package:makhzanflow/features/products/data/models/update_product_request_dto.dart';

/// T044: LWW flows never carry `version` — no conflict UI may arise from them.
void main() {
  test('customer update body has no version key', () {
    const dto = UpdateCustomerRequestDto(
      name: 'Shop',
      phone: '010',
      address: 'Cairo',
    );
    expect(dto.toJson().containsKey('version'), isFalse);
  });

  test('metadata-only product update omits version', () {
    const dto = UpdateProductRequestDto(name: 'Rice', sku: 'R1');
    final json = dto.toJson();
    expect(json.containsKey('version'), isFalse);
    expect(json['name'], 'Rice');
  });

  test('LWW op types are marked non-gated', () {
    expect(PendingOpType.customerUpdate.isGated, isFalse);
    expect(PendingOpType.productMetadata.isGated, isFalse);
    expect(PendingOpType.productPricing.isGated, isTrue);
    expect(PendingOpType.stockAdjust.isGated, isTrue);
    expect(PendingOpType.invoicePayment.isGated, isTrue);
    expect(PendingOpType.invoiceCancel.isGated, isTrue);
  });

  test('financial op types are online-only', () {
    expect(PendingOpType.invoicePayment.isQueueableOffline, isFalse);
    expect(PendingOpType.invoiceCancel.isQueueableOffline, isFalse);
    expect(PendingOpType.invoiceCreate.isQueueableOffline, isFalse);
    expect(PendingOpType.productPricing.isQueueableOffline, isFalse);
    expect(PendingOpType.productMetadata.isQueueableOffline, isFalse);
    expect(PendingOpType.customerUpdate.isQueueableOffline, isFalse);
    expect(PendingOpType.stockAdjust.isQueueableOffline, isTrue);
    expect(PendingOpType.productDelete.isQueueableOffline, isTrue);
    expect(PendingOpType.productCreate.isQueueableOffline, isTrue);
    expect(PendingOpType.customerCreate.isQueueableOffline, isTrue);
  });
}
