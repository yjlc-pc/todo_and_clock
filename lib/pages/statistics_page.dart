import 'package:flutter/material.dart';
import 'package:todo_list_and_clock/widgets/statistics_cards.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
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

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Wrap(
          spacing: 16.0, // 主轴(水平)方向间距
          runSpacing: 16.0, // 纵轴（垂直）方向间距
          alignment: WrapAlignment.center,
          children: <Widget>[
            TodayFocusTimeCard(focusTime: todayFocusTime),
            WeeklyFocusChartCard(weeklyFocusHours: weeklyFocusHours),
            WeeklyCompletedTasksCard(completedTasks: weeklyCompletedTasks),
            MostFocusTimeCard(mostFocusTime: mostFocusTime),
            RandomEncouragementCard(
              encouragementMessages: encouragementMessages,
            ),
          ],
        ),
      ),
    );
  }
}
