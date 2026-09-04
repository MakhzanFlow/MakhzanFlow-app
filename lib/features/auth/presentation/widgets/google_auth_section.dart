import 'package:flutter/material.dart';
import '../../../../core/theme/mf_tokens.dart';
import '../../../../core/constants/app_strings.dart';
import 'google_sign_in_button.dart';

class GoogleAuthSection extends StatelessWidget {
  final String label;
  final bool isLoading;
  final VoidCallback? onPressed;

  const GoogleAuthSection({
    super.key,
    required this.label,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final muted = isDark ? MFTokens.textMutedDark : MFTokens.textMutedLight;

    return Column(
      children: [
        Row(
          children: [
            Expanded(child: Divider(color: isDark ? MFTokens.borderDark : MFTokens.borderLight)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: MFTokens.sp8),
              child: Text(
                AppStrings.orContinueWith,
                style: TextStyle(
                  color: muted,
                  fontSize: MFTokens.fontSM,
                  fontFamily: 'Cairo',
                ),
              ),
            ),
            Expanded(child: Divider(color: isDark ? MFTokens.borderDark : MFTokens.borderLight)),
          ],
        ),
        SizedBox(height: MFTokens.sp24),
        GoogleSignInButton(
          label: label,
          isLoading: isLoading,
          onPressed: onPressed,
        ),
      ],
    );
  }
}
