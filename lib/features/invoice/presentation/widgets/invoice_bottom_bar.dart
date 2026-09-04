import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:makhzanflow/core/constants/app_colors.dart';
import 'package:makhzanflow/core/constants/app_sizes.dart';
import 'package:makhzanflow/core/constants/app_strings.dart';
import 'package:makhzanflow/features/invoice/presentation/cubit/create_invoice/create_invoice_cubit.dart';

class InvoiceBottomBar extends StatelessWidget {
  final VoidCallback onConfirm;

  const InvoiceBottomBar({super.key, required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<CreateInvoiceCubit, CreateInvoiceState, _BarView>(
      selector: (state) {
        if (state is! CreateInvoiceFormState) return const _BarView.empty();
        return _BarView(
          totalAfterDiscount: state.totalAfterDiscount,
          remainingDebt: state.remainingDebt,
        );
      },
      builder: (context, view) {
        return Container(
          padding: EdgeInsets.fromLTRB(
            AppSizes.spacingMedium,
            AppSizes.spacingSmall,
            AppSizes.spacingMedium,
            AppSizes.spacingMedium,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.totalLabel,
                        style: TextStyle(
                          fontSize: AppSizes.fontSmall,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        '${view.totalAfterDiscount.toInt()} ${AppStrings.currencyEg}',
                        style: TextStyle(
                          fontSize: AppSizes.fontXXLarge,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                      if (view.remainingDebt > 0)
                        Text(
                          '${AppStrings.remainingDebt}: ${view.remainingDebt.toInt()} ${AppStrings.currencyEg}',
                          style: TextStyle(
                            fontSize: AppSizes.fontSmall,
                            color: AppColors.secondary,
                          ),
                        ),
                    ],
                  ),
                ),
                SizedBox(width: AppSizes.spacingMedium),
                SizedBox(
                  height: AppSizes.buttonHeight,
                  child: ElevatedButton(
                    onPressed: onConfirm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppSizes.radiusSmall,
                        ),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSizes.spacingLarge,
                      ),
                    ),
                    child: Text(
                      AppStrings.confirmAndIssue,
                      style: TextStyle(
                        fontSize: AppSizes.fontLarge,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _BarView {
  final double totalAfterDiscount;
  final double remainingDebt;
  const _BarView({
    required this.totalAfterDiscount,
    required this.remainingDebt,
  });
  const _BarView.empty() : totalAfterDiscount = 0, remainingDebt = 0;
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _BarView &&
          totalAfterDiscount == other.totalAfterDiscount &&
          remainingDebt == other.remainingDebt;
  @override
  int get hashCode => Object.hash(totalAfterDiscount, remainingDebt);
}
