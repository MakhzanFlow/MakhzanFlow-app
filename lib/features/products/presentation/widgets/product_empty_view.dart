import 'package:flutter/material.dart';
import '../../../../core/theme/mf_tokens.dart';
import '../../../../core/constants/app_strings.dart';

class ProductEmptyView extends StatelessWidget {
  final String? message;
  final VoidCallback? onAction;

  const ProductEmptyView({
    super.key,
    this.message,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textSecondary = isDark ? MFTokens.textSecondaryDark : MFTokens.textSecondaryLight;
    final muted = isDark ? MFTokens.textMutedDark : MFTokens.textMutedLight;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(MFTokens.sp24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inventory_2_outlined, size: 64, color: muted),
            const SizedBox(height: MFTokens.sp16),
            Text(
              message ?? AppStrings.emptyProducts,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: MFTokens.fontMD,
                color: textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
