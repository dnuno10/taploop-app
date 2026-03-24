import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

class WeeklyVisitsChart extends StatelessWidget {
  final List<int> visitsByDay;
  final Color barColor;
  final DateTime? referenceDate;

  const WeeklyVisitsChart({
    super.key,
    required this.visitsByDay,
    this.barColor = AppColors.primary,
    this.referenceDate,
  });

  @override
  Widget build(BuildContext context) {
    const _all = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
    final _ref = referenceDate ?? DateTime.now();
    final days = List.generate(7, (i) {
      final d = _ref.subtract(Duration(days: 6 - i));
      return _all[d.weekday - 1];
    });
    final rawMax = visitsByDay.fold(0, (a, b) => a > b ? a : b).toDouble();
    final maxY = rawMax == 0 ? 5.0 : rawMax;

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY * 1.3,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '${visitsByDay[groupIndex]}',
                GoogleFonts.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.white,
                ),
              );
            },
          ),
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
              reservedSize: 28,
              getTitlesWidget: (value, meta) {
                if (value == 0) return const SizedBox.shrink();
                return Text(
                  value.toInt().toString(),
                  style: GoogleFonts.dmSans(
                    fontSize: 10,
                    color: AppColors.lightGrey,
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx < 0 || idx >= days.length) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    days[idx],
                    style: GoogleFonts.dmSans(
                      fontSize: 11,
                      color: AppColors.grey,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        gridData: FlGridData(
          show: true,
          horizontalInterval: maxY / 4,
          getDrawingHorizontalLine: (_) =>
              FlLine(color: AppColors.border, strokeWidth: 1),
          drawVerticalLine: false,
        ),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(visitsByDay.length, (i) {
          final isLast = i == visitsByDay.length - 1;
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: visitsByDay[i].toDouble(),
                color: isLast ? barColor : barColor.withValues(alpha: 0.4),
                width: 18,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(6),
                ),
              ),
            ],
          );
        }),
      ),
      duration: const Duration(milliseconds: 300),
    );
  }
}
