import 'package:flutter/material.dart';
import 'package:makhzanflow/core/theme/mf_tokens.dart';
import 'package:makhzanflow/core/widgets/app_network_image.dart';
import 'package:makhzanflow/features/companies/domain/entities/company.dart';

/// A selectable company card used inside the company-switcher bottom sheet.
///
/// Shows an avatar (initials or logo), the company name, business type,
/// and a trailing check/chevron icon.
class CompanyCard extends StatelessWidget {
  final Company company;
  final bool isSelected;
  final VoidCallback onTap;

  const CompanyCard({
    super.key,
    required this.company,
    required this.isSelected,
    required this.onTap,
  });

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}';
    }
    return name.isNotEmpty ? name[0] : '?';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isSelected
        ? MFTokens.primary.withValues(alpha: 0.19)
        : (isDark ? MFTokens.borderDark : MFTokens.surfaceMutedLight);
    final textPrimary = isDark ? MFTokens.textPrimaryDark : MFTokens.textPrimaryLight;
    final textSecondary = isDark ? MFTokens.textSecondaryDark : MFTokens.textSecondaryLight;
    final cardBg = isDark
        ? (isSelected ? MFTokens.primaryDarkModeSubtle : MFTokens.surfaceDark)
        : (isSelected ? MFTokens.primarySubtle : MFTokens.surfaceMutedLight);
    final selectedBg = isDark ? MFTokens.primaryDarkMode : MFTokens.primary;
    final avatarBg = isSelected ? selectedBg : (isDark ? MFTokens.surfaceMutedDark : MFTokens.surfaceMutedLight);
    final initialsColor = isSelected ? Colors.white : const Color(0xFF404040);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(MFTokens.sp12),
        decoration: BoxDecoration(
          color: cardBg,
          border: Border(
            top: BorderSide(color: borderColor, width: 0.8),
            bottom: BorderSide(color: borderColor, width: 0.8),
            left: BorderSide(color: borderColor, width: 0.8),
            right: isSelected
                ? BorderSide(color: borderColor, width: 2.4)
                : BorderSide.none,
          ),
          borderRadius: BorderRadius.circular(MFTokens.radiusLG),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: avatarBg,
                shape: BoxShape.circle,
              ),
              child: company.logoUrl != null && company.logoUrl!.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(44),
                      child: AppNetworkImage(
                        imageUrl: company.logoUrl!,
                        width: 44,
                        height: 44,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Center(
                      child: Text(
                        _initials(company.name),
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: MFTokens.fontBase,
                          color: initialsColor,
                        ),
                      ),
                    ),
            ),
            const SizedBox(width: MFTokens.sp12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    company.name,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: MFTokens.fontBase,
                      fontWeight: FontWeight.w400,
                      color: textPrimary,
                    ),
                  ),
                  if (company.businessType != null)
                    Text(
                      company.businessType!,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: MFTokens.fontXS,
                        color: textSecondary,
                      ),
                    ),
                ],
              ),
            ),
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: isSelected ? selectedBg : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : Icon(Icons.chevron_left, size: 16, color: isDark ? MFTokens.textMutedDark : MFTokens.textMutedLight),
            ),
          ],
        ),
      ),
    );
  }
}
