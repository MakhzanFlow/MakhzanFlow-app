import 'package:flutter/material.dart';
import 'package:makhzanflow/core/constants/app_colors.dart';
import 'package:makhzanflow/core/constants/app_sizes.dart';
import 'package:makhzanflow/core/constants/app_strings.dart';
import 'package:makhzanflow/features/invoice/domain/entities/invoice.dart';

class InvoiceDetailsProductsTable extends StatelessWidget {
  final Invoice invoice;

  const InvoiceDetailsProductsTable({super.key, required this.invoice});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSizes.spacingMedium),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _HeaderCell(AppStrings.productCol, flex: 3),
              _HeaderCell(AppStrings.qtyCol),
              _HeaderCell(AppStrings.priceCol),
              _HeaderCell(AppStrings.totalCol),
            ],
          ),
          Divider(color: AppColors.inputBorder),
          ...invoice.items.map(
            (item) => Padding(
              padding: EdgeInsets.symmetric(vertical: AppSizes.spacingSmall),
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Text(
                      item.productName,
                      style: TextStyle(
                        fontSize: AppSizes.fontMedium,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      '${item.quantity}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: AppSizes.fontMedium,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      '${item.unitPrice.toInt()} ${AppStrings.currencyEg}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: AppSizes.fontMedium,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      '${item.total.toInt()} ${AppStrings.currencyEg}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: AppSizes.fontMedium,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  final String label;
  final int flex;

  const _HeaderCell(this.label, {this.flex = 1});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: AppSizes.fontMedium,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}
