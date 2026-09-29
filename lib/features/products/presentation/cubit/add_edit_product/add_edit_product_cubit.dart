import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:makhzanflow/core/constants/api_endpoints.dart';
import 'package:makhzanflow/core/constants/app_strings.dart';
import 'package:makhzanflow/core/error/failures.dart';
import 'package:makhzanflow/core/sync/enqueue_guard.dart';
import 'package:makhzanflow/core/sync/pending_op.dart';
import 'package:makhzanflow/core/sync/pending_ops_queue.dart';
import '../../../data/models/create_product_request_dto.dart';
import '../../../domain/entities/product_input.dart';
import '../../../domain/usecases/create_product_usecase.dart';
import '../../../domain/usecases/upload_product_image_usecase.dart';
import '../../../domain/usecases/get_product_usecase.dart';
import '../../../domain/usecases/update_product_usecase.dart';
import 'add_edit_product_state.dart';

export 'add_edit_product_state.dart';

class AddEditProductCubit extends Cubit<AddEditProductState> {
  final CreateProductUseCase _createProductUseCase;
  final UploadProductImageUseCase _uploadImageUseCase;
  final GetProductUseCase? _getProductUseCase;
  final UpdateProductUseCase? _updateProductUseCase;
  final PendingOpsQueue? _pendingOpsQueue;
  String? _productId;
  int _loadedVersion = 1;

  AddEditProductCubit({
    required CreateProductUseCase createProductUseCase,
    required UploadProductImageUseCase uploadImageUseCase,
    GetProductUseCase? getProductUseCase,
    UpdateProductUseCase? updateProductUseCase,
    PendingOpsQueue? pendingOpsQueue,
  })  : _createProductUseCase = createProductUseCase,
        _uploadImageUseCase = uploadImageUseCase,
        _getProductUseCase = getProductUseCase,
        _updateProductUseCase = updateProductUseCase,
        _pendingOpsQueue = pendingOpsQueue,
        super(const AddEditProductState());

  Future<void> loadForEdit(String productId, String companyId) async {
    _productId = productId;
    emit(state.copyWith(status: AddEditProductStatus.loading));
    final result = await _getProductUseCase!(productId, companyId);
    result.fold(
      (failure) => emit(state.copyWith(
        status: AddEditProductStatus.error,
        errorMessage: failure.message,
      )),
      (product) {
        _loadedVersion = product.version;
        emit(state.copyWith(
        status: AddEditProductStatus.initial,
        isEditMode: true,
        input: ProductInput(
          name: product.name,
          sku: product.sku,
          barcode: product.barcode,
          price: product.price,
          quantity: product.quantity,
          minStock: product.minStock,
        ),
        skuText: product.sku,
        barcodeText: product.barcode ?? '',
        priceText: product.price.toString(),
        quantityText: product.quantity.toString(),
        minStockText: product.minStock.toString(),
        expirationDate: product.expirationDate,
        imageUploadUrl: product.imageUrl,
      ));
      },
    );
  }

  void updateExpirationDate(DateTime? date) {
    emit(state.copyWith(expirationDate: date));
  }

  void updateName(String value) {
    emit(state.copyWith(
      input: ProductInput(
        name: value,
        sku: state.input.sku,
        barcode: state.input.barcode,
        price: state.input.price,
        quantity: state.input.quantity,
        minStock: state.input.minStock,
      ),
    ));
  }

  void updateSku(String value) {
    emit(state.copyWith(skuText: value));
  }

  void updateBarcode(String value) {
    emit(state.copyWith(barcodeText: value));
  }

  void updatePrice(String value) {
    emit(state.copyWith(priceText: value));
  }

  void updateQuantity(String value) {
    emit(state.copyWith(quantityText: value));
  }

  void updateMinStock(String value) {
    emit(state.copyWith(minStockText: value));
  }

  void setImagePath(String path) {
    emit(state.copyWith(
      imageLocalPath: path,
      isImageUploading: false,
    ));
  }

  void removeImage() {
    emit(state.copyWith(
      imageLocalPath: null,
      imageUploadUrl: null,
    ));
  }

