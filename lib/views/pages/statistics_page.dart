import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_models/statistics_view_model.dart';

/// 统计页面 - MVVM 架构的 View
class StatisticsPage extends StatelessWidget {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<StatisticsViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '数据统计',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 24),
              _buildSummaryCards(viewModel, context),
              const SizedBox(height: 24),
              _buildTimeRangeSelector(viewModel),
              const SizedBox(height: 16),
              Expanded(
                child: _buildChart(viewModel, context),
              ),
            ],
          ),
        );
      },
    );
  }

  /// 构建统计摘要卡片
  Widget _buildSummaryCards(StatisticsViewModel viewModel, BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            '完成次数',
            '${viewModel.completedCount}',
            Icons.check_circle_outline,
            Colors.green,
            context,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            '总时长',
            '${viewModel.totalHours.toStringAsFixed(1)}h',
            Icons.timer_outlined,
            Colors.blue,
            context,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            '日均',
            '${viewModel.averageDailyDuration.toInt()}m',
            Icons.trending_up,
            Colors.orange,
            context,
          ),
        ),
      ],
    );
  }

  /// 构建统计卡片
  Widget _buildStatCard(String label, String value, IconData icon, Color color, BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  /// 构建时间范围选择器
  Widget _buildTimeRangeSelector(StatisticsViewModel viewModel) {
    return SegmentedButton<String>(
      segments: const [
        ButtonSegment(value: '7d', label: Text('7 天')),
        ButtonSegment(value: '30d', label: Text('30 天')),
        ButtonSegment(value: 'week', label: Text('本周')),
        ButtonSegment(value: 'month', label: Text('本月')),
      ],
      selected: {'7d'},
      onSelectionChanged: (Set<String> selected) {
        switch (selected.first) {
          case '7d':
            viewModel.loadLast7Days();
            break;
          case '30d':
            viewModel.loadLast30Days();
            break;
          case 'week':
            viewModel.loadThisWeek();
            break;
          case 'month':
            viewModel.loadThisMonth();
            break;
        }
      },
    );
  }

  /// 构建图表
  Widget _buildChart(StatisticsViewModel viewModel, BuildContext context) {
    return Card(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bar_chart,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              '图表功能开发中...',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              '统计周期：${_formatDate(viewModel.startDate)} - ${_formatDate(viewModel.endDate)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}';
  }
}
