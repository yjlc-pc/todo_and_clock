import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:todo_list_and_clock/models/task.dart';
import 'package:todo_list_and_clock/models/pomodoro.dart';
import 'package:todo_list_and_clock/models/category.dart';
import 'task_database_factory.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('tasks.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    // 使用新的数据库工厂，避免与全局设置冲突
    final factory = TaskDatabaseFactory.instance;
    return await factory.getDatabase(filePath);
  }

  // 任务相关操作
  Future<int> createTask(Task task) async {
    final db = await instance.database;
    final factory = TaskDatabaseFactory.instance;
    return await factory.createTask(db, task);
  }

  Future<List<Task>> readAllTasks() async {
    final db = await instance.database;
    final factory = TaskDatabaseFactory.instance;
    return await factory.readAllTasks(db);
  }

  Future<int> updateTask(Task task) async {
    final db = await instance.database;
    final factory = TaskDatabaseFactory.instance;
    return await factory.updateTask(db, task);
  }

  Future<int> deleteTask(int id) async {
    final db = await instance.database;
    final factory = TaskDatabaseFactory.instance;
    return await factory.deleteTask(db, id);
  }

  // 番茄钟相关操作
  Future<int> createPomodoro(Pomodoro pomodoro) async {
    final db = await instance.database;
    final factory = TaskDatabaseFactory.instance;
    return await factory.createPomodoro(db, pomodoro);
  }

  Future<List<Pomodoro>> readAllPomodoros() async {
    final db = await instance.database;
    final factory = TaskDatabaseFactory.instance;
    return await factory.readAllPomodoros(db);
  }

  Future<List<Pomodoro>> readPomodorosByTaskId(int taskId) async {
    final db = await instance.database;
    final factory = TaskDatabaseFactory.instance;
    return await factory.readPomodorosByTaskId(db, taskId);
  }

  Future<int> updatePomodoro(Pomodoro pomodoro) async {
    final db = await instance.database;
    final factory = TaskDatabaseFactory.instance;
    return await factory.updatePomodoro(db, pomodoro);
  }

  Future<int> deletePomodoro(int id) async {
    final db = await instance.database;
    final factory = TaskDatabaseFactory.instance;
    return await factory.deletePomodoro(db, id);
  }

  // 分类相关操作
  Future<int> createCategory(Category category) async {
    final db = await instance.database;
    final factory = TaskDatabaseFactory.instance;
    return await factory.createCategory(db, category);
  }

  Future<List<Category>> readAllCategories() async {
    final db = await instance.database;
    final factory = TaskDatabaseFactory.instance;
    return await factory.readAllCategories(db);
  }

  Future<int> updateCategory(Category category) async {
    final db = await instance.database;
    final factory = TaskDatabaseFactory.instance;
    return await factory.updateCategory(db, category);
  }

  Future<int> deleteCategory(int id) async {
    final db = await instance.database;
    final factory = TaskDatabaseFactory.instance;
    return await factory.deleteCategory(db, id);
  }

  // 统计相关查询
  /// 获取指定日期范围内的专注记录
  Future<List<Pomodoro>> readPomodorosByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final db = await instance.database;
    final query = '''
      SELECT * FROM pomodoros 
      WHERE isRest = 0 
      AND startTime >= ? 
      AND startTime <= ?
      ORDER BY startTime ASC
    ''';
    final result = await db.rawQuery(
      query,
      [startDate.toIso8601String(), endDate.toIso8601String()],
    );
    return result.map((map) => Pomodoro.fromMap(map)).toList();
  }

  /// 获取按分类统计的专注时长
  Future<Map<int, int>> getCategoryFocusDuration() async {
    final db = await instance.database;
    final query = '''
      SELECT p.taskId, t.categoryId, SUM(p.duration) as totalDuration
      FROM pomodoros p
      LEFT JOIN tasks t ON p.taskId = t.id
      WHERE p.isRest = 0
      GROUP BY t.categoryId
    ''';
    final result = await db.rawQuery(query);
    
    Map<int, int> categoryMap = {};
    for (var row in result) {
      final categoryId = row['categoryId'] as int?;
      final duration = row['totalDuration'] as int?;
      if (categoryId != null && duration != null) {
        categoryMap[categoryId] = (categoryMap[categoryId] ?? 0) + duration;
      }
    }
    return categoryMap;
  }

  /// 获取按日期分组的专注时长（用于热力图等）
  Future<Map<String, int>> getDailyFocusDuration({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final db = await instance.database;
    final query = '''
      SELECT DATE(startTime) as date, SUM(duration) as totalDuration
      FROM pomodoros
      WHERE isRest = 0
      AND startTime >= ?
      AND startTime <= ?
      GROUP BY DATE(startTime)
      ORDER BY date ASC
    ''';
    final result = await db.rawQuery(
      query,
      [startDate.toIso8601String(), endDate.toIso8601String()],
    );
    
    Map<String, int> dailyMap = {};
    for (var row in result) {
      final date = row['date'] as String;
      final duration = row['totalDuration'] as int?;
      if (duration != null) {
        dailyMap[date] = duration;
      }
    }
    return dailyMap;
  }

  Future close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
