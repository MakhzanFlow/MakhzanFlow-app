import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:makhzanflow/core/constants/app_constants.dart';
import 'package:makhzanflow/core/sync/enqueue_guard.dart';
import 'package:makhzanflow/core/sync/pending_op.dart';
import 'package:makhzanflow/core/sync/pending_ops_queue.dart';
import '../../../data/models/pending_entity_mapper.dart';
import '../../../domain/entities/product.dart';
import '../../../domain/usecases/get_products_usecase.dart';
import 'products_state.dart';

export 'products_state.dart';

const int _pageSize = AppConstants.defaultPageSize;

class ProductsCubit extends Cubit<ProductsState> {
  final GetProductsUseCase _getProductsUseCase;
  final PendingOpsQueue? _pendingOpsQueue;
  Timer? _debounce;
  int _currentPage = 0;

  ProductsCubit({
    required GetProductsUseCase getProductsUseCase,
    PendingOpsQueue? pendingOpsQueue,
  })  : _getProductsUseCase = getProductsUseCase,
        _pendingOpsQueue = pendingOpsQueue,
        super(const ProductsState());

  Future<void> loadProducts({required String companyId}) async {
    _currentPage = 0;
    emit(state.copyWith(status: ProductsStatus.loading, isLoadingMore: false));

    final result = await _getProductsUseCase(
      companyId: companyId,
      query: state.filter.hasQuery ? state.filter.query : null,
      limit: _pageSize,
      offset: 0,
      sortColumn: state.filter.sortColumn,
      ascending: state.filter.ascending,
    );
    final pending = await _pendingCreates();

    result.fold(
      (failure) {
        // Offline with queued creates: show the optimistic rows instead of
        // an error (the offline banner marks them stale).
        if (shouldEnqueueFailure(failure) && pending.isNotEmpty) {
          emit(state.copyWith(
            status: ProductsStatus.success,
            products: pending,
            totalCount: pending.length,
            hasMore: false,
            pendingIds: pending.map((p) => p.id).toSet(),
          ));
          return;
        }
        emit(state.copyWith(
            status: ProductsStatus.error, errorMessage: failure.message));
      },
      (products) {
        emit(
          state.copyWith(
            status: products.isEmpty && pending.isEmpty
                ? ProductsStatus.empty
                : ProductsStatus.success,
            products: [...pending, ...products],
            totalCount: products.length,
            hasMore: products.length == _pageSize,
            pendingIds: pending.map((p) => p.id).toSet(),
          ),
        );
      },
    );
  }

  Future<void> loadMore({required String companyId}) async {
    if (state.isLoadingMore || !state.hasMore) return;
    emit(state.copyWith(isLoadingMore: true));

    final nextPage = _currentPage + 1;
    final nextOffset = nextPage * _pageSize;

    final result = await _getProductsUseCase(
      companyId: companyId,
      query: state.filter.hasQuery ? state.filter.query : null,
      limit: _pageSize,
      offset: nextOffset,
      sortColumn: state.filter.sortColumn,
      ascending: state.filter.ascending,
    );

    result.fold(
      (_) {
        emit(state.copyWith(isLoadingMore: false));
      },
      (newProducts) {
        _currentPage = nextPage;
        final allProducts = [...state.products, ...newProducts];
        emit(
          state.copyWith(
            status: ProductsStatus.success,
            products: allProducts,
            totalCount: allProducts.length,
            hasMore: newProducts.length == _pageSize,
            isLoadingMore: false,
          ),
        );
      },
    );
  }

  void updateSearchQuery(String query, {required String companyId}) {
    emit(state.copyWith(filter: state.filter.copyWith(query: query)));
    _debounce?.cancel();
    final cid = companyId;
    _debounce = Timer(const Duration(milliseconds: 400), () {
      loadProducts(companyId: cid);
    });
  }

  Future<void> refresh({required String companyId}) async {
    await loadProducts(companyId: companyId);
  }

  /// Optimistic entities for queued `productCreate` ops (newest first).
  Future<List<Product>> _pendingCreates() async {
    final queue = _pendingOpsQueue;
    if (queue == null) return const [];
    final ops = await queue.pending();
    return ops
        .where((op) => op.opType == PendingOpType.productCreate)
        .map(productFromQueueOp)
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
