import 'package:flutter/material.dart';
import 'package:todo_list_and_clock/widgets/statistics_cards.dart';
import 'package:todo_list_and_clock/utils/database_helper.dart';
import 'package:todo_list_and_clock/models/pomodoro.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  late Future<Map<String, dynamic>> _statisticsFuture;

  @override
  void initState() {
    super.initState();
    _statisticsFuture = _loadStatistics();
  }

  // 加载统计数据
  Future<Map<String, dynamic>> _loadStatistics() async {
    final dbHelper = DatabaseHelper.instance;
    final pomodoros = await dbHelper.readAllPomodoros();

    // 计算今日专注时间
    String todayFocusTime = _calculateTodayFocusTime(pomodoros);

    // 计算本周每天的专注小时数
    List<double> weeklyFocusHours = _calculateWeeklyFocusHours(pomodoros);

    // 计算本周完成的任务数
    int weeklyCompletedTasks = _calculateWeeklyCompletedTasks(pomodoros);

    // 计算最常专注的时间段
    String mostFocusTime = _calculateMostFocusTime(pomodoros);

    return {
      'todayFocusTime': todayFocusTime,
      'weeklyFocusHours': weeklyFocusHours,
      'weeklyCompletedTasks': weeklyCompletedTasks,
      'mostFocusTime': mostFocusTime,
    };
  }

  // 计算今日专注时间
  String _calculateTodayFocusTime(List<Pomodoro> pomodoros) {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59);

    final todayPomodoros = pomodoros.where(
      (pomodoro) =>
          pomodoro.isCompleted &&
          !pomodoro.isRest &&
          pomodoro.startTime.isAfter(startOfDay) &&
          pomodoro.startTime.isBefore(endOfDay),
    );

    int totalMinutes = 0;
    for (var pomodoro in todayPomodoros) {
      totalMinutes += pomodoro.duration;
    }

    int hours = totalMinutes ~/ 60;
    int minutes = totalMinutes % 60;

    if (hours > 0) {
      return "$hours小时$minutes分钟";
    } else {
      return "$minutes分钟";
    }
  }

  // 计算本周每天的专注小时数
  List<double> _calculateWeeklyFocusHours(List<Pomodoro> pomodoros) {
    final today = DateTime.now();
    // 获取本周一的日期
    final monday = DateTime(
      today.year,
      today.month,
      today.day - (today.weekday - 1),
    );

    // 创建一个包含7天的列表，初始值为0
    List<double> weeklyHours = List.generate(7, (index) => 0.0);

    for (var pomodoro in pomodoros) {
      if (!pomodoro.isCompleted || pomodoro.isRest) continue;

      // 检查番茄钟是否在本周内
      if (pomodoro.startTime.isAfter(monday) &&
          pomodoro.startTime.isBefore(
            DateTime(monday.year, monday.month, monday.day + 7),
          )) {
        // 计算该番茄钟属于本周的第几天
        int dayIndex = pomodoro.startTime.weekday - 1; // 周一为0，周日为6

        // 累加专注时间（转换为小时）
        weeklyHours[dayIndex] += pomodoro.duration / 60.0;
      }
    }

    return weeklyHours;
  }

  // 计算本周完成的任务数
  int _calculateWeeklyCompletedTasks(List<Pomodoro> pomodoros) {
    final today = DateTime.now();
    final monday = DateTime(
      today.year,
      today.month,
      today.day - (today.weekday - 1),
    );

    final weekPomodoros = pomodoros.where(
      (pomodoro) =>
          pomodoro.isCompleted &&
          !pomodoro.isRest &&
          pomodoro.startTime.isAfter(monday) &&
          pomodoro.startTime.isBefore(
            DateTime(monday.year, monday.month, monday.day + 7),
          ),
    );

    // 使用Set来去重，按任务ID统计
    Set<int> uniqueTaskIds = {};
    for (var pomodoro in weekPomodoros) {
      uniqueTaskIds.add(pomodoro.taskId);
    }

    return uniqueTaskIds.length;
  }

  // 计算最常专注的时间段
  String _calculateMostFocusTime(List<Pomodoro> pomodoros) {
    // 过滤出已完成的专注番茄钟
    final completedFocusPomodoros = pomodoros.where(
      (pomodoro) => pomodoro.isCompleted && !pomodoro.isRest,
    );

    // 按小时分组统计
    Map<int, int> hourCount = {};
    for (var pomodoro in completedFocusPomodoros) {
      int hour = pomodoro.startTime.hour;
      hourCount[hour] = (hourCount[hour] ?? 0) + 1;
    }

    // 找到出现次数最多的小时段
    int mostCommonHour = 0;
    int maxCount = 0;
    for (var entry in hourCount.entries) {
      if (entry.value > maxCount) {
        maxCount = entry.value;
        mostCommonHour = entry.key;
      }
    }

    // 返回格式化的时间段
    if (maxCount > 0) {
      if (mostCommonHour < 12) {
        return "上午 $mostCommonHour:00 - ${mostCommonHour + 1}:00";
      } else if (mostCommonHour == 12) {
        return "中午 $mostCommonHour:00 - ${mostCommonHour + 1}:00";
      } else {
        return "下午 $mostCommonHour:00 - ${mostCommonHour + 1}:00";
      }
    } else {
      return "暂无数据";
    }
  }

  @override
  Widget build(BuildContext context) {
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

    return FutureBuilder<Map<String, dynamic>>(
      future: _statisticsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('加载数据时出错: ${snapshot.error}'));
        }

        final data = snapshot.data!;
        final todayFocusTime = data['todayFocusTime'] as String;
        final weeklyFocusHours = data['weeklyFocusHours'] as List<double>;
        final weeklyCompletedTasks = data['weeklyCompletedTasks'] as int;
        final mostFocusTime = data['mostFocusTime'] as String;

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Wrap(
              spacing: 16.0, // 主轴(水平)方向间距
              runSpacing: 12.0, // 纵轴（垂直）方向间距
              alignment: WrapAlignment.center,
              children: <Widget>[
                TodayFocusTimeCard(focusTime: todayFocusTime),

                WeeklyCompletedTasksCard(completedTasks: weeklyCompletedTasks),
                MostFocusTimeCard(mostFocusTime: mostFocusTime),

                WeeklyFocusChartCard(weeklyFocusHours: weeklyFocusHours),
                RandomEncouragementCard(
                  encouragementMessages: encouragementMessages,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
