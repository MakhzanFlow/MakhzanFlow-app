import 'package:flutter/material.dart';
import '../../../../core/theme/mf_tokens.dart';
import '../../../../core/constants/app_strings.dart';

class ProductErrorView extends StatelessWidget {
  final String? message;
  final VoidCallback? onRetry;

  const ProductErrorView({
    super.key,
    this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textSecondary = isDark ? MFTokens.textSecondaryDark : MFTokens.textSecondaryLight;
    final errorColor = isDark ? MFTokens.errorTextDark : MFTokens.errorText;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(MFTokens.sp24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 64, color: errorColor),
            const SizedBox(height: MFTokens.sp16),
            Text(
              message ?? AppStrings.productLoadError,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: MFTokens.fontMD,
                color: textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: MFTokens.sp16),
              ElevatedButton(
                onPressed: onRetry,
                child: Text(AppStrings.productRetry),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
