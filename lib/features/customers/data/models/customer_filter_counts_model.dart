import '../../domain/entities/customer_filter_counts.dart';

class CustomerFilterCountsModel extends CustomerFilterCounts {
  const CustomerFilterCountsModel({
    required super.totalCount,
    required super.paidCount,
    required super.partialCount,
    required super.deferredCount,
    required super.totalDebtSum,
  });

  factory CustomerFilterCountsModel.fromJson(Map<String, dynamic> json) {
    return CustomerFilterCountsModel(
      totalCount: json['total'] as int? ??
          (json['total_count'] as num?)?.toInt() ??
          0,
      paidCount: json['zero_debt'] as int? ??
          (json['paid_count'] as num?)?.toInt() ??
          0,
      partialCount: json['with_debt'] as int? ??
          (json['partial_count'] as num?)?.toInt() ??
          0,
      deferredCount: json['credit_balance'] as int? ??
          (json['deferred_count'] as num?)?.toInt() ??
          0,
      totalDebtSum: (json['total_debt'] as num?)?.toDouble() ??
          (json['total_debt_sum'] as num?)?.toDouble() ??
          0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_count': totalCount,
      'paid_count': paidCount,
      'partial_count': partialCount,
      'deferred_count': deferredCount,
      'total_debt_sum': totalDebtSum,
    };
  }

  CustomerFilterCounts toEntity() {
    return CustomerFilterCounts(
      totalCount: totalCount,
      paidCount: paidCount,
      partialCount: partialCount,
      deferredCount: deferredCount,
      totalDebtSum: totalDebtSum,
    );
  }
}
