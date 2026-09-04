import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:makhzanflow/core/company/company_aware_state.dart';
import 'package:makhzanflow/core/constants/app_colors.dart';
import 'package:makhzanflow/core/constants/app_sizes.dart';
import 'package:makhzanflow/core/constants/app_strings.dart';
import 'package:makhzanflow/core/theme/mf_tokens.dart';
import 'package:makhzanflow/core/constants/app_routes.dart';
import 'package:makhzanflow/core/permissions/permission_constants.dart';
import 'package:makhzanflow/core/permissions/permission_gate.dart';
import 'package:makhzanflow/features/invoice/domain/entities/invoice_status.dart';
import 'package:makhzanflow/features/invoice/presentation/cubit/invoices/invoices_cubit.dart';
import 'package:makhzanflow/features/invoice/presentation/widgets/invoice_card.dart';
import 'package:makhzanflow/features/invoice/presentation/widgets/invoices_filter_chip.dart';
import 'package:makhzanflow/features/invoice/presentation/widgets/invoices_empty_state.dart';

class InvoicesScreen extends StatefulWidget {
  const InvoicesScreen({super.key});

  @override
  State<InvoicesScreen> createState() => _InvoicesScreenState();
}

class _InvoicesScreenState extends State<InvoicesScreen>
    with CompanyAwareState<InvoicesScreen> {
  InvoiceStatus? _selectedStatus;
  String _selectedCustomerId = '';

  @override
  void initState() {
    super.initState();
    final cubit = context.read<InvoicesCubit>();
    cubit.loadCustomers(companyId);
    cubit.loadInvoices(companyId);
  }

  @override
  void onCompanyChanged(String companyId) {
    setState(() {
      _selectedStatus = null;
      _selectedCustomerId = '';
    });
    final cubit = context.read<InvoicesCubit>();
    cubit.loadCustomers(companyId);
    cubit.loadInvoices(companyId);
  }

  void _setStatusFilter(InvoiceStatus? status) {
    final newStatus = _selectedStatus == status ? null : status;
    setState(() => _selectedStatus = newStatus);
    context.read<InvoicesCubit>().setFilter(
      companyId: companyId,
      statusFilter: newStatus,
      customerId: _selectedCustomerId,
    );
  }

  void _setCustomerFilter(String? customerId) {
    final resolvedId = customerId?.isEmpty == true ? null : customerId;
    setState(() => _selectedCustomerId = resolvedId ?? '');
    context.read<InvoicesCubit>().setFilter(
      companyId: companyId,
      statusFilter: _selectedStatus,
      customerId: resolvedId,
    );
  }

  void _clearFilters() {
    setState(() {
      _selectedStatus = null;
      _selectedCustomerId = '';
    });
    context.read<InvoicesCubit>().clearFilters(companyId);
  }

  @override
  Widget build(BuildContext context) {
    final hasActiveFilter =
        _selectedStatus != null || _selectedCustomerId.isNotEmpty;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? MFTokens.backgroundDark : MFTokens.backgroundLight;
    final surface = isDark ? MFTokens.surfaceDark : MFTokens.surfaceLight;
    final textDark = isDark ? MFTokens.textPrimaryDark : MFTokens.textPrimaryLight;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Text(
          AppStrings.navInvoices,
          style: TextStyle(
            fontSize: AppSizes.fontXXLarge,
            fontWeight: FontWeight.w700,
            color: textDark,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => context.read<InvoicesCubit>().refresh(companyId),
        child: Column(
          children: [
            _buildFilters(hasActiveFilter),
            Expanded(
              child: BlocBuilder<InvoicesCubit, InvoicesState>(
                buildWhen: (prev, curr) =>
                    prev.status != curr.status || prev.invoices != curr.invoices || prev.failure != curr.failure,
                builder: (context, state) {
                  switch (state.status) {
                    case InvoicesStatus.initial:
                    case InvoicesStatus.loading:
                      return SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height * 0.6,
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      );
                    case InvoicesStatus.error:
                      return SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height * 0.6,
                          child: Center(
                            child: Text(
                              state.failure?.message ??
                                  'Error loading invoices',
                              style: TextStyle(color: AppColors.redDark),
                            ),
                          ),
                        ),
                      );
                    case InvoicesStatus.empty:
                      return ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.6,
                            child: InvoicesEmptyState(
                              hasFilter: hasActiveFilter,
                            ),
                          ),
                        ],
                      );
                    case InvoicesStatus.success:
                      return ListView.builder(
                        padding: EdgeInsets.symmetric(
                          vertical: AppSizes.spacingSmall,
                        ),
                        itemCount: state.invoices.length,
                        itemBuilder: (context, index) => InvoiceCard(
                          invoice: state.invoices[index],
                          onTap: () {
                            context.push(
                              AppRoutes.invoiceDetailsPath(
                                state.invoices[index].id,
                              ),
                            );
                          },
                        ),
                      );
                  }
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: PermissionGate(
        permission: PermissionKeys.invoicesCreate,
        child: FloatingActionButton.extended(
          onPressed: () => context.push(AppRoutes.invoiceCreate),
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.surface,
          icon: const Icon(Icons.add),
          label: Text(AppStrings.invoiceNew),
        ),
      ),
    );
  }

  Widget _buildFilters(bool hasActiveFilter) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSizes.spacingMedium,
        AppSizes.spacingSmall,
        AppSizes.spacingMedium,
        AppSizes.spacingSmall,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final screenWidth = MediaQuery.sizeOf(context).width;
              final useWrap = screenWidth < 400;
              return useWrap
                  ? Wrap(
                      spacing: AppSizes.spacingSmall,
                      runSpacing: AppSizes.spacingSmall,
                      children: [
                        InvoiceFilterChip(
                          label: AppStrings.customerAllFilter,
                          selected:
                              _selectedStatus == null &&
                              _selectedCustomerId.isEmpty,
                          onTap: _clearFilters,
                        ),
                        InvoiceFilterChip(
                          label: AppStrings.customerPaidFilter,
                          selected: _selectedStatus == InvoiceStatus.paid,
                          onTap: () => _setStatusFilter(InvoiceStatus.paid),
                        ),
                        InvoiceFilterChip(
                          label: AppStrings.customerPartialFilter,
                          selected: _selectedStatus == InvoiceStatus.partial,
                          onTap: () => _setStatusFilter(InvoiceStatus.partial),
                        ),
                        InvoiceFilterChip(
                          label: AppStrings.customerDeferredFilter,
                          selected: _selectedStatus == InvoiceStatus.debt,
                          onTap: () => _setStatusFilter(InvoiceStatus.debt),
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        InvoiceFilterChip(
                          label: AppStrings.customerAllFilter,
                          selected:
                              _selectedStatus == null &&
                              _selectedCustomerId.isEmpty,
                          onTap: _clearFilters,
                        ),
                        SizedBox(width: AppSizes.spacingSmall),
                        InvoiceFilterChip(
                          label: AppStrings.customerPaidFilter,
                          selected: _selectedStatus == InvoiceStatus.paid,
                          onTap: () => _setStatusFilter(InvoiceStatus.paid),
                        ),
                        SizedBox(width: AppSizes.spacingSmall),
                        InvoiceFilterChip(
                          label: AppStrings.customerPartialFilter,
                          selected: _selectedStatus == InvoiceStatus.partial,
                          onTap: () => _setStatusFilter(InvoiceStatus.partial),
                        ),
                        SizedBox(width: AppSizes.spacingSmall),
                        InvoiceFilterChip(
                          label: AppStrings.customerDeferredFilter,
                          selected: _selectedStatus == InvoiceStatus.debt,
                          onTap: () => _setStatusFilter(InvoiceStatus.debt),
                        ),
                      ],
                    );
            },
          ),
          SizedBox(height: AppSizes.spacingSmall),
          _buildCustomerDropdown(),
        ],
      ),
    );
  }

  Widget _buildCustomerDropdown() {
    return BlocBuilder<InvoicesCubit, InvoicesState>(
      buildWhen: (prev, curr) => prev.customers != curr.customers,
      builder: (context, state) {
        return Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: AppSizes.spacingMedium),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
            border: Border.all(color: AppColors.inputBorder),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedCustomerId,
              isExpanded: true,
              hint: Text(
                AppStrings.customerSection,
                style: TextStyle(color: AppColors.textSecondary),
              ),
              items: [
                DropdownMenuItem<String>(
                  value: '',
                  child: Text(
                    AppStrings.customerAllFilter,
                    style: const TextStyle(color: AppColors.textDark),
                  ),
                ),
                ...state.customers.map(
                  (c) => DropdownMenuItem(value: c.id, child: Text(c.name)),
                ),
              ],
              onChanged: (id) => _setCustomerFilter(id),
            ),
          ),
        );
      },
    );
  }
}
