import 'package:path/path.dart';
import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// 数据库服务
/// 负责数据库的初始化、连接和基本操作
class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Database? _database;

  /// 获取数据库实例
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// 初始化数据库
  Future<Database> _initDatabase() async {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'todo_clock.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  /// 创建数据库表
  Future<void> _onCreate(Database db, int version) async {
    // 任务表
    await db.execute('''
      CREATE TABLE tasks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        isCompleted INTEGER DEFAULT 0,
        categoryId INTEGER,
        dueDate TEXT,
        priority INTEGER DEFAULT 0,
        repeatType INTEGER DEFAULT 0,
        repeatInterval INTEGER,
        createdAt TEXT NOT NULL,
        updatedAt TEXT
      )
    ''');

    // 分类表
    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        color INTEGER,
        icon TEXT,
        createdAt TEXT NOT NULL
      )
    ''');

    // 番茄钟记录表
    await db.execute('''
      CREATE TABLE pomodoros (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        taskId INTEGER,
        title TEXT NOT NULL,
        startTime TEXT NOT NULL,
        endTime TEXT,
        duration INTEGER DEFAULT 0,
        isCompleted INTEGER DEFAULT 0,
        isRest INTEGER DEFAULT 0,
        earlyExit INTEGER DEFAULT 0,
        createdAt TEXT NOT NULL
      )
    ''');

    // 插入默认分类
    await db.insert('categories', {
      'name': '工作',
      'color': 0xFF2196F3,
      'icon': 'work',
      'createdAt': DateTime.now().toIso8601String(),
    });

    await db.insert('categories', {
      'name': '学习',
      'color': 0xFF4CAF50,
      'icon': 'school',
      'createdAt': DateTime.now().toIso8601String(),
    });

    await db.insert('categories', {
      'name': '生活',
      'color': 0xFFFF9800,
      'icon': 'home',
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  /// 关闭数据库
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
