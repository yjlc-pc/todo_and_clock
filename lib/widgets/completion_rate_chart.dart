import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

/// 完成率统计组件 - 展示任务完成情况
class CompletionRateChart extends StatelessWidget {
  final int completedTasks;
  final int totalTasks;

  const CompletionRateChart({
    super.key,
    required this.completedTasks,
    required this.totalTasks,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    if (totalTasks == 0) {
      return _buildEmptyCard(context);
    }

    final completionRate = (completedTasks / totalTasks) * 100;
    final incompleteTasks = totalTasks - completedTasks;

    return Card(
      color: colorScheme.surfaceContainerLowest,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '任务完成率',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              '已完成 $completedTasks / 总计 $totalTasks',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.outline,
                  ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 180,
              child: Row(
                children: [
                  Expanded(
                    child: PieChart(
                      PieChartData(
                        pieTouchData: PieTouchData(enabled: false),
                        borderData: FlBorderData(show: false),
                        sectionsSpace: 0,
                        centerSpaceRadius: 0,
                        sections: [
                          // 已完成部分
                          PieChartSectionData(
                            color: colorScheme.primary,
                            value: completedTasks.toDouble(),
                            title: '${completionRate.toStringAsFixed(0)}%',
                            radius: 70,
                            titleStyle: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onPrimary,
                            ),
                          ),
                          // 未完成部分
                          if (incompleteTasks > 0)
                            PieChartSectionData(
                              color: colorScheme.outline.withValues(alpha: 0.3),
                              value: incompleteTasks.toDouble(),
                              title: '',
                              radius: 70,
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildStatItem(
                          context,
                          colorScheme.primary,
                          '已完成',
                          completedTasks.toString(),
                        ),
                        const SizedBox(height: 12),
                        _buildStatItem(
                          context,
                          colorScheme.outline.withValues(alpha: 0.3),
                          '未完成',
                          incompleteTasks.toString(),
                        ),
                        const SizedBox(height: 12),
                        _buildStatItem(
                          context,
                          colorScheme.tertiary,
                          '总计',
                          totalTasks.toString(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildProgressBar(context, completionRate),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    Color color,
    String label,
    String value,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    
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
        const SizedBox(width: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.outline,
              ),
        ),
        const Spacer(),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }

  Widget _buildProgressBar(BuildContext context, double percentage) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: percentage >= 80
            ? colorScheme.primaryContainer.withValues(alpha: 0.3)
            : percentage >= 50
                ? colorScheme.secondaryContainer.withValues(alpha: 0.3)
                : colorScheme.errorContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '完成进度',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              Text(
                '${percentage.toStringAsFixed(1)}%',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: percentage >= 80
                          ? colorScheme.primary
                          : percentage >= 50
                              ? colorScheme.secondary
                              : colorScheme.error,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage / 100,
              minHeight: 8,
              backgroundColor: colorScheme.outline.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation<Color>(
                percentage >= 80
                    ? colorScheme.primary
                    : percentage >= 50
                        ? colorScheme.secondary
                        : colorScheme.error,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            percentage >= 80
                ? '🎉 太棒了！继续保持'
                : percentage >= 50
                    ? '💪 加油，已经完成一半了'
                    : '🚀 开始行动吧',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: percentage >= 80
                      ? colorScheme.primary
                      : percentage >= 50
                          ? colorScheme.secondary
                          : colorScheme.error,
                ),
          ),
        ],
      ),
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
              Icons.task_alt,
              size: 64,
              color: colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              '暂无任务',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: colorScheme.outline,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              '添加任务后，这里会显示完成率统计',
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
