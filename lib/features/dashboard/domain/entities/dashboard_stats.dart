import 'package:equatable/equatable.dart';
import 'weekly_sales_point.dart';
import 'activity_entry.dart';

/// Core dashboard KPI entity — all values are computed from REST `GET /dashboard/stats`.
class DashboardStats extends Equatable {
  const DashboardStats({
    required this.productsCount,
    required this.customersCount,
    required this.totalDebt,
    required this.todaySales,
    required this.monthlyPayments,
    required this.weeklySales,
    required this.recentActivities,
    required this.fetchedAt,
  });

  final int productsCount;
  final int customersCount;

  /// Sum of [invoices.remaining_amount] (unpaid balance) for the active company.
  final double totalDebt;

  /// Sum of [payments.amount] collected today (payment_type = 'payment').
  final double todaySales;

  /// Sum of [payments.amount] where payment_type = 'payment' this month.
  final double monthlyPayments;

  /// Aggregated daily totals for the last 7 days (oldest → newest).
  final List<WeeklySalesPoint> weeklySales;

  /// Last 5 invoices (mapped to activity entries for the dashboard feed).
  final List<ActivityEntry> recentActivities;

  final DateTime fetchedAt;

  @override
  List<Object?> get props => [
    productsCount,
    customersCount,
    totalDebt,
    todaySales,
    monthlyPayments,
    weeklySales,
    recentActivities,
    fetchedAt,
  ];
}
