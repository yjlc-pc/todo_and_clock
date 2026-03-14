import '../models/task.dart';
import '../models/category.dart' as app_models;
import '../services/data_services.dart';
import 'base_view_model.dart';

/// 任务 ViewModel
/// 负责任务的业务逻辑和状态管理
class TaskViewModel extends BaseViewModel {
  final TaskDataService _taskDataService = TaskDataService();
  final CategoryDataService _categoryDataService = CategoryDataService();

  List<Task> _tasks = [];
  List<app_models.Category> _categories = [];
  int? _selectedCategoryId;

  List<Task> get tasks => _tasks;
  List<app_models.Category> get categories => _categories;
  int? get selectedCategoryId => _selectedCategoryId;

  /// 获取过滤后的任务列表
  List<Task> get filteredTasks {
    if (_selectedCategoryId == null) return _tasks;
    return _tasks.where((task) => task.categoryId == _selectedCategoryId).toList();
  }

  @override
  Future<void> initialize() async {
    await loadTasks();
    await loadCategories();
  }

  /// 加载所有任务
  Future<void> loadTasks() async {
    try {
      setLoading(true);
      _tasks = await _taskDataService.getAllTasks();
      setLoading(false);
    } catch (e) {
      setError('加载任务失败：$e');
      setLoading(false);
    }
  }

  /// 加载所有分类
  Future<void> loadCategories() async {
    try {
      _categories = await _categoryDataService.getAllCategories();
      notifyListeners();
    } catch (e) {
      setError('加载分类失败：$e');
    }
  }

  /// 添加任务
  Future<bool> addTask(Task task) async {
    try {
      final id = await _taskDataService.insertTask(task);
      if (id > 0) {
        task.id = id;
        _tasks.insert(0, task);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      setError('添加任务失败：$e');
      return false;
    }
  }

  /// 更新任务
  Future<bool> updateTask(Task task) async {
    try {
      final result = await _taskDataService.updateTask(task);
      if (result > 0) {
        final index = _tasks.indexWhere((t) => t.id == task.id);
        if (index >= 0) {
          _tasks[index] = task;
          notifyListeners();
        }
        return true;
      }
      return false;
    } catch (e) {
      setError('更新任务失败：$e');
      return false;
    }
  }

  /// 删除任务
  Future<bool> deleteTask(int taskId) async {
    try {
      final result = await _taskDataService.deleteTask(taskId);
      if (result > 0) {
        _tasks.removeWhere((task) => task.id == taskId);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      setError('删除任务失败：$e');
      return false;
    }
  }

  /// 切换任务完成状态
  Future<bool> toggleTaskCompletion(Task task) async {
    final updatedTask = task.copyWith(isCompleted: !task.isCompleted);
    return await updateTask(updatedTask);
  }

  /// 选择分类
  void selectCategory(int? categoryId) {
    _selectedCategoryId = categoryId;
    notifyListeners();
  }

  /// 添加分类
  Future<bool> addCategory(app_models.Category category) async {
    try {
      final id = await _categoryDataService.insertCategory(category);
      if (id > 0) {
        category.id = id;
        _categories.add(category);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      setError('添加分类失败：$e');
      return false;
    }
  }

  /// 删除分类
  Future<bool> deleteCategory(int categoryId) async {
    try {
      final result = await _categoryDataService.deleteCategory(categoryId);
      if (result > 0) {
        _categories.removeWhere((cat) => cat.id == categoryId);
        _tasks.removeWhere((task) => task.categoryId == categoryId);
        if (_selectedCategoryId == categoryId) {
          _selectedCategoryId = null;
        }
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      setError('删除分类失败：$e');
      return false;
    }
  }

  /// 初始化默认分类
  Future<void> initializeDefaultCategories() async {
    // 如果已有分类，则不初始化
    if (_categories.isNotEmpty) return;

    final defaultCategories = [
      app_models.Category(name: '工作', color: 0xFF2196F3, icon: 'work'),
      app_models.Category(name: '学习', color: 0xFF4CAF50, icon: 'school'),
      app_models.Category(name: '生活', color: 0xFFFF9800, icon: 'home'),
    ];

    for (final category in defaultCategories) {
      await addCategory(category);
    }
  }
}
