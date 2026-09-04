import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:makhzanflow/core/company/company_aware_state.dart';
import 'package:makhzanflow/core/constants/app_colors.dart';
import 'package:makhzanflow/core/constants/app_sizes.dart';
import 'package:makhzanflow/core/constants/app_strings.dart';
import 'package:makhzanflow/core/permissions/permission_gate.dart';
import 'package:makhzanflow/core/permissions/permission_constants.dart';
import 'package:makhzanflow/core/widgets/app_snackbar.dart';
import 'package:makhzanflow/features/invoice/domain/entities/invoice.dart';
import 'package:makhzanflow/features/invoice/domain/entities/invoice_status.dart';
import 'package:makhzanflow/features/invoice/presentation/cubit/invoice_details/invoice_details_cubit.dart';
import 'package:makhzanflow/features/invoice/presentation/widgets/invoice_cancel_sheet.dart';
import 'package:makhzanflow/features/invoice/presentation/widgets/invoice_details_company_header.dart';
import 'package:makhzanflow/features/invoice/presentation/widgets/invoice_details_info_section.dart';
import 'package:makhzanflow/features/invoice/presentation/widgets/invoice_details_products_table.dart';
import 'package:makhzanflow/features/invoice/presentation/widgets/invoice_details_summary_section.dart';
import 'package:makhzanflow/features/invoice/presentation/widgets/invoice_details_payment_status.dart';
import 'package:makhzanflow/features/invoice/presentation/widgets/invoice_details_payment_history.dart';
import 'package:makhzanflow/features/invoice/presentation/widgets/invoice_details_reminder_footer.dart';
import 'package:makhzanflow/features/invoice/presentation/widgets/invoice_details_loading.dart';
import 'package:makhzanflow/features/invoice/presentation/widgets/invoice_details_error.dart';

class InvoiceDetailsScreen extends StatefulWidget {
  final String invoiceId;

  const InvoiceDetailsScreen({super.key, required this.invoiceId});

  @override
  State<InvoiceDetailsScreen> createState() => _InvoiceDetailsScreenState();
}

