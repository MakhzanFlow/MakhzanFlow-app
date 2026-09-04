import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:makhzanflow/core/company/company_aware_state.dart';
import '../../../../core/theme/mf_tokens.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/permissions/permission_constants.dart';
import '../../../../core/permissions/permission_gate.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../cubit/product_details/product_details_cubit.dart';
import '../widgets/inventory_movement_list.dart';
import '../widgets/product_delete_dialog.dart';
import '../widgets/product_details_sections.dart';
import '../widgets/product_error_view.dart';
import '../widgets/product_loading_view.dart';

class ProductDetailsScreen extends StatefulWidget {
  final String productId;

  const ProductDetailsScreen({super.key, required this.productId});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen>
    with CompanyAwareState<ProductDetailsScreen> {
  late final ProductDetailsCubit _cubit;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _cubit = context.read<ProductDetailsCubit>();
      _cubit.loadProduct(widget.productId, companyId);
      _initialized = true;
    }
  }

  @override
  void onCompanyChanged(String companyId) {
    _cubit.loadProduct(widget.productId, companyId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.productDetails)),
      body: BlocConsumer<ProductDetailsCubit, ProductDetailsState>(
        listener: (context, state) {
          if (state.status == ProductDetailsStatus.error &&
              state.errorMessage != null) {
            AppSnackbar.error(context, state.errorMessage!);
          }
        },
        builder: (context, state) {
          switch (state.status) {
            case ProductDetailsStatus.initial:
            case ProductDetailsStatus.loading:
              return const ProductLoadingView();
            case ProductDetailsStatus.error:
              return ProductErrorView(
                message: state.errorMessage ?? AppStrings.productLoadError,
                onRetry: () => _cubit.loadProduct(widget.productId, companyId),
              );
            case ProductDetailsStatus.success:
              final product = state.product!;
              return RefreshIndicator(
                onRefresh: () =>
                    _cubit.loadProduct(widget.productId, companyId),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(MFTokens.sp16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ProductDetailsImage(imageUrl: product.imageUrl),
                      const SizedBox(height: MFTokens.sp24),
                      ProductInfoSection(product: product),
                      const SizedBox(height: MFTokens.sp24),
                      PermissionGate(
                        anyPermissions: [
                          PermissionKeys.productsEdit,
                          PermissionKeys.productsDelete,
                        ],
                        child: ProductActionButtons(
                          onEdit: () async {
                            final updated = await context.push<bool>(
                              '/products/${product.id}/edit',
                            );
                            if (updated == true && mounted) {
                              _cubit.loadProduct(widget.productId, companyId);
                            }
                          },
                          onDelete: () => _confirmDelete(context, product.id),
                          isDeleting: state.isDeleting,
                        ),
                      ),
                      InventoryMovementList(movements: state.recentMovements),
                    ],
                  ),
                ),
              );
          }
        },
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, String id) async {
    final confirmed = await DeleteConfirmationDialog.show(context);
    if (confirmed == true && mounted) {
      final success = await _cubit.deleteProduct(id, companyId);
      if (success && context.mounted) {
        AppSnackbar.success(context, AppStrings.productDeleted);
        context.pop();
      }
    }
  }
}
