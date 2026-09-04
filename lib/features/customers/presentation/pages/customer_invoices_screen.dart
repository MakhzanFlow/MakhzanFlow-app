import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:makhzanflow/core/company/company_aware_state.dart';
import 'package:makhzanflow/core/theme/mf_tokens.dart';
import 'package:makhzanflow/core/constants/app_routes.dart';
import 'package:makhzanflow/core/constants/app_strings.dart';
import 'package:makhzanflow/features/invoice/domain/entities/invoice_status.dart';
import '../cubit/customer_invoices/customer_invoices_cubit.dart';

class CustomerInvoicesScreen extends StatefulWidget {
  final String customerId;
  final String customerName;

  const CustomerInvoicesScreen({super.key, required this.customerId, required this.customerName});

  @override
  State<CustomerInvoicesScreen> createState() => _CustomerInvoicesScreenState();
}

class _CustomerInvoicesScreenState extends State<CustomerInvoicesScreen>
    with CompanyAwareState<CustomerInvoicesScreen> {
  late final CustomerInvoicesCubit _cubit;
  final ScrollController _scrollController = ScrollController();
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _cubit = context.read<CustomerInvoicesCubit>();
      _cubit.loadInvoices();
      _scrollController.addListener(_onScroll);
      _initialized = true;
    }
  }

  @override
  void onCompanyChanged(String companyId) {}

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      _cubit.loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? MFTokens.backgroundDark : MFTokens.backgroundLight;
    final textPrimary = isDark ? MFTokens.textPrimaryDark : MFTokens.textPrimaryLight;
    final textSecondary = isDark ? MFTokens.textSecondaryDark : MFTokens.textSecondaryLight;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        title: Text(
          '${AppStrings.customerInvoicesTab} - ${widget.customerName}',
          style: TextStyle(fontFamily: 'Cairo', fontSize: MFTokens.fontMD, color: textPrimary),
        ),
      ),
      body: BlocBuilder<CustomerInvoicesCubit, CustomerInvoicesState>(
        builder: (context, state) {
          return switch (state.status) {
            CustomerInvoicesStatus.initial || CustomerInvoicesStatus.loading =>
              const Center(child: CircularProgressIndicator()),
            CustomerInvoicesStatus.error => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.failure?.message ?? AppStrings.unexpectedError, style: const TextStyle(fontFamily: 'Cairo')),
                  const SizedBox(height: MFTokens.sp16),
                  TextButton(onPressed: () => _cubit.loadInvoices(), child: Text(AppStrings.productRetry, style: const TextStyle(fontFamily: 'Cairo'))),
                ],
              ),
            ),
            CustomerInvoicesStatus.loadingMore || CustomerInvoicesStatus.success => _buildList(state, isDark),
            CustomerInvoicesStatus.empty => Center(
              child: Text(AppStrings.emptyInvoices, style: TextStyle(fontFamily: 'Cairo', fontSize: MFTokens.fontSM, color: textSecondary)),
            ),
          };
        },
      ),
    );
  }

  Widget _buildList(CustomerInvoicesState state, bool isDark) {
    final textPrimary = isDark ? MFTokens.textPrimaryDark : MFTokens.textPrimaryLight;
    final textSecondary = isDark ? MFTokens.textSecondaryDark : MFTokens.textSecondaryLight;
    final primary = isDark ? MFTokens.primaryDarkMode : MFTokens.primary;
    final primaryDark = isDark ? MFTokens.primaryDarkMode : MFTokens.primaryDark;
    final primarySubtle = isDark ? MFTokens.primaryDarkModeSubtle : MFTokens.primarySubtle;
    final warningBg = isDark ? MFTokens.warningBgDark : MFTokens.warningBg;
    final accent = isDark ? MFTokens.primaryDarkMode : MFTokens.accent;
    final errorBg = isDark ? MFTokens.errorBgDark : MFTokens.errorBg;
    final errorColor = isDark ? MFTokens.errorTextDark : MFTokens.errorText;
    final muted = isDark ? MFTokens.textMutedDark : MFTokens.textMutedLight;
    final cardBg = isDark ? MFTokens.cardDark : MFTokens.cardLight;

    if (state.invoices.isEmpty) {
      return Center(child: Text(AppStrings.emptyInvoices, style: TextStyle(fontFamily: 'Cairo', fontSize: MFTokens.fontSM, color: textSecondary)));
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: MFTokens.sp16, vertical: MFTokens.sp8),
      itemCount: state.invoices.length + (state.hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == state.invoices.length) return const Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator()));
        final invoice = state.invoices[index];
        final amountColor = invoice.paymentStatus == InvoiceStatus.debt ? primaryDark : primary;
        final truncatedId = invoice.id.substring(0, invoice.id.length > 8 ? 8 : invoice.id.length);

        return GestureDetector(
          onTap: () => context.push(AppRoutes.invoiceDetailsPath(invoice.id)),
          child: Container(
            margin: const EdgeInsets.only(bottom: MFTokens.sp8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(MFTokens.radiusLG),
              boxShadow: MFTokens.shadowSM,
            ),
            child: Row(
              children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(color: primarySubtle, borderRadius: BorderRadius.circular(MFTokens.radiusMD)),
                  child: Icon(Icons.receipt, size: 16, color: primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(child: Text('${AppStrings.invoiceNo} #$truncatedId', overflow: TextOverflow.ellipsis, style: TextStyle(fontFamily: 'Cairo', fontSize: MFTokens.fontSM, color: textPrimary))),
                          const SizedBox(width: MFTokens.sp8),
                          _statusChip(invoice.paymentStatus, isDark, primarySubtle, primary, warningBg, accent, errorBg, errorColor),
                        ],
                      ),
                      const SizedBox(height: MFTokens.sp4),
                      Text(invoice.createdAt != null ? _formatDate(invoice.createdAt!) : '', style: TextStyle(fontFamily: 'Cairo', fontSize: MFTokens.fontXS, color: textSecondary)),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(invoice.totalAmount.toInt().toString(), style: TextStyle(fontFamily: 'Cairo', fontSize: MFTokens.fontBase, color: amountColor)),
                    Text(AppStrings.currencyEg, style: TextStyle(fontFamily: 'Cairo', fontSize: MFTokens.fontXS, color: muted)),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _statusChip(InvoiceStatus status, bool isDark, Color primarySubtle, Color primary, Color warningBg, Color accent, Color errorBg, Color errorColor) {
    final isDebt = status == InvoiceStatus.debt;
    final isPartial = status == InvoiceStatus.partial;
    String label;
    Color textColor;
    Color bgColor;

    if (isDebt) { label = AppStrings.customerDeferred; textColor = errorColor; bgColor = errorBg; }
    else if (isPartial) { label = AppStrings.addPaymentStatusPartial; textColor = accent; bgColor = warningBg; }
    else { label = AppStrings.customerPaidFilter; textColor = primary; bgColor = primarySubtle; }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: MFTokens.sp8, vertical: 2),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(MFTokens.radiusXL)),
      child: Text(label, style: TextStyle(fontFamily: 'Cairo', fontSize: MFTokens.fontXS, color: textColor)),
    );
  }

  String _formatDate(DateTime date) {
    final local = date.toLocal();
    return '${local.year}/${local.month}/${local.day}';
  }
}
