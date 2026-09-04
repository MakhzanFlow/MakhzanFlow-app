import 'package:makhzanflow/features/dashboard/domain/entities/dashboard_stats.dart';
import 'package:makhzanflow/features/dashboard/domain/entities/weekly_sales_point.dart';
import 'package:makhzanflow/features/dashboard/domain/entities/activity_entry.dart';
import 'dashboard_stats_response_dto.dart';
import 'weekly_sales_point_model.dart';
import 'activity_entry_model.dart';

/// JSON-deserializable version of [DashboardStats].
class DashboardStatsModel extends DashboardStats {
  const DashboardStatsModel({
    required super.productsCount,
    required super.customersCount,
    required super.totalDebt,
    required super.todaySales,
    required super.monthlyPayments,
    required super.weeklySales,
    required super.recentActivities,
    required super.fetchedAt,
  });

  /// REST path: delegates to [DashboardStatsResponseDto] then maps DTOs → Models.
  factory DashboardStatsModel.fromJson(Map<String, dynamic> json) {
    final dto = DashboardStatsResponseDto.fromJson(json);
    final weeklySales = dto.weeklySales
        .where((w) => DateTime.tryParse(w.date) != null)
        .map(
          (w) {
            final date = DateTime.parse(w.date);
            final label = w.label.isNotEmpty ? w.label : _arabicLabelFor(date);
            return WeeklySalesPointModel(
              label: label,
              amount: w.amount,
              date: date,
            );
          },
        )
        .toList();
    final recentActivities = dto.recentActivities
        .where((a) => a.id.isNotEmpty && a.action.isNotEmpty)
        .map(
          (a) => ActivityEntryModel(
            id: a.id,
            userId: a.userId,
            userName: a.userName,
            action: a.action,
            entityType: a.entity,
            entityId: a.entityId,
            details: a.changes,
            createdAt: a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0),
          ),
        )
        .toList();

    return DashboardStatsModel(
      productsCount: dto.productsCount,
      customersCount: dto.customersCount,
      totalDebt: dto.totalDebt,
      todaySales: dto.todaySales,
      monthlyPayments: dto.monthlyPayments,
      weeklySales: weeklySales,
      recentActivities: recentActivities,
      fetchedAt: dto.fetchedAt ?? DateTime.now(),
    );
  }

  static String _arabicLabelFor(DateTime date) {
    const labels = <int, String>{
      1: 'اثن',
      2: 'ثلا',
      3: 'أرب',
      4: 'خمس',
      5: 'جمع',
      6: 'سبت',
      7: 'أحد',
    };
    return labels[date.weekday] ?? '؟';
  }

  factory DashboardStatsModel.fromRawData({
    required int productsCount,
    required int customersCount,
    required double totalDebt,
    required double todaySales,
    required double monthlyPayments,
    required List<Map<String, dynamic>> weeklySalesRaw,
    required List<Map<String, dynamic>> recentActivitiesRaw,
  }) {
    final List<WeeklySalesPoint> weeklySales = weeklySalesRaw
        .map(WeeklySalesPointModel.fromJson)
        .toList();
    final List<ActivityEntry> recentActivities = recentActivitiesRaw
        .map(ActivityEntryModel.fromJson)
        .toList();

    return DashboardStatsModel(
      productsCount: productsCount,
      customersCount: customersCount,
      totalDebt: totalDebt,
      todaySales: todaySales,
      monthlyPayments: monthlyPayments,
      weeklySales: weeklySales,
      recentActivities: recentActivities,
      fetchedAt: DateTime.now(),
    );
  }
}
