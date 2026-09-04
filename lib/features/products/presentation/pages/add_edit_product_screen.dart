import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:makhzanflow/core/company/company_aware_state.dart';
import 'package:makhzanflow/core/theme/mf_tokens.dart';
import 'package:makhzanflow/core/constants/app_strings.dart';
import 'package:makhzanflow/core/permissions/permission_constants.dart';
import 'package:makhzanflow/core/permissions/permission_service.dart';
import 'package:makhzanflow/core/di/service_locator.dart';
import 'package:makhzanflow/core/widgets/app_snackbar.dart';
import '../../../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../../../features/auth/presentation/cubit/auth_state.dart';
import '../cubit/add_edit_product/add_edit_product_cubit.dart';
import '../widgets/product_form_fields.dart';
import '../widgets/product_image_picker_field.dart';
import '../widgets/product_save_button.dart';

class AddEditProductScreen extends StatefulWidget {
  final String? productId;

  const AddEditProductScreen({super.key, this.productId});

  @override
  State<AddEditProductScreen> createState() => _AddEditProductScreenState();
}

class _AddEditProductScreenState extends State<AddEditProductScreen>
    with CompanyAwareState<AddEditProductScreen> {
  late final AddEditProductCubit _cubit;
  bool _initialized = false;

  bool get _isEditMode => widget.productId != null;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _cubit = context.read<AddEditProductCubit>();
      if (widget.productId != null) {
        _cubit.loadForEdit(widget.productId!, companyId);
      }
      _initialized = true;
    }
  }

  @override
  void onCompanyChanged(String companyId) {
    if (widget.productId != null) {
      _cubit.loadForEdit(widget.productId!, companyId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditMode ? AppStrings.productEdit : AppStrings.productsAdd,
        ),
        actions: [
          TextButton(
            onPressed: () => _save(),
            child: Text(
              AppStrings.productSave,
              style: const TextStyle(
                fontFamily: 'Cairo',
                color: Colors.white,
                fontSize: MFTokens.fontMD,
              ),
            ),
          ),
        ],
      ),
      body: BlocConsumer<AddEditProductCubit, AddEditProductState>(
        listener: (context, state) {
          if (state.status == AddEditProductStatus.success) {
            AppSnackbar.success(
              context,
              state.successMessage ?? AppStrings.productSaved,
            );
            context.pop(true);
          }
          if (state.status == AddEditProductStatus.error &&
              state.errorMessage != null) {
            AppSnackbar.error(context, state.errorMessage!);
            _cubit.resetStatus();
          }
        },
        builder: (context, state) {
          if (state.status == AddEditProductStatus.loading && _isEditMode) {
            return const Center(child: CircularProgressIndicator());
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(MFTokens.sp16),
            child: Column(
              children: [
                ProductImagePickerField(
                  imageLocalPath: state.imageLocalPath,
                  imageUploadUrl: state.imageUploadUrl,
                  isUploading: state.isImageUploading,
                  onImagePicked: (path) => _cubit.setImagePath(path),
                  onRemove: () => _cubit.removeImage(),
                ),
                const SizedBox(height: MFTokens.sp24),
                ProductFormFields(
                  name: state.input.name,
                  sku: state.skuText,
                  barcode: state.barcodeText,
                  price: state.priceText,
                  quantity: state.quantityText,
                  minStock: state.minStockText,
                  expirationDate: state.expirationDate,
                  onNameChanged: _cubit.updateName,
                  onSkuChanged: _cubit.updateSku,
                  onBarcodeChanged: _cubit.updateBarcode,
                  onPriceChanged: _cubit.updatePrice,
                  onQuantityChanged: _cubit.updateQuantity,
                  onMinStockChanged: _cubit.updateMinStock,
                  onExpirationDateChanged: _cubit.updateExpirationDate,
                ),
                const SizedBox(height: MFTokens.sp24),
                ProductSaveButton(
                  isLoading: state.status == AddEditProductStatus.loading,
                  isEditMode: state.isEditMode,
                  onPressed: () => _save(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _save() async {
    final permissionService = sl<PermissionService>();
    final permission = _isEditMode
        ? PermissionKeys.productsEdit
        : PermissionKeys.productsCreate;
    if (!permissionService.hasPermission(permission)) {
      if (mounted) {
        AppSnackbar.error(context, 'ليس لديك صلاحية للقيام بهذا الإجراء');
      }
      return;
    }
    final authState = context.read<AuthCubit>().state;
    final userId = authState is Authenticated ? authState.user.id : '';
    if (userId.isEmpty) return;
    await _cubit.save(userId, companyId);
  }
}
