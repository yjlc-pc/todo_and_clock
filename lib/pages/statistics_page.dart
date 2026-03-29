import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_list_and_clock/providers/todo_provider.dart';
import 'package:todo_list_and_clock/models/statistics_summary.dart';
import 'package:todo_list_and_clock/utils/statistics_helper.dart';
import 'package:todo_list_and_clock/widgets/monthly_trend_chart.dart';
import 'package:todo_list_and_clock/widgets/category_pie_chart.dart';
import 'package:todo_list_and_clock/widgets/completion_rate_chart.dart';
import 'package:todo_list_and_clock/widgets/hourly_distribution_chart.dart';
import 'package:todo_list_and_clock/widgets/statistics_cards.dart';
import 'package:todo_list_and_clock/widgets/seven_day_streak_progress.dart';

/// 统计页面 - 展示专注和任务的完整统计数据
class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  late Future<StatisticsSummary> _statisticsFuture;

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  void _loadStatistics() {
    setState(() {
      _statisticsFuture = StatisticsHelper.loadStatisticsSummary();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TodoProvider>(
      builder: (context, todoProvider, child) {
        return RefreshIndicator(
          onRefresh: () async {
            _loadStatistics();
            await todoProvider.loadTasks();
            await todoProvider.loadCategories();
          },
          child: FutureBuilder<StatisticsSummary>(
            future: _statisticsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '加载数据时出错',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${snapshot.error}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.outline,
                            ),
                      ),
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        onPressed: _loadStatistics,
                        icon: const Icon(Icons.refresh),
                        label: const Text('重新加载'),
                      ),
                    ],
                  ),
                );
              }

              final data = snapshot.data!;
              final categories = todoProvider.categories;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 页面标题
                    _buildHeader(context),
                    const SizedBox(height: 24),

                    // 关键指标卡片（今日、本周、本月）
                    _buildKeyMetricsCards(context, data),
                    const SizedBox(height: 16),

                    // 7 天连胜进度条
                    SevenDayStreakProgress(
                      last7Days: data.last7DaysFocus,
                      currentStreak: data.currentStreak,
                    ),
                    const SizedBox(height: 16),

                    // 完成率统计
                    CompletionRateChart(
                      completedTasks: data.completedTasks,
                      totalTasks: data.totalTasks,
                    ),
                    const SizedBox(height: 16),

                    // 月度趋势图
                    MonthlyTrendChart(dailyMinutes: data.dailyFocusLast30Days),
                    const SizedBox(height: 16),

                    // 分类饼图和时段分布（并排）
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: CategoryPieChart(
                            categoryDistribution: data.categoryDistribution,
                            categories: categories,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 2,
                          child: HourlyDistributionChart(
                            hourlyDistribution: data.hourlyDistribution,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // 鼓励信息卡片
                    _buildEncouragementCard(context, data),
                    const SizedBox(height: 8),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  /// 构建页面头部
  Widget _buildHeader(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '数据统计',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              '你的专注轨迹，一目了然',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.outline,
                  ),
            ),
          ],
        ),
        IconButton(
          onPressed: _loadStatistics,
          icon: const Icon(Icons.refresh),
          tooltip: '刷新数据',
        ),
      ],
    );
  }

  /// 构建关键指标卡片
  Widget _buildKeyMetricsCards(BuildContext context, StatisticsSummary data) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 今日专注
            Expanded(
              child: TodayFocusTimeCard(focusMinutes: data.todayFocusMinutes),
            ),
            const SizedBox(width: 16),
            // 本周专注
            Expanded(
              child: WeekFocusTimeCard(focusMinutes: data.weekFocusMinutes),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 本月专注
            Expanded(
              child: MonthFocusTimeCard(focusMinutes: data.monthFocusMinutes),
            ),
            const SizedBox(width: 16),
            // 平均每日专注
            Expanded(
              child: _buildAverageDailyCard(context, data.averageDailyFocus),
            ),
          ],
        ),
      ],
    );
  }

  /// 构建平均每日专注卡片
  Widget _buildAverageDailyCard(BuildContext context, double avgMinutes) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      color: colorScheme.surfaceContainerLowest,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.av_timer,
                  color: colorScheme.outline,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  '平均每日',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              StatisticsHelper.formatDuration(avgMinutes),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.tertiary,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建鼓励信息卡片
  Widget _buildEncouragementCard(
    BuildContext context,
    StatisticsSummary data,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    String message;
    IconData icon;
    Color cardColor;

    if (data.todayFocusMinutes == 0) {
      message = '今天还没开始专注，现在就开始吧！';
      icon = Icons.lightbulb_outline;
      cardColor = colorScheme.surfaceContainer;
    } else if (data.todayFocusMinutes < 60) {
      message = '好的开始！继续加油，积少成多~';
      icon = Icons.trending_up;
      cardColor = colorScheme.primaryContainer;
    } else if (data.todayFocusMinutes < 120) {
      message = '太棒了！你已经超越了很多人的今天';
      icon = Icons.star;
      cardColor = colorScheme.secondaryContainer;
    } else {
      message = '专注大师！今天的成就值得骄傲！';
      icon = Icons.emoji_events;
      cardColor = colorScheme.tertiaryContainer;
    }

    return Card(
      color: cardColor,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.onSecondaryContainer.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 32,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '今日寄语',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: colorScheme.outline,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
