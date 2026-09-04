import 'package:flutter/material.dart';
import 'package:makhzanflow/core/theme/mf_tokens.dart';

/// ForUI-style segmented tabs — quiet SaaS, token-only, no hardcode.
/// Used for dashboard chart filters (Today/Week/Month) and invoice filters.
class MFTabs extends StatelessWidget {
  const MFTabs({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mutedBg = isDark ? MFTokens.borderDark : MFTokens.surfaceMutedLight;
    final textSecondary = isDark ? MFTokens.textSecondaryDark : MFTokens.textSecondaryLight;

    return Container(
      decoration: BoxDecoration(
        color: mutedBg,
        borderRadius: BorderRadius.circular(MFTokens.radiusSM),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(labels.length, (i) {
          final selected = i == selectedIndex;
          return GestureDetector(
            onTap: () => onSelected(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: MFTokens.sp10, vertical: MFTokens.sp6),
              decoration: BoxDecoration(
                color: selected ? (isDark ? MFTokens.primaryDarkMode : MFTokens.primary) : Colors.transparent,
                borderRadius: BorderRadius.circular(MFTokens.radiusSM),
              ),
              child: Text(
                labels[i],
                style: TextStyle(
                  color: selected ? MFTokens.textInverseLight : textSecondary,
                  fontSize: MFTokens.fontXS,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  fontFamily: 'Cairo',
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
