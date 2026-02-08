import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:todo_list_and_clock/models/task.dart';
import 'package:todo_list_and_clock/models/pomodoro.dart';

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
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      // 将全局 databaseFactory 切换为 FFI 实现
      databaseFactory = databaseFactoryFfi;
    }
    final dbPath = await getDatabasesPath();

    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const boolType = 'BOOLEAN NOT NULL';
    const textType = 'TEXT NOT NULL';
    const intType = 'INTEGER NOT NULL';

    await db.execute('''
      CREATE TABLE tasks (
        id $idType,
        isImportant $boolType,
        title $textType,
        isCompleted $boolType,
        time $textType,
        repeat $textType
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
        createdAt $textType
      )
    ''');
  }

  Future<int> createTask(Task task) async {
    final db = await instance.database;
    return await db.insert('tasks', task.toMap());
  }

  Future<List<Task>> readAllTasks() async {
    final db = await instance.database;
    final result = await db.query('tasks');

    return result.map((json) => Task.fromMap(json)).toList();
  }

  Future<int> updateTask(Task task) async {
    final db = await instance.database;

    return db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  Future<int> deleteTask(int id) async {
    final db = await instance.database;

    return await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  // Pomodoro 相关操作
  Future<int> createPomodoro(Pomodoro pomodoro) async {
    final db = await instance.database;
    return await db.insert('pomodoros', pomodoro.toMap());
  }

  Future<List<Pomodoro>> readAllPomodoros() async {
    final db = await instance.database;
    final result = await db.query('pomodoros', orderBy: 'createdAt DESC');

    return result.map((json) => Pomodoro.fromMap(json)).toList();
  }

  Future<List<Pomodoro>> readPomodorosByTaskId(int taskId) async {
    final db = await instance.database;
    final result = await db.query(
      'pomodoros',
      where: 'taskId = ?',
      whereArgs: [taskId],
      orderBy: 'createdAt DESC',
    );

    return result.map((json) => Pomodoro.fromMap(json)).toList();
  }

  Future<int> updatePomodoro(Pomodoro pomodoro) async {
    final db = await instance.database;

    return db.update(
      'pomodoros',
      pomodoro.toMap(),
      where: 'id = ?',
      whereArgs: [pomodoro.id],
    );
  }

  Future<int> deletePomodoro(int id) async {
    final db = await instance.database;

    return await db.delete('pomodoros', where: 'id = ?', whereArgs: [id]);
  }

  Future close() async {
    final db = await instance.database;

    db.close();
  }
}
