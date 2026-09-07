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
    if (widget.points.isEmpty) {
      return const SizedBox.shrink();
    }
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final maxY = widget.points
        .map((p) => p.amount)
        .reduce((a, b) => a > b ? a : b);
    final effectiveMax = maxY <= 0 ? 1000.0 : maxY * 1.25;

    final primary = isDark ? MFTokens.primaryDarkMode : MFTokens.primary;
    final mutedGrid = isDark ? MFTokens.borderDark : MFTokens.borderLight;
    final tooltipBg = isDark ? MFTokens.surfaceDark : MFTokens.primaryDark;
    final cardBg = isDark ? MFTokens.cardDark : MFTokens.cardLight;

    return Container(
      padding: const EdgeInsets.fromLTRB(
        MFTokens.sp8,
        MFTokens.sp16,
        MFTokens.sp8,
        MFTokens.sp8,
      ),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(MFTokens.radiusLG),
        border: Border.all(
          color: isDark ? MFTokens.borderDark : MFTokens.borderLight,
        ),
        boxShadow: MFTokens.shadowSM,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) => AnimatedBuilder(
          animation: _anim,
          builder: (_, _) => SizedBox(
            height: constraints.maxWidth < 420 ? 180 : 220,
            child: LineChart(
              LineChartData(
                minX: 0,
                maxX: (widget.points.length - 1).toDouble(),
                maxY: effectiveMax,
                minY: 0,
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (_) => tooltipBg.withValues(alpha: 0.9),
                    tooltipBorderRadius: BorderRadius.circular(
                      MFTokens.radiusSM,
                    ),
                    getTooltipItems: (spots) {
                      return spots.map((spot) {
                        final point = widget.points[spot.x.toInt()];
                        final formatted = NumberFormat(
                          '#,##0',
                          'ar',
                        ).format(point.amount);
                        return LineTooltipItem(
                          '$formatted ج.م',
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
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
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
                        final label = widget.points.length > 7
                            ? DateFormat(
                                'd/M',
                                'ar',
                              ).format(widget.points[i].date)
                            : widget.points[i].label;
                        return Padding(
                          padding: const EdgeInsets.only(top: MFTokens.sp4),
                          child: Text(
                            label,
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: MFTokens.fontSM,
                              fontWeight: isToday
                                  ? FontWeight.w700
                                  : FontWeight.w400,
                              color: isToday
                                  ? MFTokens.accent
                                  : MFTokens.textSecondaryLight,
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
                    color: mutedGrid.withValues(alpha: 0.28),
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
                    curveSmoothness: 0.28,
                    color: primary,
                    barWidth: 3,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, bar, index) =>
                          FlDotCirclePainter(
                            radius: index == _touchedIndex ? 5 : 0,
                            color: MFTokens.accent,
                            strokeWidth: 2,
                            strokeColor: cardBg,
                          ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          primary.withValues(alpha: 0.24),
                          primary.withValues(alpha: 0.02),
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
    );
  }
}
