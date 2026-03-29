import '../models/pomodoro.dart';
import '../models/task.dart';
import '../models/statistics_summary.dart';
import '../utils/database_helper.dart';

/// 统计工具类 - 用于计算各种统计数据
class StatisticsHelper {
  /// 加载完整的统计数据汇总
  static Future<StatisticsSummary> loadStatisticsSummary() async {
    final dbHelper = DatabaseHelper.instance;
    final pomodoros = await dbHelper.readAllPomodoros();
    final tasks = await dbHelper.readAllTasks();

    // 过滤出已完成的专注记录（不包括休息时间和提前退出的）
    final completedFocusPomodoros = pomodoros
        .where((p) => p.isCompleted && !p.isRest)
        .toList();

    // 今日专注时间
    final todayFocusMinutes = _calculateTodayFocusMinutes(completedFocusPomodoros);

    // 本周专注时间
    final weekFocusMinutes = _calculateWeekFocusMinutes(completedFocusPomodoros);

    // 本月专注时间
    final monthFocusMinutes = _calculateMonthFocusMinutes(completedFocusPomodoros);

    // 近 30 天每天专注时间
    final dailyFocusLast30Days = _calculateDailyFocusLast30Days(completedFocusPomodoros);

    // 近 12 个月每月专注时间
    final dailyFocusLast12Months = _calculateMonthlyFocusLast12Months(completedFocusPomodoros);

    // 近 4 周每周专注时间
    final weeklyFocusLast4Weeks = _calculateWeeklyFocusLast4Weeks(completedFocusPomodoros);

    // 分类时间分布
    final categoryDistribution = _calculateCategoryDistribution(
      completedFocusPomodoros,
      tasks,
    );

    // 时段分布
    final hourlyDistribution = _calculateHourlyDistribution(completedFocusPomodoros);

    // 完成任务数
    final completedTasks = tasks.where((t) => t.isCompleted).length;
    final totalTasks = tasks.length;

    // 连续天数
    final streaks = _calculateStreaks(completedFocusPomodoros);

    // 近 7 天专注状态
    final last7DaysFocus = calculateLast7DaysFocus(completedFocusPomodoros);

    return StatisticsSummary(
      todayFocusMinutes: todayFocusMinutes,
      weekFocusMinutes: weekFocusMinutes,
      monthFocusMinutes: monthFocusMinutes,
      completedTasks: completedTasks,
      totalTasks: totalTasks,
      categoryDistribution: categoryDistribution,
      dailyFocusLast30Days: dailyFocusLast30Days,
      dailyFocusLast12Months: dailyFocusLast12Months,
      hourlyDistribution: hourlyDistribution,
      currentStreak: streaks['current'] ?? 0,
      bestStreak: streaks['best'] ?? 0,
      weeklyFocusLast4Weeks: weeklyFocusLast4Weeks,
      last7DaysFocus: last7DaysFocus,
    );
  }

  /// 计算今日专注分钟数
  static double _calculateTodayFocusMinutes(List<Pomodoro> pomodoros) {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final todayPomodoros = pomodoros.where(
      (p) => p.startTime.isAfter(startOfDay) && p.startTime.isBefore(endOfDay),
    );

    return todayPomodoros.fold(0.0, (sum, p) => sum + p.duration);
  }

  /// 计算本周专注分钟数
  static double _calculateWeekFocusMinutes(List<Pomodoro> pomodoros) {
    final today = DateTime.now();
    final startOfWeek = DateTime(today.year, today.month, today.day - (today.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 7));

    final weekPomodoros = pomodoros.where(
      (p) => p.startTime.isAfter(startOfWeek) && p.startTime.isBefore(endOfWeek),
    );

    return weekPomodoros.fold(0.0, (sum, p) => sum + p.duration);
  }

  /// 计算本月专注分钟数
  static double _calculateMonthFocusMinutes(List<Pomodoro> pomodoros) {
    final today = DateTime.now();
    final startOfMonth = DateTime(today.year, today.month, 1);
    final endOfMonth = today.month == 12
        ? DateTime(today.year + 1, 1, 1)
        : DateTime(today.year, today.month + 1, 1);

    final monthPomodoros = pomodoros.where(
      (p) => p.startTime.isAfter(startOfMonth) && p.startTime.isBefore(endOfMonth),
    );

    return monthPomodoros.fold(0.0, (sum, p) => sum + p.duration);
  }

