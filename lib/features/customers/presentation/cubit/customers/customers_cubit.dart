import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/get_customers_usecase.dart';
import 'customers_state.dart';

export 'customers_state.dart';

const int _pageSize = 20;

class CustomersCubit extends Cubit<CustomersState> {
  final GetCustomersUseCase _getCustomersUseCase;
  Timer? _debounce;
  int _currentPage = 0;

  CustomersCubit({required GetCustomersUseCase getCustomersUseCase})
    : _getCustomersUseCase = getCustomersUseCase,
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

    customerResult.fold(
      (failure) {
        emit(state.copyWith(status: CustomersStatus.error, failure: failure));
      },
      (customersList) {
        emit(
          state.copyWith(
            status: customersList.isEmpty
                ? CustomersStatus.empty
                : CustomersStatus.success,
            customers: customersList,
            totalCount: state.totalCount,
            hasMore: customersList.length == _pageSize,
            filterCounts: state.filterCounts,
            totalDebtSum: state.totalDebtSum,
          ),
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
            totalCount: state.filterCounts.totalCount,
            hasMore: newCustomers.length == _pageSize,
            isLoadingMore: false,
            totalDebtSum: state.filterCounts.totalDebtSum,
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

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}
