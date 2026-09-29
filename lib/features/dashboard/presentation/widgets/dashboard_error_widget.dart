import 'package:flutter/material.dart';
import 'package:makhzanflow/core/constants/app_strings.dart';
import 'package:makhzanflow/core/theme/mf_tokens.dart';
import 'package:makhzanflow/shared/widgets/mf_button.dart';

/// Full-screen error state for the dashboard with a retry action.
///
/// ui-skills: token-only surfaces, 4-level type hierarchy (title 18/bold →
/// message 14/secondary), one accent (retry button), 64px status medallion,
/// 44px+ hit area via [MFButton].
class DashboardErrorWidget extends StatelessWidget {
  const DashboardErrorWidget({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary =
        isDark ? MFTokens.textPrimaryDark : MFTokens.textPrimaryLight;
    final textSecondary =
        isDark ? MFTokens.textSecondaryDark : MFTokens.textSecondaryLight;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: MFTokens.contentPaddingTablet,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Status medallion — 64px circle, semantic error tint
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: isDark ? MFTokens.errorBgDark : MFTokens.errorBg,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.wifi_off_rounded,
                size: 28,
                color: isDark
                    ? MFTokens.errorTextDark
                    : MFTokens.errorText,
              ),
            ),
            const SizedBox(height: MFTokens.sp16),
            Text(
              AppStrings.dashboardErrorTitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: MFTokens.fontXL,
                fontWeight: FontWeight.w700,
                color: textPrimary,
              ),
            ),
            const SizedBox(height: MFTokens.sp8),
            Text(
              message,
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: MFTokens.fontMD,
                color: textSecondary,
                height: MFTokens.lineHeightRelaxed,
              ),
            ),
            const SizedBox(height: MFTokens.sp24),
            MFButton(
              label: AppStrings.retry,
              icon: Icons.refresh_rounded,
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}
