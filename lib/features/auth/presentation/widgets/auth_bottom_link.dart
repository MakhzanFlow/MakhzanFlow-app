import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/mf_tokens.dart';

class AuthBottomLink extends StatelessWidget {
  final String label;
  final String actionLabel;
  final String route;

  const AuthBottomLink({
    super.key,
    required this.label,
    required this.actionLabel,
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textSecondary = isDark ? MFTokens.textSecondaryDark : MFTokens.textSecondaryLight;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: MFTokens.fontSM,
            color: textSecondary,
          ),
        ),
        GestureDetector(
          onTap: () => context.go(route),
          child: Text(
            actionLabel,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: MFTokens.fontSM,
              color: isDark ? MFTokens.primaryDarkMode : MFTokens.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
