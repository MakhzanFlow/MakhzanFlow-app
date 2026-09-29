import 'package:flutter_test/flutter_test.dart';
import 'package:makhzanflow/features/customers/data/models/update_customer_request_dto.dart';
import 'package:makhzanflow/features/invoice/data/models/add_payment_dto.dart';
import 'package:makhzanflow/features/products/data/models/adjust_stock_request_dto.dart';
import 'package:makhzanflow/features/products/data/models/update_product_request_dto.dart';

void main() {
  group('versioned DTO serialization', () {
    test('product pricing DTO carries version only when set', () {
      expect(
        const UpdateProductRequestDto(price: 55.0, version: 5).toJson(),
        {'price': 55.0, 'version': 5},
      );
      expect(
        const UpdateProductRequestDto(name: 'Rice').toJson(),
        containsPair('name', 'Rice'),
      );
      expect(
        const UpdateProductRequestDto(name: 'Rice').toJson(),
        isNot(contains('version')),
      );
    });

    test('stock adjust DTO carries version only when set', () {
      expect(
        const AdjustStockRequestDto(quantityChange: -2, reason: 'sale')
            .toJson(),
        {'quantity_change': -2, 'reason': 'sale'},
      );
      expect(
        const AdjustStockRequestDto(
          quantityChange: -2,
          reason: 'sale',
          version: 4,
        ).toJson()['version'],
        4,
      );
    });

    test('payment DTO carries version only when set', () {
      const dto = AddPaymentDto(invoiceId: 'inv-1', amount: 50, version: 3);
      expect(dto.toJson()['version'], 3);
      expect(
        const AddPaymentDto(invoiceId: 'inv-1', amount: 50).toJson(),
        isNot(contains('version')),
      );
    });

    test('customer DTO never carries version (LWW)', () {
      const dto = UpdateCustomerRequestDto(name: 'Shop');
      expect(dto.toJson(), {'name': 'Shop'});
      expect(dto.toJson(), isNot(contains('version')));
    });
  });
}
