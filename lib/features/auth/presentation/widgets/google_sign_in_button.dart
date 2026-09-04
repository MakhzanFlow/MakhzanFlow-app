import 'package:flutter/material.dart';
import '../../../../core/theme/mf_tokens.dart';
import '../../../../core/constants/app_strings.dart';

class GoogleSignInButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final VoidCallback? onPressed;

  const GoogleSignInButton({
    super.key,
    required this.label,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? MFTokens.textPrimaryDark : MFTokens.textPrimaryLight;

    return SizedBox(
      width: double.infinity,
      height: MFTokens.buttonHeightMD,
      child: OutlinedButton.icon(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: isDark ? MFTokens.surfaceDark : MFTokens.surfaceLight,
          foregroundColor: textPrimary,
          side: BorderSide(color: isDark ? MFTokens.borderDark : MFTokens.borderLight),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(MFTokens.radiusMD),
          ),
        ),
        icon: isLoading
            ? SizedBox(
                width: MFTokens.sp24,
                height: MFTokens.sp24,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  color: MFTokens.textSecondaryLight,
                ),
              )
            : _GoogleG(),
        label: Text(
          label,
          style: const TextStyle(
            fontSize: MFTokens.fontMD,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _GoogleG extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MFTokens.sp24,
      height: MFTokens.sp24,
      alignment: Alignment.center,
      child: Text(
        AppStrings.googleLogoLetter,
        style: const TextStyle(
          fontSize: MFTokens.fontLG,
          fontWeight: FontWeight.bold,
          color: Color(0xFF4285F4),
          letterSpacing: 0,
        ),
      ),
    );
  }
}
