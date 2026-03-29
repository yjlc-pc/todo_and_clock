import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../utils/statistics_helper.dart';

/// 时段分布图组件 - 展示一天中各时间段的专注分布
class HourlyDistributionChart extends StatelessWidget {
  final Map<int, int> hourlyDistribution; // hour -> minutes

  const HourlyDistributionChart({
    super.key,
    required this.hourlyDistribution,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (hourlyDistribution.isEmpty) {
      return _buildEmptyCard(context);
    }

    // 找出专注最多的时段
    final peakHour = _getPeakHour();

    // 生成 24 小时数据
    final hourlyData = List.generate(24, (hour) => hourlyDistribution[hour] ?? 0);
    final maxMinutes = hourlyData.reduce((a, b) => a > b ? a : b);

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
                  '时段分布',
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
                    color: colorScheme.tertiaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.star,
                        size: 14,
                        color: colorScheme.onTertiaryContainer,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '黄金时段：${_formatHour(peakHour)}',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: colorScheme.onTertiaryContainer,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '24 小时专注时长分布',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.outline,
                  ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: maxMinutes > 60 ? 60 : 30,
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
                        reservedSize: 36,
                        getTitlesWidget: (value, meta) {
                          if (value == 0) return const Text('');
                          return Text(
                            '${(value / 60).round()}h',
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
                        reservedSize: 28,
                        interval: 4,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '${value.toInt()}',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: colorScheme.outline,
                                ),
                          );
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
                  minY: 0,
                  maxY: maxMinutes > 60 ? ((maxMinutes / 60).ceil() + 1) * 60 : 120,
                  barGroups: hourlyData.asMap().entries.map((entry) {
                    final hour = entry.key;
                    final minutes = entry.value;
                    final isPeak = hour == peakHour;

                    return BarChartGroupData(
                      x: hour,
                      barRods: [
                        BarChartRodData(
                          toY: minutes.toDouble(),
                          color: isPeak
                              ? colorScheme.tertiary
                              : colorScheme.primary.withValues(alpha: 0.7),
                          width: 10,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(4),
                            topRight: Radius.circular(4),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      tooltipRoundedRadius: 8,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        return BarTooltipItem(
                          StatisticsHelper.formatDuration(rod.toY),
                          TextStyle(
                            color: colorScheme.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildTimePeriods(context),
          ],
        ),
      ),
    );
  }

  /// 获取专注最多的时段
  int _getPeakHour() {
    if (hourlyDistribution.isEmpty) return 0;
    
    int peakHour = 0;
    int maxMinutes = 0;
    
    for (var entry in hourlyDistribution.entries) {
      if (entry.value > maxMinutes) {
        maxMinutes = entry.value;
        peakHour = entry.key;
      }
    }
    
    return peakHour;
  }

  String _formatHour(int hour) {
    return '${hour.toString().padLeft(2, '0')}:00';
  }

  Widget _buildTimePeriods(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final periods = [
      {'label': '早晨', 'range': '5-9 点', 'icon': Icons.bedtime_outlined, 'color': colorScheme.primary},
      {'label': '上午', 'range': '9-12 点', 'icon': Icons.light_mode, 'color': colorScheme.tertiary},
      {'label': '下午', 'range': '13-18 点', 'icon': Icons.wb_sunny_outlined, 'color': colorScheme.secondary},
      {'label': '晚上', 'range': '19-24 点', 'icon': Icons.nightlight_outlined, 'color': colorScheme.primaryContainer},
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: periods.map((period) {
        final range = period['range'] as String;
        final hours = range.split('-');
        final startHour = int.parse(hours[0]);
        final endHour = int.parse(hours[1].replaceAll('点', ''));
        int totalMinutes = 0;
        for (int h = startHour; h < endHour; h++) {
          totalMinutes += hourlyDistribution[h] ?? 0;
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: (period['color'] as Color).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: (period['color'] as Color).withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                period['icon'] as IconData,
                size: 16,
                color: period['color'] as Color?,
              ),
              const SizedBox(width: 6),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    period['label'] as String,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    StatisticsHelper.formatDurationShort(totalMinutes.toDouble()),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: colorScheme.outline,
                        ),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEmptyCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Card(
      color: colorScheme.surfaceContainerLowest,
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            Icon(
              Icons.schedule,
              size: 64,
              color: colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              '暂无数据',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: colorScheme.outline,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              '开始专注后，这里会显示时段分布',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.outline.withValues(alpha: 0.7),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
