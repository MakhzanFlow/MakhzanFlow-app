import 'package:flutter/material.dart';
import '../../../../core/theme/mf_tokens.dart';
import '../../../../core/constants/app_strings.dart';

class CustomerDebtDisplay extends StatelessWidget {
  final String debtText;

  const CustomerDebtDisplay({
    super.key,
    required this.debtText,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? MFTokens.textPrimaryDark : MFTokens.textPrimaryLight;
    final accent = isDark ? MFTokens.primaryDarkMode : MFTokens.accent;
    final warningBg = isDark ? MFTokens.warningBgDark : MFTokens.warningBg;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(MFTokens.sp16),
      decoration: BoxDecoration(
        color: warningBg,
        borderRadius: BorderRadius.circular(MFTokens.radiusMD),
      ),
      child: Row(
        children: [
          Icon(
            Icons.lock_outline,
            color: accent,
          ),
          SizedBox(width: MFTokens.sp8),
          Expanded(
            child: Text(
              '${AppStrings.customerDebtTotal}: $debtText ${AppStrings.currencyEg}'
              ' - ${AppStrings.customerDebtEditNote}',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: MFTokens.fontMD,
                color: textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
