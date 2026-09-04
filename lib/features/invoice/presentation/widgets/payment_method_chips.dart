import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:makhzanflow/core/constants/app_colors.dart';
import 'package:makhzanflow/core/constants/app_sizes.dart';
import 'package:makhzanflow/core/constants/app_strings.dart';
import 'package:makhzanflow/features/invoice/domain/constants/invoice_constants.dart';
import 'package:makhzanflow/features/invoice/presentation/cubit/create_invoice/create_invoice_cubit.dart';

class PaymentMethodChips extends StatelessWidget {
  final CreateInvoiceCubit cubit;

  const PaymentMethodChips({super.key, required this.cubit});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<CreateInvoiceCubit, CreateInvoiceState, String>(
      selector: (state) => state is CreateInvoiceFormState ? state.paymentMethod : InvoiceConstants.paymentFull,
      builder: (context, paymentMethod) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.paymentMethod,
              style: TextStyle(
                fontSize: AppSizes.fontXLarge,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
            SizedBox(height: AppSizes.spacingSmall),
            Wrap(
              spacing: AppSizes.spacingSmall,
              runSpacing: AppSizes.spacingSmall,
              children: [
                _MethodChip(
                  label: AppStrings.deferredPayment,
                  selected: paymentMethod == InvoiceConstants.paymentDeferred,
                  onTap: () => cubit.setPaymentMethod(InvoiceConstants.paymentDeferred),
                ),
                _MethodChip(
                  label: AppStrings.partialPayment,
                  selected: paymentMethod == InvoiceConstants.paymentPartial,
                  onTap: () => cubit.setPaymentMethod(InvoiceConstants.paymentPartial),
                ),
                _MethodChip(
                  label: AppStrings.fullPayment,
                  selected: paymentMethod == InvoiceConstants.paymentFull,
                  onTap: () => cubit.setPaymentMethod(InvoiceConstants.paymentFull),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _MethodChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _MethodChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSizes.spacingMedium,
          vertical: AppSizes.spacingSmall,
        ),
        decoration: BoxDecoration(
          color: selected ? AppColors.lightGreen : AppColors.inputBackground,
          borderRadius: BorderRadius.circular(AppSizes.radiusXLarge),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.inputBorder,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? AppColors.primary : AppColors.textSecondary,
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
            fontSize: AppSizes.fontMedium,
          ),
        ),
      ),
    );
  }
}
