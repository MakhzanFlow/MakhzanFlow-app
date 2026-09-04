import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:makhzanflow/core/company/company_aware_state.dart';
import '../../../../core/theme/mf_tokens.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../cubit/customer_details/customer_details_cubit.dart';
import '../widgets/customer_action_buttons.dart';
import '../widgets/customer_debt_summary_card.dart';
import '../widgets/customer_details_header.dart';
import '../widgets/customer_transaction_list.dart';

class CustomerDetailsScreen extends StatefulWidget {
  final String customerId;

  const CustomerDetailsScreen({super.key, required this.customerId});

  @override
  State<CustomerDetailsScreen> createState() => _CustomerDetailsScreenState();
}

class _CustomerDetailsScreenState extends State<CustomerDetailsScreen>
    with CompanyAwareState<CustomerDetailsScreen> {
  late final CustomerDetailsCubit _cubit;
  int _selectedTab = 0;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _cubit = context.read<CustomerDetailsCubit>();
      _cubit.loadCustomer(widget.customerId, companyId);
      _initialized = true;
    }
  }

  @override
  void onCompanyChanged(String companyId) {
    _cubit.loadCustomer(widget.customerId, companyId);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? MFTokens.backgroundDark : MFTokens.backgroundLight;

    return Scaffold(
      backgroundColor: bg,
      body: BlocConsumer<CustomerDetailsCubit, CustomerDetailsState>(
        listener: (context, state) {
          if (state.status == CustomerDetailsStatus.error && state.failure != null) {
            AppSnackbar.error(context, state.failure?.message ?? AppStrings.unexpectedError);
          }
        },
        builder: (context, state) {
          switch (state.status) {
            case CustomerDetailsStatus.initial:
            case CustomerDetailsStatus.loading:
              return const Center(child: CircularProgressIndicator());
            case CustomerDetailsStatus.error:
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      AppStrings.customerLoadError,
                      style: TextStyle(
                        fontSize: MFTokens.fontSM,
                        color: isDark ? MFTokens.textPrimaryDark : MFTokens.textPrimaryLight,
                      ),
                    ),
                    const SizedBox(height: MFTokens.sp16),
                    ElevatedButton(
                      onPressed: () => _cubit.loadCustomer(widget.customerId, companyId),
                      child: Text(AppStrings.customerRetry, style: const TextStyle(fontFamily: 'Cairo')),
                    ),
                  ],
                ),
              );
            case CustomerDetailsStatus.success:
              final customer = state.customer!;
              return SafeArea(
                child: NestedScrollView(
                  headerSliverBuilder: (context, innerBoxScrolled) => [
                    SliverToBoxAdapter(
                      child: CustomerDetailsHeader(
                        name: customer.name,
                        address: customer.address,
                        phone: customer.phone,
                        imageUrl: customer.imageUrl,
                        onPressed: () async {
                          final updated = await context.push<bool>(AppRoutes.customerEditPath(widget.customerId));
                          if (updated == true && mounted) {
                            _cubit.loadCustomer(widget.customerId, companyId);
                          }
                        },
                      ),
                    ),
                  ],
                  body: SingleChildScrollView(
                    padding: const EdgeInsets.only(top: MFTokens.sp16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomerDebtSummaryCard(
                          totalDebt: customer.totalDebt,
                          totalPurchases: customer.totalPurchases,
                          totalPaid: customer.totalPaid,
                        ),
                        const SizedBox(height: MFTokens.sp16),
                        CustomerActionButtons(
                          onNewInvoice: () {
                            context.push(AppRoutes.invoiceCreate, extra: {
                              'customerId': widget.customerId,
                              'customerName': customer.name,
                            });
                          },
                          onRecordPayment: () async {
                            final result = await context.push<bool>(
                              AppRoutes.customerAddPaymentPath(widget.customerId),
                              extra: customer.name,
                            );
                            if (result == true && mounted) {
                              _cubit.loadCustomer(widget.customerId, companyId);
                            }
                          },
                        ),
                        const SizedBox(height: MFTokens.sp16),
                        _tabBar(),
                        const SizedBox(height: MFTokens.sp8),
                        CustomerTransactionList(
                          selectedTab: _selectedTab,
                          transactions: customer.transactions,
                          onViewAll: () => context.push(
                            AppRoutes.customerInvoicesPath(widget.customerId),
                            extra: customer.name,
                          ),
                          onInvoiceTap: (invoiceId) => context.push(AppRoutes.invoiceDetailsPath(invoiceId)),
                        ),
                        const SizedBox(height: MFTokens.sp24),
                      ],
                    ),
                  ),
                ),
              );
          }
        },
      ),
    );
  }

  Widget _tabBar() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? MFTokens.cardDark : MFTokens.cardLight;
    final primary = isDark ? MFTokens.primaryDarkMode : MFTokens.primary;
    final muted = isDark ? MFTokens.textMutedDark : MFTokens.textMutedLight;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(MFTokens.sp4),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(MFTokens.radiusMD),
          boxShadow: MFTokens.shadowSM,
        ),
        child: Row(
          children: [
            _tabItem(label: AppStrings.customerAllFilter, index: 0, primary: primary, muted: muted),
            const SizedBox(width: MFTokens.sp4),
            _tabItem(label: AppStrings.customerInvoicesTab, index: 1, primary: primary, muted: muted),
            const SizedBox(width: MFTokens.sp4),
            _tabItem(label: AppStrings.customerPaymentsTab, index: 2, primary: primary, muted: muted),
          ],
        ),
      ),
    );
  }

  Widget _tabItem({required String label, required int index, required Color primary, required Color muted}) {
    final isActive = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: MFTokens.sp8),
          decoration: BoxDecoration(
            color: isActive ? primary : null,
            borderRadius: BorderRadius.circular(MFTokens.radiusSM),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: MFTokens.fontXS,
              color: isActive ? Colors.white : muted,
            ),
          ),
        ),
      ),
    );
  }
}
