import 'package:flutter/material.dart';
import 'package:makhzanflow/core/constants/app_colors.dart';
import 'package:makhzanflow/core/constants/app_sizes.dart';
import 'package:makhzanflow/core/constants/app_strings.dart';
import 'package:makhzanflow/core/constants/error_messages.dart';
import 'package:makhzanflow/features/invoice/domain/entities/invoice.dart';
import 'package:makhzanflow/features/invoice/domain/entities/invoice_status.dart';
import 'package:intl/intl.dart';

class InvoiceCard extends StatelessWidget {
  final Invoice invoice;
  final VoidCallback? onTap;

  const InvoiceCard({super.key, required this.invoice, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(
        horizontal: AppSizes.spacingMedium,
        vertical: AppSizes.spacingTiny,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        child: Padding(
          padding: EdgeInsets.all(AppSizes.spacingMedium),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${AppStrings.customerInvoicePrefix}${invoice.id.substring(0, 8)}',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                    ),
                    if (invoice.customerName != null) ...[
                      SizedBox(height: AppSizes.spacingTiny),
                      Text(
                        invoice.customerName!,
                        style: TextStyle(
                          fontSize: AppSizes.fontLarge,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                    SizedBox(height: AppSizes.spacingTiny),
                    Text(
                      '${invoice.remainingAmount.toInt()} ${AppStrings.currencyEg}',
                      style: TextStyle(
                        fontSize: AppSizes.fontXLarge,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(height: AppSizes.spacingTiny),
                    Text(
                      '${AppStrings.addPaymentTotal}${invoice.totalAmount.toInt()} ${AppStrings.currencyEg}',
                      style: TextStyle(
                        fontSize: AppSizes.fontSmall,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    if (invoice.createdAt != null) ...[
                      SizedBox(height: AppSizes.spacingTiny),
                      Text(
                        DateFormat(
                          'yyyy/MM/dd – hh:mm a',
                        ).format(invoice.createdAt!.toLocal()),
                        style: TextStyle(
                          fontSize: AppSizes.fontMedium,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              _buildStatusBadge(invoice.paymentStatus),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(InvoiceStatus status) {
    Color bgColor;
    Color textColor;
    String label;

    switch (status) {
      case InvoiceStatus.paid:
        bgColor = AppColors.debtGreenBg;
        textColor = AppColors.trendUp;
        label = AppStrings.customerPaidFilter;
      case InvoiceStatus.partial:
        bgColor = AppColors.debtAmberBg;
        textColor = AppColors.accent;
        label = AppStrings.customerPartialFilter;
      case InvoiceStatus.debt:
        bgColor = AppColors.debtRedBg;
        textColor = AppColors.redDark;
        label = AppStrings.customerDeferredFilter;
      case InvoiceStatus.canceled:
        bgColor = AppColors.searchBg;
        textColor = AppColors.textSecondary;
        label = ErrorMessages.invoiceCanceled;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSizes.spacingMedium,
        vertical: AppSizes.spacingTiny,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: AppSizes.fontMedium,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
