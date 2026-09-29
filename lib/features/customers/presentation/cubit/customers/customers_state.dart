import 'package:equatable/equatable.dart';
import 'package:makhzanflow/core/error/failures.dart';
import '../../../domain/entities/customer.dart';
import '../../../domain/entities/customer_filter_counts.dart';

enum CustomersStatus { initial, loading, success, empty, error }

class CustomersState extends Equatable {
  final CustomersStatus status;
  final List<Customer> customers;
  final String query;
  final Failure? failure;
  final int totalCount;
  final bool hasMore;
  final bool isLoadingMore;
  final CustomerFilterCounts filterCounts;
  final double totalDebtSum;
  /// Ids of optimistic (unsynced) creates prepended from the offline queue.
  final Set<String> pendingIds;

  const CustomersState({
    this.status = CustomersStatus.initial,
    this.customers = const [],
    this.query = '',
    this.failure,
    this.totalCount = 0,
    this.hasMore = true,
    this.isLoadingMore = false,
    this.filterCounts = const CustomerFilterCounts.zero(),
    this.totalDebtSum = 0,
    this.pendingIds = const {},
  });

  CustomersState copyWith({
    CustomersStatus? status,
    List<Customer>? customers,
    String? query,
    Failure? failure,
    int? totalCount,
    bool? hasMore,
    bool? isLoadingMore,
    CustomerFilterCounts? filterCounts,
    double? totalDebtSum,
    Set<String>? pendingIds,
  }) {
    return CustomersState(
      status: status ?? this.status,
      customers: customers ?? this.customers,
      query: query ?? this.query,
      failure: failure ?? this.failure,
      totalCount: totalCount ?? this.totalCount,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      filterCounts: filterCounts ?? this.filterCounts,
      totalDebtSum: totalDebtSum ?? this.totalDebtSum,
      pendingIds: pendingIds ?? this.pendingIds,
    );
  }

  @override
  List<Object?> get props => [
    status,
    customers,
    query,
    failure,
    totalCount,
    hasMore,
    isLoadingMore,
    filterCounts,
    totalDebtSum,
    pendingIds,
  ];
}
