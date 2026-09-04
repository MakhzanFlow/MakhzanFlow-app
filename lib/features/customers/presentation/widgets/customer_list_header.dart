import 'package:flutter/material.dart';
import '../../../../core/theme/mf_tokens.dart';
import '../../../../core/constants/app_strings.dart';

class CustomerListHeader extends StatelessWidget {
  final int totalCount;
  final double totalDebt;

  const CustomerListHeader({
    super.key,
    required this.totalCount,
    required this.totalDebt,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark
        ? MFTokens.textPrimaryDark
        : MFTokens.textPrimaryLight;
    final textSecondary = isDark
        ? MFTokens.textSecondaryDark
        : MFTokens.textSecondaryLight;
    final accent = isDark ? MFTokens.primaryDarkMode : MFTokens.accent;
    final warningBg = isDark ? MFTokens.warningBgDark : MFTokens.warningBg;

    return Padding(
      padding: const EdgeInsets.only(
        left: MFTokens.sp16,
        right: MFTokens.sp16,
        top: MFTokens.sp16,
        bottom: MFTokens.sp8,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.customersTitle,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: MFTokens.font2XL,
                    fontWeight: FontWeight.bold,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: MFTokens.sp4),
                Text(
                  '$totalCount ${AppStrings.customerStore}',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: MFTokens.fontSM,
                    color: textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: MFTokens.sp8),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: MFTokens.sp8,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: warningBg,
              borderRadius: BorderRadius.circular(MFTokens.radiusSM),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.account_balance_wallet_outlined,
                  size: MFTokens.sp16,
                  color: accent,
                ),
                const SizedBox(width: MFTokens.sp8),
                Text(
                  '${AppStrings.customerDebtsLabel}: ${totalDebt.toInt()} ${AppStrings.currencyEg}',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: MFTokens.fontSM,
                    fontWeight: FontWeight.w600,
                    color: accent,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
