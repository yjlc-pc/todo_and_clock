class Pomodoro {
  int? id;
  int taskId; // 关联的任务ID
  String title; // 番茄钟标题
  DateTime startTime; // 开始时间
  DateTime endTime; // 结束时间
  int duration; // 持续时间（分钟）
  bool isCompleted; // 是否完成
  bool isRest; // 是否是休息时间
  DateTime createdAt; // 创建时间

  Pomodoro({
    this.id,
    required this.taskId,
    required this.title,
    required this.startTime,
    required this.endTime,
    required this.duration,
    required this.isCompleted,
    required this.isRest,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'taskId': taskId,
      'title': title,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'duration': duration,
      'isCompleted': isCompleted ? 1 : 0,
      'isRest': isRest ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Pomodoro.fromMap(Map<String, dynamic> map) {
    return Pomodoro(
      id: map['id'] as int?,
      taskId: map['taskId'] as int,
      title: map['title'] as String,
      startTime: DateTime.parse(map['startTime'] as String),
      endTime: DateTime.parse(map['endTime'] as String),
      duration: map['duration'] as int,
      isCompleted: map['isCompleted'] == 1,
      isRest: map['isRest'] == 1,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}