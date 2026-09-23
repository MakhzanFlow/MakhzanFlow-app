import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:makhzanflow/core/constants/app_strings.dart';
import 'package:makhzanflow/core/theme/mf_tokens.dart';
import '../../domain/entities/weekly_sales_point.dart';

/// Chart — uses [MFTokens] only (no hardcoded AppColors/AppSizes)
class WeeklySalesChart extends StatefulWidget {
  const WeeklySalesChart({super.key, required this.points});
  final List<WeeklySalesPoint> points;

  @override
  State<WeeklySalesChart> createState() => _WeeklySalesChartState();
}

class _WeeklySalesChartState extends State<WeeklySalesChart>
    with SingleTickerProviderStateMixin {
  int _touchedIndex = -1;
  late final AnimationController _controller;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _anim = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatCompactAmount(double amount, String localeCode) {
    final isAr = localeCode.startsWith('ar');
    if (amount >= 1000000) {
      final val = amount / 1000000;
      final formattedVal = val.toStringAsFixed(val % 1 == 0 ? 0 : 1);
      return isAr ? '$formattedVal م' : '${formattedVal}M';
    } else if (amount >= 1000) {
      final val = amount / 1000;
      final formattedVal = val.toStringAsFixed(val % 1 == 0 ? 0 : 1);
      return isAr ? '$formattedVal ألف' : '${formattedVal}k';
    }
    return amount.toInt().toString();
  }

  String _getLocalizedDayLabel(WeeklySalesPoint point, String localeCode) {
    try {
      return DateFormat.E(localeCode).format(point.date);
    } catch (_) {
      return point.label;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.points.isEmpty) {
      return const SizedBox.shrink();
    }
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final localeCode = Localizations.localeOf(context).languageCode;
    final currencySymbol = AppStrings.currencyEg;
    final isArabic = AppStrings.isArabic;

    final maxY = widget.points
        .map((p) => p.amount)
        .reduce((a, b) => a > b ? a : b);
    final effectiveMax = maxY <= 0 ? 1000.0 : maxY * 1.25;
    final totalSum = widget.points.fold<double>(0, (sum, p) => sum + p.amount);

    final primary = isDark ? MFTokens.primaryDarkMode : MFTokens.primary;
    final accentColor = MFTokens.accent;
    final mutedGrid = isDark ? MFTokens.borderDark : MFTokens.borderLight;
    final tooltipBg = isDark ? MFTokens.surfaceDark : MFTokens.primaryDark;
    final cardBg = isDark ? MFTokens.cardDark : MFTokens.cardLight;
    final textPrimary = isDark ? MFTokens.textPrimaryDark : MFTokens.textPrimaryLight;
    final textSecondary = isDark ? MFTokens.textSecondaryDark : MFTokens.textSecondaryLight;

    final activePoint = (_touchedIndex >= 0 && _touchedIndex < widget.points.length)
        ? widget.points[_touchedIndex]
        : null;

    final numberFormat = NumberFormat('#,##0', localeCode);

    return Container(
      padding: const EdgeInsets.all(MFTokens.sp16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(MFTokens.radiusLG),
        border: Border.all(
          color: isDark ? MFTokens.borderDark : MFTokens.borderLight,
        ),
        boxShadow: MFTokens.shadowSM,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Dynamic Header Summary / Touch Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(MFTokens.sp6),
                    decoration: BoxDecoration(
                      color: primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(MFTokens.radiusSM),
                    ),
                    child: Icon(
                      Icons.show_chart_rounded,
                      size: 18,
                      color: primary,
                    ),
                  ),
                  const SizedBox(width: MFTokens.sp8),
                  Text(
                    AppStrings.dashboardWeeklySales,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: MFTokens.fontMD,
                      fontWeight: FontWeight.w700,
                      color: textPrimary,
                    ),
                  ),
                ],
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: MFTokens.sp12,
                  vertical: MFTokens.sp6,
                ),
                decoration: BoxDecoration(
                  color: activePoint != null
                      ? accentColor.withValues(alpha: 0.15)
                      : primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(MFTokens.radiusMD),
                  border: Border.all(
                    color: activePoint != null
                        ? accentColor.withValues(alpha: 0.3)
                        : Colors.transparent,
                  ),
                ),
                child: Text(
                  activePoint != null
                      ? '${_getLocalizedDayLabel(activePoint, localeCode)} (${DateFormat('d/M', localeCode).format(activePoint.date)}): ${numberFormat.format(activePoint.amount)} $currencySymbol'
                      : '${isArabic ? 'الإجمالي' : 'Total'}: ${numberFormat.format(totalSum)} $currencySymbol',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: MFTokens.fontSM,
                    fontWeight: FontWeight.w700,
                    color: activePoint != null ? accentColor : primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: MFTokens.sp16),
          LayoutBuilder(
            builder: (context, constraints) => AnimatedBuilder(
              animation: _anim,
              builder: (_, _) => SizedBox(
                height: constraints.maxWidth < 420 ? 190 : 230,
                child: LineChart(
                  LineChartData(
                    minX: 0,
                    maxX: (widget.points.length - 1).toDouble(),
                    maxY: effectiveMax,
                    minY: 0,
                    lineTouchData: LineTouchData(
                      touchTooltipData: LineTouchTooltipData(
                        getTooltipColor: (_) => tooltipBg.withValues(alpha: 0.95),
                        tooltipBorderRadius: BorderRadius.circular(
                          MFTokens.radiusMD,
                        ),
                        tooltipPadding: const EdgeInsets.symmetric(
                          horizontal: MFTokens.sp12,
                          vertical: MFTokens.sp8,
                        ),
                        getTooltipItems: (spots) {
                          return spots.map((spot) {
                            final point = widget.points[spot.x.toInt()];
                            final formatted = numberFormat.format(point.amount);
                            final dayName = _getLocalizedDayLabel(point, localeCode);
                            return LineTooltipItem(
                              '$dayName • $formatted $currencySymbol',
                              const TextStyle(
                                fontFamily: 'Cairo',
                                color: Colors.white,
                                fontSize: MFTokens.fontSM,
                                fontWeight: FontWeight.w700,
                              ),
                            );
                          }).toList();
                        },
                      ),
                      touchCallback: (event, response) {
                        final spots = response?.lineBarSpots;
                        setState(
                          () => _touchedIndex = spots == null || spots.isEmpty
                              ? -1
                              : spots.first.x.toInt(),
                        );
                      },
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 44,
                          interval: effectiveMax / 4,
                          getTitlesWidget: (value, meta) {
                            if (value == 0) {
                              return Text(
                                '0',
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: MFTokens.fontXS,
                                  color: textSecondary,
                                ),
                              );
                            }
                            if (value == meta.max) {
                              return const SizedBox.shrink();
                            }
                            return Padding(
                              padding: const EdgeInsets.only(left: MFTokens.sp4),
                              child: Text(
                                _formatCompactAmount(value, localeCode),
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: MFTokens.fontXS,
                                  color: textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 36,
                          getTitlesWidget: (value, meta) {
                            final i = value.toInt();
                            if (i < 0 || i >= widget.points.length) {
                              return const SizedBox.shrink();
                            }
                            final labelInterval = widget.points.length > 60
                                ? 14
                                : widget.points.length > 14
                                    ? 5
                                    : 1;
                            if (i != widget.points.length - 1 &&
                                i % labelInterval != 0) {
                              return const SizedBox.shrink();
                            }
                            final isToday = i == widget.points.length - 1;
                            final isTouched = i == _touchedIndex;
                            final label = widget.points.length > 7
                                ? DateFormat(
                                    'd/M',
                                    localeCode,
                                  ).format(widget.points[i].date)
                                : _getLocalizedDayLabel(widget.points[i], localeCode);

                            final isHighlighted = isToday || isTouched;

                            return Padding(
                              padding: const EdgeInsets.only(top: MFTokens.sp6),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: MFTokens.sp8,
                                  vertical: MFTokens.sp2,
                                ),
                                decoration: BoxDecoration(
                                  color: isTouched
                                      ? accentColor.withValues(alpha: 0.2)
                                      : isToday
                                          ? primary.withValues(alpha: 0.12)
                                          : Colors.transparent,
                                  borderRadius: BorderRadius.circular(
                                    MFTokens.radiusSM,
                                  ),
                                  border: isTouched
                                      ? Border.all(
                                          color: accentColor.withValues(alpha: 0.5),
                                          width: 1,
                                        )
                                      : null,
                                ),
                                child: Text(
                                  label,
                                  style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: MFTokens.fontSM,
                                    fontWeight: isHighlighted
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    color: isTouched
                                        ? accentColor
                                        : isToday
                                            ? primary
                                            : textSecondary,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: true,
                      horizontalInterval: effectiveMax / 4,
                      getDrawingHorizontalLine: (_) => FlLine(
                        color: mutedGrid.withValues(alpha: 0.5),
                        strokeWidth: 0.8,
                        dashArray: [4, 4],
                      ),
                      getDrawingVerticalLine: (_) => FlLine(
                        color: mutedGrid.withValues(alpha: 0.2),
                        strokeWidth: 0.8,
                      ),
                    ),
                    lineBarsData: [
                      LineChartBarData(
                        spots: List.generate(
                          widget.points.length,
                          (i) => FlSpot(
                            i.toDouble(),
                            (widget.points[i].amount * _anim.value).clamp(
                              0,
                              effectiveMax,
                            ),
                          ),
                        ),
                        isCurved: true,
                        curveSmoothness: 0.45,
                        preventCurveOverShooting: true,
                        isStrokeCapRound: true,
                        isStrokeJoinRound: true,
                        color: primary,
                        barWidth: 4.0,
                        dotData: FlDotData(
                          show: true,
                          getDotPainter: (spot, percent, bar, index) {
                            final isSelected = index == _touchedIndex;
                            if (isSelected) {
                              return FlDotCirclePainter(
                                radius: 6.5,
                                color: accentColor,
                                strokeWidth: 3.5,
                                strokeColor: cardBg,
                              );
                            }
                            return FlDotCirclePainter(
                              radius: widget.points.length <= 7 ? 4.0 : 2.5,
                              color: primary,
                              strokeWidth: 2,
                              strokeColor: cardBg,
                            );
                          },
                        ),
                        belowBarData: BarAreaData(
                          show: true,
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              primary.withValues(alpha: 0.32),
                              primary.withValues(alpha: 0.0),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


