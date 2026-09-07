import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:makhzanflow/core/theme/app_locale_cubit.dart';
import 'package:makhzanflow/core/theme/mf_tokens.dart';
import 'package:makhzanflow/features/companies/domain/entities/company.dart';
import 'package:makhzanflow/features/dashboard/domain/entities/dashboard_stats.dart';
import 'package:makhzanflow/features/dashboard/domain/entities/weekly_sales_point.dart';
import 'weekly_sales_chart.dart';

/// Redesigned dashboard body using ForUI cards + design tokens.
///
/// Layout (scrollable):
///  ① Greeting header
///  ② 2×2 metric cards (Sales / Profit / Invoices / Overdue)
///  ③ Sales chart with Today/Week/Month tab
///  ④ Recent invoices table
/// Minimal ForUI dashboard — uses FCard + flutter_hooks for a clean, airy layout.
/// `dart run forui init` themes (lib/theme/) provide light/dark via MFTokens, Cairo.
/// Hook state replaces StatefulWidget for the chart tabs (clearer, less boilerplate).
class DashboardLoadedBody extends HookWidget {
  const DashboardLoadedBody({
    super.key,
    required this.userName,
    required this.company,
    required this.stats,
    this.salesPoints,
    required this.isRefreshing,
    this.isSalesLoading = false,
    required this.onRefresh,
    this.onSalesRangeChanged,
  });

  final String userName;
  final Company? company;
  final DashboardStats stats;
  final List<WeeklySalesPoint>? salesPoints;
  final bool isRefreshing;
  final bool isSalesLoading;
  final VoidCallback onRefresh;
  final ValueChanged<String>? onSalesRangeChanged;

