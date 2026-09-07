import 'package:flutter_test/flutter_test.dart';
import 'package:makhzanflow/features/customers/data/models/customer_filter_counts_model.dart';
import 'package:makhzanflow/features/customers/domain/entities/customer_filter_counts.dart';

void main() {
  group('CustomerFilterCountsModel', () {
    test('fromJson parses counts and total debt sum correctly', () {
      final json = {
        'total_count': 10,
        'paid_count': 4,
        'partial_count': 2,
        'deferred_count': 4,
        'total_debt_sum': 12500.50,
      };

      final model = CustomerFilterCountsModel.fromJson(json);

      expect(model.totalCount, 10);
      expect(model.paidCount, 4);
      expect(model.partialCount, 2);
      expect(model.deferredCount, 4);
      expect(model.totalDebtSum, 12500.50);
    });

    test('fromJson parses backend total_debt response field', () {
      final model = CustomerFilterCountsModel.fromJson({
        'total': 10,
        'zero_debt': 4,
        'with_debt': 6,
        'credit_balance': 2,
        'total_debt': 12500.50,
      });

      expect(model.totalDebtSum, 12500.50);
    });

    test('fromJson parses total_debt when backend returns a string', () {
      final model = CustomerFilterCountsModel.fromJson({
        'total_debt': '12500.50',
      });

      expect(model.totalDebtSum, 12500.50);
    });

    test('toJson serializes fields correctly', () {
      const model = CustomerFilterCountsModel(
        totalCount: 5,
        paidCount: 2,
        partialCount: 1,
        deferredCount: 2,
        totalDebtSum: 450.0,
      );

      final json = model.toJson();

      expect(json['total_count'], 5);
      expect(json['paid_count'], 2);
      expect(json['partial_count'], 1);
      expect(json['deferred_count'], 2);
      expect(json['total_debt_sum'], 450.0);
    });

    test('toEntity maps all fields correctly', () {
      const model = CustomerFilterCountsModel(
        totalCount: 5,
        paidCount: 2,
        partialCount: 1,
        deferredCount: 2,
        totalDebtSum: 450.0,
      );

      final entity = model.toEntity();

      expect(entity, isA<CustomerFilterCounts>());
      expect(entity.totalCount, model.totalCount);
      expect(entity.paidCount, model.paidCount);
      expect(entity.partialCount, model.partialCount);
      expect(entity.deferredCount, model.deferredCount);
      expect(entity.totalDebtSum, model.totalDebtSum);
    });
  });
}
