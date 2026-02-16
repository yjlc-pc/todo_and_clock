import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

// 今日专注时间卡片
class TodayFocusTimeCard extends StatelessWidget {
  final String focusTime;

  const TodayFocusTimeCard({super.key, required this.focusTime});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "今日共计专注时间",
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
            const SizedBox(height: 8),
            Text(focusTime, style: Theme.of(context).textTheme.displayLarge),
          ],
        ),
      ),
    );
  }
}

// 本周专注情况图表卡片
class WeeklyFocusChartCard extends StatelessWidget {
  final List<double> weeklyFocusHours;

  const WeeklyFocusChartCard({super.key, required this.weeklyFocusHours});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double totalWeeklyHours = weeklyFocusHours.reduce((a, b) => a + b);

        // 判断屏幕是否窄于800像素
        bool isNarrowScreen = constraints.maxWidth < 800;

        if (isNarrowScreen) {
          // 窄屏模式：将总时间和图表分为两个独立的Card
          return Column(
            children: [
              // 总时间Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "本周专注情况",
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                "总计",
                                style: Theme.of(context).textTheme.bodyLarge
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.outline,
                                    ),
                              ),
                              Text(
                                "${totalWeeklyHours.toStringAsFixed(1)} 小时",
                                style: Theme.of(context).textTheme.displayLarge,
                              ),
                            ],
                          ),
                          const SizedBox(width: 8),
                          VerticalDivider(
                            thickness: 4,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // 图表Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "每日专注时长分布",
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 300,
                        child: BarChart(
                          BarChartData(
                            alignment: BarChartAlignment.spaceAround,
                            maxY: 4,
                            barTouchData: BarTouchData(enabled: false),
                            titlesData: FlTitlesData(
                              show: true,
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 28,
                                  getTitlesWidget: (value, meta) {
                                    switch (value.toInt()) {
                                      case 0:
                                        return const Text('周一');
                                      case 1:
                                        return const Text('周二');
                                      case 2:
                                        return const Text('周三');
                                      case 3:
                                        return const Text('周四');
                                      case 4:
                                        return const Text('周五');
                                      case 5:
                                        return const Text('周六');
                                      case 6:
                                        return const Text('周日');
                                      default:
                                        return const Text('');
                                    }
                                  },
                                ),
                              ),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 40,
                                ),
                              ),
                              topTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              rightTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                            ),
                            borderData: FlBorderData(show: false),
                            gridData: FlGridData(show: true),
                            groupsSpace: 12,
                            barGroups: weeklyFocusHours.asMap().entries.map((
                              entry,
                            ) {
                              int index = entry.key;
                              double value = entry.value;
                              return BarChartGroupData(
                                x: index,
                                barRods: [
                                  BarChartRodData(
                                    toY: value,
                                    gradient: LinearGradient(
                                      colors: [Colors.blue, Colors.lightBlue],
                                    ),
                                    width: 16,
                                    borderRadius: BorderRadius.zero,
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        } else {
          // 宽屏模式：保持原有布局
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "本周专注情况",
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Column(
                        children: [
                          Text(
                            "总计",
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.outline,
                                ),
                          ),
                          Text(
                            "${totalWeeklyHours.toStringAsFixed(1)} 小时",
                            style: Theme.of(context).textTheme.displayLarge,
                          ),
                        ],
                      ),
                      const SizedBox(width: 8),
                      VerticalDivider(
                        thickness: 4,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      Expanded(
                        child: Container(
                          height: 240,
                          padding: EdgeInsets.only(left: 8),
                          child: BarChart(
                            BarChartData(
                              alignment: BarChartAlignment.spaceAround,
                              barTouchData: BarTouchData(enabled: false),
                              titlesData: FlTitlesData(
                                show: true,
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 28,
                                    getTitlesWidget: (value, meta) {
                                      switch (value.toInt()) {
                                        case 0:
                                          return const Text('周一');
                                        case 1:
                                          return const Text('周二');
                                        case 2:
                                          return const Text('周三');
                                        case 3:
                                          return const Text('周四');
                                        case 4:
                                          return const Text('周五');
                                        case 5:
                                          return const Text('周六');
                                        case 6:
                                          return const Text('周日');
                                        default:
                                          return const Text('');
                                      }
                                    },
                                  ),
                                ),
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 40,
                                  ),
                                ),
                                topTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                rightTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                              ),
                              borderData: FlBorderData(show: false),
                              gridData: FlGridData(show: true),
                              groupsSpace: 12,
                              barGroups: weeklyFocusHours.asMap().entries.map((
                                entry,
                              ) {
                                int index = entry.key;
                                double value = entry.value;
                                return BarChartGroupData(
                                  x: index,
                                  barRods: [
                                    BarChartRodData(
                                      toY: value,
                                      gradient: LinearGradient(
                                        colors: [Colors.blue, Colors.lightBlue],
                                      ),
                                      width: 16,
                                      borderRadius: BorderRadius.zero,
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}

// 本周完成专注任务数卡片
class WeeklyCompletedTasksCard extends StatelessWidget {
  final int completedTasks;

  const WeeklyCompletedTasksCard({super.key, required this.completedTasks});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "本周完成专注（任务）数量",
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              completedTasks.toString(),
              style: Theme.of(context).textTheme.displayLarge,
            ),
          ],
        ),
      ),
    );
  }
}

// 最常专注时间段卡片
class MostFocusTimeCard extends StatelessWidget {
  final String mostFocusTime;

  const MostFocusTimeCard({super.key, required this.mostFocusTime});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "最常专注的时间段",
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              mostFocusTime,
              style: Theme.of(context).textTheme.displayLarge,
            ),
          ],
        ),
      ),
    );
  }
}