  @override
  Widget build(BuildContext context) {
    // forui_hooks / flutter_hooks — minimal state for chart period tabs
    final chartTabIndex = useState(2); // 0=90d, 1=30d, 2=7d
    final isArabic = context.watch<AppLocaleCubit>().state.isArabic;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? MFTokens.cardDark : MFTokens.cardLight;
    final textPrimary = isDark
        ? MFTokens.textPrimaryDark
        : MFTokens.textPrimaryLight;
    final textSecondary = isDark
        ? MFTokens.textSecondaryDark
        : MFTokens.textSecondaryLight;
    final border = isDark ? MFTokens.borderDark : MFTokens.borderLight;

    final greeting = _getGreeting(isArabic);

    final primaryColor = isDark ? MFTokens.primaryDarkMode : MFTokens.primary;
    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      color: primaryColor,
      child: ListView(
        padding: const EdgeInsets.only(bottom: MFTokens.sp32),
        children: [
          if (isRefreshing)
            LinearProgressIndicator(
              minHeight: 2,
              backgroundColor: isDark
                  ? MFTokens.successBgDark
                  : MFTokens.successBg,
              valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
            ),

          // ① Greeting header — minimal ForUI: large type, generous whitespace, no heavy shadow
          _buildGreetingHeader(
            context,
            greeting: greeting,
            userName: userName,
            isArabic: isArabic,
            isDark: isDark,
            textPrimary: textPrimary,
            textSecondary: textSecondary,
            bg: isDark ? MFTokens.sidebarBgDark : MFTokens.sidebarBg,
          ),

          const SizedBox(height: MFTokens.sp20),

          // ② Metrics grid
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: MFTokens.contentPaddingMobile,
            ),
            child: _buildMetricsGrid(
              context,
              isArabic: isArabic,
              isDark: isDark,
              cardBg: cardBg,
              textPrimary: textPrimary,
              textSecondary: textSecondary,
              border: border,
            ),
          ),

          const SizedBox(height: MFTokens.sp20),

          // ③ Sales chart — minimal FCard with hook-driven FTabs
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: MFTokens.contentPaddingMobile,
            ),
            child: _buildChartCard(
              context,
              isArabic: isArabic,
              isDark: isDark,
              cardBg: cardBg,
              textPrimary: textPrimary,
              textSecondary: textSecondary,
              border: border,
              tabIndex: chartTabIndex,
              salesPoints: salesPoints ?? stats.weeklySales,
              isSalesLoading: isSalesLoading,
              onSalesRangeChanged: onSalesRangeChanged,
            ),
          ),

          const SizedBox(height: MFTokens.sp20),

          // ④ Recent invoices
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: MFTokens.contentPaddingMobile,
            ),
            child: _buildRecentInvoicesCard(
              context,
              isArabic: isArabic,
              isDark: isDark,
              cardBg: cardBg,
              textPrimary: textPrimary,
              textSecondary: textSecondary,
              border: border,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Greeting Header — uses tokens, no hardcoded sizes/colors ──────────────
  Widget _buildGreetingHeader(
    BuildContext context, {
    required String greeting,
    required String userName,
    required bool isArabic,
    required bool isDark,
    required Color textPrimary,
    required Color textSecondary,
    required Color bg,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        MFTokens.sp20,
        MFTokens.sp20,
        MFTokens.sp20,
        MFTokens.sp24,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(MFTokens.radiusXL),
          bottomRight: Radius.circular(MFTokens.radiusXL),
        ),
      ),
      child: Column(
        crossAxisAlignment: isArabic
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Text(
            '$greeting ${userName.isNotEmpty ? userName : (isArabic ? 'المستخدم' : 'User')} 👋',
            style: const TextStyle(
              color: MFTokens.textInverseLight,
              fontSize: MFTokens.font2XL,
              fontWeight: FontWeight.bold,
              fontFamily: 'Cairo',
            ),
            textDirection: isArabic
                ? ui.TextDirection.rtl
                : ui.TextDirection.ltr,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            softWrap: true,
          ),
          const SizedBox(height: MFTokens.sp4),
          Text(
            isArabic ? 'إليك ملخص نشاطك اليوم' : "Here's today's summary",
            style: TextStyle(
              color: MFTokens.sidebarTextInactive,
              fontSize: MFTokens.fontBase,
              fontFamily: 'Cairo',
            ),
            textDirection: isArabic
                ? ui.TextDirection.rtl
                : ui.TextDirection.ltr,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // ─── Metrics Grid — tokens only, no hardcoded hex ──────────────────────────
  Widget _buildMetricsGrid(
    BuildContext context, {
    required bool isArabic,
    required bool isDark,
    required Color cardBg,
    required Color textPrimary,
    required Color textSecondary,
    required Color border,
  }) {
    final primaryColor = isDark ? MFTokens.primaryDarkMode : MFTokens.primary;
    final currency = isArabic ? 'ج.م' : 'EGP';

    final metrics = [
      _MetricData(
        title: isArabic ? 'المبيعات' : 'Sales',
        value: _formatAmount(stats.todaySales),
        suffix: currency,
        icon: Icons.trending_up_rounded,
        iconBg: isDark ? MFTokens.successBgDark : MFTokens.successBg,
        iconColor: primaryColor,
        valueColor: textPrimary,
      ),
      _MetricData(
        title: isArabic ? 'الأرباح' : 'Profit',
        value: _formatAmount(stats.monthlyPayments),
        suffix: currency,
        icon: Icons.account_balance_wallet_outlined,
        iconBg: isDark ? MFTokens.warningBgDark : MFTokens.warningBg,
        iconColor: MFTokens.accent,
        valueColor: textPrimary,
      ),
      _MetricData(
        title: isArabic ? 'الفواتير' : 'Invoices',
        value: stats.productsCount.toString(),
        suffix: null,
        icon: Icons.receipt_long_outlined,
        iconBg: isDark ? MFTokens.infoBgDark : MFTokens.infoSubtle,
        iconColor: MFTokens.info,
        valueColor: textPrimary,
      ),
      _MetricData(
        title: isArabic ? 'المتأخرات' : 'Overdue',
        value: _formatAmount(stats.totalDebt),
        suffix: currency,
        icon: Icons.warning_amber_outlined,
        iconBg: isDark ? MFTokens.errorBgDark : MFTokens.errorBg,
        iconColor: isDark ? MFTokens.errorTextDark : MFTokens.errorText,
        valueColor: textPrimary,
      ),
    ];

    return LayoutBuilder(
      builder: (context, c) {
        // Mobile: 2 columns; larger phones/tablets handled by parent width
        final isWidePhone = c.maxWidth >= 360;
        return GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: MFTokens.sp12,
          mainAxisSpacing: MFTokens.sp12,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          // Reduced aspect to give extra vertical space and prevent 1.3px overflow (see _MetricCard)
          childAspectRatio: isWidePhone ? 1.45 : 1.30,
          children: metrics
              .map(
                (m) => _MetricCard(
                  data: m,
                  cardBg: cardBg,
                  textSecondary: textSecondary,
                  border: border,
                ),
              )
              .toList(),
        );
      },
    );
  }

  // ─── Chart Card — minimal ForUI FCard + hook-driven tabs ───────────────────
  Widget _buildChartCard(
    BuildContext context, {
    required bool isArabic,
    required bool isDark,
    required Color cardBg,
    required Color textPrimary,
    required Color textSecondary,
    required Color border,
    required ValueNotifier<int> tabIndex,
    required List<WeeklySalesPoint> salesPoints,
    required bool isSalesLoading,
    ValueChanged<String>? onSalesRangeChanged,
  }) {
    final tabs = isArabic
        ? ['آخر 3 أشهر', 'آخر 30 يوم', 'آخر 7 أيام']
        : ['Last 3 months', 'Last 30 days', 'Last 7 days'];
    const ranges = ['90d', '30d', '7d'];

    // Minimal FCard — ForUI provides consistent padding/border/shadow via theme/style
    return FCard(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          MFTokens.sp16,
          MFTokens.sp12,
          MFTokens.sp16,
          MFTokens.sp12,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isArabic ? 'المبيعات' : 'Sales',
                  style: TextStyle(
                    color: textPrimary,
                    fontSize: MFTokens.fontLG,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Cairo',
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: isDark
                        ? MFTokens.borderDark
                        : MFTokens.surfaceMutedLight,
                    borderRadius: BorderRadius.circular(MFTokens.radiusSM),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(tabs.length, (i) {
                      final isSelected = tabIndex.value == i;
                      return GestureDetector(
                        onTap: () {
                          tabIndex.value = i;
                          onSalesRangeChanged?.call(ranges[i]);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: MFTokens.sp10,
                            vertical: MFTokens.sp6,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? (isDark
                                      ? MFTokens.primaryDarkMode
                                      : MFTokens.primary)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(
                              MFTokens.radiusSM,
                            ),
                          ),
                          child: Text(
                            tabs[i],
                            style: TextStyle(
                              color: isSelected
                                  ? MFTokens.textInverseLight
                                  : textSecondary,
                              fontSize: MFTokens.fontXS,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              fontFamily: 'Cairo',
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
            const SizedBox(height: MFTokens.sp12),
            Stack(
              children: [
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 150),
                  opacity: isSalesLoading ? 0.45 : 1,
                  child: WeeklySalesChart(points: salesPoints),
                ),
                if (isSalesLoading)
                  const Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: LinearProgressIndicator(minHeight: 2),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ─── Recent Invoices ───────────────────────────────────────────────────────
  Widget _buildRecentInvoicesCard(
    BuildContext context, {
    required bool isArabic,
    required bool isDark,
    required Color cardBg,
    required Color textPrimary,
    required Color textSecondary,
    required Color border,
  }) {
    final currency = isArabic ? 'ج.م' : 'EGP';
    final activities = stats.recentActivities;

    // ForUI FCard gives minimal border + consistent radius, no heavy shadow — clearer hierarchy
    return FCard(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          MFTokens.sp16,
          MFTokens.sp12,
          MFTokens.sp16,
          MFTokens.sp12,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isArabic ? 'آخر الفواتير' : 'Recent Invoices',
              style: TextStyle(
                color: textPrimary,
                fontSize: MFTokens.fontLG,
                fontWeight: FontWeight.bold,
                fontFamily: 'Cairo',
              ),
            ),
            const SizedBox(height: MFTokens.sp8),
            Divider(color: border, height: 1),
            if (activities.isEmpty)
              Padding(
                padding: const EdgeInsets.all(MFTokens.sp24),
                child: Center(
                  child: Text(
                    isArabic ? 'لا توجد فواتير' : 'No invoices yet',
                    style: TextStyle(
                      color: textSecondary,
                      fontSize: MFTokens.fontBase,
                      fontFamily: 'Cairo',
                    ),
                  ),
                ),
              )
            else
              ...activities.take(5).map((activity) {
                final entityId = activity.entityId ?? '';
                final name = activity.userName;
                final amount =
                    (activity.details?['amount'] as num?)?.toDouble() ?? 0.0;
                return _InvoiceRow(
                  invoiceNumber: '#$entityId',
                  customerName: name,
                  amount: '${_formatAmount(amount)} $currency',
                  isDark: isDark,
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                  border: border,
                  primaryColor: isDark
                      ? MFTokens.primaryDarkMode
                      : MFTokens.primary,
                );
              }),
            const SizedBox(height: MFTokens.sp8),
          ],
        ),
      ),
    );
  }

  // ─── Helpers ───────────────────────────────────────────────────────────────
  String _getGreeting(bool isArabic) {
    final hour = DateTime.now().hour;
    if (isArabic) {
      if (hour < 12) return 'صباح الخير،';
      if (hour < 17) return 'مساء الخير،';
      return 'مساء النور،';
    } else {
      if (hour < 12) return 'Good morning,';
      if (hour < 17) return 'Good afternoon,';
      return 'Good evening,';
    }
  }

  String _formatAmount(double v) {
    if (v >= 1000000) {
      return NumberFormat('#,##0.0', 'ar').format(v / 1000000) +
          (NumberFormat.compact(locale: 'en').format(1000000).substring(1));
    }
    return NumberFormat('#,##0', 'ar').format(v);
  }
}

// ─── Sub-widgets ──────────────────────────────────────────────────────────────

class _MetricData {
  const _MetricData({
    required this.title,
    required this.value,
    required this.suffix,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.valueColor,
  });
  final String title;
  final String value;
  final String? suffix;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final Color valueColor;
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.data,
    required this.cardBg,
    required this.textSecondary,
    required this.border,
  });

  final _MetricData data;
  final Color cardBg;
  final Color textSecondary;
  final Color border;

  @override
  Widget build(BuildContext context) {
    // Minimal ForUI card — uses theme's cardStyle (MFTokens radius/border/shadow) for a clean look.
    // No heavy shadows, just subtle border + MFTokens surface, Cairo typography, airy padding.
    return FCard(
      child: Padding(
        padding: const EdgeInsets.all(MFTokens.sp12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: data.iconBg,
                borderRadius: BorderRadius.circular(MFTokens.radiusSM),
              ),
              child: Icon(data.icon, size: 16, color: data.iconColor),
            ),
            const SizedBox(height: MFTokens.sp8),
            Text(
              data.title,
              style: TextStyle(
                color: textSecondary,
                fontSize: MFTokens.fontXS,
                fontFamily: 'Cairo',
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: MFTokens.sp2),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: AlignmentDirectional.centerStart,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    data.value,
                    style: TextStyle(
                      color: data.valueColor,
                      fontSize: MFTokens.fontLG,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Cairo',
                    ),
                  ),
                  if (data.suffix != null) ...[
                    const SizedBox(width: MFTokens.sp4),
                    Text(
                      data.suffix!,
                      style: TextStyle(
                        color: textSecondary,
                        fontSize: MFTokens.fontXS,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InvoiceRow extends StatelessWidget {
  const _InvoiceRow({
    required this.invoiceNumber,
    required this.customerName,
    required this.amount,
    required this.isDark,
    required this.textPrimary,
    required this.textSecondary,
    required this.border,
    required this.primaryColor,
  });

  final String invoiceNumber;
  final String customerName;
  final String amount;
  final bool isDark;
  final Color textPrimary;
  final Color textSecondary;
  final Color border;
  final Color primaryColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: MFTokens.sp16,
        vertical: MFTokens.sp12,
      ),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: border, width: 0.5)),
      ),
      child: Row(
        children: [
          Flexible(
            flex: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: MFTokens.sp8,
                vertical: MFTokens.sp4,
              ),
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(MFTokens.radiusXS),
              ),
              child: Text(
                invoiceNumber,
                style: TextStyle(
                  color: primaryColor,
                  fontSize: MFTokens.fontXS,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Cairo',
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ),
          const SizedBox(width: MFTokens.sp10),
          Expanded(
            child: Text(
              customerName,
              style: TextStyle(
                color: textPrimary,
                fontSize: MFTokens.fontBase,
                fontWeight: FontWeight.w500,
                fontFamily: 'Cairo',
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          const SizedBox(width: MFTokens.sp8),
          Flexible(
            child: Text(
              amount,
              style: TextStyle(
                color: textPrimary,
                fontSize: MFTokens.fontBase,
                fontWeight: FontWeight.w700,
                fontFamily: 'Cairo',
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
