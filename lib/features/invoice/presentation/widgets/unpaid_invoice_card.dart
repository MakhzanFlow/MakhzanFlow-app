import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:makhzanflow/core/constants/app_colors.dart';
import 'package:makhzanflow/core/constants/app_sizes.dart';
import 'package:makhzanflow/core/constants/app_strings.dart';
import 'package:makhzanflow/core/constants/error_messages.dart';
import 'package:makhzanflow/features/invoice/domain/entities/invoice.dart';
import 'package:makhzanflow/features/invoice/domain/entities/invoice_status.dart';

class UnpaidInvoiceCard extends StatelessWidget {
  final Invoice invoice;
  final bool isSelected;
  final VoidCallback onTap;

  const UnpaidInvoiceCard({
    super.key,
    required this.invoice,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('d MMMM yyyy', 'ar');
    final dateStr = invoice.createdAt != null
        ? dateFormat.format(invoice.createdAt!.toLocal())
        : '';
    final productCount = invoice.items.length;

    final (
      statusLabel,
      statusColor,
      statusBg,
    ) = switch (invoice.paymentStatus) {
      InvoiceStatus.partial => (
        AppStrings.addPaymentStatusPartial,
        AppColors.accent,
        AppColors.lightOrange,
      ),
      InvoiceStatus.paid => (
        AppStrings.customerPaidFilter,
        AppColors.trendUp,
        AppColors.lightGreen,
      ),
      InvoiceStatus.canceled => (
        ErrorMessages.invoiceCanceled,
        AppColors.textSecondary,
        AppColors.searchBg,
      ),
      _ => (
        AppStrings.addPaymentStatusDebt,
        AppColors.redDark,
        AppColors.lightRed,
      ),
    };

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(AppSizes.spacingMedium),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.inputBorder,
            width: isSelected ? 0.8 : 0.8,
          ),
          borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
          boxShadow: [
            BoxShadow(
              color: AppColors.secondary.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 20,
                  height: 20,
                  margin: EdgeInsets.only(top: 2),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.inputBackground,
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.inputBorder,
                      width: 0.8,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: isSelected
                      ? Icon(Icons.check, size: 12, color: AppColors.white)
                      : null,
                ),
                SizedBox(width: AppSizes.spacingMedium),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${AppStrings.addPaymentInvoicePrefix}${invoice.id.substring(0, 4).toUpperCase()}',
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontWeight: FontWeight.w500,
                                  fontSize: AppSizes.fontXLarge - 3,
                                  color: AppColors.secondary,
                                ),
                              ),
                              SizedBox(width: AppSizes.spacingSmall),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: AppSizes.spacingSmall,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: statusBg,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  statusLabel,
                                  style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: AppSizes.fontSmall,
                                    color: statusColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                invoice.remainingAmount.toInt().toString(),
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontWeight: FontWeight.w700,
                                  fontSize: AppSizes.fontXLarge - 3,
                                  color: AppColors.secondary,
                                ),
                              ),
                              SizedBox(width: 2),
                              Text(
                                'ج.م',
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontWeight: FontWeight.w700,
                                  fontSize: AppSizes.fontSmall,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: AppSizes.spacingTiny),
                      Row(
                        children: [
                          Icon(
                            Icons.inventory_2_outlined,
                            size: 12,
                            color: AppColors.textSecondary,
                          ),
                          SizedBox(width: AppSizes.spacingTiny),
                          Text(
                            '$productCount منتجات',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: AppSizes.fontSmall,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          SizedBox(width: AppSizes.spacingSmall),
                          Text(
                            '•',
                            style: TextStyle(
                              fontSize: AppSizes.fontSmall,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          SizedBox(width: AppSizes.spacingSmall),
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 12,
                            color: AppColors.textSecondary,
                          ),
                          SizedBox(width: AppSizes.spacingTiny),
                          Text(
                            dateStr,
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: AppSizes.fontSmall,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
