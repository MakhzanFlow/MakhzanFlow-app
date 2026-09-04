import 'package:flutter/material.dart';
import 'package:makhzanflow/core/constants/app_colors.dart';
import 'package:makhzanflow/core/constants/app_sizes.dart';
import 'package:makhzanflow/core/constants/app_strings.dart';
import 'package:makhzanflow/core/constants/error_messages.dart';
import 'package:makhzanflow/features/invoice/domain/entities/invoice.dart';
import 'package:makhzanflow/features/invoice/domain/entities/invoice_status.dart';

class InvoiceDetailsPaymentStatus extends StatelessWidget {
  final Invoice invoice;

  const InvoiceDetailsPaymentStatus({super.key, required this.invoice});

  @override
  Widget build(BuildContext context) {
    String statusLabel;
    Color statusColor;
    Color statusBg;

    switch (invoice.paymentStatus) {
      case InvoiceStatus.paid:
        statusLabel = AppStrings.customerPaidFilter;
        statusColor = AppColors.trendUp;
        statusBg = AppColors.lightGreen;
      case InvoiceStatus.partial:
        statusLabel = AppStrings.customerPartialFilter;
        statusColor = AppColors.accent;
        statusBg = AppColors.lightOrange;
      case InvoiceStatus.debt:
        statusLabel = AppStrings.customerDeferredFilter;
        statusColor = AppColors.redDark;
        statusBg = AppColors.lightRed;
      case InvoiceStatus.canceled:
        statusLabel = ErrorMessages.invoiceCanceled;
        statusColor = AppColors.textSecondary;
        statusBg = AppColors.searchBg;
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSizes.spacingMedium),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            AppStrings.paymentMethod,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: AppSizes.fontLarge,
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppSizes.spacingMedium,
              vertical: AppSizes.spacingTiny,
            ),
            decoration: BoxDecoration(
              color: statusBg,
              borderRadius: BorderRadius.circular(AppSizes.radiusXLarge),
            ),
            child: Text(
              statusLabel,
              style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.w600,
                fontSize: AppSizes.fontMedium,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
