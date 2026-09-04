import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:makhzanflow/core/constants/app_colors.dart';
import 'package:makhzanflow/core/constants/app_routes.dart';
import 'package:makhzanflow/core/constants/app_sizes.dart';
import 'package:makhzanflow/core/constants/app_strings.dart';
import 'package:makhzanflow/core/widgets/app_snackbar.dart';
import 'package:makhzanflow/features/customers/domain/entities/customer.dart';
import 'package:makhzanflow/features/invoice/presentation/cubit/create_invoice/create_invoice_cubit.dart';
import 'package:makhzanflow/features/invoice/presentation/widgets/create_invoice_form.dart';
import 'package:makhzanflow/features/invoice/presentation/widgets/create_invoice_loading.dart';

class CreateInvoiceScreen extends StatefulWidget {
  final String? preselectedCustomerId;
  final String? preselectedCustomerName;
  final bool lockCustomer;

  const CreateInvoiceScreen({
    super.key,
    this.preselectedCustomerId,
    this.preselectedCustomerName,
    this.lockCustomer = false,
  });

  @override
  State<CreateInvoiceScreen> createState() => _CreateInvoiceScreenState();
}

class _CreateInvoiceScreenState extends State<CreateInvoiceScreen> {
  late final CreateInvoiceCubit _cubit;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _cubit = context.read<CreateInvoiceCubit>();
      if (widget.preselectedCustomerId != null &&
          widget.preselectedCustomerName != null) {
        _cubit.selectCustomer(
          Customer(
            id: widget.preselectedCustomerId!,
            name: widget.preselectedCustomerName!,
          ),
        );
      }
      _initialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CreateInvoiceCubit, CreateInvoiceState>(
      listenWhen: (prev, curr) =>
          curr is CreateInvoiceSuccess || curr is CreateInvoiceError,
      listener: (context, state) {
        if (state is CreateInvoiceSuccess) {
          AppSnackbar.success(context, AppStrings.invoiceCreated);
          context.go(AppRoutes.invoiceDetailsPath(state.invoiceId));
        }
        if (state is CreateInvoiceError) {
          AppSnackbar.error(context, state.failure.message);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.appBackground,
        appBar: AppBar(
          backgroundColor: AppColors.appBackground,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: AppColors.textDark,
              size: AppSizes.iconMedium,
            ),
            onPressed: () => context.pop(),
          ),
          title: Text(
            AppStrings.invoiceCreateSale,
            style: TextStyle(
              fontSize: AppSizes.fontXLarge,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
        ),
        body: BlocSelector<CreateInvoiceCubit, CreateInvoiceState, bool>(
          selector: (s) => s is CreateInvoiceLoading,
          builder: (context, isLoading) => isLoading
              ? const CreateInvoiceLoadingState()
              : CreateInvoiceForm(lockCustomer: widget.lockCustomer),
        ),
      ),
    );
  }
}
