import 'package:flutter/material.dart';
import 'package:makhzanflow/core/theme/mf_tokens.dart';

/// Calm SaaS table — used for invoices / recent activity.
/// Token-only, ForUI-inspired (FTable equivalent).
class MFTable extends StatelessWidget {
  const MFTable({
    super.key,
    required this.headers,
    required this.rows,
    this.emptyLabel = 'لا توجد بيانات',
  });

  final List<String> headers;
  final List<List<String>> rows;
  final String emptyLabel;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? MFTokens.cardDark : MFTokens.cardLight;
    final border = isDark ? MFTokens.borderDark : MFTokens.borderLight;
    final textPrimary = isDark ? MFTokens.textPrimaryDark : MFTokens.textPrimaryLight;
    final textSecondary = isDark ? MFTokens.textSecondaryDark : MFTokens.textSecondaryLight;

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(MFTokens.radiusLG),
        border: Border.all(color: border),
        boxShadow: MFTokens.shadowSM,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: MFTokens.sp16, vertical: MFTokens.sp12),
            decoration: BoxDecoration(
              color: isDark ? MFTokens.surfaceMutedDark : MFTokens.surfaceMutedLight,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(MFTokens.radiusLG)),
              border: Border(bottom: BorderSide(color: border)),
            ),
            child: Row(
              children: headers
                  .map((h) => Expanded(
                        child: Text(h,
                            style: TextStyle(
                                color: textSecondary,
                                fontSize: MFTokens.fontXS,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Cairo')),
                      ))
                  .toList(),
            ),
          ),
          if (rows.isEmpty)
            Padding(
              padding: const EdgeInsets.all(MFTokens.sp24),
              child: Center(
                child: Text(emptyLabel,
                    style: TextStyle(color: textSecondary, fontSize: MFTokens.fontSM, fontFamily: 'Cairo')),
              ),
            )
          else
            ...rows.map((row) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: MFTokens.sp16, vertical: MFTokens.sp12),
                  decoration: BoxDecoration(border: Border(bottom: BorderSide(color: border, width: 0.5))),
                  child: Row(
                    children: row
                        .map((cell) => Expanded(
                              child: Text(cell,
                                  style: TextStyle(
                                      color: textPrimary,
                                      fontSize: MFTokens.fontSM,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: 'Cairo'),
                                  overflow: TextOverflow.ellipsis),
                            ))
                        .toList(),
                  ),
                )),
        ],
      ),
    );
  }
}

/// Invoice row — extracted for dashboard reuse, token-only.
class MFInvoiceRow extends StatelessWidget {
  const MFInvoiceRow({
    super.key,
    required this.invoiceNumber,
    required this.customerName,
    required this.amount,
  });

  final String invoiceNumber;
  final String customerName;
  final String amount;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = isDark ? MFTokens.primaryDarkMode : MFTokens.primary;
    final textPrimary = isDark ? MFTokens.textPrimaryDark : MFTokens.textPrimaryLight;
    final border = isDark ? MFTokens.borderDark : MFTokens.borderLight;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: MFTokens.sp16, vertical: MFTokens.sp12),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: border, width: 0.5))),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: MFTokens.sp8, vertical: MFTokens.sp4),
            decoration: BoxDecoration(
                color: primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(MFTokens.radiusXS)),
            child: Text(invoiceNumber,
                style: TextStyle(color: primary, fontSize: MFTokens.fontXS, fontWeight: FontWeight.w700, fontFamily: 'Cairo')),
          ),
          const SizedBox(width: MFTokens.sp10),
          Expanded(
            child: Text(customerName,
                style:
                    TextStyle(color: textPrimary, fontSize: MFTokens.fontBase, fontWeight: FontWeight.w500, fontFamily: 'Cairo'),
                overflow: TextOverflow.ellipsis),
          ),
          Text(amount,
              style: TextStyle(color: textPrimary, fontSize: MFTokens.fontBase, fontWeight: FontWeight.w700, fontFamily: 'Cairo')),
        ],
      ),
    );
  }
}