  /// 计算近 30 天每天专注时间（分钟）
  static List<double> _calculateDailyFocusLast30Days(List<Pomodoro> pomodoros) {
    final today = DateTime.now();
    final startDate = today.subtract(const Duration(days: 29));
    
    List<double> dailyMinutes = List.filled(30, 0.0);

    for (var pomodoro in pomodoros) {
      if (pomodoro.startTime.isAfter(startDate.subtract(const Duration(days: 1)))) {
        final daysDiff = today.difference(
          DateTime(pomodoro.startTime.year, pomodoro.startTime.month, pomodoro.startTime.day),
        ).inDays;
        if (daysDiff >= 0 && daysDiff < 30) {
          dailyMinutes[29 - daysDiff] += pomodoro.duration;
        }
      }
    }

    return dailyMinutes;
  }

  /// 计算近 12 个月每月专注时间（分钟）
  static List<double> _calculateMonthlyFocusLast12Months(List<Pomodoro> pomodoros) {
    final today = DateTime.now();
    List<double> monthlyMinutes = List.filled(12, 0.0);

    for (var pomodoro in pomodoros) {
      final monthsDiff = (today.year - pomodoro.startTime.year) * 12 +
          (today.month - pomodoro.startTime.month);
      if (monthsDiff >= 0 && monthsDiff < 12) {
        monthlyMinutes[11 - monthsDiff] += pomodoro.duration;
      }
    }

    return monthlyMinutes;
  }

  /// 计算近 4 周每周专注时间（分钟）
  static List<double> _calculateWeeklyFocusLast4Weeks(List<Pomodoro> pomodoros) {
    final today = DateTime.now();
    List<double> weeklyMinutes = List.filled(4, 0.0);

    for (var pomodoro in pomodoros) {
      final daysDiff = today.difference(
        DateTime(pomodoro.startTime.year, pomodoro.startTime.month, pomodoro.startTime.day),
      ).inDays;
      final weekIndex = daysDiff ~/ 7;
      if (weekIndex >= 0 && weekIndex < 4) {
        weeklyMinutes[3 - weekIndex] += pomodoro.duration;
      }
    }

    return weeklyMinutes;
  }

  /// 计算分类时间分布
  static Map<int, double> _calculateCategoryDistribution(
    List<Pomodoro> pomodoros,
    List<Task> tasks,
  ) {
    Map<int, double> distribution = {};

    // 创建任务 ID 到分类 ID 的映射
    Map<int, int> taskIdToCategory = {};
    for (var task in tasks) {
      if (task.id != null && task.categoryId != null) {
        taskIdToCategory[task.id!] = task.categoryId!;
      }
    }

    for (var pomodoro in pomodoros) {
      if (taskIdToCategory.containsKey(pomodoro.taskId)) {
        final categoryId = taskIdToCategory[pomodoro.taskId]!;
        if (distribution.containsKey(categoryId)) {
          distribution[categoryId] = distribution[categoryId]! + pomodoro.duration.toDouble();
        } else {
          distribution[categoryId] = pomodoro.duration.toDouble();
        }
      }
    }

    return distribution;
  }

  /// 计算时段分布（按小时统计专注分钟数）
  static Map<int, int> _calculateHourlyDistribution(List<Pomodoro> pomodoros) {
    Map<int, int> distribution = {};
    
    for (var pomodoro in pomodoros) {
      final hour = pomodoro.startTime.hour;
      distribution[hour] = (distribution[hour] ?? 0) + pomodoro.duration;
    }

    return distribution;
  }

