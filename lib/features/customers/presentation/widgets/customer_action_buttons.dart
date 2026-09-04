import 'package:flutter/material.dart';
import '../../../../core/theme/mf_tokens.dart';
import '../../../../core/constants/app_strings.dart';

class CustomerActionButtons extends StatelessWidget {
  final VoidCallback? onNewInvoice;
  final VoidCallback? onRecordPayment;

  const CustomerActionButtons({super.key, this.onNewInvoice, this.onRecordPayment});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryDark = isDark ? MFTokens.primaryDarkMode : MFTokens.primaryDark;
    final accent = isDark ? MFTokens.primaryDarkMode : MFTokens.accent;
    final border = isDark ? MFTokens.borderDark : MFTokens.borderLight;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: onNewInvoice,
              icon: Icon(Icons.add, size: 15, color: primaryDark),
              label: Text(AppStrings.customerNewInvoice, style: TextStyle(fontFamily: 'Cairo', fontSize: MFTokens.fontSM, fontWeight: FontWeight.w500, color: primaryDark)),
              style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12), side: BorderSide(color: border), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(MFTokens.radiusMD))),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: onRecordPayment,
              icon: const Icon(Icons.add, size: 15, color: Colors.white),
              label: Text(AppStrings.customerRecordPayment, style: const TextStyle(fontFamily: 'Cairo', fontSize: MFTokens.fontSM, fontWeight: FontWeight.w500, color: Colors.white)),
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12), backgroundColor: accent, foregroundColor: Colors.white, elevation: 8, shadowColor: accent.withValues(alpha: 0.35), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(MFTokens.radiusMD))),
            ),
          ),
        ],
      ),
    );
  }
}
