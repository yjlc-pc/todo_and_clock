/// 统计数据汇总模型
class StatisticsSummary {
  final double todayFocusMinutes;
  final double weekFocusMinutes;
  final double monthFocusMinutes;
  final int completedTasks;
  final int totalTasks;
  final Map<int, double> categoryDistribution; // categoryId -> minutes
  final List<double> dailyFocusLast30Days; // 近 30 天每天专注分钟数
  final List<double> dailyFocusLast12Months; // 近 12 个月每月专注分钟数
  final Map<int, int> hourlyDistribution; // hour -> minutes
  final int currentStreak; // 当前连续专注天数
  final int bestStreak; // 最佳连续天数
  final List<double> weeklyFocusLast4Weeks; // 近 4 周每周专注分钟数
  final List<bool> last7DaysFocus; // 近 7 天每天专注状态（true=已专注）

  StatisticsSummary({
    required this.todayFocusMinutes,
    required this.weekFocusMinutes,
    required this.monthFocusMinutes,
    required this.completedTasks,
    required this.totalTasks,
    required this.categoryDistribution,
    required this.dailyFocusLast30Days,
    required this.dailyFocusLast12Months,
    required this.hourlyDistribution,
    required this.currentStreak,
    required this.bestStreak,
    required this.weeklyFocusLast4Weeks,
    required this.last7DaysFocus,
  });

  double get completionRate =>
      totalTasks > 0 ? (completedTasks / totalTasks) * 100 : 0.0;

  double get averageDailyFocus =>
      dailyFocusLast30Days.isNotEmpty
          ? dailyFocusLast30Days.reduce((a, b) => a + b) /
              dailyFocusLast30Days.length
          : 0.0;
}

/// 时间范围枚举
enum TimeRange { week, month, year }

extension TimeRangeExtension on TimeRange {
  String get displayName {
    switch (this) {
      case TimeRange.week:
        return '周';
      case TimeRange.month:
        return '月';
      case TimeRange.year:
        return '年';
    }
  }
}
