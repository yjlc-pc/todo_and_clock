import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:todo_list_and_clock/models/task.dart';
import 'package:todo_list_and_clock/models/pomodoro.dart';
import 'package:todo_list_and_clock/models/category.dart';
import 'database_factory.dart';
import 'data_operation.dart';


/// 任务专用数据库工厂实现
class TaskDatabaseFactory implements IDatabaseFactory, IDataOperation {
  static final TaskDatabaseFactory _instance = TaskDatabaseFactory._internal();
  static TaskDatabaseFactory get instance => _instance;
  factory TaskDatabaseFactory() => _instance;
  TaskDatabaseFactory._internal();
  
  static bool _isInitialized = false;

  /// 初始化数据库工厂
  static void initialize() {
    if (!_isInitialized && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
      _isInitialized = true;
    }
  }

  final Map<String, Database> _databases = {};

  @override
  Future<Database> getDatabase(String dbName) async {
    if (_databases.containsKey(dbName)) {
      return _databases[dbName]!;
    }

    // 初始化数据库工厂
    initialize();

    final database = await _createTaskDatabase(dbName);
    _databases[dbName] = database;
    return database;
  }

  /// 创建任务专用数据库
  Future<Database> _createTaskDatabase(String dbName) async {
    final path = await getDatabasesPath();
    final dbPath = join(path, dbName);

    // 检查数据库是否存在，如果存在则直接打开
    if (await databaseExists(dbPath)) {
      return await openDatabase(dbPath, version: 4, onUpgrade: _onUpgrade);
    }

    // 否则创建新数据库
    return await openDatabase(
      dbPath,
      version: 4,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  /// 创建数据库表
  Future<void> _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const boolType = 'BOOLEAN NOT NULL';
    const textType = 'TEXT NOT NULL';
    const intType = 'INTEGER NOT NULL';

    await db.execute('''
      CREATE TABLE categories (
        id $idType,
        name $textType,
        icon TEXT,
        color TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE tasks (
        id $idType,
        categoryId INTEGER,
        isImportant $boolType,
        title $textType,
        isCompleted $boolType,
        time $textType,
        repeat $textType,
        FOREIGN KEY (categoryId) REFERENCES categories (id) ON DELETE SET NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE pomodoros (
        id $idType,
        taskId $intType,
        title $textType,
        startTime $textType,
        endTime $textType,
        duration $intType,
        isCompleted $boolType,
        isRest $boolType,
        earlyExit $boolType DEFAULT 0,
        createdAt $textType
      )
    ''');
  }

  /// 升级数据库
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 3 && newVersion >= 3) {
      // 版本3的更新逻辑
      // 检查earlyExit列是否存在，如果不存在则添加
      try {
        await db.rawQuery('SELECT earlyExit FROM pomodoros LIMIT 1;');
      } catch (e) {
        // 如果查询失败，说明列不存在，需要添加
        await db.execute(
          'ALTER TABLE pomodoros ADD COLUMN earlyExit BOOLEAN DEFAULT 0;',
        );
      }
    }
    
    if (oldVersion < 4 && newVersion >= 4) {
      // 版本4的更新逻辑 - 添加分类功能
      // 首先创建分类表（如果不存在）
      try {
        await db.rawQuery('SELECT name FROM categories LIMIT 1;');
      } catch (e) {
        // 如果查询失败，说明表不存在，需要创建
        await _createCategoriesTable(db);
      }
      
      // 然后添加分类ID列到任务表（如果不存在）
      try {
        await db.rawQuery('SELECT categoryId FROM tasks LIMIT 1;');
      } catch (e) {
        // 如果查询失败，说明列不存在，需要添加
        await db.execute(
          'ALTER TABLE tasks ADD COLUMN categoryId INTEGER REFERENCES categories (id) ON DELETE SET NULL;',
        );
      }
    }
  }
  
  /// 创建分类表
  Future<void> _createCategoriesTable(Database db) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    
    await db.execute('''
      CREATE TABLE categories (
        id $idType,
        name $textType,
        icon TEXT,
        color TEXT
      )
    ''');
  }

  /// 创建任务
  @override
  Future<int> createTask(Database db, Task task) async {
    return await db.insert('tasks', task.toMap());
  }

  /// 读取所有任务
  @override
  Future<List<Task>> readAllTasks(Database db) async {
    final result = await db.query('tasks');
    return result.map((json) => Task.fromMap(json)).toList();
  }

  /// 更新任务
  @override
  Future<int> updateTask(Database db, Task task) async {
    return await db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  /// 删除任务
  @override
  Future<int> deleteTask(Database db, int id) async {
    return await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  /// 创建番茄钟
  @override
  Future<int> createPomodoro(Database db, Pomodoro pomodoro) async {
    return await db.insert('pomodoros', pomodoro.toMap());
  }

  /// 读取所有番茄钟
  @override
  Future<List<Pomodoro>> readAllPomodoros(Database db) async {
    final result = await db.query('pomodoros', orderBy: 'createdAt DESC');
    return result.map((json) => Pomodoro.fromMap(json)).toList();
  }

  /// 根据任务ID读取番茄钟
  @override
  Future<List<Pomodoro>> readPomodorosByTaskId(Database db, int taskId) async {
    final result = await db.query(
      'pomodoros',
      where: 'taskId = ?',
      whereArgs: [taskId],
      orderBy: 'createdAt DESC',
    );
    return result.map((json) => Pomodoro.fromMap(json)).toList();
  }

  /// 更新番茄钟
  @override
  Future<int> updatePomodoro(Database db, Pomodoro pomodoro) async {
    return await db.update(
      'pomodoros',
      pomodoro.toMap(),
      where: 'id = ?',
      whereArgs: [pomodoro.id],
    );
  }

  /// 删除番茄钟
  @override
  Future<int> deletePomodoro(Database db, int id) async {
    return await db.delete('pomodoros', where: 'id = ?', whereArgs: [id]);
  }

  /// 创建分类
  @override
  Future<int> createCategory(Database db, Category category) async {
    return await db.insert('categories', category.toMap());
  }

  /// 读取所有分类
  @override
  Future<List<Category>> readAllCategories(Database db) async {
    final result = await db.query('categories');
    return result.map((json) => Category.fromMap(json)).toList();
  }

  /// 更新分类
  @override
  Future<int> updateCategory(Database db, Category category) async {
    return await db.update(
      'categories',
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  /// 删除分类
  @override
  Future<int> deleteCategory(Database db, int id) async {
    return await db.delete('categories', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<void> closeDatabase(String dbName) async {
    if (_databases.containsKey(dbName)) {
      await _databases[dbName]?.close();
      _databases.remove(dbName);
    }
  }

  @override
  Future<void> deleteDatabase(String dbName) async {
    if (_databases.containsKey(dbName)) {
      await _databases[dbName]?.close();
      _databases.remove(dbName);
    }

    final path = await getDatabasesPath();
    final dbPath = join(path, dbName);
    if (await databaseExists(dbPath)) {
      await deleteDatabase(dbPath);
    }
  }
}
