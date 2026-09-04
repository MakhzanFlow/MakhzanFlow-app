import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:makhzanflow/core/constants/app_colors.dart';
import 'package:makhzanflow/core/constants/app_sizes.dart';
import 'package:makhzanflow/core/constants/app_strings.dart';
import 'package:makhzanflow/features/invoice/domain/constants/invoice_constants.dart';
import 'package:makhzanflow/features/invoice/presentation/cubit/create_invoice/create_invoice_cubit.dart';

class InvoiceSummaryCard extends StatelessWidget {
  const InvoiceSummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<CreateInvoiceCubit, CreateInvoiceState, _SummaryView>(
      selector: (state) {
        if (state is! CreateInvoiceFormState) return const _SummaryView.empty();
        return _SummaryView(
          subtotal: state.subtotal,
          discountValue: state.discountValue,
          discountAmount: state.discountAmount,
          totalAfterDiscount: state.totalAfterDiscount,
          paidNow: state.paidNow,
          paymentMethod: state.paymentMethod,
          remainingDebt: state.remainingDebt,
        );
      },
      builder: (context, view) {
        final showDiscount = view.discountValue > 0;
        final showPaidNow = view.paymentMethod == InvoiceConstants.paymentPartial && view.paidNow > 0;
        final showRemaining = view.remainingDebt > 0;

        return Container(
          padding: EdgeInsets.all(AppSizes.spacingMedium),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
          ),
          child: Column(
            children: [
              _SummaryRow(label: AppStrings.subtotal, value: view.subtotal, valueColor: AppColors.textDark),
              if (showDiscount) ...[
                SizedBox(height: AppSizes.spacingSmall),
                _SummaryRow(label: AppStrings.discountLabel, value: -view.discountAmount, valueColor: AppColors.redDark),
              ],
              if (showDiscount) ...[
                SizedBox(height: AppSizes.spacingSmall),
                _SummaryRow(label: AppStrings.afterDiscount, value: view.totalAfterDiscount, valueColor: AppColors.textDark, bold: true),
              ],
              Divider(height: AppSizes.spacingMedium, color: AppColors.inputBorder),
              if (showPaidNow) ...[
                _SummaryRow(label: AppStrings.paidNowLabel, value: -view.paidNow, valueColor: AppColors.trendUp),
                Divider(height: AppSizes.spacingMedium, color: AppColors.inputBorder),
              ],
              _SummaryRow(label: AppStrings.totalLabel, value: view.totalAfterDiscount, valueColor: AppColors.accent, bold: true, large: true),
              if (showRemaining) ...[
                SizedBox(height: AppSizes.spacingSmall),
                _SummaryRow(label: AppStrings.remainingDebt, value: view.remainingDebt, valueColor: AppColors.redDark),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _SummaryView {
  final double subtotal;
  final double discountValue;
  final double discountAmount;
  final double totalAfterDiscount;
  final double paidNow;
  final String paymentMethod;
  final double remainingDebt;
  const _SummaryView({
    required this.subtotal,
    required this.discountValue,
    required this.discountAmount,
    required this.totalAfterDiscount,
    required this.paidNow,
    required this.paymentMethod,
    required this.remainingDebt,
  });
  const _SummaryView.empty()
      : subtotal = 0,
        discountValue = 0,
        discountAmount = 0,
        totalAfterDiscount = 0,
        paidNow = 0,
        paymentMethod = InvoiceConstants.paymentFull,
        remainingDebt = 0;
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _SummaryView &&
          subtotal == other.subtotal &&
          discountValue == other.discountValue &&
          discountAmount == other.discountAmount &&
          totalAfterDiscount == other.totalAfterDiscount &&
          paidNow == other.paidNow &&
          paymentMethod == other.paymentMethod &&
          remainingDebt == other.remainingDebt;
  @override
  int get hashCode => Object.hash(subtotal, discountValue, discountAmount, totalAfterDiscount, paidNow, paymentMethod, remainingDebt);
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final double value;
  final Color valueColor;
  final bool bold;
  final bool large;

  const _SummaryRow({required this.label, required this.value, required this.valueColor, this.bold = false, this.large = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: large ? AppSizes.fontXLarge : AppSizes.fontLarge, fontWeight: bold ? FontWeight.w600 : FontWeight.normal, color: AppColors.textSecondary)),
        Text('${value >= 0 ? '' : '-'}${value.abs().toInt()} ${AppStrings.currencyEg}', style: TextStyle(fontSize: large ? AppSizes.fontXXLarge : AppSizes.fontLarge, fontWeight: bold ? FontWeight.w700 : FontWeight.w500, color: valueColor)),
      ],
    );
  }
}
