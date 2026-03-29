import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../utils/statistics_helper.dart';

/// 月度趋势图组件 - 展示近 30 天专注时长趋势
class MonthlyTrendChart extends StatelessWidget {
  final List<double> dailyMinutes; // 近 30 天每天的专注分钟数

  const MonthlyTrendChart({
    super.key,
    required this.dailyMinutes,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final totalMinutes = dailyMinutes.reduce((a, b) => a + b);
    final avgMinutes = totalMinutes / dailyMinutes.length;

    return Card(
      color: colorScheme.surfaceContainerLowest,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '月度趋势',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '平均 ${StatisticsHelper.formatDurationShort(avgMinutes)}/天',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: colorScheme.onPrimaryContainer,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '近 30 天专注时长变化',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.outline,
                  ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: _calculateGridInterval(dailyMinutes),
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: colorScheme.outline.withValues(alpha: 0.1),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          if (value == 0) return const Text('');
                          return Text(
                            '${(value / 60).round()}',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: colorScheme.outline,
                                ),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 32,
                        interval: 5,
                        getTitlesWidget: (value, meta) {
                          if (value == 0) return const Text('1');
                          if (value == 14) return const Text('15');
                          if (value == 29) return const Text('30');
                          return const Text('');
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  minX: 0,
                  maxX: 29,
                  minY: 0,
                  maxY: _calculateMaxY(dailyMinutes),
                  lineBarsData: [
                    LineChartBarData(
                      spots: dailyMinutes.asMap().entries.map((entry) {
                        return FlSpot(entry.key.toDouble(), entry.value);
                      }).toList(),
                      isCurved: true,
                      curveSmoothness: 0.2,
                      color: colorScheme.primary,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: false,
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            colorScheme.primary.withValues(alpha: 0.3),
                            colorScheme.primary.withValues(alpha: 0.0),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ],
                  lineTouchData: LineTouchData(
                    enabled: true,
                    touchTooltipData: LineTouchTooltipData(
                      tooltipRoundedRadius: 8,
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((spot) {
                          return LineTooltipItem(
                            '${(spot.y / 60).toStringAsFixed(1)}h',
                            TextStyle(
                              color: colorScheme.onSurface,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        }).toList();
                      },
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem(
                  context,
                  colorScheme.primary,
                  '专注时长',
                ),
                const SizedBox(width: 16),
                _buildLegendItem(
                  context,
                  colorScheme.primary.withValues(alpha: 0.3),
                  '累计 ${StatisticsHelper.formatDuration(totalMinutes)}',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 计算网格间隔
  double _calculateGridInterval(List<double> data) {
    final max = data.reduce((a, b) => a > b ? a : b);
    if (max <= 60) return 20;
    if (max <= 120) return 40;
    if (max <= 240) return 60;
    return 120;
  }

  /// 计算 Y 轴最大值
  double _calculateMaxY(List<double> data) {
    final max = data.reduce((a, b) => a > b ? a : b);
    if (max <= 60) return 60;
    if (max <= 120) return 120;
    if (max <= 240) return 240;
    return ((max / 120).ceil() + 1) * 120;
  }

  Widget _buildLegendItem(BuildContext context, Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall,
        ),
      ],
    );
  }
}
