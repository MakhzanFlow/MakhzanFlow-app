import 'package:flutter/material.dart';
import 'package:makhzanflow/core/constants/app_colors.dart';
import 'package:makhzanflow/core/constants/app_sizes.dart';
import 'package:makhzanflow/core/constants/app_strings.dart';
import 'package:makhzanflow/features/invoice/domain/entities/invoice.dart';

class InvoiceCancelSheet extends StatelessWidget {
  final Invoice invoice;
  final VoidCallback onConfirm;
  final bool isLoading;

  const InvoiceCancelSheet({super.key, required this.invoice, required this.onConfirm, this.isLoading = false});

  static Future<bool?> show(BuildContext context, {required Invoice invoice, required VoidCallback onConfirm, bool isLoading = false}) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.radiusLarge)),
      ),
      builder: (_) => InvoiceCancelSheet(invoice: invoice, onConfirm: onConfirm, isLoading: isLoading),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(AppSizes.spacingMedium, AppSizes.spacingSmall, AppSizes.spacingMedium, AppSizes.spacingMedium),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: AppColors.inputBorder, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            SizedBox(height: AppSizes.spacingMedium),
            // Icon
            Center(
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(color: AppColors.lightRed, shape: BoxShape.circle),
                child: const Icon(Icons.warning_amber_rounded, color: AppColors.redDark, size: 32),
              ),
            ),
            SizedBox(height: AppSizes.spacingMedium),
            Text(
              AppStrings.cancelInvoiceConfirmTitle,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: AppSizes.fontXLarge, fontWeight: FontWeight.w700, color: AppColors.textDark),
            ),
            SizedBox(height: AppSizes.spacingSmall),
            Text(
              AppStrings.cancelInvoiceConfirmBody,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: AppSizes.fontLarge, color: AppColors.textSecondary, height: 1.4),
            ),
            SizedBox(height: AppSizes.spacingMedium),
            // Invoice mini card
            Container(
              padding: EdgeInsets.all(AppSizes.spacingMedium),
              decoration: BoxDecoration(
                color: AppColors.appBackground,
                borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                border: Border.all(color: AppColors.inputBorder),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(AppSizes.spacingSmall),
                    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppSizes.radiusSmall)),
                    child: Icon(Icons.receipt_long, color: AppColors.textSecondary, size: AppSizes.iconSmall),
                  ),
                  SizedBox(width: AppSizes.spacingSmall),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '#${invoice.id.substring(0, 8).toUpperCase()}',
                          style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textDark),
                        ),
                        SizedBox(height: 2),
                        Text(
                          '${invoice.totalAmount.toInt()} ${AppStrings.currencyEg} • ${invoice.items.length} ${AppStrings.customerProductsUnit}',
                          style: TextStyle(fontSize: AppSizes.fontSmall, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: AppSizes.spacingSmall, vertical: 2),
                    decoration: BoxDecoration(color: AppColors.debtRedBg, borderRadius: BorderRadius.circular(20)),
                    child: Text(AppStrings.cancelInvoiceBadge, style: TextStyle(fontSize: AppSizes.fontSmall, color: AppColors.redDark, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
            SizedBox(height: AppSizes.spacingSmall),
            Row(
              children: [
                Icon(Icons.inventory_2_outlined, size: 14, color: AppColors.trendUp),
                SizedBox(width: AppSizes.spacingTiny),
                Expanded(
                  child: Text(
                    AppStrings.cancelInvoiceStockNote,
                    style: TextStyle(fontSize: AppSizes.fontSmall, color: AppColors.trendUp, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSizes.spacingLarge),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: isLoading ? null : () => Navigator.pop(context, false),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: AppSizes.spacingMedium - 2),
                      side: BorderSide(color: AppColors.inputBorder),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusMedium)),
                    ),
                    child: Text(AppStrings.cancel, style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w600)),
                  ),
                ),
                SizedBox(width: AppSizes.spacingSmall),
                Expanded(
                  child: ElevatedButton(
                    onPressed: isLoading ? null : onConfirm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.redDark,
                      foregroundColor: AppColors.surface,
                      padding: EdgeInsets.symmetric(vertical: AppSizes.spacingMedium - 2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusMedium)),
                      elevation: 0,
                    ),
                    child: isLoading
                        ? SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.surface))
                        : Text(AppStrings.cancelInvoiceAction, style: TextStyle(fontWeight: FontWeight.w600)),
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
