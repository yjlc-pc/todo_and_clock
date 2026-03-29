import 'package:flutter/material.dart';
import '../utils/statistics_helper.dart';

// ==================== 基础统计卡片 ====================

/// 今日专注时间卡片
class TodayFocusTimeCard extends StatelessWidget {
  final double focusMinutes;

  const TodayFocusTimeCard({super.key, required this.focusMinutes});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // 根据专注时长选择颜色和图标
    IconData icon;
    Color cardColor;
    String message;
    
    if (focusMinutes == 0) {
      icon = Icons.play_circle_outline;
      cardColor = colorScheme.surfaceContainer;
      message = '今天还没开始专注哦';
    } else if (focusMinutes < 60) {
      icon = Icons.timer_outlined;
      cardColor = colorScheme.primaryContainer;
      message = '专注进行中，继续保持！';
    } else if (focusMinutes < 120) {
      icon = Icons.thumb_up_outlined;
      cardColor = colorScheme.secondaryContainer;
      message = '不错哦，已经专注一小时了！';
    } else {
      icon = Icons.emoji_events_outlined;
      cardColor = colorScheme.tertiaryContainer;
      message = '太厉害了，专注达人！';
    }

    return Card(
      color: cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: colorScheme.onSecondaryContainer),
                Text(
                  '今日',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: colorScheme.onSecondaryContainer.withValues(alpha: 0.7),
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              StatisticsHelper.formatDuration(focusMinutes),
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSecondaryContainer,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              message,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSecondaryContainer.withValues(alpha: 0.8),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 本周专注时间卡片
class WeekFocusTimeCard extends StatelessWidget {
  final double focusMinutes;

  const WeekFocusTimeCard({super.key, required this.focusMinutes});

  @override
  Widget build(BuildContext context) {
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
                  Icons.calendar_today_outlined,
                  color: colorScheme.outline,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  '本周专注',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              StatisticsHelper.formatDuration(focusMinutes),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 本月专注时间卡片
class MonthFocusTimeCard extends StatelessWidget {
  final double focusMinutes;

  const MonthFocusTimeCard({super.key, required this.focusMinutes});

  @override
  Widget build(BuildContext context) {
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
                  Icons.date_range_outlined,
                  color: colorScheme.outline,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  '本月专注',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              StatisticsHelper.formatDuration(focusMinutes),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.secondary,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== 原有卡片（保持兼容） ====================

/// 本周完成专注任务数卡片
class WeeklyCompletedTasksCard extends StatelessWidget {
  final int completedTasks;

  const WeeklyCompletedTasksCard({super.key, required this.completedTasks});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.surfaceContainerLowest,
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

/// 最常专注时间段卡片
class MostFocusTimeCard extends StatelessWidget {
  final String mostFocusTime;

  const MostFocusTimeCard({super.key, required this.mostFocusTime});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.surfaceContainerLowest,
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

/// 随机鼓励信息卡片
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
      color: Theme.of(context).colorScheme.primaryContainer,
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

// ==================== 统计卡片集合（旧版，保持兼容） ====================

class StatisticsCards extends StatelessWidget {
  const StatisticsCards({super.key});

  @override
  Widget build(BuildContext context) {
    // 模拟数据 - 实际应用中应从数据库获取
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
        TodayFocusTimeCard(focusMinutes: 150),
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
