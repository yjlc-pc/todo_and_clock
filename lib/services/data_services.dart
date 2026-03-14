import '../models/task.dart';
import '../models/category.dart';
import '../models/pomodoro.dart';
import 'database_service.dart';

/// 任务数据服务
/// 负责任务的 CRUD 操作
class TaskDataService {
  final DatabaseService _dbService = DatabaseService();

  /// 获取所有任务
  Future<List<Task>> getAllTasks() async {
    final db = await _dbService.database;
    final maps = await db.query('tasks', orderBy: 'createdAt DESC');
    return maps.map((map) => Task.fromMap(map)).toList();
  }

  /// 获取指定分类的任务
  Future<List<Task>> getTasksByCategory(int categoryId) async {
    final db = await _dbService.database;
    final maps = await db.query(
      'tasks',
      where: 'categoryId = ?',
      whereArgs: [categoryId],
      orderBy: 'createdAt DESC',
    );
    return maps.map((map) => Task.fromMap(map)).toList();
  }

  /// 获取未完成的任务
  Future<List<Task>> getIncompleteTasks() async {
    final db = await _dbService.database;
    final maps = await db.query(
      'tasks',
      where: 'isCompleted = 0',
      orderBy: 'createdAt DESC',
    );
    return maps.map((map) => Task.fromMap(map)).toList();
  }

  /// 插入任务
  Future<int> insertTask(Task task) async {
    final db = await _dbService.database;
    return await db.insert('tasks', task.toMap());
  }

  /// 更新任务
  Future<int> updateTask(Task task) async {
    final db = await _dbService.database;
    return await db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  /// 删除任务
  Future<int> deleteTask(int id) async {
    final db = await _dbService.database;
    return await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  /// 批量删除任务
  Future<void> deleteTasks(List<int> ids) async {
    final db = await _dbService.database;
    for (final id in ids) {
      await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
    }
  }
}

/// 分类数据服务
class CategoryDataService {
  final DatabaseService _dbService = DatabaseService();

  /// 获取所有分类
  Future<List<Category>> getAllCategories() async {
    final db = await _dbService.database;
    final maps = await db.query('categories', orderBy: 'id ASC');
    return maps.map((map) => Category.fromMap(map)).toList();
  }

  /// 插入分类
  Future<int> insertCategory(Category category) async {
    final db = await _dbService.database;
    return await db.insert('categories', category.toMap());
  }

  /// 更新分类
  Future<int> updateCategory(Category category) async {
    final db = await _dbService.database;
    return await db.update(
      'categories',
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  /// 删除分类
  Future<int> deleteCategory(int id) async {
    final db = await _dbService.database;
    return await db.delete('categories', where: 'id = ?', whereArgs: [id]);
  }
}

/// 番茄钟数据服务
class PomodoroDataService {
  final DatabaseService _dbService = DatabaseService();

  /// 获取所有番茄钟记录
  Future<List<Pomodoro>> getAllPomodoros() async {
    final db = await _dbService.database;
    final maps = await db.query('pomodoros', orderBy: 'createdAt DESC');
    return maps.map((map) => Pomodoro.fromMap(map)).toList();
  }

  /// 获取指定任务的番茄钟记录
  Future<List<Pomodoro>> getPomodorosByTask(int taskId) async {
    final db = await _dbService.database;
    final maps = await db.query(
      'pomodoros',
      where: 'taskId = ?',
      whereArgs: [taskId],
      orderBy: 'createdAt DESC',
    );
    return maps.map((map) => Pomodoro.fromMap(map)).toList();
  }

  /// 获取指定日期范围的番茄钟记录
  Future<List<Pomodoro>> getPomodorosByDateRange(DateTime start, DateTime end) async {
    final db = await _dbService.database;
    final maps = await db.query(
      'pomodoros',
      where: 'startTime >= ? AND startTime <= ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
      orderBy: 'createdAt DESC',
    );
    return maps.map((map) => Pomodoro.fromMap(map)).toList();
  }

  /// 插入番茄钟记录
  Future<int> insertPomodoro(Pomodoro pomodoro) async {
    final db = await _dbService.database;
    return await db.insert('pomodoros', pomodoro.toMap());
  }

  /// 获取统计数据
  Future<Map<String, dynamic>> getStatistics(DateTime start, DateTime end) async {
    final db = await _dbService.database;
    
    // 总专注时长
    final durationResult = await db.rawQuery('''
      SELECT SUM(duration) as totalDuration 
      FROM pomodoros 
      WHERE startTime >= ? AND startTime <= ? AND isCompleted = 1
    ''', [start.toIso8601String(), end.toIso8601String()]);
    
    // 完成的番茄钟数量
    final countResult = await db.rawQuery('''
      SELECT COUNT(*) as count 
      FROM pomodoros 
      WHERE startTime >= ? AND startTime <= ? AND isCompleted = 1
    ''', [start.toIso8601String(), end.toIso8601String()]);
    
    return {
      'totalDuration': durationResult.first['totalDuration'] ?? 0,
      'completedCount': countResult.first['count'] ?? 0,
    };
  }
}
