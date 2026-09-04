import 'activity_entry_dto.dart';
import 'weekly_sales_point_dto.dart';

/// Response DTO for `GET /dashboard/stats`.
/// Backend returns `{ productsCount, customersCount, totalDebt, todaySales,
///                    monthlyPayments, weeklySales: [], recentActivities: [], fetchedAt }`
/// Supports both camelCase (backend) and snake_case (fallback).
class DashboardStatsResponseDto {
  final int productsCount;
  final int customersCount;
  final double totalDebt;
  final double todaySales;
  final double monthlyPayments;
  final List<WeeklySalesPointDto> weeklySales;
  final List<ActivityEntryDto> recentActivities;
  final DateTime? fetchedAt;

  const DashboardStatsResponseDto({
    required this.productsCount,
    required this.customersCount,
    required this.totalDebt,
    required this.todaySales,
    required this.monthlyPayments,
    required this.weeklySales,
    required this.recentActivities,
    this.fetchedAt,
  });

  factory DashboardStatsResponseDto.fromJson(Map<String, dynamic> json) {
    final productsCount = (json['productsCount'] as num?)?.toInt() ??
        (json['products_count'] as num?)?.toInt() ??
        0;
    final customersCount = (json['customersCount'] as num?)?.toInt() ??
        (json['customers_count'] as num?)?.toInt() ??
        0;
    final totalDebt = (json['totalDebt'] as num?)?.toDouble() ??
        (json['total_debt'] as num?)?.toDouble() ??
        0.0;
    final todaySales = (json['todaySales'] as num?)?.toDouble() ??
        (json['today_sales'] as num?)?.toDouble() ??
        0.0;
    final monthlyPayments = (json['monthlyPayments'] as num?)?.toDouble() ??
        (json['monthly_payments'] as num?)?.toDouble() ??
        0.0;

    final weeklyRaw = (json['weeklySales'] as List?) ?? (json['weekly_sales'] as List?) ?? const [];
    final weeklySales = weeklyRaw
        .whereType<Map<String, dynamic>>()
        .map(WeeklySalesPointDto.fromJson)
        .toList();

    final activityRaw = (json['recentActivities'] as List?) ??
        (json['recent_activities'] as List?) ??
        (json['activities'] as List?) ??
        const [];
    final recentActivities = activityRaw
        .whereType<Map<String, dynamic>>()
        .map(ActivityEntryDto.fromJson)
        .toList();

    // Fallback: legacy key `recent_activities` already handled above;
    // also check `activities`
    DateTime? fetchedAt;
    final fetchedRaw = json['fetchedAt'] ?? json['fetched_at'];
    if (fetchedRaw is String) {
      fetchedAt = DateTime.tryParse(fetchedRaw);
    }

    return DashboardStatsResponseDto(
      productsCount: productsCount,
      customersCount: customersCount,
      totalDebt: totalDebt,
      todaySales: todaySales,
      monthlyPayments: monthlyPayments,
      weeklySales: weeklySales,
      recentActivities: recentActivities,
      fetchedAt: fetchedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'productsCount': productsCount,
        'customersCount': customersCount,
        'totalDebt': totalDebt,
        'todaySales': todaySales,
        'monthlyPayments': monthlyPayments,
        'weeklySales': weeklySales.map((e) => e.toJson()).toList(),
        'recentActivities': recentActivities.map((e) => e.toJson()).toList(),
        if (fetchedAt != null) 'fetchedAt': fetchedAt!.toIso8601String(),
      };
}