  Future<bool> save(String userId, String companyId) async {
    final sku = state.skuText.trim();
    final barcode = state.barcodeText.trim();

    final price = double.tryParse(state.priceText.isNotEmpty ? state.priceText : '0');
    if (price == null || price < 0) {
      emit(state.copyWith(
        status: AddEditProductStatus.error,
        errorMessage: 'السعر غير صالح',
      ));
      return false;
    }

    final quantity = int.tryParse(state.quantityText.isNotEmpty ? state.quantityText : '0');
    if (quantity == null || quantity < 0) {
      emit(state.copyWith(
        status: AddEditProductStatus.error,
        errorMessage: 'الكمية غير صالحة',
      ));
      return false;
    }

    final minStock = int.tryParse(state.minStockText.isNotEmpty ? state.minStockText : '0');
    if (minStock == null || minStock < 0) {
      emit(state.copyWith(
        status: AddEditProductStatus.error,
        errorMessage: 'الحد الأدنى للمخزون غير صالح',
      ));
      return false;
    }

    emit(state.copyWith(
      status: AddEditProductStatus.loading,
      clearConflict: true,
    ));

    final input = ProductInput(
      name: state.input.name,
      sku: sku.isEmpty ? null : sku,
      barcode: barcode.isEmpty ? null : barcode,
      price: price,
      quantity: quantity,
      minStock: minStock,
      imageUrl: state.imageUploadUrl,
      expirationDate: state.expirationDate,
    );

    final hasNewImage = state.imageLocalPath != null;

    Future<bool> uploadNewImage(String productId) async {
      emit(state.copyWith(isImageUploading: true));
      final uploadResult = await _uploadImageUseCase(
        state.imageLocalPath!,
        productId,
      );
      return uploadResult.fold(
        (failure) {
          emit(state.copyWith(
            status: AddEditProductStatus.error,
            errorMessage: failure.message,
            isImageUploading: false,
          ));
          return false;
        },
        (_) {
          emit(state.copyWith(isImageUploading: false));
          return true;
        },
      );
    }

    if (state.isEditMode && _updateProductUseCase != null) {
      final result = await _updateProductUseCase(
        _productId!,
        input,
        userId,
        companyId,
        version: _loadedVersion,
      );
      return result.fold(
        (failure) async {
          // Offline edits are not allowed (add-new-only policy): existing
          // products can only be edited online. Creates still queue.
          if (shouldEnqueueFailure(failure)) {
            emit(state.copyWith(
              status: AddEditProductStatus.error,
              errorMessage: AppStrings.offlineEditOnlyNew,
              clearConflict: true,
            ));
            return false;
          }
          emit(state.copyWith(
            status: AddEditProductStatus.error,
            errorMessage: failure.message,
            conflict:
                failure is VersionConflictFailure ? failure : null,
            clearConflict: failure is! VersionConflictFailure,
          ));
          return false;
        },
        (product) async {
          if (hasNewImage) {
            final uploaded = await uploadNewImage(product.id);
            if (!uploaded) return false;
          }
          emit(state.copyWith(
            status: AddEditProductStatus.success,
            successMessage: 'تم حفظ المنتج بنجاح',
            clearConflict: true,
          ));
          return true;
        },
      );
    } else {
      final result = await _createProductUseCase(input, userId, companyId);
      return result.fold(
        (failure) async {
          // Offline create: queued — report success so the form pops and the
          // record appears in the list with a pending badge until sync.
          if (shouldEnqueueFailure(failure) && _pendingOpsQueue != null) {
            final dto = CreateProductRequestDto(
              name: input.name,
              sku: input.sku,
              barcode: input.barcode,
              price: input.price,
              stock: input.quantity,
              minStock: input.minStock,
              expiryDate: input.expirationDate,
            );
            final dropped = await tryEnqueue(
              _pendingOpsQueue,
              PendingOp.createNew(
                opType: PendingOpType.productCreate,
                method: 'POST',
                path: ApiEndpoints.products,
                body: dto.toJson(),
                companyId: companyId,
                imageLocalPath: state.imageLocalPath,
              ),
            );
            emit(state.copyWith(
              status: AddEditProductStatus.success,
              successMessage: dropped
                  ? AppStrings.queueOverflow
                  : AppStrings.queuedWillSync,
            ));
            return true;
          }
          emit(state.copyWith(
            status: AddEditProductStatus.error,
            errorMessage: failure.message,
          ));
          return false;
        },
        (product) async {
          if (hasNewImage) {
            final uploaded = await uploadNewImage(product.id);
            if (!uploaded) return false;
          }
          emit(state.copyWith(
            status: AddEditProductStatus.success,
            successMessage: 'تم حفظ المنتج بنجاح',
          ));
          return true;
        },
      );
    }
  }

  void resetStatus() {
    emit(state.copyWith(
      status: AddEditProductStatus.initial,
      errorMessage: null,
      successMessage: null,
      clearConflict: true,
    ));
  }

  /// Adopts the fresh server version after a Merge "Keep mine" choice so the
  /// next [save] retries against current data (see guide §5).
  void applyServerVersion(int version) {
    _loadedVersion = version;
  }
}
