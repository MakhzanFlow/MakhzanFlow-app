import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:makhzanflow/core/company/company_aware_state.dart';
import 'package:makhzanflow/core/constants/app_colors.dart';
import 'package:makhzanflow/core/constants/app_sizes.dart';
import 'package:makhzanflow/core/constants/app_routes.dart';
import 'package:makhzanflow/core/constants/app_strings.dart';
import 'package:makhzanflow/core/widgets/app_snackbar.dart';
import '../cubit/add_payment/add_payment_cubit.dart';
import '../widgets/add_payment_amount_card.dart';
import '../widgets/add_payment_header.dart';
import '../widgets/unpaid_invoice_card.dart';

class AddPaymentScreen extends StatefulWidget {
  final String customerId;
  final String? customerName;

  const AddPaymentScreen({
    super.key,
    required this.customerId,
    this.customerName,
  });

  @override
  State<AddPaymentScreen> createState() => _AddPaymentScreenState();
}

class _AddPaymentScreenState extends State<AddPaymentScreen>
    with CompanyAwareState<AddPaymentScreen> {
  late final AddPaymentCubit _cubit;
  late final TextEditingController _amountController;
  AddPaymentLoaded? _lastLoaded;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _cubit = context.read<AddPaymentCubit>();
      _cubit.loadUnpaidInvoices(
        customerId: widget.customerId,
        customerName: widget.customerName ?? '',
        companyId: companyId,
      );
      _initialized = true;
    }
  }

  @override
  void onCompanyChanged(String companyId) {
    _cubit.loadUnpaidInvoices(
      customerId: widget.customerId,
      customerName: widget.customerName ?? '',
      companyId: companyId,
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _syncAmountController(String stateAmount) {
    if (_amountController.text != stateAmount) {
      _amountController.text = stateAmount;
      _amountController.selection = TextSelection.fromPosition(
        TextPosition(offset: stateAmount.length),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.appBackground,
        body: BlocConsumer<AddPaymentCubit, AddPaymentState>(
          listener: (context, state) {
            switch (state) {
              case AddPaymentError(:final failure):
                AppSnackbar.error(context, failure.message);
              case AddPaymentSuccess(:final invoiceId):
                AppSnackbar.success(context, AppStrings.addPaymentSuccess);
                context.go(AppRoutes.invoiceDetailsPath(invoiceId));
              case _:
                break;
            }
          },
          builder: (context, state) {
            if (state is AddPaymentLoaded) {
              _lastLoaded = state;
              _syncAmountController(state.amount);
            }
            return switch (state) {
              AddPaymentInitial() || AddPaymentLoading() => const Center(
                child: CircularProgressIndicator(),
              ),
              AddPaymentError() => _buildError(),
              AddPaymentLoaded(
                :final invoices,
                :final selectedInvoiceId,
                :final customerName,
                :final amountError,
                :final maxAmount,
              ) =>
                _buildContent(
                  invoices: invoices,
                  selectedInvoiceId: selectedInvoiceId,
                  customerName: customerName,
                  amountError: amountError,
                  maxAmount: maxAmount,
                  isSubmitting: false,
                ),
              AddPaymentSubmitting() when _lastLoaded != null => _buildContent(
                invoices: _lastLoaded!.invoices,
                selectedInvoiceId: _lastLoaded!.selectedInvoiceId,
                customerName: _lastLoaded!.customerName,
                amountError: _lastLoaded!.amountError,
                maxAmount: _lastLoaded!.maxAmount,
                isSubmitting: true,
              ),
              AddPaymentSubmitting() => const Center(
                child: CircularProgressIndicator(),
              ),
              AddPaymentSuccess() => const SizedBox.shrink(),
            };
          },
        ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            AppStrings.customerLoadError,
            style: TextStyle(
              fontSize: AppSizes.fontMedium,
              color: AppColors.textDark,
            ),
          ),
          SizedBox(height: AppSizes.spacingMedium),
          ElevatedButton(
            onPressed: () => _cubit.loadUnpaidInvoices(
              customerId: widget.customerId,
              customerName: widget.customerName ?? '',
              companyId: companyId,
            ),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: Text(
              AppStrings.customerRetry,
              style: const TextStyle(fontFamily: 'Cairo'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent({
    required List<dynamic> invoices,
    required String? selectedInvoiceId,
    required String customerName,
    required String? amountError,
    required double? maxAmount,
    required bool isSubmitting,
  }) {
    return SafeArea(
      child: Column(
        children: [
          AddPaymentHeader(
            customerName: customerName,
            onBack: () => context.pop(),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(AppSizes.spacingMedium),
              child: Column(
                children: [
                  if (maxAmount != null) ...[
                    AddPaymentAmountCard(
                      controller: _amountController,
                      errorText: amountError,
                      maxAmount: maxAmount,
                      onChanged: (value) => _cubit.updateAmount(value),
                    ),
                    SizedBox(height: AppSizes.spacingMedium),
                  ],
                  _buildInvoiceSection(invoices, selectedInvoiceId),
                ],
              ),
            ),
          ),
          _buildBottomBar(isSubmitting),
        ],
      ),
    );
  }

  Widget _buildInvoiceSection(
    List<dynamic> invoices,
    String? selectedInvoiceId,
  ) {
    final selectedCount = selectedInvoiceId != null ? 1 : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppStrings.addPaymentSelectInvoices,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontWeight: FontWeight.w500,
                fontSize: AppSizes.fontXLarge - 3,
                color: AppColors.secondary,
              ),
            ),
            Text(
              '$selectedCount ${AppStrings.addPaymentInvoicesSelected}',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: AppSizes.fontSmall,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        SizedBox(height: AppSizes.spacingMedium - 4),
        if (invoices.isEmpty)
          Padding(
            padding: EdgeInsets.symmetric(vertical: AppSizes.spacingLarge),
            child: Center(
              child: Text(
                AppStrings.emptyInvoices,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: AppSizes.fontMedium,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: invoices.length,
            separatorBuilder: (_, _) => SizedBox(height: 10),
            itemBuilder: (context, index) {
              final invoice = invoices[index];
              return UnpaidInvoiceCard(
                invoice: invoice,
                isSelected: invoice.id == selectedInvoiceId,
                onTap: () => _cubit.selectInvoice(invoice.id),
              );
            },
          ),
      ],
    );
  }

  Widget _buildBottomBar(bool isSubmitting) {
    final canSubmit = !isSubmitting && _cubit.canSubmit;

    return Container(
      padding: EdgeInsets.all(AppSizes.spacingMedium),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.searchBg, width: 0.8)),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 55,
        child: ElevatedButton(
          onPressed: canSubmit
              ? () {
                  _cubit.submit();
                }
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: canSubmit
                ? AppColors.primary
                : const Color(0xFFD1D5DB),
            disabledBackgroundColor: const Color(0xFFD1D5DB),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
            ),
            elevation: 0,
          ),
          child: isSubmitting
              ? SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.white,
                  ),
                )
              : Text(
                  AppStrings.addPaymentSave,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.w500,
                    fontSize: AppSizes.fontXLarge - 1,
                    color: AppColors.white,
                  ),
                ),
        ),
      ),
    );
  }
}
