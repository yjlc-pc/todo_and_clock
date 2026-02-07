class Task {
  Task({
    this.id,
    required this.isImportant,
    required this.title,
    required this.isCompleted,
    required this.time,
    required this.repeat,
  });

  int? id;
  bool isImportant;
  String title;
  bool isCompleted;
  DateTime time;
  String repeat;

  void toggleCompleted() {
    isCompleted = !isCompleted;
  }

  // 序列化为 JSON
  Map<String, dynamic> toJson() {
    return {
      'isImportant': isImportant,
      'title': title,
      'isCompleted': isCompleted,
      'time': time.toIso8601String(),
      'repeat': repeat,
    };
  }

  // 从 JSON 反序列化
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      isImportant: json['isImportant'] as bool,
      title: json['title'] as String,
      isCompleted: json['isCompleted'] as bool,
      time: DateTime.parse(json['time'] as String),
      repeat: json['repeat'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'isImportant': isImportant ? 1 : 0,
      'title': title,
      'isCompleted': isCompleted ? 1 : 0,
      'time': time.toIso8601String(),
      'repeat': repeat,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] as int?,
      isImportant: map['isImportant'] == 1,
      title: map['title'] as String,
      isCompleted: map['isCompleted'] == 1,
      time: DateTime.parse(map['time'] as String),
      repeat: map['repeat'] as String,
    );
  }
}
