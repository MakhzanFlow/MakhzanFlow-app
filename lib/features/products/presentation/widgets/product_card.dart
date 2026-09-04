import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/mf_tokens.dart';
import '../../../../core/constants/app_strings.dart';
import '../../domain/entities/product.dart';
import 'dashed_border_painter.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;
  final int lowStockThreshold;

  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.lowStockThreshold = 5,
  });

  bool get _isLowStock => product.quantity <= lowStockThreshold && product.quantity > 0;
  bool get _isOutOfStock => product.quantity == 0;
  bool get _isExpiringSoon => product.expirationDate != null &&
      product.expirationDate!.difference(DateTime.now()).inDays <= 30 &&
      product.expirationDate!.isAfter(DateTime.now());
  bool get _isExpired => product.expirationDate != null &&
      product.expirationDate!.isBefore(DateTime.now());

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? MFTokens.cardDark : MFTokens.cardLight;
    final textPrimary = isDark ? MFTokens.textPrimaryDark : MFTokens.textPrimaryLight;
    final textSecondary = isDark ? MFTokens.textSecondaryDark : MFTokens.textSecondaryLight;
    final accent = isDark ? MFTokens.primaryDarkMode : MFTokens.accent;
    final errorColor = isDark ? MFTokens.errorTextDark : MFTokens.errorText;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(MFTokens.radiusMD),
          border: isDark ? Border.all(color: MFTokens.borderDark, width: 1) : null,
          boxShadow: isDark ? null : MFTokens.shadowSM,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 3, child: Stack(
              children: [
                _buildImage(isDark),
                if (_isOutOfStock) _buildBadge(
                  AppStrings.productOutOfStock, errorColor,
                ),
                if (_isLowStock) _buildBadge(
                  AppStrings.productLowStock, accent,
                ),
                if (_isExpired) Positioned(
                  top: 4, right: 4,
                  child: _buildSmallBadge(
                    AppStrings.productExpired, errorColor,
                  ),
                ),
                if (_isExpiringSoon) Positioned(
                  top: 4, right: 4,
                  child: _buildSmallBadge(
                    AppStrings.productExpiringSoon, accent,
                  ),
                ),
              ],
            )),
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(MFTokens.sp8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: MFTokens.fontSM,
                        fontWeight: FontWeight.w600,
                        color: textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${product.price.toStringAsFixed(2)} ${AppStrings.currencyEg}',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: MFTokens.fontXS,
                        color: accent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(flex: 1),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            '${AppStrings.productQuantityLabel}: ${product.quantity}',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: MFTokens.fontXS,
                              color: textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Positioned(
      top: 0, left: 0, right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 6),
        color: color.withValues(alpha: 0.85),
        alignment: Alignment.center,
        child: Text(
          text,
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: MFTokens.fontXS,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildSmallBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'Cairo',
          fontSize: 8,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildImage(bool isDark) {
    final placeholder = Container(
      decoration: BoxDecoration(
        color: isDark ? MFTokens.primaryDarkModeSubtle : const Color(0xFFE8F1EC),
        borderRadius: BorderRadius.circular(MFTokens.radiusMD),
      ),
      child: CustomPaint(
        painter: DashedBorderPainter(
          color: isDark ? MFTokens.primaryDarkMode : MFTokens.primary,
        ),
        child: Center(
          child: Icon(
            Icons.inventory_2_outlined,
            size: 24,
            color: isDark ? MFTokens.primaryDarkMode : MFTokens.primary,
          ),
        ),
      ),
    );

    if (product.imageUrl != null && product.imageUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(MFTokens.radiusMD),
        child: CachedNetworkImage(
          imageUrl: product.imageUrl!,
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
          placeholder: (_, __) => placeholder,
          errorWidget: (_, __, ___) => placeholder,
        ),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(MFTokens.radiusMD),
      child: placeholder,
    );
  }
}
