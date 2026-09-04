import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:makhzanflow/features/customers/domain/entities/customer_transaction.dart';
import '../../../../core/theme/mf_tokens.dart';
import '../../../../core/constants/app_strings.dart';

String _arNum(num n) {
  final fmt = NumberFormat.decimalPattern('ar');
  return fmt.format(n);
}

class CustomerTransactionList extends StatelessWidget {
  final int selectedTab;
  final List<CustomerTransaction> transactions;
  final VoidCallback? onViewAll;
  final ValueChanged<String>? onInvoiceTap;

  const CustomerTransactionList({
    super.key,
    this.selectedTab = 0,
    this.transactions = const [],
    this.onViewAll,
    this.onInvoiceTap,
  });

  List<CustomerTransaction> get _filteredTransactions {
    if (selectedTab == 0) return transactions;
    if (selectedTab == 1) {
      return transactions.where((t) => t.type == 'invoice').toList();
    }
    return transactions.where((t) => t.type == 'payment').toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? MFTokens.textPrimaryDark : MFTokens.textPrimaryLight;
    final textSecondary = isDark ? MFTokens.textSecondaryDark : MFTokens.textSecondaryLight;
    final textMuted = isDark ? MFTokens.textMutedDark : MFTokens.textMutedLight;
    final primary = isDark ? MFTokens.primaryDarkMode : MFTokens.primary;
    final accent = isDark ? MFTokens.primaryDarkMode : MFTokens.accent;
    final primarySubtle = isDark ? MFTokens.primaryDarkModeSubtle : MFTokens.primarySubtle;
    final warningBg = isDark ? MFTokens.warningBgDark : MFTokens.warningBg;
    final errorBg = isDark ? MFTokens.errorBgDark : MFTokens.errorBg;
    final errorColor = isDark ? MFTokens.errorTextDark : MFTokens.errorText;
    final successBg = isDark ? MFTokens.successBgDark : MFTokens.successBg;
    final cardBg = isDark ? MFTokens.cardDark : MFTokens.cardLight;
    final border = isDark ? MFTokens.borderDark : MFTokens.borderLight;

    final items = _filteredTransactions;
    if (items.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: MFTokens.sp24),
        child: Center(
          child: Text(
            AppStrings.emptyInvoices,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: MFTokens.fontMD,
              color: textSecondary,
            ),
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: MFTokens.sp16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(MFTokens.radiusLG),
        boxShadow: MFTokens.shadowSM,
      ),
      child: Column(children: [_header(isDark, accent, textSecondary, textPrimary, border), ...items.map((t) => _transactionItem(t, isDark, primarySubtle, primary, accent, warningBg, errorBg, errorColor, successBg, textSecondary, textPrimary, textMuted, border))]),
    );
  }

  Widget _header(bool isDark, Color accent, Color textSecondary, Color textPrimary, Color border) {
    return Container(
      padding: const EdgeInsets.fromLTRB(MFTokens.sp16, MFTokens.sp12, MFTokens.sp16, MFTokens.sp8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: border, width: 0.8),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: onViewAll,
            child: Text(
              AppStrings.customerViewAll,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: MFTokens.fontSM,
                color: accent,
              ),
            ),
          ),
          Text(
            AppStrings.customerTransactionLog,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: MFTokens.fontMD,
              color: textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _transactionItem(CustomerTransaction data, bool isDark, Color primarySubtle, Color primary, Color accent, Color warningBg, Color errorBg, Color errorColor, Color successBg, Color textSecondary, Color textPrimary, Color textMuted, Color border) {
    final isInvoice = data.type == 'invoice';
    final isLast = _filteredTransactions.last == data;

    final icon = data.type == 'payment' ? Icons.receipt_long : Icons.receipt;
    final iconBg = data.type == 'payment' ? warningBg : primarySubtle;
    final iconColor = data.type == 'payment' ? accent : primary;
    final amountColor = data.type == 'payment' ? primary : textPrimary;

    return GestureDetector(
      onTap: isInvoice ? () => onInvoiceTap?.call(data.id) : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: MFTokens.sp16, vertical: MFTokens.sp12),
        decoration: BoxDecoration(
          border: isLast
              ? null
              : Border(
                  bottom: BorderSide(color: border, width: 0.8),
                ),
        ),
        child: Row(
          children: [
            Container(
              width: MFTokens.sp40,
              height: MFTokens.sp40,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(MFTokens.radiusMD),
              ),
              child: Icon(icon, size: MFTokens.sp16, color: iconColor),
            ),
            SizedBox(width: MFTokens.sp12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          data.title,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: MFTokens.fontMD,
                            color: textPrimary,
                          ),
                        ),
                      ),
                      SizedBox(width: MFTokens.sp8),
                      _statusChip(data.statusLabel, isDark, primarySubtle, primary, warningBg, accent, errorBg, errorColor, successBg),
                    ],
                  ),
                  SizedBox(height: MFTokens.sp2),
                  Text(
                    data.subtitle,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: MFTokens.fontSM,
                      color: textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: MFTokens.sp12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _arNum(data.amount),
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: MFTokens.fontBase,
                    color: amountColor,
                  ),
                ),
                Text(
                  AppStrings.currencyEg,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: MFTokens.fontXS,
                    color: textMuted,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusChip(String label, bool isDark, Color primarySubtle, Color primary, Color warningBg, Color accent, Color errorBg, Color errorColor, Color successBg) {
    final isRed = label == 'آجل' || label == 'معلق';
    final isGreen = label == 'مدفوع' || label == 'مستلم';
    final textColor = isRed
        ? errorColor
        : (isGreen ? primary : accent);
    final bgColor = isRed
        ? errorBg
        : (isGreen ? successBg : warningBg);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: MFTokens.sp8,
        vertical: MFTokens.sp2,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(MFTokens.radiusXL),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Cairo',
          fontSize: MFTokens.fontSM,
          color: textColor,
        ),
      ),
    );
  }
}
