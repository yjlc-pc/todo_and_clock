/// 任务模型 - 纯数据类
class Task {
  int? id;
  final String title;
  final String? description;
  final bool isCompleted;
  final int? categoryId;
  final DateTime? dueDate;
  final int priority;
  final int repeatType;
  final int? repeatInterval;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Task({
    this.id,
    required this.title,
    this.description,
    this.isCompleted = false,
    this.categoryId,
    this.dueDate,
    this.priority = 0,
    this.repeatType = 0,
    this.repeatInterval,
    required this.createdAt,
    this.updatedAt,
  });

  /// 从 Map 创建任务
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] as int?,
      title: map['title'] as String,
      description: map['description'] as String?,
      isCompleted: (map['isCompleted'] as int?) == 1,
      categoryId: map['categoryId'] as int?,
      dueDate: map['dueDate'] != null ? DateTime.parse(map['dueDate'] as String) : null,
      priority: map['priority'] as int? ?? 0,
      repeatType: map['repeatType'] as int? ?? 0,
      repeatInterval: map['repeatInterval'] as int?,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: map['updatedAt'] != null ? DateTime.parse(map['updatedAt'] as String) : null,
    );
  }

  /// 转换为 Map
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'description': description,
      'isCompleted': isCompleted ? 1 : 0,
      'categoryId': categoryId,
      'dueDate': dueDate?.toIso8601String(),
      'priority': priority,
      'repeatType': repeatType,
      'repeatInterval': repeatInterval,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
    };
  }

  /// 复制并修改任务
  Task copyWith({
    int? id,
    String? title,
    String? description,
    bool? isCompleted,
    int? categoryId,
    DateTime? dueDate,
    int? priority,
    int? repeatType,
    int? repeatInterval,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      categoryId: categoryId ?? this.categoryId,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      repeatType: repeatType ?? this.repeatType,
      repeatInterval: repeatInterval ?? this.repeatInterval,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// 获取优先级文本
  String get priorityText {
    switch (priority) {
      case 0:
        return '低';
      case 1:
        return '中';
      case 2:
        return '高';
      default:
        return '中';
    }
  }
}