  /// 计算连续专注天数
  static Map<String, int> _calculateStreaks(List<Pomodoro> pomodoros) {
    if (pomodoros.isEmpty) {
      return {'current': 0, 'best': 0};
    }

    // 获取有专注记录的日期（去重）
    Set<String> uniqueDates = {};
    for (var pomodoro in pomodoros) {
      final dateStr = '${pomodoro.startTime.year}-${pomodoro.startTime.month}-${pomodoro.startTime.day}';
      uniqueDates.add(dateStr);
    }

    List<DateTime> dates = uniqueDates
        .map((d) {
          final parts = d.split('-');
          return DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
        })
        .toList();
    
    dates.sort((a, b) => b.compareTo(a)); // 降序排列

    if (dates.isEmpty) {
      return {'current': 0, 'best': 0};
    }

    // 计算当前连续天数
    int currentStreak = 1;
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final yesterday = todayDate.subtract(const Duration(days: 1));
    
    bool hasToday = dates.any((d) => 
      d.year == todayDate.year && d.month == todayDate.month && d.day == todayDate.day);
    bool hasYesterday = dates.any((d) => 
      d.year == yesterday.year && d.month == yesterday.month && d.day == yesterday.day);

    if (!hasToday && !hasYesterday) {
      currentStreak = 0;
    } else {
      for (int i = 0; i < dates.length - 1; i++) {
        final diff = dates[i].difference(dates[i + 1]).inDays;
        if (diff == 1) {
          currentStreak++;
        } else if (diff > 1) {
          break;
        }
      }
      // 如果没有今天的记录，但有昨天的，当前连续天数从昨天开始算
      if (!hasToday && hasYesterday) {
        // currentStreak 已经正确计算
      }
    }

    // 计算最佳连续天数
    int bestStreak = 1;
    int tempStreak = 1;
    
    for (int i = 0; i < dates.length - 1; i++) {
      final diff = dates[i].difference(dates[i + 1]).inDays;
      if (diff == 1) {
        tempStreak++;
        if (tempStreak > bestStreak) {
          bestStreak = tempStreak;
        }
      } else if (diff > 1) {
        tempStreak = 1;
      }
    }

    return {'current': currentStreak, 'best': bestStreak};
  }

  /// 格式化时间显示（分钟转为小时 + 分钟）
  static String formatDuration(double minutes) {
    if (minutes < 60) {
      return '${minutes.round()}分钟';
    }
    final hours = (minutes / 60).floor();
    final remainingMinutes = (minutes % 60).round();
    if (remainingMinutes == 0) {
      return '$hours 小时';
    }
    return '$hours 小时$remainingMinutes 分钟';
  }

  /// 格式化时间显示（简短版）
  static String formatDurationShort(double minutes) {
    if (minutes < 60) {
      return '${minutes.round()}m';
    }
    final hours = (minutes / 60);
    return '${hours.toStringAsFixed(1)}h';
  }

  /// 获取最常专注的时段
  static String getMostFocusTime(Map<int, int> hourlyDistribution) {
    if (hourlyDistribution.isEmpty) {
      return '暂无数据';
    }

    int maxHour = 0;
    int maxMinutes = 0;

    for (var entry in hourlyDistribution.entries) {
      if (entry.value > maxMinutes) {
        maxMinutes = entry.value;
        maxHour = entry.key;
      }
    }

    String period;
    if (maxHour >= 5 && maxHour < 12) {
      period = '上午';
    } else if (maxHour >= 12 && maxHour < 14) {
      period = '中午';
    } else if (maxHour >= 14 && maxHour < 18) {
      period = '下午';
    } else {
      period = '晚上';
    }

    return '$period ${maxHour.toString().padLeft(2, '0')}:00';
  }

  /// 计算近 7 天每天的专注状态（true=已专注，false=未专注）
  static List<bool> calculateLast7DaysFocus(List<Pomodoro> pomodoros) {
    final today = DateTime.now();
    List<bool> last7Days = List.filled(7, false);

    // 获取有专注记录的日期（去重）
    Set<String> uniqueDates = {};
    for (var pomodoro in pomodoros) {
      if (pomodoro.isCompleted && !pomodoro.isRest) {
        final dateStr = '${pomodoro.startTime.year}-${pomodoro.startTime.month}-${pomodoro.startTime.day}';
        uniqueDates.add(dateStr);
      }
    }

    for (var dateStr in uniqueDates) {
      final parts = dateStr.split('-');
      final date = DateTime(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      );
      final daysDiff = today.difference(
        DateTime(date.year, date.month, date.day),
      ).inDays;
      if (daysDiff >= 0 && daysDiff < 7) {
        last7Days[6 - daysDiff] = true;
      }
    }

    return last7Days;
  }
}
