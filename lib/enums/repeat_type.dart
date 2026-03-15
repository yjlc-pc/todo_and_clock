/// 重复周期类型枚举
enum RepeatType {
  none('无', ''),
  daily('每天', 'daily'),
  weekly('每周', 'weekly'),
  monthly('每月', 'monthly'),
  yearly('每年', 'yearly');

  const RepeatType(this.displayName, this.value);

  final String displayName;
  final String value;

  /// 根据字符串值获取对应的枚举
  static RepeatType fromValue(String value) {
    return RepeatType.values.firstWhere(
      (type) => type.value.toLowerCase() == value.toLowerCase(),
      orElse: () => RepeatType.none,
    );
  }

  /// 获取下一个日期（根据重复周期）
  DateTime getNextDate(DateTime startDate) {
    switch (this) {
      case RepeatType.daily:
        return startDate.add(const Duration(days: 1));
      case RepeatType.weekly:
        return startDate.add(const Duration(days: 7));
      case RepeatType.monthly:
        // 处理月份边界情况
        int nextMonth = startDate.month + 1;
        int nextYear = startDate.year;

        if (nextMonth > 12) {
          nextMonth = 1;
          nextYear += 1;
        }

        // 确保日期有效（例如：1月31日 + 1个月 = 2月28/29日）
        int day = startDate.day;
        int daysInNextMonth = DateTime(nextYear, nextMonth + 1, 0).day;
        if (day > daysInNextMonth) {
          day = daysInNextMonth;
        }

        return DateTime(nextYear, nextMonth, day);
      case RepeatType.yearly:
        // 处理闰年情况
        int nextYear = startDate.year + 1;
        int month = startDate.month;
        int day = startDate.day;

        // 检查下一年的同月同日是否存在（如2月29日的情况）
        try {
          return DateTime(nextYear, month, day);
        } catch (e) {
          // 如果日期无效（如2月29日），则改为2月28日
          return DateTime(nextYear, 2, 28);
        }
      case RepeatType.none:
        return startDate;
    }
  }
}
