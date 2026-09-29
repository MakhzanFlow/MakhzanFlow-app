import 'package:flutter_test/flutter_test.dart';
import 'package:makhzanflow/core/sync/pending_op.dart';
import 'package:makhzanflow/features/customers/data/models/create_customer_request_dto.dart';
import 'package:makhzanflow/features/customers/data/models/pending_entity_mapper.dart';
import 'package:makhzanflow/features/products/data/models/create_product_request_dto.dart';
import 'package:makhzanflow/features/products/data/models/pending_entity_mapper.dart';

void main() {
  test('product body rebuilds display entity', () {
    const dto = CreateProductRequestDto(
      name: 'Rice',
      sku: 'R1',
      price: 50,
      stock: 10,
      minStock: 2,
    );
    final op = PendingOp.createNew(
      opType: PendingOpType.productCreate,
      method: 'POST',
      path: '/products/',
      body: dto.toJson(),
      companyId: 'co-1',
    );
    final product = productFromQueueOp(op);

    expect(product.id, startsWith('pending_'));
    expect(product.id, op.id);
    expect(product.name, 'Rice');
    expect(product.price, 50);
    expect(product.quantity, 10);
    expect(product.sku, 'R1');
    expect(product.minStock, 2);
  });

  test('customer body rebuilds display entity', () {
    const dto = CreateCustomerRequestDto(
      name: 'Shop',
      phone: '010',
      address: 'Cairo',
      openingBalance: 100,
    );
    final op = PendingOp.createNew(
      opType: PendingOpType.customerCreate,
      method: 'POST',
      path: '/customers/',
      body: dto.toJson(),
      companyId: 'co-1',
    );
    final customer = customerFromQueueOp(op);

    expect(customer.id, startsWith('pending_'));
    expect(customer.id, op.id);
    expect(customer.name, 'Shop');
    expect(customer.phone, '010');
    expect(customer.address, 'Cairo');
    expect(customer.openingBalance, 100);
  });
}
