import 'package:sqflite/sqflite.dart';
import 'package:todo_list_and_clock/models/task.dart';
import 'package:todo_list_and_clock/models/pomodoro.dart';
import 'package:todo_list_and_clock/models/category.dart';

/// 任务和番茄钟数据操作接口
abstract class IDataOperation {
  /// 创建任务
  Future<int> createTask(Database db, Task task);

  /// 读取所有任务
  Future<List<Task>> readAllTasks(Database db);

  /// 更新任务
  Future<int> updateTask(Database db, Task task);

  /// 删除任务
  Future<int> deleteTask(Database db, int id);

  /// 创建番茄钟
  Future<int> createPomodoro(Database db, Pomodoro pomodoro);

  /// 读取所有番茄钟
  Future<List<Pomodoro>> readAllPomodoros(Database db);

  /// 根据任务ID读取番茄钟
  Future<List<Pomodoro>> readPomodorosByTaskId(Database db, int taskId);

  /// 更新番茄钟
  Future<int> updatePomodoro(Database db, Pomodoro pomodoro);

  /// 删除番茄钟
  Future<int> deletePomodoro(Database db, int id);
  
  /// 创建分类
  Future<int> createCategory(Database db, Category category);

  /// 读取所有分类
  Future<List<Category>> readAllCategories(Database db);

  /// 更新分类
  Future<int> updateCategory(Database db, Category category);

  /// 删除分类
  Future<int> deleteCategory(Database db, int id);
}