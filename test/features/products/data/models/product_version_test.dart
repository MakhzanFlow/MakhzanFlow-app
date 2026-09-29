import 'package:flutter_test/flutter_test.dart';
import 'package:makhzanflow/features/products/data/models/product_model.dart';

void main() {
  group('ProductModel version cursor', () {
    test('parses version from JSON', () {
      final model = ProductModel.fromJson({
        'id': 'p1',
        'name': 'Rice',
        'stock': 10,
        'price': 50.0,
        'version': 5,
      });
      expect(model.version, 5);
      expect(model.toEntity().version, 5);
    });

    test('defaults to 1 when version absent', () {
      final model = ProductModel.fromJson({
        'id': 'p1',
        'name': 'Rice',
        'stock': 10,
        'price': 50.0,
      });
      expect(model.version, 1);
    });

    test('round-trips through entity', () {
      final model = ProductModel.fromJson({
        'id': 'p1',
        'name': 'Rice',
        'stock': 10,
        'price': 50.0,
        'version': 7,
      });
      final revived = ProductModel.fromEntity(model.toEntity());
      expect(revived.version, 7);
      expect(model.toEntity().copyWith(price: 60).version, 7);
    });
  });
}
