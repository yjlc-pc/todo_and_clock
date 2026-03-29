import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/category.dart';
import '../utils/statistics_helper.dart';

/// 分类饼图组件 - 展示各分类专注时间占比
class CategoryPieChart extends StatelessWidget {
  final Map<int, double> categoryDistribution; // categoryId -> minutes
  final List<Category> categories;

  const CategoryPieChart({
    super.key,
    required this.categoryDistribution,
    required this.categories,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    if (categoryDistribution.isEmpty) {
      return _buildEmptyCard(context);
    }

    final totalMinutes = categoryDistribution.values.reduce((a, b) => a + b);
    final sortedCategories = categoryDistribution.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // 生成颜色
    final colors = [
      colorScheme.primary,
      colorScheme.secondary,
      colorScheme.tertiary,
      colorScheme.error,
      colorScheme.primaryContainer,
      colorScheme.secondaryContainer,
      colorScheme.tertiaryContainer,
      colorScheme.errorContainer,
    ];

    return Card(
      color: colorScheme.surfaceContainerLowest,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '分类时间分布',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              '各分类专注时长占比',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.outline,
                  ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: Row(
                children: [
                  Expanded(
                    child: PieChart(
                      PieChartData(
                        pieTouchData: PieTouchData(
                          touchCallback: (FlTouchEvent event, pieTouchResponse) {
                            // 触摸处理
                          },
                        ),
                        borderData: FlBorderData(show: false),
                        sectionsSpace: 2,
                        centerSpaceRadius: 50,
                        sections: sortedCategories.asMap().entries.map((entry) {
                          final index = entry.key;
                          final categoryEntry = entry.value;
                          final percentage = categoryEntry.value / totalMinutes * 100;

                          return PieChartSectionData(
                            color: colors[index % colors.length],
                            value: categoryEntry.value,
                            title: '${percentage.toStringAsFixed(0)}%',
                            radius: 60,
                            titleStyle: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onPrimary,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: sortedCategories.take(5).map((entry) {
                        final category = categories.firstWhere(
                          (c) => c.id == entry.key,
                          orElse: () => Category(
                            name: '未分类',
                            icon: 'book',
                          ),
                        );
                        final percentage = entry.value / totalMinutes * 100;
                        final colorIndex = sortedCategories.indexOf(entry) % colors.length;
                        
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: colors[colorIndex],
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  category.name,
                                  style: Theme.of(context).textTheme.bodySmall,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                '${percentage.toStringAsFixed(1)}%',
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Text(
                        '总计',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: colorScheme.outline,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        StatisticsHelper.formatDuration(totalMinutes),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.primary,
                            ),
                      ),
                    ],
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: colorScheme.outline.withValues(alpha: 0.2),
                  ),
                  Column(
                    children: [
                      Text(
                        '分类数',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: colorScheme.outline,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${sortedCategories.length}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.secondary,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
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
              Icons.pie_chart_outline,
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
              '开始专注后，这里会显示分类统计',
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
