import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:makhzanflow/core/company/company_aware_state.dart';
import 'package:makhzanflow/core/activity/activity_log_entry.dart';
import '../../../../core/theme/mf_tokens.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/merge_retry.dart';
import '../../../../core/permissions/permission_constants.dart';
import '../../../../core/permissions/permission_gate.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../shared/widgets/version_conflict_dialog.dart';
import '../cubit/product_details/product_details_cubit.dart';
import '../widgets/inventory_movement_list.dart';
import '../widgets/product_delete_dialog.dart';
import '../widgets/product_details_sections.dart';
import '../widgets/product_error_view.dart';
import '../widgets/product_loading_view.dart';
import '../../../../shared/widgets/activity_section.dart';
import '../../domain/entities/product.dart';

class ProductDetailsScreen extends StatefulWidget {
  final String productId;
  /// List snapshot used as details when offline with no cached response.
  final Product? fallbackProduct;

  const ProductDetailsScreen({
    super.key,
    required this.productId,
    this.fallbackProduct,
  });

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
      _cubit.loadProduct(
        widget.productId,
        companyId,
        fallback: widget.fallbackProduct,
      );
      _initialized = true;
    }
  }

  @override
  void onCompanyChanged(String companyId) {
    _cubit.loadProduct(
      widget.productId,
      companyId,
      fallback: widget.fallbackProduct,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.productDetails)),
      body: BlocConsumer<ProductDetailsCubit, ProductDetailsState>(
        listener: (context, state) {
          if (state.status == ProductDetailsStatus.error &&
              state.errorMessage != null) {
            if (state.conflict != null) {
              _onStockConflict(state.conflict!);
            } else {
              AppSnackbar.error(context, state.errorMessage!);
            }
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
              final isPending = product.id
                  .startsWith(AppConstants.pendingIdPrefix);
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
                      if (!isPending)
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
                      const SizedBox(height: MFTokens.sp24),
                      ActivitySection(
                        entity: ActivityLogEntity.product,
                        entityId: product.id,
                        readPermission: PermissionKeys.productsView,
                      ),
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

  /// Merge UI for a stale stock version (guide §5): attempted stock vs server
  /// stock. Keep mine retries the identical adjust with the fresh version;
  /// Use server reloads the product (discards the attempt).
  Future<void> _onStockConflict(VersionConflictFailure conflict) async {
    final current = conflict.current ?? const {};
    final attempted = conflict.attempted ?? const {};
    final rows = [
      ConflictFieldRow(
        label: AppStrings.productQuantityLabel,
        mine: '${attempted['stock'] ?? '—'}',
        server: '${current['stock'] ?? current['quantity'] ?? '—'}',
      ),
    ];
    final choice = await showVersionConflictDialog(context, rows: rows);
    if (!mounted) return;
    if (choice == MergeChoice.mine) {
      await _cubit.retryLastAdjust(serverVersionOf(conflict));
    } else {
      await _cubit.loadProduct(widget.productId, companyId);
    }
  }
}
