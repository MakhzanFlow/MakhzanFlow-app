/// DTO for `WeeklySalesPoint` from `GET /dashboard/stats`.
/// Backend shape: `{ date: string, label: string, amount: number }`
/// Also supports legacy shape: `{ day: string, total: number }`.
class WeeklySalesPointDto {
  final String date;
  final String label;
  final double amount;

  const WeeklySalesPointDto({
    required this.date,
    required this.label,
    required this.amount,
  });

  factory WeeklySalesPointDto.fromJson(Map<String, dynamic> json) {
    // Backend REST shape
    if (json.containsKey('date')) {
      final dateStr = json['date'] as String? ?? '';
      final label = json['label'] as String? ?? '';
      final amount = (json['amount'] as num?)?.toDouble() ?? 0.0;
      return WeeklySalesPointDto(date: dateStr, label: label, amount: amount);
    }
    // Legacy shape: { day: ISO date, total: number }
    final dateStr = json['day'] as String? ?? '';
    final total = (json['total'] as num?)?.toDouble() ?? 0.0;
    // Derive label from date if not supplied — will be enriched by model layer
    final label = _deriveLabel(dateStr);
    return WeeklySalesPointDto(date: dateStr, label: label, amount: total);
  }

  static String _deriveLabel(String isoDate) {
    if (isoDate.isEmpty) return '';
    final date = DateTime.tryParse(isoDate);
    if (date == null) return '';
    const arabicLabels = <int, String>{
      1: 'اثن',
      2: 'ثلا',
      3: 'أرب',
      4: 'خمس',
      5: 'جمع',
      6: 'سبت',
      7: 'أحد',
    };
    return arabicLabels[date.weekday] ?? '';
  }

  Map<String, dynamic> toJson() => {
        'date': date,
        'label': label,
        'amount': amount,
      };
}
