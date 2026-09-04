import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/mf_tokens.dart';
import '../../../../core/constants/app_strings.dart';
import '../../domain/entities/customer.dart';

class CustomerCard extends StatelessWidget {
  final Customer customer;
  final VoidCallback? onTap;

  const CustomerCard({super.key, required this.customer, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? MFTokens.cardDark : MFTokens.cardLight;
    final textPrimary = isDark ? MFTokens.textPrimaryDark : MFTokens.textPrimaryLight;
    final textSecondary = isDark ? MFTokens.textSecondaryDark : MFTokens.textSecondaryLight;
    final primary = isDark ? MFTokens.primaryDarkMode : MFTokens.primary;
    final primarySubtle = isDark ? MFTokens.primaryDarkModeSubtle : MFTokens.primarySubtle;
    final accent = isDark ? MFTokens.primaryDarkMode : MFTokens.accent;
    final chipBg = isDark ? MFTokens.surfaceMutedDark : MFTokens.surfaceMutedLight;
    final warningBg = isDark ? MFTokens.warningBgDark : MFTokens.warningBg;
    final labelSecondary = const Color(0xFF525252);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(MFTokens.radiusLG),
          boxShadow: MFTokens.shadowSM,
        ),
        child: Padding(
          padding: const EdgeInsets.all(MFTokens.sp16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopRow(textPrimary, textSecondary, primarySubtle, primary),
              const SizedBox(height: MFTokens.sp8),
              _buildStatBoxes(primary, primarySubtle, accent, warningBg, chipBg, labelSecondary, textSecondary),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopRow(Color textPrimary, Color textSecondary, Color primarySubtle, Color primary) {
    return Row(
      textDirection: TextDirection.rtl,
      children: [
        _buildAvatar(primarySubtle, primary),
        const SizedBox(width: MFTokens.sp8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(customer.name, style: TextStyle(fontFamily: 'Cairo', fontSize: MFTokens.fontLG, fontWeight: FontWeight.w600, color: textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
              if (customer.address != null && customer.address!.isNotEmpty)
                Padding(padding: const EdgeInsets.only(top: 2), child: Text(customer.address!, style: TextStyle(fontFamily: 'Cairo', fontSize: MFTokens.fontXS, color: textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatBoxes(Color primary, Color primarySubtle, Color accent, Color warningBg, Color chipBg, Color labelSecondary, Color textSecondary) {
    final remaining = customer.totalDebt;
    final remainingColor = remaining > 0 ? accent : textSecondary;
    return Row(
      textDirection: TextDirection.rtl,
      children: [
        Expanded(child: _StatBox(label: AppStrings.customerTotalPurchases, amount: customer.totalPurchases, amountColor: primary, bgColor: chipBg, labelColor: labelSecondary, currencyColor: textSecondary)),
        const SizedBox(width: MFTokens.sp8),
        Expanded(child: _StatBox(label: AppStrings.customerPaidLabel, amount: customer.totalPaid, amountColor: primary, bgColor: primarySubtle, labelColor: labelSecondary, currencyColor: textSecondary)),
        const SizedBox(width: MFTokens.sp8),
        Expanded(child: _StatBox(label: AppStrings.customerRemainingLabel, amount: remaining, amountColor: remainingColor, bgColor: warningBg, labelColor: labelSecondary, currencyColor: textSecondary)),
      ],
    );
  }

  Widget _buildAvatar(Color bg, Color primary) {
    if (customer.imageUrl != null && customer.imageUrl!.isNotEmpty) {
      return ClipRRect(borderRadius: BorderRadius.circular(MFTokens.radiusMD), child: CachedNetworkImage(imageUrl: customer.imageUrl!, width: 44, height: 44, fit: BoxFit.cover, placeholder: (_, __) => _buildPlaceholder(bg, primary), errorWidget: (_, __, ___) => _buildPlaceholder(bg, primary)));
    }
    return _buildPlaceholder(bg, primary);
  }

  Widget _buildPlaceholder(Color bg, Color primary) {
    return Container(width: 44, height: 44, decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(MFTokens.radiusMD)), child: Icon(Icons.store_outlined, size: 20, color: primary));
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final double amount;
  final Color amountColor;
  final Color bgColor;
  final Color labelColor;
  final Color currencyColor;

  const _StatBox({required this.label, required this.amount, required this.amountColor, required this.bgColor, required this.labelColor, required this.currencyColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(MFTokens.sp8),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(MFTokens.radiusMD)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontFamily: 'Cairo', fontSize: MFTokens.fontXS, color: labelColor)),
          const SizedBox(height: 2),
          Row(children: [
            Text(amount == 0 && amount.truncateToDouble() == 0 ? '0' : amount.toInt().toString(), style: TextStyle(fontFamily: 'Cairo', fontSize: MFTokens.fontLG, fontWeight: FontWeight.w600, color: amountColor)),
            const SizedBox(width: 2),
            Text(AppStrings.currencyEg, style: TextStyle(fontFamily: 'Cairo', fontSize: MFTokens.fontXS, color: currencyColor)),
          ]),
        ],
      ),
    );
  }
}
