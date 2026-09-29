import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:makhzanflow/core/sync/enqueue_guard.dart';
import 'package:makhzanflow/core/sync/pending_op.dart';
import 'package:makhzanflow/core/sync/pending_ops_queue.dart';
import '../../../data/models/pending_entity_mapper.dart';
import '../../../domain/entities/customer.dart';
import '../../../domain/usecases/get_customer_filter_counts_usecase.dart';
import '../../../domain/usecases/get_customers_usecase.dart';
import 'customers_state.dart';

export 'customers_state.dart';

const int _pageSize = 20;

class CustomersCubit extends Cubit<CustomersState> {
  final GetCustomersUseCase _getCustomersUseCase;
  final GetCustomerFilterCountsUseCase _getCustomerFilterCountsUseCase;
  final PendingOpsQueue? _pendingOpsQueue;
  Timer? _debounce;
  int _currentPage = 0;

  CustomersCubit({
    required GetCustomersUseCase getCustomersUseCase,
    required GetCustomerFilterCountsUseCase getCustomerFilterCountsUseCase,
    PendingOpsQueue? pendingOpsQueue,
  })  : _getCustomersUseCase = getCustomersUseCase,
        _getCustomerFilterCountsUseCase = getCustomerFilterCountsUseCase,
        _pendingOpsQueue = pendingOpsQueue,
        super(const CustomersState());

  Future<void> loadCustomers(String companyId) async {
    _currentPage = 0;
    emit(state.copyWith(status: CustomersStatus.loading, isLoadingMore: false));

    final customerResult = await _getCustomersUseCase(
      query: state.query.isNotEmpty ? state.query : null,
      limit: _pageSize,
      offset: 0,
      companyId: companyId,
    );
    final countsResult = await _getCustomerFilterCountsUseCase(
      query: state.query.isNotEmpty ? state.query : null,
      companyId: companyId,
    );
    final pending = await _pendingCreates();

    customerResult.fold(
      (failure) {
        // Offline with queued creates: show the optimistic rows instead of
        // an error (the offline banner marks them stale).
        if (shouldEnqueueFailure(failure) && pending.isNotEmpty) {
          emit(state.copyWith(
            status: CustomersStatus.success,
            customers: pending,
            totalCount: pending.length,
            hasMore: false,
            pendingIds: pending.map((c) => c.id).toSet(),
          ));
          return;
        }
        emit(state.copyWith(status: CustomersStatus.error, failure: failure));
      },
      (customersList) {
        countsResult.fold(
          (failure) {
            emit(
              state.copyWith(status: CustomersStatus.error, failure: failure),
            );
          },
          (filterCounts) {
            emit(
              state.copyWith(
                status: customersList.isEmpty && pending.isEmpty
                    ? CustomersStatus.empty
                    : CustomersStatus.success,
                customers: [...pending, ...customersList],
                totalCount: filterCounts.totalCount,
                filterCounts: filterCounts,
                totalDebtSum: filterCounts.totalDebtSum,
                pendingIds: pending.map((c) => c.id).toSet(),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> loadMore(String companyId) async {
    if (state.isLoadingMore || !state.hasMore) return;
    emit(state.copyWith(isLoadingMore: true));

    final nextPage = _currentPage + 1;
    final nextOffset = nextPage * _pageSize;

    final result = await _getCustomersUseCase(
      query: state.query.isNotEmpty ? state.query : null,
      limit: _pageSize,
      offset: nextOffset,
      companyId: companyId,
    );

    result.fold(
      (_) {
        emit(state.copyWith(isLoadingMore: false));
      },
      (newCustomers) {
        _currentPage = nextPage;
        final allCustomers = [...state.customers, ...newCustomers];
        emit(
          state.copyWith(
            status: CustomersStatus.success,
            customers: allCustomers,
            hasMore: newCustomers.length == _pageSize,
            isLoadingMore: false,
          ),
        );
      },
    );
  }

  void updateSearchQuery(String query, String companyId) {
    emit(state.copyWith(query: query));
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      loadCustomers(companyId);
    });
  }

  Future<void> refresh(String companyId) async {
    await loadCustomers(companyId);
  }

  /// Optimistic entities for queued `customerCreate` ops (newest first).
  Future<List<Customer>> _pendingCreates() async {
    final queue = _pendingOpsQueue;
    if (queue == null) return const [];
    final ops = await queue.pending();
    return ops
        .where((op) => op.opType == PendingOpType.customerCreate)
        .map(customerFromQueueOp)
        .toList()
        .reversed
        .toList();
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}
