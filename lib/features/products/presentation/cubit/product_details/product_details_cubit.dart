import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:makhzanflow/core/constants/api_endpoints.dart';
import 'package:makhzanflow/core/constants/app_strings.dart';
import 'package:makhzanflow/core/error/failures.dart';
import 'package:makhzanflow/core/sync/enqueue_guard.dart';
import 'package:makhzanflow/core/sync/pending_op.dart';
import 'package:makhzanflow/core/sync/pending_ops_queue.dart';
import '../../../domain/entities/product.dart';
import '../../../data/models/update_product_request_dto.dart';
import '../../../domain/usecases/get_product_usecase.dart';
import '../../../domain/usecases/delete_product_usecase.dart';
import '../../../domain/usecases/update_product_quantity_usecase.dart';
import '../../../domain/usecases/get_inventory_movements_usecase.dart';
import 'product_details_state.dart';

export 'product_details_state.dart';

class ProductDetailsCubit extends Cubit<ProductDetailsState> {
  final GetProductUseCase _getProductUseCase;
  final DeleteProductUseCase _deleteProductUseCase;
  final UpdateProductQuantityUseCase? _updateQuantityUseCase;
  final GetInventoryMovementsUseCase? _getMovementsUseCase;
  final PendingOpsQueue? _pendingOpsQueue;
  String _companyId = '';
  _AdjustArgs? _lastAdjust;

  ProductDetailsCubit({
    required GetProductUseCase getProductUseCase,
    required DeleteProductUseCase deleteProductUseCase,
    UpdateProductQuantityUseCase? updateQuantityUseCase,
    GetInventoryMovementsUseCase? getMovementsUseCase,
    PendingOpsQueue? pendingOpsQueue,
  })  : _getProductUseCase = getProductUseCase,
        _deleteProductUseCase = deleteProductUseCase,
        _updateQuantityUseCase = updateQuantityUseCase,
        _getMovementsUseCase = getMovementsUseCase,
        _pendingOpsQueue = pendingOpsQueue,
        super(const ProductDetailsState());

  Future<void> loadProduct(
    String id,
    String companyId, {
    Product? fallback,
  }) async {
    _companyId = companyId;
    emit(state.copyWith(status: ProductDetailsStatus.loading));

    final result = await _getProductUseCase(id, companyId);
    result.fold(
      (failure) {
        // Offline with list data: render the list snapshot as details.
        if (shouldEnqueueFailure(failure) && fallback != null) {
          emit(state.copyWith(
            status: ProductDetailsStatus.success,
            product: fallback,
          ));
          return;
        }
        emit(state.copyWith(
          status: ProductDetailsStatus.error,
          errorMessage: failure.message,
        ));
      },
      (product) {
        emit(state.copyWith(
          status: ProductDetailsStatus.success,
          product: product,
        ));
        _loadMovements(product.id);
      },
    );
  }

  Future<void> _loadMovements(String productId) async {
    if (_getMovementsUseCase == null) return;
    final result = await _getMovementsUseCase(productId, _companyId);
    result.fold(
      (_) {},
      (movements) => emit(state.copyWith(recentMovements: movements)),
    );
  }

  Future<bool> deleteProduct(String id, String companyId) async {
    _companyId = companyId;
    emit(state.copyWith(isDeleting: true));
    final result = await _deleteProductUseCase(id, companyId);
    return result.fold(
      (failure) async {
        // Offline: queue the delete for replay.
        if (shouldEnqueueFailure(failure) && _pendingOpsQueue != null) {
          final dropped = await tryEnqueue(
            _pendingOpsQueue,
            PendingOp.createNew(
              opType: PendingOpType.productDelete,
              method: 'DELETE',
              path: ApiEndpoints.productById(id),
              body: const {},
              companyId: companyId,
            ),
          );
          emit(state.copyWith(
            isDeleting: false,
            errorMessage: dropped
                ? AppStrings.queueOverflow
                : AppStrings.queuedWillSync,
          ));
          return false;
        }
        emit(state.copyWith(
          isDeleting: false,
          errorMessage: failure.message,
        ));
        return false;
      },
      (_) {
        emit(state.copyWith(isDeleting: false));
        return true;
      },
    );
  }

  Future<bool> updateQuantity({
    required String productId,
    required int delta,
    String? note,
    required String userId,
    required String companyId,
    QuantityAction action = QuantityAction.add,
    int? version,
  }) async {
    _companyId = companyId;
    if (_updateQuantityUseCase == null) return false;
    _lastAdjust = _AdjustArgs(
      productId: productId,
      delta: delta,
      note: note,
      userId: userId,
      companyId: companyId,
      action: action,
    );

    emit(state.copyWith(isUpdatingQuantity: true, clearConflict: true));
    final result = await _updateQuantityUseCase(
      productId: productId,
      delta: delta,
      note: note,
      userId: userId,
      companyId: companyId,
      version: version ?? state.product?.version,
    );

    return result.fold(
      (failure) async {
        // Offline: replay the same absolute-stock PUT the live path sends
        // (read-modify-write collapses to `{stock, version}` at enqueue time).
        if (shouldEnqueueFailure(failure) && _pendingOpsQueue != null) {
          final dropped = await _enqueueStockAdjust(
            productId: productId,
            delta: delta,
            companyId: companyId,
          );
          emit(state.copyWith(
            isUpdatingQuantity: false,
            errorMessage: dropped
                ? AppStrings.queueOverflow
                : AppStrings.queuedWillSync,
            clearConflict: true,
          ));
          return false;
        }
        emit(state.copyWith(
          isUpdatingQuantity: false,
          errorMessage: failure.message,
          conflict: failure is VersionConflictFailure ? failure : null,
          clearConflict: failure is! VersionConflictFailure,
        ));
        return false;
      },
      (product) async {
        emit(state.copyWith(
          isUpdatingQuantity: false,
          product: product,
          clearConflict: true,
        ));
        _loadMovements(productId);
        return true;
      },
    );
  }

  /// Retries the last stock adjust after a Merge "Keep mine" choice with the
  /// fresh server version (guide §5). Returns false when nothing to retry.
  Future<bool> retryLastAdjust(int version) {
    final args = _lastAdjust;
    if (args == null) return Future.value(false);
    return updateQuantity(
      productId: args.productId,
      delta: args.delta,
      note: args.note,
      userId: args.userId,
      companyId: args.companyId,
      action: args.action,
      version: version,
    );
  }

  /// Queues an absolute-stock write mirroring the live read-modify-write PUT.
  /// Returns true when the queue cap forced a drop-oldest.
  Future<bool> _enqueueStockAdjust({
    required String productId,
    required int delta,
    required String companyId,
  }) {
    final current = state.product;
    final dto = UpdateProductRequestDto(
      stock: (current?.quantity ?? 0) + delta,
      version: current?.version ?? 1,
    );
    return tryEnqueue(
      _pendingOpsQueue!,
      PendingOp.createNew(
        opType: PendingOpType.stockAdjust,
        method: 'PUT',
        path: ApiEndpoints.productById(productId),
        body: dto.toJson(),
        companyId: companyId,
      ),
    );
  }
}

/// Last stock-adjust arguments, retained so a Merge "Keep mine" choice can
/// retry the identical write against the fresh server version.
class _AdjustArgs {
  final String productId;
  final int delta;
  final String? note;
  final String userId;
  final String companyId;
  final QuantityAction action;

  const _AdjustArgs({
    required this.productId,
    required this.delta,
    this.note,
    required this.userId,
    required this.companyId,
    required this.action,
  });
}
