import 'package:flutter/material.dart';
import '../../../../core/theme/mf_tokens.dart';
import '../../../../core/constants/app_strings.dart';

class CustomerDebtBadge extends StatelessWidget {
  final double debt;

  const CustomerDebtBadge({
    super.key,
    required this.debt,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = isDark ? MFTokens.primaryDarkMode : MFTokens.primary;
    final errorColor = isDark ? MFTokens.errorTextDark : MFTokens.errorText;
    final successBg = isDark ? MFTokens.successBgDark : MFTokens.successBg;
    final errorBg = isDark ? MFTokens.errorBgDark : MFTokens.errorBg;

    return Container(
      padding: const EdgeInsets.all(MFTokens.sp16),
      decoration: BoxDecoration(
        color: debt > 0 ? errorBg : successBg,
        borderRadius: BorderRadius.circular(MFTokens.radiusMD),
      ),
      child: Row(
        children: [
          Icon(
            debt > 0 ? Icons.warning_amber_rounded : Icons.check_circle,
            color: debt > 0 ? errorColor : primary,
          ),
          SizedBox(width: MFTokens.sp8),
          Expanded(
            child: Text(
              '${AppStrings.customerDebtTotal}: ${debt.toStringAsFixed(2)} ${AppStrings.currencyEg}',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: MFTokens.fontLG,
                fontWeight: FontWeight.bold,
                color: debt > 0 ? errorColor : primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
