import 'package:equatable/equatable.dart';
import 'package:makhzanflow/features/dashboard/domain/entities/dashboard_stats.dart';
import 'package:makhzanflow/features/dashboard/domain/entities/weekly_sales_point.dart';

/// Sealed state hierarchy for [DashboardCubit].
sealed class DashboardState extends Equatable {
  const DashboardState();
  @override
  List<Object?> get props => [];
}

/// Initial state before any load is triggered.
final class DashboardInitial extends DashboardState {
  const DashboardInitial();
}

/// Loading — full skeleton shimmer shown.
final class DashboardLoading extends DashboardState {
  const DashboardLoading();
}

/// Data successfully loaded.
final class DashboardLoaded extends DashboardState {
  const DashboardLoaded({
    required this.stats,
    this.salesPoints,
    this.salesRange = '7d',
    this.isSalesLoading = false,
    this.isRefreshing = false,
  });

  final DashboardStats stats;
  final List<WeeklySalesPoint>? salesPoints;
  final String salesRange;
  final bool isSalesLoading;

  /// True while a background refresh is in flight (data still visible).
  final bool isRefreshing;

  DashboardLoaded copyWith({
    DashboardStats? stats,
    List<WeeklySalesPoint>? salesPoints,
    String? salesRange,
    bool? isSalesLoading,
    bool? isRefreshing,
  }) => DashboardLoaded(
    stats: stats ?? this.stats,
    salesPoints: salesPoints ?? this.salesPoints,
    salesRange: salesRange ?? this.salesRange,
    isSalesLoading: isSalesLoading ?? this.isSalesLoading,
    isRefreshing: isRefreshing ?? this.isRefreshing,
  );

  @override
  List<Object?> get props => [
    stats,
    salesPoints,
    salesRange,
    isSalesLoading,
    isRefreshing,
  ];
}

/// Load failed — error widget with retry shown.
final class DashboardError extends DashboardState {
  const DashboardError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
