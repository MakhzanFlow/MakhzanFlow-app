import 'package:flutter_test/flutter_test.dart';
import 'package:makhzanflow/features/invoice/data/models/invoice_model.dart';

Map<String, dynamic> _json({int? version}) => {
      'id': 'inv-1',
      'customer_id': 'cust-1',
      'total_amount': 100.0,
      if (version != null) 'version': version,
    };

void main() {
  group('InvoiceModel version cursor', () {
    test('parses version from JSON', () {
      final model = InvoiceModel.fromJson(_json(version: 3));
      expect(model.version, 3);
      expect(model.toEntity().version, 3);
    });

    test('defaults to 1 when version absent', () {
      expect(InvoiceModel.fromJson(_json()).version, 1);
    });

    test('round-trips through entity', () {
      final model = InvoiceModel.fromJson(_json(version: 4));
      final revived = InvoiceModel.fromEntity(model.toEntity());
      expect(revived.version, 4);
      expect(model.toEntity().copyWith(totalAmount: 120).version, 4);
    });
  });
}
