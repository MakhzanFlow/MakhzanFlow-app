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
import 'recent_invoices_card.dart';
import 'package:makhzanflow/shared/widgets/mf_entrance.dart';

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
    this.onViewAllInvoices,
    this.onCreateInvoice,
  });

  final String userName;
  final Company? company;
  final DashboardStats stats;
  final List<WeeklySalesPoint>? salesPoints;
  final bool isRefreshing;
  final bool isSalesLoading;
  final VoidCallback onRefresh;
  final ValueChanged<String>? onSalesRangeChanged;
  final VoidCallback? onViewAllInvoices;
  final VoidCallback? onCreateInvoice;

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

          // ① Greeting header — light & minimal: type-led, no color block
          _buildGreetingHeader(
            context,
            greeting: greeting,
            userName: userName,
            isArabic: isArabic,
            isDark: isDark,
            textPrimary: textPrimary,
            textSecondary: textSecondary,
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

  // ─── Greeting Header — light & minimal (ui-skills: hierarchy through type,
  // not color blocks). Canvas background; greeting is the hero (20/bold),
  // subtitle + date + company demoted via weight + muted color. Tinted avatar
  // carries identity without a dark banner.
  Widget _buildGreetingHeader(
    BuildContext context, {
    required String greeting,
    required String userName,
    required bool isArabic,
    required bool isDark,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    final displayName = userName.isNotEmpty
        ? userName
        : (isArabic ? 'المستخدم' : 'User');
    final initial = displayName.trim().isEmpty
        ? (isArabic ? 'م' : 'U')
        : String.fromCharCode(displayName.trim().runes.first).toUpperCase();
    final textMuted = isDark
        ? MFTokens.textMutedDark
        : MFTokens.textMutedLight;
    final avatarBg = isDark
        ? MFTokens.primaryDarkModeSubtle
        : MFTokens.primarySubtle;
    final avatarFg = isDark ? MFTokens.primaryDarkMode : MFTokens.primary;
    final align = !isArabic
        ? CrossAxisAlignment.end
        : CrossAxisAlignment.start;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        MFTokens.contentPaddingMobile,
        MFTokens.sp20,
        MFTokens.contentPaddingMobile,
        MFTokens.sp4,
      ),
      child: Column(
        crossAxisAlignment: align,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: align,
                  children: [
                    Text(
                      '$greeting $displayName',
                      style: TextStyle(
                        color: textPrimary,
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
                    const SizedBox(height: MFTokens.sp2),
                    Text(
                      isArabic
                          ? 'إليك ملخص نشاطك اليوم'
                          : "Here's today's summary",
                      style: TextStyle(
                        color: textSecondary,
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
              ),
              const SizedBox(width: MFTokens.sp12),
              // Identity avatar — 52px circle, primary tint, quiet ring
              Container(
                width: 52,
                height: 52,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: avatarBg,
                  border: Border.all(
                    color: avatarFg.withValues(alpha: 0.35),
                    width: 1.5,
                  ),
                ),
                child: Text(
                  initial,
                  style: TextStyle(
                    color: avatarFg,
                    fontSize: MFTokens.fontXL,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Cairo',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: MFTokens.sp10),
          // Meta row: date · company (one muted line, wraps once at most)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: 14,
                color: textMuted,
              ),
              const SizedBox(width: MFTokens.sp6),
              Flexible(
                child: Text(
                  _todayLabel(isArabic),
                  style: TextStyle(
                    color: textMuted,
                    fontSize: MFTokens.fontSM,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Cairo',
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (company != null) ...[
                Container(
                  width: 3,
                  height: 3,
                  margin: const EdgeInsets.symmetric(
                    horizontal: MFTokens.sp8,
                  ),
                  decoration: BoxDecoration(
                    color: textMuted.withValues(alpha: 0.6),
                    shape: BoxShape.circle,
                  ),
                ),
                Icon(
                  Icons.storefront_outlined,
                  size: 14,
                  color: textMuted,
                ),
                const SizedBox(width: MFTokens.sp6),
                Flexible(
                  child: Text(
                    company!.businessType?.isNotEmpty ?? false
                        ? '${company!.name} · ${company!.businessType!}'
                        : company!.name,
                    style: TextStyle(
                      color: textMuted,
                      fontSize: MFTokens.fontSM,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Cairo',
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  /// Locale-safe today label (static month/weekday names — no date-symbol init).
  static String _todayLabel(bool isArabic) {
    final now = DateTime.now();
    if (isArabic) {
      const days = [
        'الاثنين',
        'الثلاثاء',
        'الأربعاء',
        'الخميس',
        'الجمعة',
        'السبت',
        'الأحد',
      ];
      const months = [
        'يناير',
        'فبراير',
        'مارس',
        'أبريل',
        'مايو',
        'يونيو',
        'يوليو',
        'أغسطس',
        'سبتمبر',
        'أكتوبر',
        'نوفمبر',
        'ديسمبر',
      ];
      return '${days[now.weekday - 1]}، ${now.day} ${months[now.month - 1]} ${now.year}';
    }
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${days[now.weekday - 1]}, ${now.day} ${months[now.month - 1]} ${now.year}';
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
        final cards = metrics
            .map(
              (m) => _MetricCard(
                data: m,
                cardBg: cardBg,
                textSecondary: textSecondary,
                border: border,
              ),
            )
            .toList();
        return GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: MFTokens.sp12,
          mainAxisSpacing: MFTokens.sp12,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          // Reduced aspect to give extra vertical space and prevent 1.3px overflow (see _MetricCard)
          childAspectRatio: isWidePhone ? 1.45 : 1.30,
          children: [
            for (var i = 0; i < cards.length; i++)
              MFEntrance(index: i, child: cards[i]),
          ],
        );
      },
    );
  }

  // ─── Chart Card — ui-skills: ONE card (WeeklySalesChart renders content only,
  // no nested card), one header, full-width 40px segmented tabs (InkWell +
  // semantics), designed empty state. ─────────────────────────────────────────
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
    final primaryColor = isDark ? MFTokens.primaryDarkMode : MFTokens.primary;

    return FCard(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          MFTokens.sp16,
          MFTokens.sp12,
          MFTokens.sp16,
          MFTokens.sp12,
        ),
        // Rebuild header subtitle + segmented selection on tab taps.
        child: ValueListenableBuilder<int>(
          valueListenable: tabIndex,
          builder: (context, selected, _) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            // Header: icon tile + title/subtitle (subtitle mirrors selected range)
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isDark
                        ? MFTokens.primaryDarkModeSubtle
                        : MFTokens.primarySubtle,
                    borderRadius: BorderRadius.circular(MFTokens.radiusSM),
                  ),
                  child: Icon(
                    Icons.show_chart_rounded,
                    size: 20,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(width: MFTokens.sp12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isArabic ? 'المبيعات' : 'Sales',
                        style: TextStyle(
                          color: textPrimary,
                          fontSize: MFTokens.fontLG,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Cairo',
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        tabs[selected],
                        style: TextStyle(
                          color: textSecondary,
                          fontSize: MFTokens.fontXS,
                          fontFamily: 'Cairo',
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: MFTokens.sp12),
            // Segmented range control — full width, ≥40px targets, InkWell
            // feedback + radio semantics (baseline-ui: no hand-rolled focus).
            Material(
              color: Colors.transparent,
              child: Container(
                decoration: BoxDecoration(
                  color: isDark
                      ? MFTokens.borderDark
                      : MFTokens.surfaceMutedLight,
                  borderRadius: BorderRadius.circular(MFTokens.radiusSM),
                ),
                padding: const EdgeInsets.all(MFTokens.sp4),
                child: Row(
                  children: List.generate(tabs.length, (i) {
                    final isSelected = selected == i;
                    return Expanded(
                      child: Semantics(
                        button: true,
                        selected: isSelected,
                        label: tabs[i],
                        child: InkWell(
                          onTap: () {
                            tabIndex.value = i;
                            onSalesRangeChanged?.call(ranges[i]);
                          },
                          borderRadius: BorderRadius.circular(
                            MFTokens.radiusXS,
                          ),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeOut,
                            constraints:
                                const BoxConstraints(minHeight: 40),
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(
                              horizontal: MFTokens.sp8,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? primaryColor
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(
                                MFTokens.radiusXS,
                              ),
                              // Concentric: outer 8 = inner 4 + 4 padding ✓
                            ),
                            child: Text(
                              tabs[i],
                              style: TextStyle(
                                color: isSelected
                                    ? MFTokens.textInverseLight
                                    : textSecondary,
                                fontSize: MFTokens.fontSM,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                                fontFamily: 'Cairo',
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
            const SizedBox(height: MFTokens.sp12),
            if (salesPoints.isEmpty && !isSalesLoading)
              _ChartEmptyState(
                isArabic: isArabic,
                isDark: isDark,
                textSecondary: textSecondary,
                textMuted: isDark
                    ? MFTokens.textMutedDark
                    : MFTokens.textMutedLight,
              )
            else
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
      ),
    );
  }

  // ─── Recent Invoices — polished card (see recent_invoices_card.dart) ─────────
  // ui-skills: interface-design (hierarchy: amount > name > # + time),
  // baseline-ui (one accent, empty-state CTA), better-ui (stagger, tabular).
  Widget _buildRecentInvoicesCard(
    BuildContext context, {
    required bool isArabic,
    required bool isDark,
    required Color cardBg,
    required Color textPrimary,
    required Color textSecondary,
    required Color border,
  }) {
    return RecentInvoicesCard(
      activities: stats.recentActivities,
      isArabic: isArabic,
      isDark: isDark,
      onViewAll: onViewAllInvoices,
      onCreateInvoice: onCreateInvoice,
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

/// Designed empty state for the sales chart (baseline-ui: states not optional).
class _ChartEmptyState extends StatelessWidget {
  const _ChartEmptyState({
    required this.isArabic,
    required this.isDark,
    required this.textSecondary,
    required this.textMuted,
  });

  final bool isArabic;
  final bool isDark;
  final Color textSecondary;
  final Color textMuted;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: MFTokens.sp24),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: isDark
                    ? MFTokens.surfaceMutedDark
                    : MFTokens.surfaceMutedLight,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.timeline_rounded,
                size: 26,
                color: textMuted,
              ),
            ),
            const SizedBox(height: MFTokens.sp12),
            Text(
              isArabic ? 'لا توجد بيانات بعد' : 'No data yet',
              style: TextStyle(
                color: textSecondary,
                fontSize: MFTokens.fontMD,
                fontWeight: FontWeight.w600,
                fontFamily: 'Cairo',
              ),
            ),
            const SizedBox(height: MFTokens.sp4),
            Text(
              isArabic
                  ? 'ستظهر مبيعاتك هنا فور تسجيلها'
                  : 'Your sales will appear here once recorded',
              style: TextStyle(
                color: textMuted,
                fontSize: MFTokens.fontSM,
                fontFamily: 'Cairo',
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

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
    // ui-skills: hero value wins via size (18) + weight + tabular figures;
    // label demoted to 11/muted; 36px icon tile (concentric 12 ≈ 8 + padding).
    return FCard(
      child: Padding(
        padding: const EdgeInsets.all(MFTokens.sp12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: data.iconBg,
                borderRadius: BorderRadius.circular(MFTokens.radiusSM),
              ),
              child: Icon(data.icon, size: 18, color: data.iconColor),
            ),
            const SizedBox(height: MFTokens.sp8),
            Text(
              data.title,
              style: TextStyle(
                color: textSecondary,
                fontSize: MFTokens.fontXS,
                fontWeight: FontWeight.w500,
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
                      fontSize: MFTokens.fontXL,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Cairo',
                      fontFeatures: const [
                        ui.FontFeature.tabularFigures(),
                      ],
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