class _InvoiceDetailsScreenState extends State<InvoiceDetailsScreen>
    with CompanyAwareState<InvoiceDetailsScreen> {
  late final InvoiceDetailsCubit _cubit;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _cubit = context.read<InvoiceDetailsCubit>();
      _cubit.loadInvoice(widget.invoiceId, companyId);
      _initialized = true;
    }
  }

  @override
  void onCompanyChanged(String companyId) {
    _cubit.loadInvoice(widget.invoiceId, companyId);
  }

  Future<void> _confirmCancel(Invoice invoice) async {
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSizes.radiusLarge),
        ),
      ),
      builder: (_) => InvoiceCancelSheet(
        invoice: invoice,
        onConfirm: () => Navigator.pop(context, true),
      ),
    );
    if (confirmed == true && mounted) {
      await _cubit.cancelInvoice(companyId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          AppStrings.invoiceDetailsTitle,
          style: TextStyle(
            fontSize: AppSizes.fontXLarge,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () =>
                AppSnackbar.info(context, AppStrings.actionComingSoon),
            icon: Icon(Icons.print, color: AppColors.primary),
          ),
          IconButton(
            onPressed: () =>
                AppSnackbar.info(context, AppStrings.actionComingSoon),
            icon: Icon(Icons.share, color: AppColors.primary),
          ),
          SizedBox(width: AppSizes.spacingTiny),
        ],
      ),
      body: BlocConsumer<InvoiceDetailsCubit, InvoiceDetailsState>(
        listenWhen: (prev, curr) =>
            curr is InvoiceDetailsCanceled || curr is InvoiceDetailsError,
        listener: (context, state) {
          if (state is InvoiceDetailsCanceled) {
            AppSnackbar.success(context, AppStrings.cancelInvoiceSuccess);
          }
          if (state is InvoiceDetailsError) {
            AppSnackbar.error(context, state.failure.message);
          }
        },
        buildWhen: (prev, curr) =>
            prev.runtimeType != curr.runtimeType ||
            (curr is InvoiceDetailsLoaded &&
                prev is InvoiceDetailsLoaded &&
                prev.invoice.paymentStatus != curr.invoice.paymentStatus),
        builder: (context, state) {
          if (state is InvoiceDetailsLoading ||
              state is InvoiceDetailsInitial) {
            return const InvoiceDetailsLoadingState();
          }
          if (state is InvoiceDetailsError) {
            return InvoiceDetailsErrorState(message: state.failure.message);
          }
          if (state is InvoiceDetailsCanceling) {
            return Stack(
              children: [
                _InvoiceDetailContent(
                  invoice: state.invoice,
                  onCancel: () => _confirmCancel(state.invoice),
                ),
                Container(
                  color: AppColors.surface.withValues(alpha: 0.6),
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                ),
              ],
            );
          }
          if (state is InvoiceDetailsLoaded) {
            return _InvoiceDetailContent(
              invoice: state.invoice,
              onCancel: () => _confirmCancel(state.invoice),
            );
          }
          if (state is InvoiceDetailsCanceled) {
            return _InvoiceDetailContent(
              invoice: state.invoice,
              onCancel: null,
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _InvoiceDetailContent extends StatelessWidget {
  final Invoice invoice;
  final VoidCallback? onCancel;

  const _InvoiceDetailContent({required this.invoice, this.onCancel});

  @override
  Widget build(BuildContext context) {
    final dateStr = invoice.createdAt != null
        ? DateFormat('yyyy/MM/dd').format(invoice.createdAt!.toLocal())
        : '--';
    final isCanceled = invoice.paymentStatus == InvoiceStatus.canceled;
    final canCancel = onCancel != null && !isCanceled;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final horizontalPadding = screenWidth > 600
        ? AppSizes.spacingXLarge
        : AppSizes.spacingMedium;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: AppSizes.spacingMedium,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const InvoiceDetailsCompanyHeader(),
          SizedBox(height: AppSizes.spacingMedium),
          InvoiceDetailsInfoSection(invoice: invoice, dateStr: dateStr),
          SizedBox(height: AppSizes.spacingMedium),
          InvoiceDetailsProductsTable(invoice: invoice),
          SizedBox(height: AppSizes.spacingMedium),
          InvoiceDetailsSummarySection(invoice: invoice),
          SizedBox(height: AppSizes.spacingMedium),
          InvoiceDetailsPaymentStatus(invoice: invoice),
          if (invoice.payments.isNotEmpty) ...[
            SizedBox(height: AppSizes.spacingMedium),
            InvoiceDetailsPaymentHistory(invoice: invoice),
          ],
          if (invoice.remainingAmount > 0 && !isCanceled) ...[
            SizedBox(height: AppSizes.spacingLarge),
            const InvoiceDetailsReminderFooter(),
          ],
          if (isCanceled) ...[
            SizedBox(height: AppSizes.spacingLarge),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(AppSizes.spacingMedium),
              decoration: BoxDecoration(
                color: AppColors.debtRedBg,
                borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                border: Border.all(color: AppColors.lightRed),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: AppColors.redDark, size: 18),
                  SizedBox(width: AppSizes.spacingSmall),
                  Expanded(
                    child: Text(
                      AppStrings.invoiceCanceledNote,
                      style: TextStyle(
                        color: AppColors.redDark,
                        fontWeight: FontWeight.w600,
                        fontSize: AppSizes.fontMedium,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          SizedBox(height: AppSizes.spacingLarge),
          // Destructive cancel button — good UI: full-width outlined red, hidden when canceled or no permission
          if (canCancel)
            PermissionGate(
              permission: PermissionKeys.invoicesCancel,
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: onCancel,
                  icon: Icon(
                    Icons.cancel_outlined,
                    color: AppColors.redDark,
                    size: 18,
                  ),
                  label: Text(
                    AppStrings.cancelInvoice,
                    style: TextStyle(
                      color: AppColors.redDark,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      vertical: AppSizes.spacingMedium - 2,
                    ),
                    side: BorderSide(
                      color: AppColors.redDark.withValues(alpha: 0.5),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppSizes.radiusMedium,
                      ),
                    ),
                    backgroundColor: AppColors.surface,
                  ),
                ),
              ),
            ),
          SizedBox(height: AppSizes.spacingMedium),
        ],
      ),
    );
  }
}
