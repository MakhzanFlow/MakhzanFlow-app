import 'package:flutter/material.dart';
import '../../../../core/theme/mf_tokens.dart';
import '../../../../core/constants/app_strings.dart';

class FilterOption {
  final String key;
  final String label;
  final int count;
  const FilterOption({required this.key, required this.label, required this.count});
}

class CustomerFilterChips extends StatelessWidget {
  final String selectedFilter;
  final ValueChanged<String> onFilterChanged;
  final int totalCount;
  final int paidCount;
  final int partialCount;
  final int deferredCount;

  const CustomerFilterChips({super.key, required this.selectedFilter, required this.onFilterChanged, required this.totalCount, required this.paidCount, required this.partialCount, required this.deferredCount});

  List<FilterOption> get _options => [
    FilterOption(key: 'all', label: AppStrings.customerAllFilter, count: totalCount),
    FilterOption(key: 'paid', label: AppStrings.customerPaidFilter, count: paidCount),
    FilterOption(key: 'partial', label: AppStrings.customerPartialFilter, count: partialCount),
    FilterOption(key: 'deferred', label: AppStrings.customerDeferredFilter, count: deferredCount),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: MFTokens.sp16, vertical: MFTokens.sp8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Row(
            children: _options.map((opt) {
              final isSelected = opt.key == selectedFilter;
              return Padding(
                padding: const EdgeInsets.only(left: 8),
                child: _FilterChipItem(option: opt, isSelected: isSelected, onTap: () => onFilterChanged(opt.key)),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _FilterChipItem extends StatelessWidget {
  final FilterOption option;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChipItem({required this.option, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = isDark ? MFTokens.primaryDarkMode : MFTokens.primary;
    final chipBg = isDark ? MFTokens.surfaceMutedDark : MFTokens.surfaceMutedLight;
    final textSecondary = isDark ? MFTokens.textSecondaryDark : MFTokens.textSecondaryLight;
    final border = isDark ? MFTokens.borderDark : MFTokens.borderLight;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: MFTokens.sp16, vertical: MFTokens.sp8),
        decoration: BoxDecoration(
          color: isSelected ? primary : chipBg,
          borderRadius: BorderRadius.circular(MFTokens.radiusXL),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(option.label, style: TextStyle(fontFamily: 'Cairo', fontSize: MFTokens.fontMD, fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal, color: isSelected ? Colors.white : textSecondary)),
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white.withValues(alpha: 0.2) : border,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(option.count.toString(), style: TextStyle(fontFamily: 'Cairo', fontSize: MFTokens.fontXS, fontWeight: FontWeight.w600, color: isSelected ? Colors.white : textSecondary)),
            ),
          ],
        ),
      ),
    );
  }
}
