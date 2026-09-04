import 'package:flutter/material.dart';
import '../../../../core/theme/mf_tokens.dart';
import '../../../../core/constants/app_strings.dart';

class CustomerDebtSummaryCard extends StatelessWidget {
  final double totalDebt;
  final double totalPurchases;
  final double totalPaid;

  const CustomerDebtSummaryCard({
    super.key,
    required this.totalDebt,
    this.totalPurchases = 0,
    this.totalPaid = 0,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textSecondary = isDark ? MFTokens.textSecondaryDark : MFTokens.textSecondaryLight;
    final primary = isDark ? MFTokens.primaryDarkMode : MFTokens.primary;
    final primarySubtle = isDark ? MFTokens.primaryDarkModeSubtle : MFTokens.primarySubtle;
    final accent = isDark ? MFTokens.primaryDarkMode : MFTokens.accent;
    final warningBg = isDark ? MFTokens.warningBgDark : MFTokens.warningBg;
    final cardBg = isDark ? MFTokens.cardDark : MFTokens.cardLight;
    final border = isDark ? MFTokens.borderDark : MFTokens.borderLight;

    final ratio = totalPurchases > 0 ? (totalPaid / totalPurchases * 100) : 0.0;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: MFTokens.sp16),
      padding: const EdgeInsets.all(MFTokens.sp16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(MFTokens.radiusLG),
        boxShadow: MFTokens.shadowSM,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppStrings.customerTotalPurchases,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: MFTokens.fontSM,
                  color: textSecondary,
                ),
              ),
            ],
          ),
          SizedBox(height: MFTokens.sp2),
          _amountRow(primary, textSecondary),
          SizedBox(height: MFTokens.sp12),
          _ratioRow(ratio, textSecondary, primary),
          SizedBox(height: MFTokens.sp6),
          _progressBar(ratio, border, primary),
          SizedBox(height: MFTokens.sp12),
          _statBoxes(primary, primarySubtle, accent, warningBg, textSecondary),
        ],
      ),
    );
  }

  Widget _amountRow(Color primary, Color textSecondary) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          AppStrings.currencyEg,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: MFTokens.fontSM,
            color: textSecondary,
          ),
        ),
        SizedBox(width: MFTokens.sp4),
        Text(
          totalPurchases == 0 && totalPurchases.truncateToDouble() == 0
              ? '0'
              : totalPurchases.toInt().toString(),
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: MFTokens.font3XL,
            color: primary,
          ),
        ),
      ],
    );
  }

  Widget _ratioRow(double ratio, Color textSecondary, Color primary) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          AppStrings.customerPaymentRatio,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: MFTokens.fontSM,
            color: textSecondary,
          ),
        ),
        Text(
          '${ratio.toInt()}${AppStrings.customerPaidPercent}',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: MFTokens.fontSM,
            color: primary,
          ),
        ),
      ],
    );
  }

  Widget _progressBar(double ratio, Color border, Color primary) {
    return Container(
      width: double.infinity,
      height: MFTokens.sp10,
      decoration: BoxDecoration(
        color: border,
        borderRadius: BorderRadius.circular(MFTokens.radiusXL),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerRight,
        widthFactor: ratio.clamp(0, 100) / 100,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(MFTokens.radiusXL),
            gradient: const LinearGradient(
              colors: [MFTokens.primary, MFTokens.successText],
            ),
          ),
        ),
      ),
    );
  }

  Widget _statBoxes(Color primary, Color primarySubtle, Color accent, Color warningBg, Color textSecondary) {
    return Row(
      children: [
        _statBox(
          AppStrings.customerPaidLabel,
          totalPaid,
          primarySubtle,
          primary,
          textSecondary,
        ),
        SizedBox(width: MFTokens.sp8),
        _statBox(
          AppStrings.customerRemainingLabel,
          totalDebt,
          warningBg,
          accent,
          textSecondary,
        ),
      ],
    );
  }

  Widget _statBox(String label, double amount, Color bg, Color amountColor, Color textSecondary) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(MFTokens.sp10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(MFTokens.radiusMD),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: MFTokens.fontXS,
                color: textSecondary,
              ),
            ),
            SizedBox(height: MFTokens.sp2),
            Row(
              children: [
                Text(
                  amount == 0 && amount.truncateToDouble() == 0
                      ? '0'
                      : amount.toInt().toString(),
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: MFTokens.fontLG,
                    fontWeight: FontWeight.w600,
                    color: amountColor,
                  ),
                ),
                SizedBox(width: MFTokens.sp2),
                Text(
                  AppStrings.currencyEg,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: MFTokens.fontSM,
                    color: textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
