import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;
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

  @override
  Widget build(BuildContext context) {
    if (widget.points.isEmpty) return const SizedBox.shrink();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final maxY = widget.points.map((p) => p.amount).reduce((a, b) => a > b ? a : b);
    final effectiveMax = maxY <= 0 ? 1000.0 : maxY * 1.25;

    final primary = isDark ? MFTokens.primaryDarkMode : MFTokens.primary;
    final mutedGrid = isDark ? MFTokens.borderDark : MFTokens.borderLight;
    final tooltipBg = isDark ? MFTokens.surfaceDark : MFTokens.primaryDark;
    final cardBg = isDark ? MFTokens.cardDark : MFTokens.cardLight;

    return Container(
      padding: const EdgeInsets.fromLTRB(MFTokens.sp8, MFTokens.sp16, MFTokens.sp8, MFTokens.sp8),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(MFTokens.radiusLG),
        border: Border.all(color: isDark ? MFTokens.borderDark : MFTokens.borderLight),
        boxShadow: MFTokens.shadowSM,
      ),
      child: AnimatedBuilder(
        animation: _anim,
        builder: (_, __) => SizedBox(
          height: 160,
          child: BarChart(
            BarChartData(
              maxY: effectiveMax,
              minY: 0,
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  getTooltipColor: (_) => tooltipBg.withValues(alpha: 0.9),
                  tooltipBorderRadius: BorderRadius.circular(MFTokens.radiusSM),
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    final point = widget.points[group.x];
                    final formatted = NumberFormat('#,##0', 'ar').format(point.amount);
                    return BarTooltipItem(
                      '$formatted ج.م',
                      const TextStyle(
                        fontFamily: 'Cairo',
                        color: Colors.white,
                        fontSize: MFTokens.fontSM,
                        fontWeight: FontWeight.w700,
                      ),
                    );
                  },
                ),
                touchCallback: (event, response) {
                  setState(() => _touchedIndex = response?.spot?.touchedBarGroupIndex ?? -1);
                },
              ),
              titlesData: FlTitlesData(
                show: true,
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 28,
                    getTitlesWidget: (value, meta) {
                      final i = value.toInt();
                      if (i < 0 || i >= widget.points.length) return const SizedBox.shrink();
                      final isToday = i == widget.points.length - 1;
                      return Padding(
                        padding: const EdgeInsets.only(top: MFTokens.sp4),
                        child: Text(
                          widget.points[i].label,
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: MFTokens.fontSM,
                            fontWeight: isToday ? FontWeight.w700 : FontWeight.w400,
                            color: isToday ? MFTokens.accent : MFTokens.textSecondaryLight,
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
                drawVerticalLine: false,
                horizontalInterval: effectiveMax / 4,
                getDrawingHorizontalLine: (_) => FlLine(
                  color: mutedGrid.withValues(alpha: 0.5),
                  strokeWidth: 0.8,
                  dashArray: [4, 4],
                ),
              ),
              barGroups: List.generate(widget.points.length, (i) {
                final point = widget.points[i];
                final isToday = i == widget.points.length - 1;
                final isTouched = i == _touchedIndex;
                return BarChartGroupData(
                  x: i,
                  barRods: [
                    BarChartRodData(
                      toY: (point.amount * _anim.value).clamp(0, effectiveMax),
                      width: 18,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(MFTokens.radiusSM)),
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: isToday || isTouched
                            ? [MFTokens.accent.withValues(alpha: 0.7), MFTokens.accent]
                            : [primary.withValues(alpha: 0.4), primary.withValues(alpha: 0.85)],
                      ),
                      backDrawRodData: BackgroundBarChartRodData(
                        show: true,
                        toY: effectiveMax,
                        color: (isDark ? MFTokens.backgroundDark : MFTokens.backgroundLight).withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                );
              }),
            ),
            duration: const Duration(milliseconds: 300),
          ),
        ),
      ),
    );
  }
}
