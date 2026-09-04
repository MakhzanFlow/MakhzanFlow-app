import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/mf_tokens.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/permissions/permission_constants.dart';
import '../../../../core/permissions/permission_service.dart';
import '../../../../core/di/service_locator.dart';
import '../../domain/entities/product.dart';
import 'dashed_border_painter.dart';

class ProductDetailsImage extends StatelessWidget {
  final String? imageUrl;

  const ProductDetailsImage({super.key, this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = isDark ? MFTokens.primaryDarkMode : MFTokens.primary;
    final primarySubtle = isDark ? MFTokens.primaryDarkModeSubtle : const Color(0xFFE8F1EC);

    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(MFTokens.radiusMD),
        child: CachedNetworkImage(
          imageUrl: imageUrl!,
          height: 200,
          width: double.infinity,
          fit: BoxFit.cover,
          placeholder: (_, __) => _placeholder(primary, primarySubtle),
          errorWidget: (_, __, ___) => _placeholder(primary, primarySubtle),
        ),
      );
    }
    return _placeholder(primary, primarySubtle);
  }

  Widget _placeholder(Color primary, Color bg) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(MFTokens.radiusLG),
      ),
      child: CustomPaint(
        painter: DashedBorderPainter(color: primary),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: primary, width: 2.17),
                ),
                child: Icon(Icons.inventory_2_outlined, size: 14, color: primary),
              ),
              const SizedBox(height: 4),
              Text(
                AppStrings.productImagePicker,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: MFTokens.fontXS,
                  color: primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProductInfoSection extends StatelessWidget {
  final Product product;

  const ProductInfoSection({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? MFTokens.textPrimaryDark : MFTokens.textPrimaryLight;
    final textSecondary = isDark ? MFTokens.textSecondaryDark : MFTokens.textSecondaryLight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          product.name,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: MFTokens.font2XL,
            fontWeight: FontWeight.bold,
            color: textPrimary,
          ),
        ),
        const SizedBox(height: MFTokens.sp8),
        _infoRow(
          AppStrings.productPriceLabel,
          '${product.price.toStringAsFixed(2)} ${AppStrings.currencyEg}',
          textPrimary: textPrimary,
          textSecondary: textSecondary,
        ),
        _infoRow(
          AppStrings.productQuantityLabel,
          product.quantity.toString(),
          textPrimary: textPrimary,
          textSecondary: textSecondary,
        ),
        if (product.expirationDate != null)
          _infoRow(
            AppStrings.productExpirationDateLabel,
            '${product.expirationDate!.year}-${product.expirationDate!.month.toString().padLeft(2, '0')}-${product.expirationDate!.day.toString().padLeft(2, '0')}',
            textPrimary: textPrimary,
            textSecondary: textSecondary,
          ),
      ],
    );
  }

  Widget _infoRow(String label, String value, {required Color textPrimary, required Color textSecondary}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: MFTokens.fontSM,
              color: textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: MFTokens.fontSM,
              color: textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class ProductActionButtons extends StatelessWidget {
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool isDeleting;

  const ProductActionButtons({
    super.key,
    this.onEdit,
    this.onDelete,
    this.isDeleting = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final errorColor = isDark ? MFTokens.errorTextDark : MFTokens.errorText;
    final ps = sl<PermissionService>();
    final canEdit = ps.hasPermission(PermissionKeys.productsEdit);
    final canDelete = ps.hasPermission(PermissionKeys.productsDelete);

    final children = <Widget>[];
    if (canEdit) {
      children.add(
        Expanded(
          child: ElevatedButton.icon(
            onPressed: onEdit,
            icon: const Icon(Icons.edit_outlined),
            label: Text(AppStrings.productEdit),
          ),
        ),
      );
    }
    if (canEdit && canDelete) {
      children.add(const SizedBox(width: MFTokens.sp16));
    }
    if (canDelete) {
      children.add(
        Expanded(
          child: OutlinedButton.icon(
            onPressed: isDeleting ? null : onDelete,
            icon: isDeleting
                ? const SizedBox(
                    width: 16, height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(Icons.delete_outline, color: errorColor),
            label: Text(
              AppStrings.productDelete,
              style: TextStyle(color: isDeleting ? null : errorColor),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: errorColor),
            ),
          ),
        ),
      );
    }

    if (children.isEmpty) return const SizedBox.shrink();
    return Row(children: children);
  }
}
