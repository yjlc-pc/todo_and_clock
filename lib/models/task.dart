import '../enums/repeat_type.dart';

class Task {
  Task({
    this.id,
    required this.isImportant,
    required this.title,
    required this.isCompleted,
    required this.date,
    this.repeat = RepeatType.none,
  });

  int? id;
  bool isImportant;
  String title;
  bool isCompleted;
  DateTime date;
  RepeatType repeat;

  void toggleCompleted() {
    isCompleted = !isCompleted;
  }

  // 序列化为 JSON
  Map<String, dynamic> toJson() {
    return {
      'isImportant': isImportant,
      'title': title,
      'isCompleted': isCompleted,
      'time': date.toIso8601String(),
      'repeat': repeat.value,
    };
  }

  // 从 JSON 反序列化
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      isImportant: json['isImportant'] as bool,
      title: json['title'] as String,
      isCompleted: json['isCompleted'] as bool,
      date: DateTime.parse(json['time'] as String),
      repeat: RepeatType.fromValue(json['repeat'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'isImportant': isImportant ? 1 : 0,
      'title': title,
      'isCompleted': isCompleted ? 1 : 0,
      'time': date.toIso8601String(),
      'repeat': repeat.value,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] as int?,
      isImportant: map['isImportant'] == 1,
      title: map['title'] as String,
      isCompleted: map['isCompleted'] == 1,
      date: DateTime.parse(map['time'] as String),
      repeat: RepeatType.fromValue(map['repeat'] as String),
    );
  }
}
