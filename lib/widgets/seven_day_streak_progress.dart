import 'package:flutter/material.dart';

/// 7 天连胜进度条组件 - 类似多邻国 UI 风格
class SevenDayStreakProgress extends StatelessWidget {
  final List<bool> last7Days; // 近 7 天每天的专注状态（true=已专注，false=未专注）
  final int currentStreak;
  final int targetStreak; // 目标连胜天数，默认 7 天

  const SevenDayStreakProgress({
    super.key,
    required this.last7Days,
    required this.currentStreak,
    this.targetStreak = 7,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (last7Days.isEmpty) {
      return _buildEmptyCard(context);
    }

    final progress = currentStreak / targetStreak;

    return Card(
      color: colorScheme.surfaceContainerLowest,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题和连胜信息
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '7 天连胜挑战',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                _buildStreakBadge(context, currentStreak, targetStreak),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '保持每日专注，完成 7 天连胜挑战！',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.outline,
                  ),
            ),
            const SizedBox(height: 16),

            // 进度条
            _buildProgressBar(context, progress),
            const SizedBox(height: 16),

            // 7 天每日状态
            _buildDayCells(context),
            const SizedBox(height: 16),

            // 图例
            _buildLegend(context),
          ],
        ),
      ),
    );
  }

  /// 构建连胜徽章
  Widget _buildStreakBadge(BuildContext context, int current, int target) {
    final colorScheme = Theme.of(context).colorScheme;
    final isCompleted = current >= target;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: isCompleted
            ? LinearGradient(
                colors: [Colors.orange, Colors.deepOrange],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: isCompleted ? null : colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: isCompleted
            ? null
            : Border.all(
                color: colorScheme.outline.withValues(alpha: 0.3),
                width: 1,
              ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isCompleted ? Icons.emoji_events : Icons.local_fire_department,
            size: 18,
            color: isCompleted ? Colors.white : Colors.orange,
          ),
          const SizedBox(width: 6),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$current / $target',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isCompleted ? Colors.white : colorScheme.onSurface,
                    ),
              ),
              Text(
                isCompleted ? '已完成！' : '当前连胜',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontSize: 8,
                      color: isCompleted
                          ? Colors.white.withValues(alpha: 0.9)
                          : colorScheme.outline,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 构建进度条
  Widget _buildProgressBar(BuildContext context, double progress) {
    final colorScheme = Theme.of(context).colorScheme;
    final isCompleted = progress >= 1.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            minHeight: 12,
            backgroundColor: colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(
              isCompleted ? Colors.orange : colorScheme.primary,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '进度',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: colorScheme.outline,
                  ),
            ),
            Text(
              '${(progress * 100).toInt()}%',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isCompleted ? Colors.orange : colorScheme.primary,
                  ),
            ),
          ],
        ),
      ],
    );
  }

  /// 构建 7 天每日状态单元格
  Widget _buildDayCells(BuildContext context) {
    final today = DateTime.now();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        for (int i = 6; i >= 0; i--)
          _buildDayCell(
            context,
            today.subtract(Duration(days: i)),
            i >= last7Days.length ? false : last7Days[last7Days.length - 1 - i],
          ),
      ],
    );
  }

  /// 构建单个日期单元格
  Widget _buildDayCell(BuildContext context, DateTime date, bool hasFocus) {
    final colorScheme = Theme.of(context).colorScheme;
    final today = DateTime.now();
    final isToday =
        date.year == today.year &&
        date.month == today.month &&
        date.day == today.day;

    // 星期标签
    const weekdays = ['一', '二', '三', '四', '五', '六', '日'];
    final weekday = weekdays[date.weekday - 1];

    return Column(
      children: [
        // 日期方块
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: hasFocus
                ? (isToday ? Colors.orange : colorScheme.primary)
                : colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(10),
            border: isToday
                ? Border.all(
                    color: hasFocus ? Colors.orange : colorScheme.primary,
                    width: 2,
                  )
                : null,
            boxShadow: hasFocus
                ? [
                    BoxShadow(
                      color: (isToday ? Colors.orange : colorScheme.primary)
                          .withValues(alpha: 0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: hasFocus
              ? Icon(
                  Icons.check,
                  color: isToday ? Colors.white : colorScheme.onPrimary,
                  size: 20,
                )
              : null,
        ),
        const SizedBox(height: 4),
        // 星期标签
        Text(
          weekday,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: isToday
                    ? (hasFocus ? Colors.orange : colorScheme.primary)
                    : colorScheme.outline,
                fontWeight: isToday ? FontWeight.bold : null,
              ),
        ),
      ],
    );
  }

  /// 构建图例
  Widget _buildLegend(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLegendItem(context, '未专注', colorScheme.surfaceContainerHighest),
        const SizedBox(width: 24),
        _buildLegendItem(context, '已专注', colorScheme.primary),
        const SizedBox(width: 24),
        _buildLegendItem(context, '今天', Colors.orange),
      ],
    );
  }

  Widget _buildLegendItem(BuildContext context, String label, Color color) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: color == Colors.orange
                    ? Colors.orange
                    : Theme.of(context).colorScheme.outline,
              ),
        ),
      ],
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
              Icons.local_fire_department_outlined,
              size: 64,
              color: colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              '开始你的第一次专注',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: colorScheme.outline,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              '完成专注后，这里会显示连胜进度',
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
