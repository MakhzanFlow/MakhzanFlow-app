import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:makhzanflow/core/company/company_aware_state.dart';
import 'package:makhzanflow/core/constants/app_strings.dart';
import 'package:makhzanflow/core/permissions/permission_constants.dart';
import 'package:makhzanflow/core/permissions/permission_gate.dart';
import 'package:makhzanflow/core/theme/mf_tokens.dart';
import 'package:makhzanflow/core/widgets/app_snackbar.dart';
import 'package:makhzanflow/shared/widgets/makhzanflow_empty_state.dart';
import 'package:makhzanflow/shared/widgets/makhzanflow_search_field.dart';
import '../cubit/payments_cubit.dart';

/// Paginated payment history backed by `GET /api/payments`
/// (search / date-range / sort supported server-side).
class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({super.key});

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen>
    with CompanyAwareState<PaymentsScreen> {
  final _searchController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  String? _sort;
  String? _order;

  @override
  void initState() {
    super.initState();
    context.read<PaymentsCubit>().load();
  }

  @override
  void onCompanyChanged(String companyId) {
    context.read<PaymentsCubit>().load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    context.read<PaymentsCubit>().setFilters(
          search: _searchController.text.trim().isEmpty
              ? null
              : _searchController.text.trim(),
          startDate: _startDate,
          endDate: _endDate,
          sort: _sort,
          order: _order,
        );
  }

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 5),
      lastDate: now,
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
    );
    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      _applyFilters();
    }
  }

  void _clearDates() {
    setState(() {
      _startDate = null;
      _endDate = null;
    });
    _applyFilters();
  }

  String _dateLabel(DateTime d) =>
      DateFormat('yyyy-MM-dd').format(d);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? MFTokens.backgroundDark : MFTokens.backgroundLight;
    final textPrimary =
        isDark ? MFTokens.textPrimaryDark : MFTokens.textPrimaryLight;
    final textSecondary =
        isDark ? MFTokens.textSecondaryDark : MFTokens.textSecondaryLight;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text(AppStrings.paymentsTitle),
      ),
      body: PermissionGate(
        permission: PermissionKeys.paymentsView,
        fallback: Center(
          child: Text(
            AppStrings.noPermission,
            style: TextStyle(color: textSecondary, fontFamily: 'Cairo'),
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(MFTokens.sp16),
              child: Column(
                children: [
                  MakhzanFlowSearchField(
                    controller: _searchController,
                    hintText: AppStrings.paymentsSearchHint,
                    onChanged: (_) => _applyFilters(),
                  ),
                  const SizedBox(height: MFTokens.sp12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _pickDateRange,
                          icon: const Icon(Icons.date_range_outlined, size: 18),
                          label: Text(
                            _startDate != null && _endDate != null
                                ? '${_dateLabel(_startDate!)} → ${_dateLabel(_endDate!)}'
                                : AppStrings.paymentsDateRange,
                            style: const TextStyle(
                                fontFamily: 'Cairo', fontSize: 12),
                          ),
                        ),
                      ),
                      if (_startDate != null) ...[
                        const SizedBox(width: MFTokens.sp8),
                        IconButton(
                          onPressed: _clearDates,
                          icon: const Icon(Icons.clear, size: 18),
                        ),
                      ],
                      const SizedBox(width: MFTokens.sp8),
                      DropdownButton<String>(
                        value: _sort,
                        hint: Text(AppStrings.paymentsSort,
                            style: const TextStyle(
                                fontFamily: 'Cairo', fontSize: 12)),
                        items: [
                          DropdownMenuItem(
                              value: 'created_at',
                              child: Text(AppStrings.paymentsSortNewest,
                                  style: const TextStyle(
                                      fontFamily: 'Cairo', fontSize: 12))),
                          DropdownMenuItem(
                              value: 'amount',
                              child: Text(AppStrings.paymentsSortAmount,
                                  style: const TextStyle(
                                      fontFamily: 'Cairo', fontSize: 12))),
                        ],
                        onChanged: (v) {
                          setState(() {
                            _sort = v;
                            _order = 'desc';
                          });
                          _applyFilters();
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: BlocConsumer<PaymentsCubit, PaymentsState>(
                listener: (context, state) {
                  if (state.status == PaymentsStatus.error &&
                      state.failure != null) {
                    AppSnackbar.error(context, state.failure!.message);
                  }
                },
                builder: (context, state) {
                  if (state.status == PaymentsStatus.loading ||
                      state.status == PaymentsStatus.initial) {
                    return const Center(
                        child: CircularProgressIndicator());
                  }
                  if (state.status == PaymentsStatus.empty) {
                    return MakhzanFlowEmptyState(
                      icon: Icons.payments_outlined,
                      message: AppStrings.paymentsEmpty,
                      actionLabel: AppStrings.retry,
                      onAction: () =>
                          context.read<PaymentsCubit>().refresh(),
                    );
                  }
                  if (state.status == PaymentsStatus.error &&
                      state.payments.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            state.failure?.message ??
                                AppStrings.unexpectedError,
                            style: TextStyle(
                                color: textSecondary, fontFamily: 'Cairo'),
                          ),
                          const SizedBox(height: MFTokens.sp12),
                          ElevatedButton(
                            onPressed: () =>
                                context.read<PaymentsCubit>().refresh(),
                            child: Text(AppStrings.retry),
                          ),
                        ],
                      ),
                    );
                  }
                  final total = state.payments.fold<double>(
                      0, (sum, p) => sum + p.amount);
                  return RefreshIndicator(
                    onRefresh: () =>
                        context.read<PaymentsCubit>().refresh(),
                    child: ListView(
                      padding: const EdgeInsets.symmetric(
                          horizontal: MFTokens.sp16),
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                              bottom: MFTokens.sp8),
                          child: Text(
                            AppStrings.paymentsTotal(
                                total.toStringAsFixed(2)),
                            style: TextStyle(
                              color: textPrimary,
                              fontFamily: 'Cairo',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        ...state.payments.map(
                          (p) => _PaymentCard(
                            invoiceNumber:
                                p.invoiceNumber ?? p.invoiceId,
                            customerName:
                                p.customerName ?? AppStrings.unknownCustomer,
                            amount: p.amount,
                            method: p.method,
                            date: p.createdAt,
                          ),
                        ),
                        const SizedBox(height: MFTokens.sp24),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentCard extends StatelessWidget {
  final String invoiceNumber;
  final String customerName;
  final double amount;
  final String method;
  final DateTime? date;

  const _PaymentCard({
    required this.invoiceNumber,
    required this.customerName,
    required this.amount,
    required this.method,
    this.date,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? MFTokens.cardDark : MFTokens.cardLight;
    final textPrimary =
        isDark ? MFTokens.textPrimaryDark : MFTokens.textPrimaryLight;
    final textSecondary =
        isDark ? MFTokens.textSecondaryDark : MFTokens.textSecondaryLight;
    final dateStr =
        date != null ? DateFormat('yyyy-MM-dd').format(date!) : '';

    return Card(
      color: cardBg,
      margin: const EdgeInsets.only(bottom: MFTokens.sp12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(MFTokens.sp12),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: MFTokens.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(MFTokens.radiusSM),
          ),
          child: const Icon(Icons.payments_outlined, color: MFTokens.primary),
        ),
        title: Text(
          '$invoiceNumber • $customerName',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
        ),
        subtitle: Text(
          [method, if (dateStr.isNotEmpty) dateStr].join(' • '),
          style: TextStyle(
              fontFamily: 'Cairo', fontSize: 12, color: textSecondary),
        ),
        trailing: Text(
          amount.toStringAsFixed(2),
          style: TextStyle(
            fontFamily: 'Cairo',
            fontWeight: FontWeight.w700,
            color: isDark ? MFTokens.primaryDarkMode : MFTokens.primary,
          ),
        ),
      ),
    );
  }
}
