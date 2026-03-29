import 'package:flutter/material.dart';

/// 专注热力图组件 - 类似 GitHub 贡献图
class FocusHeatmap extends StatelessWidget {
  final List<double> dailyMinutes; // 近 30 天每天的专注分钟数
  final int currentStreak;
  final int bestStreak;

  const FocusHeatmap({
    super.key,
    required this.dailyMinutes,
    required this.currentStreak,
    required this.bestStreak,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (dailyMinutes.isEmpty) {
      return _buildEmptyCard(context);
    }

    // 计算颜色强度级别
    final maxMinutes = dailyMinutes.reduce((a, b) => a > b ? a : b);
    final thresholds = _calculateThresholds(maxMinutes);

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
                  '专注热力图',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Row(
                  children: [
                    _buildStreakBadge(
                      context,
                      Icons.local_fire_department,
                      '$currentStreak 天',
                      '当前连续',
                      Colors.orange,
                    ),
                    const SizedBox(width: 8),
                    _buildStreakBadge(
                      context,
                      Icons.emoji_events,
                      '$bestStreak 天',
                      '最佳记录',
                      colorScheme.tertiary,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '近 30 天每日专注强度',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.outline,
                  ),
            ),
            const SizedBox(height: 16),
            _buildHeatmapGrid(context, thresholds),
            const SizedBox(height: 16),
            _buildLegend(context),
          ],
        ),
      ),
    );
  }

  /// 计算颜色阈值
  List<double> _calculateThresholds(double max) {
    if (max == 0) return [0, 0, 0, 0];
    return [
      0,
      max * 0.25,
      max * 0.5,
      max * 0.75,
    ];
  }

  /// 构建热力图网格
  Widget _buildHeatmapGrid(BuildContext context, List<double> thresholds) {
    final colorScheme = Theme.of(context).colorScheme;
    final today = DateTime.now();
    
    // 计算起始日期（30 天前）
    final startDate = today.subtract(const Duration(days: 29));
    
    // 计算需要多少行（每周 7 天）
    final weeks = 5; // 固定 5 行

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 月份标签
          Padding(
            padding: const EdgeInsets.only(left: 30, bottom: 4),
            child: Row(
              children: [
                Text(
                  _getMonthName(startDate.month),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: colorScheme.outline,
                      ),
                ),
                if (startDate.month != today.month) ...[
                  const SizedBox(width: 60),
                  Text(
                    _getMonthName(today.month),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: colorScheme.outline,
                        ),
                  ),
                ],
              ],
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 星期标签
              Column(
                children: [
                  const SizedBox(height: 6),
                  Text('一', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: colorScheme.outline, fontSize: 9)),
                  const SizedBox(height: 12),
                  Text('三', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: colorScheme.outline, fontSize: 9)),
                  const SizedBox(height: 12),
                  Text('五', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: colorScheme.outline, fontSize: 9)),
                  const SizedBox(height: 12),
                  Text('日', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: colorScheme.outline, fontSize: 9)),
                ],
              ),
              const SizedBox(width: 4),
              // 热力图方块
              Column(
                children: [
                  for (int week = 0; week < weeks; week++)
                    Row(
                      children: [
                        for (int day = 0; day < 7; day++)
                          _buildHeatmapCell(
                            context,
                            startDate.add(Duration(days: week * 7 + day)),
                            thresholds,
                            colorScheme,
                          ),
                        const SizedBox(width: 2),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 构建单个热力图方块
  Widget _buildHeatmapCell(
    BuildContext context,
    DateTime date,
    List<double> thresholds,
    ColorScheme colorScheme,
  ) {
    final today = DateTime.now();
    final startDate = today.subtract(const Duration(days: 29));
    final dayIndex = date.difference(startDate).inDays;
    
    double minutes = 0;
    if (dayIndex >= 0 && dayIndex < dailyMinutes.length) {
      minutes = dailyMinutes[dayIndex];
    }

    final isFuture = date.isAfter(today);

    Color cellColor;
    if (isFuture || date.isBefore(startDate)) {
      cellColor = colorScheme.surfaceContainerHighest;
    } else if (minutes == 0) {
      cellColor = colorScheme.outline.withValues(alpha: 0.1);
    } else if (minutes < thresholds[1]) {
      cellColor = colorScheme.primary.withValues(alpha: 0.3);
    } else if (minutes < thresholds[2]) {
      cellColor = colorScheme.primary.withValues(alpha: 0.5);
    } else if (minutes < thresholds[3]) {
      cellColor = colorScheme.primary.withValues(alpha: 0.7);
    } else {
      cellColor = colorScheme.primary;
    }

    final isToday = date.year == today.year &&
        date.month == today.month &&
        date.day == today.day;

    return Container(
      width: 12,
      height: 12,
      margin: const EdgeInsets.all(1),
      decoration: BoxDecoration(
        color: cellColor,
        borderRadius: BorderRadius.circular(2),
        border: isToday
            ? Border.all(
                color: colorScheme.onSurface,
                width: 2,
              )
            : null,
      ),
      child: Tooltip(
        message: '${date.month}月${date.day}日：${minutes.round()}分钟',
        child: InkWell(
          borderRadius: BorderRadius.circular(2),
          onTap: () {
            // 可以显示详细信息对话框
          },
        ),
      ),
    );
  }

  /// 构建图例
  Widget _buildLegend(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Row(
      children: [
        Text(
          '更少',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: colorScheme.outline,
              ),
        ),
        const SizedBox(width: 4),
        _buildLegendCell(colorScheme.outline.withValues(alpha: 0.1)),
        _buildLegendCell(colorScheme.primary.withValues(alpha: 0.3)),
        _buildLegendCell(colorScheme.primary.withValues(alpha: 0.5)),
        _buildLegendCell(colorScheme.primary.withValues(alpha: 0.7)),
        _buildLegendCell(colorScheme.primary),
        const SizedBox(width: 4),
        Text(
          '更多',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: colorScheme.outline,
              ),
        ),
      ],
    );
  }

  Widget _buildLegendCell(Color color) {
    return Container(
      width: 12,
      height: 12,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildStreakBadge(
    BuildContext context,
    IconData icon,
    String value,
    String label,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
              ),
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontSize: 8,
                      color: color.withValues(alpha: 0.7),
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getMonthName(int month) {
    const months = ['1 月', '2 月', '3 月', '4 月', '5 月', '6 月', '7 月', '8 月', '9 月', '10 月', '11 月', '12 月'];
    return months[month - 1];
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
              Icons.grid_on,
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
              '开始专注后，这里会显示热力图',
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
