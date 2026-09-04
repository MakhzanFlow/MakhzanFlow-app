import 'package:flutter/material.dart';
import '../../../../core/theme/mf_tokens.dart';

class CustomerActionButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isPrimary;
  final bool isLoading;

  const CustomerActionButton({super.key, required this.text, this.onPressed, this.isPrimary = true, this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = isDark ? MFTokens.primaryDarkMode : MFTokens.primary;
    final border = isDark ? MFTokens.borderDark : MFTokens.borderLight;
    final textSecondary = isDark ? MFTokens.textSecondaryDark : MFTokens.textSecondaryLight;

    if (isPrimary) {
      return SizedBox(
        width: 120, height: 50,
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(backgroundColor: primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(MFTokens.radiusMD))),
          child: isLoading
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : Text(text, style: const TextStyle(fontFamily: 'Cairo', fontSize: MFTokens.fontMD, fontWeight: FontWeight.w600)),
        ),
      );
    }

    return SizedBox(
      width: 120, height: 50,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(foregroundColor: textSecondary, side: BorderSide(color: border), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(MFTokens.radiusMD))),
        child: Text(text, style: const TextStyle(fontFamily: 'Cairo', fontSize: MFTokens.fontMD, fontWeight: FontWeight.w600)),
      ),
    );
  }
}
