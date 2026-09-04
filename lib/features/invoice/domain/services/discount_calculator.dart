import 'package:makhzanflow/features/invoice/domain/constants/invoice_constants.dart';

/// Single Responsibility: calculates discount amount from legacy values.
abstract class DiscountCalculator {
  double calculate({
    double? explicitAmount,
    required String discountType,
    required double discountValue,
    required List<Map<String, dynamic>> items,
  });
}

class DiscountCalculatorImpl implements DiscountCalculator {
  @override
  double calculate({
    double? explicitAmount,
    required String discountType,
    required double discountValue,
    required List<Map<String, dynamic>> items,
  }) {
    if (explicitAmount != null) return explicitAmount;
    if (discountValue <= 0) return 0;
    if (discountType == InvoiceConstants.discountPercentage) {
      final subtotal = _subtotal(items);
      return subtotal * (discountValue / 100);
    }
    return discountValue;
  }

  double _subtotal(List<Map<String, dynamic>> items) {
    double sum = 0;
    for (final m in items) {
      final total = (m['total_price'] as num?)?.toDouble();
      if (total != null) {
        sum += total;
      } else {
        final qty = (m['quantity'] as num?)?.toInt() ?? 1;
        final price = (m['unit_price'] as num?)?.toDouble() ?? 0;
        sum += qty * price;
      }
    }
    return sum;
  }
}
