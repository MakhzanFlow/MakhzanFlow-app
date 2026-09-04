import 'package:flutter/material.dart';
import '../../core/theme/mf_tokens.dart';

class MakhzanFlowEmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const MakhzanFlowEmptyState({
    super.key,
    required this.icon,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textSecondary = isDark ? MFTokens.textSecondaryDark : MFTokens.textSecondaryLight;
    final muted = isDark ? MFTokens.textMutedDark : MFTokens.textMutedLight;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(MFTokens.sp24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: muted),
            const SizedBox(height: MFTokens.sp16),
            Text(
              message,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: MFTokens.fontMD,
                color: textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: MFTokens.sp16),
              ElevatedButton(
                onPressed: onAction,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
