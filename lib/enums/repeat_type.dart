/// 重复类型枚举
enum RepeatType {
  none,      // 不重复
  daily,     // 每天
  weekly,    // 每周
  monthly,   // 每月
  custom,    // 自定义
}

/// 重复类型扩展
extension RepeatTypeExtension on RepeatType {
  String get displayName {
    switch (this) {
      case RepeatType.none:
        return '不重复';
      case RepeatType.daily:
        return '每天';
      case RepeatType.weekly:
        return '每周';
      case RepeatType.monthly:
        return '每月';
      case RepeatType.custom:
        return '自定义';
    }
  }

  static RepeatType fromInt(int value) {
    switch (value) {
      case 0:
        return RepeatType.none;
      case 1:
        return RepeatType.daily;
      case 2:
        return RepeatType.weekly;
      case 3:
        return RepeatType.monthly;
      case 4:
        return RepeatType.custom;
      default:
        return RepeatType.none;
    }
  }

  int toInt() {
    switch (this) {
      case RepeatType.none:
        return 0;
      case RepeatType.daily:
        return 1;
      case RepeatType.weekly:
        return 2;
      case RepeatType.monthly:
        return 3;
      case RepeatType.custom:
        return 4;
    }
  }
}
