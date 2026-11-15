import 'package:fl_chart/fl_chart.dart';
import 'package:material_ui/material_ui.dart';

import '../models/weight_entry.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';

const _axisStyle = TextStyle(color: AppColors.textSecondary, fontSize: 10);

/// Eixos dos gráficos: esquerda mostra valores, embaixo mostra as datas.
FlTitlesData _buildTitles({
  required String Function(double) left,
  required String? Function(int) bottomLabel,
  double leftSize = 44,
}) {
  return FlTitlesData(
    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
    leftTitles: AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        reservedSize: leftSize,
        getTitlesWidget: (value, meta) => Text(left(value), style: _axisStyle),
      ),
    ),
    bottomTitles: AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        reservedSize: 28,
        interval: 1,
        getTitlesWidget: (value, meta) => Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(bottomLabel(value.round()) ?? '', style: _axisStyle),
        ),
      ),
    ),
  );
}

FlGridData _grid() => FlGridData(
      drawVerticalLine: false,
      getDrawingHorizontalLine: (value) => FlLine(color: AppColors.border, strokeWidth: 1),
    );

/// Gráfico de barras: um valor por dia, com linha tracejada opcional para a meta.
class BarSeriesChart extends StatelessWidget {
  const BarSeriesChart({
    super.key,
    required this.dayKeys,
    required this.values,
    required this.formatY,
    this.goal,
  });

  final List<String> dayKeys;
  final List<double> values;
  final String Function(double) formatY;
  final double? goal;

  @override
  Widget build(BuildContext context) {
    final n = dayKeys.length;
    final goalValue = goal;
    var maxValue = 0.0;
    for (final v in values) {
      if (v > maxValue) maxValue = v;
    }
    if (goalValue != null && goalValue > maxValue) maxValue = goalValue;
    final maxY = maxValue <= 0 ? 1.0 : maxValue * 1.15;
    final labelStep = n <= 7 ? 1 : (n <= 30 ? 5 : 15);
    final barWidth = n <= 7 ? 18.0 : (n <= 30 ? 6.0 : 3.0);

    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          minY: 0,
          maxY: maxY,
          alignment: BarChartAlignment.spaceAround,
          gridData: _grid(),
          borderData: FlBorderData(show: false),
          titlesData: _buildTitles(
            left: formatY,
            bottomLabel: (i) => (i >= 0 && i < n && i % labelStep == 0) ? shortDate(dayKeys[i]) : null,
          ),
          extraLinesData: goalValue == null
              ? null
              : ExtraLinesData(horizontalLines: [
                  HorizontalLine(
                    y: goalValue,
                    color: AppColors.positive.withValues(alpha: 0.8),
                    strokeWidth: 1.5,
                    dashArray: [6, 4],
                  ),
                ]),
          barGroups: [
            for (var i = 0; i < n; i++)
              BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: values[i],
                    width: barWidth,
                    color: AppColors.purple,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(3)),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

/// Gráfico de linha da evolução do peso. O eixo X é a quantidade de dias desde [start].
class WeightLineChart extends StatelessWidget {
  const WeightLineChart({super.key, required this.entries, required this.start, required this.days});

  final List<WeightEntry> entries;
  final DateTime start;
  final int days;

  @override
  Widget build(BuildContext context) {
    final spots = [
      for (final e in entries)
        FlSpot(parseKey(e.date).difference(DateTime(start.year, start.month, start.day)).inDays.toDouble(), e.kg),
    ];
    var minKg = entries.first.kg;
    var maxKg = entries.first.kg;
    for (final e in entries) {
      if (e.kg < minKg) minKg = e.kg;
      if (e.kg > maxKg) maxKg = e.kg;
    }
    final labelStep = days <= 7 ? 1 : (days <= 30 ? 5 : 15);

    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          minX: 0,
          maxX: (days - 1).toDouble(),
          minY: (minKg - 1).floorToDouble(),
          maxY: (maxKg + 1).ceilToDouble(),
          gridData: _grid(),
          borderData: FlBorderData(show: false),
          titlesData: _buildTitles(
            left: (v) => fmtNum(v),
            bottomLabel: (i) => (i >= 0 && i < days && i % labelStep == 0)
                ? shortDate(dateKey(DateTime(start.year, start.month, start.day + i)))
                : null,
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              curveSmoothness: 0.2,
              color: AppColors.purple,
              barWidth: 3,
              dotData: FlDotData(show: true),
              belowBarData: BarAreaData(show: true, color: AppColors.purple.withValues(alpha: 0.15)),
            ),
          ],
        ),
      ),
    );
  }
}
