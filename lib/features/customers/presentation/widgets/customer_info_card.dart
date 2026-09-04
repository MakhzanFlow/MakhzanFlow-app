import 'package:flutter/material.dart';
import '../../../../core/theme/mf_tokens.dart';
import '../../../../core/constants/app_strings.dart';
import '../../domain/entities/customer.dart';
import 'customer_debt_badge.dart';

class CustomerInfoCard extends StatelessWidget {
  final Customer customer;

  const CustomerInfoCard({
    super.key,
    required this.customer,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? MFTokens.textPrimaryDark : MFTokens.textPrimaryLight;
    final textSecondary = isDark ? MFTokens.textSecondaryDark : MFTokens.textSecondaryLight;
    final primary = isDark ? MFTokens.primaryDarkMode : MFTokens.primary;
    final cardBg = isDark ? MFTokens.cardDark : MFTokens.cardLight;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(MFTokens.sp16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(MFTokens.radiusMD),
        boxShadow: MFTokens.shadowSM,
      ),
      child: Column(
        children: [
          CustomerDebtBadge(debt: customer.totalDebt),
          SizedBox(height: MFTokens.sp16),
          const Divider(),
          _buildInfoRow(
            AppStrings.customerPhoneLabel,
            customer.phone,
            Icons.phone_outlined,
            primary: primary,
            textSecondary: textSecondary,
            textPrimary: textPrimary,
          ),
          _buildInfoRow(
            AppStrings.customerAddressLabel,
            customer.address,
            Icons.location_on_outlined,
            primary: primary,
            textSecondary: textSecondary,
            textPrimary: textPrimary,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String? value, IconData icon,
      {required Color primary, required Color textSecondary, required Color textPrimary}) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: EdgeInsets.only(bottom: MFTokens.sp16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: MFTokens.sp24, color: primary),
          SizedBox(width: MFTokens.sp8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: MFTokens.fontSM,
                    color: textSecondary,
                  ),
                ),
                SizedBox(height: MFTokens.sp2),
                Text(
                  value,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: MFTokens.fontMD,
                    color: textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