// 随机鼓励信息卡片
class RandomEncouragementCard extends StatelessWidget {
  final List<String> encouragementMessages;

  const RandomEncouragementCard({
    super.key,
    required this.encouragementMessages,
  });

  @override
  Widget build(BuildContext context) {
    // 随机选择一条鼓励信息
    String randomMessage =
        encouragementMessages[DateTime.now().second %
            encouragementMessages.length];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              randomMessage,
              style: Theme.of(context).textTheme.headlineLarge,
            ),
          ],
        ),
      ),
    );
  }
}

// 统计卡片集合组件
class StatisticsCards extends StatelessWidget {
  const StatisticsCards({super.key});

  @override
  Widget build(BuildContext context) {
    // 模拟数据 - 实际应用中应从数据库获取
    String todayFocusTime = "2小时30分钟";
    List<double> weeklyFocusHours = [1.5, 2.0, 0.5, 3.0, 2.5, 1.0, 2.0];
    int weeklyCompletedTasks = 12;
    String mostFocusTime = "上午 9:00 - 11:00";
    List<String> encouragementMessages = [
      "坚持就是胜利！",
      "专注让你更接近目标！",
      "今天的努力，明天的成就！",
      "每一步都在向成功迈进！",
      "你的专注力正在提升！",
      "保持节奏，继续前进！",
      "专注是成功的秘诀！",
      "你已经取得了很大进步！",
    ];

    return Column(
      children: [
        TodayFocusTimeCard(focusTime: todayFocusTime),
        const SizedBox(height: 16),
        WeeklyFocusChartCard(weeklyFocusHours: weeklyFocusHours),
        const SizedBox(height: 16),
        WeeklyCompletedTasksCard(completedTasks: weeklyCompletedTasks),
        const SizedBox(height: 16),
        MostFocusTimeCard(mostFocusTime: mostFocusTime),
        const SizedBox(height: 16),
        RandomEncouragementCard(encouragementMessages: encouragementMessages),
      ],
    );
  }
}

// 辅助函数：计算数组总和
extension SumExtension on Iterable<double> {
  double reduce(double Function(double value, double element) combine) {
    if (isEmpty) return 0.0;
    double result = elementAt(0);
    for (int i = 1; i < length; i++) {
      result = combine(result, elementAt(i));
    }
    return result;
  }
}
