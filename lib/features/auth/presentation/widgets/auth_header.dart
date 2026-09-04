import 'package:flutter/material.dart';
import '../../../../core/theme/mf_tokens.dart';

class AuthHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const AuthHeader({super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? MFTokens.textPrimaryDark : MFTokens.textPrimaryLight;
    final textSecondary = isDark ? MFTokens.textSecondaryDark : MFTokens.textSecondaryLight;

    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: isDark ? MFTokens.surfaceDark : MFTokens.surfaceLight,
            borderRadius: BorderRadius.circular(MFTokens.radiusLG),
          ),
          child: Image.asset(
            'assets/images/logo.png',
            height: 60,
            width: 60,
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(height: MFTokens.sp16),
        Text(
          title,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: MFTokens.font2XL,
            color: textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: MFTokens.sp4),
        Text(
          subtitle,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: MFTokens.fontSM,
            color: textSecondary,
          ),
        ),
      ],
    );
  }
}
