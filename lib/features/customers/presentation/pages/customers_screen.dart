import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/company/company_aware_state.dart';
import '../../../../core/theme/mf_tokens.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/permissions/permission_constants.dart';
import '../../../../core/permissions/permission_gate.dart';
import '../../domain/entities/customer.dart';
import '../cubit/customers/customers_cubit.dart';
import '../widgets/customer_card.dart';
import '../widgets/customer_empty_view.dart';
import '../widgets/customer_error_view.dart';
import '../widgets/customer_filter_chips.dart';
import '../widgets/customer_list_header.dart';
import '../widgets/customer_loading_view.dart';
import '../widgets/customer_search_bar.dart';

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen>
    with CompanyAwareState<CustomersScreen> {
  late final CustomersCubit _cubit;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String _selectedFilter = 'all';
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _cubit = context.read<CustomersCubit>();
      _cubit.loadCustomers(companyId);
      _scrollController.addListener(_onScroll);
      _initialized = true;
    }
  }

  @override
  void onCompanyChanged(String companyId) {
    _cubit.loadCustomers(companyId);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _cubit.loadMore(companyId);
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onAddCustomer() async {
    final added = await context.push<bool>(AppRoutes.customerNew);
    if (added == true && mounted) {
      _cubit.refresh(companyId);
    }
  }

  List<Customer> _filteredCustomers() {
    final all = _cubit.state.customers;
    switch (_selectedFilter) {
      case 'paid':
        return all.where((c) => c.totalDebt == 0).toList();
      case 'deferred':
        return all.where((c) => c.totalDebt > 0).toList();
      default:
        return all;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? MFTokens.backgroundDark : MFTokens.backgroundLight;
    final accent = isDark ? MFTokens.primaryDarkMode : MFTokens.accent;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => _cubit.refresh(companyId),
          child: CustomScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: BlocBuilder<CustomersCubit, CustomersState>(
                  builder: (context, state) {
                    return CustomerListHeader(
                      totalCount: state.filterCounts.totalCount,
                      totalDebt: state.filterCounts.totalDebtSum,
                    );
                  },
                ),
              ),
              SliverToBoxAdapter(
                child: CustomerSearchBar(
                  controller: _searchController,
                  onChanged: (query) =>
                      _cubit.updateSearchQuery(query, companyId),
                  onClear: () {
                    _searchController.clear();
                    _cubit.updateSearchQuery('', companyId);
                  },
                  onAdd: _onAddCustomer,
                ),
              ),
              SliverToBoxAdapter(
                child: BlocBuilder<CustomersCubit, CustomersState>(
                  builder: (context, state) {
                    return CustomerFilterChips(
                      selectedFilter: _selectedFilter,
                      onFilterChanged: (filter) {
                        setState(() => _selectedFilter = filter);
                      },
                      totalCount: state.filterCounts.totalCount,
                      paidCount: state.filterCounts.paidCount,
                      partialCount: state.filterCounts.partialCount,
                      deferredCount: state.filterCounts.deferredCount,
                    );
                  },
                ),
              ),
              BlocBuilder<CustomersCubit, CustomersState>(
                builder: (context, state) {
                  return switch (state.status) {
                    CustomersStatus.initial || CustomersStatus.loading =>
                      const SliverFillRemaining(child: CustomerLoadingView()),
                    CustomersStatus.error => SliverFillRemaining(
                      child: CustomerErrorView(
                        message:
                            state.failure?.message ?? AppStrings.unexpectedError,
                        onRetry: () => _cubit.loadCustomers(companyId),
                      ),
                    ),
                    CustomersStatus.empty => SliverFillRemaining(
                      child: CustomerEmptyView(
                        message: state.query.isNotEmpty
                            ? AppStrings.customerEmptySearch
                            : AppStrings.emptyCustomers,
                      ),
                    ),
                    CustomersStatus.success => SliverPadding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: MFTokens.sp16,
                      ),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final filtered = _filteredCustomers();
                          if (index >= filtered.length) return null;
                          final customer = filtered[index];
                          return Padding(
                            padding: const EdgeInsets.only(
                              bottom: MFTokens.sp8,
                            ),
                            child: CustomerCard(
                              customer: customer,
                              onTap: () async {
                                final updated = await context.push<bool>(
                                  AppRoutes.customerDetailsPath(customer.id),
                                );
                                if (updated == true && mounted) {
                                  _cubit.refresh(companyId);
                                }
                              },
                            ),
                          );
                        }, childCount: _filteredCustomers().length),
                      ),
                    ),
                  };
                },
              ),
              BlocBuilder<CustomersCubit, CustomersState>(
                builder: (context, state) {
                  if (!state.isLoadingMore) {
                    return const SliverToBoxAdapter();
                  }
                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(MFTokens.sp16),
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: PermissionGate(
        permission: PermissionKeys.customersCreate,
        child: FloatingActionButton(
          heroTag: 'customers_fab',
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32),
          ),
          backgroundColor: accent,
          onPressed: _onAddCustomer,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }
}
