import 'package:flutter/material.dart';
import '../../../../core/theme/mf_tokens.dart';
import '../../../../core/constants/app_strings.dart';

class ProductScreenHeader extends StatelessWidget {
  final int totalCount;

  const ProductScreenHeader({super.key, required this.totalCount});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? MFTokens.textPrimaryDark : MFTokens.textPrimaryLight;
    final primary = isDark ? MFTokens.primaryDarkMode : MFTokens.primary;
    final primarySubtle = isDark ? MFTokens.primaryDarkModeSubtle : MFTokens.primarySubtle;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: MFTokens.sp16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: Text(
              AppStrings.productsTitle,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: MFTokens.font2XL,
                fontWeight: FontWeight.bold,
                color: textPrimary,
              ),
            ),
          ),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: MFTokens.sp8,
                vertical: MFTokens.sp4,
              ),
              decoration: BoxDecoration(
                color: primarySubtle,
                borderRadius: BorderRadius.circular(MFTokens.radiusSM),
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  '$totalCount ${AppStrings.productCount}',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: MFTokens.fontXS,
                    color: primary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
