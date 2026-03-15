import 'package:flutter/foundation.dart';
import '../models/task.dart';
import '../models/category.dart' as my_category;
import '../utils/database_helper.dart';

class TodoProvider with ChangeNotifier {
  List<Task> _tasks = [];
  List<my_category.Category> _categories = [];

  List<Task> get tasks => _tasks;
  List<my_category.Category> get categories => _categories;

  Future<void> loadTasks() async {
    final dbHelper = DatabaseHelper.instance;
    final loadedTasks = await dbHelper.readAllTasks();
    _tasks = loadedTasks;
    notifyListeners();
  }

  Future<void> initializeDefaultCategories() async {
    final dbHelper = DatabaseHelper.instance;
    final categories = await dbHelper.readAllCategories();

    // 如果还没有分类，则添加默认分类
    if (categories.isEmpty) {
      await dbHelper.createCategory(
        my_category.Category(name: "语文", icon: "book"),
      );
      await dbHelper.createCategory(
        my_category.Category(name: "数学", icon: "calculate"),
      );
      await dbHelper.createCategory(
        my_category.Category(name: "英语", icon: "language"),
      );
      await loadCategories(); // 重新加载分类
    }
  }

  Future<void> loadCategories() async {
    final dbHelper = DatabaseHelper.instance;
    final loadedCategories = await dbHelper.readAllCategories();
    _categories = loadedCategories;
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

  Future<void> addCategory(my_category.Category category) async {
    final dbHelper = DatabaseHelper.instance;
    await dbHelper.createCategory(category);
    await loadCategories(); // 重新加载分类列表
  }

  Future<void> updateCategory(my_category.Category category) async {
    final dbHelper = DatabaseHelper.instance;
    await dbHelper.updateCategory(category);
    await loadCategories(); // 重新加载分类列表
  }

  Future<void> deleteCategory(int id) async {
    final dbHelper = DatabaseHelper.instance;
    await dbHelper.deleteCategory(id);
    await loadCategories(); // 重新加载分类列表
  }
}
