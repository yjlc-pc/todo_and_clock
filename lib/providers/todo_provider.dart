import 'package:flutter/foundation.dart';
import '../models/task.dart';
import '../utils/database_helper.dart';

class TodoProvider with ChangeNotifier {
  List<Task> _tasks = [];
  
  List<Task> get tasks => _tasks;
  
  Future<void> loadTasks() async {
    final dbHelper = DatabaseHelper.instance;
    final loadedTasks = await dbHelper.readAllTasks();
    _tasks = loadedTasks;
    notifyListeners();
  }
  
  Future<void> addTask(Task task) async {
    final dbHelper = DatabaseHelper.instance;
    await dbHelper.createTask(task);
    await loadTasks(); // 重新加载任务列表
  }
  
  Future<void> updateTask(Task task) async {
    final dbHelper = DatabaseHelper.instance;
    await dbHelper.updateTask(task);
    await loadTasks(); // 重新加载任务列表
  }
  
  Future<void> deleteTask(int id) async {
    final dbHelper = DatabaseHelper.instance;
    await dbHelper.deleteTask(id);
    await loadTasks(); // 重新加载任务列表
  }
}