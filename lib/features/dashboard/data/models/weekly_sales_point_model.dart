import 'package:makhzanflow/features/dashboard/domain/entities/weekly_sales_point.dart';

/// Arabic short day names indexed by [DateTime.weekday] (1=Mon … 7=Sun).
const _kArabicDayLabels = <int, String>{
  1: 'اثن',
  2: 'ثلا',
  3: 'أرب',
  4: 'خمس',
  5: 'جمع',
  6: 'سبت',
  7: 'أحد',
};

class WeeklySalesPointModel extends WeeklySalesPoint {
  const WeeklySalesPointModel({
    required super.label,
    required super.amount,
    required super.date,
  });

  /// Supports both REST `{date,label,amount}` and legacy `{day,total}` shapes.
  factory WeeklySalesPointModel.fromJson(Map<String, dynamic> json) {
    // REST shape: { date, label, amount }
    if (json.containsKey('date')) {
      final dateStr = json['date'] as String? ?? '';
      final date = DateTime.tryParse(dateStr) ?? DateTime.now();
      final amount = (json['amount'] as num?)?.toDouble() ?? 0.0;
      final label = json['label'] as String? ?? _kArabicDayLabels[date.weekday] ?? '؟';
      return WeeklySalesPointModel(label: label, amount: amount, date: date);
    }
    // Legacy shape: { day, total }
    final date = DateTime.parse(json['day'] as String);
    final amount = (json['total'] as num?)?.toDouble() ?? 0.0;
    final label = _kArabicDayLabels[date.weekday] ?? '؟';
    return WeeklySalesPointModel(label: label, amount: amount, date: date);
  }
}
