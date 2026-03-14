/// 番茄钟记录模型 - 纯数据类
class Pomodoro {
  int? id;
  final int taskId;
  final String title;
  final DateTime startTime;
  final DateTime? endTime;
  final int duration;
  final bool isCompleted;
  final bool isRest;
  final bool earlyExit;
  final DateTime createdAt;

  Pomodoro({
    this.id,
    required this.taskId,
    required this.title,
    required this.startTime,
    this.endTime,
    this.duration = 0,
    this.isCompleted = false,
    this.isRest = false,
    this.earlyExit = false,
    required this.createdAt,
  });

  /// 从 Map 创建番茄钟记录
  factory Pomodoro.fromMap(Map<String, dynamic> map) {
    return Pomodoro(
      id: map['id'] as int?,
      taskId: map['taskId'] as int? ?? 0,
      title: map['title'] as String,
      startTime: DateTime.parse(map['startTime'] as String),
      endTime: map['endTime'] != null ? DateTime.parse(map['endTime'] as String) : null,
      duration: map['duration'] as int? ?? 0,
      isCompleted: (map['isCompleted'] as int?) == 1,
      isRest: (map['isRest'] as int?) == 1,
      earlyExit: (map['earlyExit'] as int?) == 1,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  /// 转换为 Map
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'taskId': taskId,
      'title': title,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'duration': duration,
      'isCompleted': isCompleted ? 1 : 0,
      'isRest': isRest ? 1 : 0,
      'earlyExit': earlyExit ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// 复制并修改
  Pomodoro copyWith({
    int? id,
    int? taskId,
    String? title,
    DateTime? startTime,
    DateTime? endTime,
    int? duration,
    bool? isCompleted,
    bool? isRest,
    bool? earlyExit,
    DateTime? createdAt,
  }) {
    return Pomodoro(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      title: title ?? this.title,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      duration: duration ?? this.duration,
      isCompleted: isCompleted ?? this.isCompleted,
      isRest: isRest ?? this.isRest,
      earlyExit: earlyExit ?? this.earlyExit,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// 获取实际结束时间
  DateTime get actualEndTime => endTime ?? DateTime.now();

  /// 获取会话时长（分钟）
  int get sessionMinutes {
    if (endTime == null) return 0;
    return endTime!.difference(startTime).inMinutes;
  }
}
