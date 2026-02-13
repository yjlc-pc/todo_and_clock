import 'package:sqflite/sqflite.dart';

/// 数据库工厂接口，用于抽象数据库创建过程
abstract class IDatabaseFactory {
  /// 获取数据库实例
  Future<Database> getDatabase(String dbName);

  /// 关闭数据库连接
  Future<void> closeDatabase(String dbName);

  /// 删除数据库
  Future<void> deleteDatabase(String dbName);
}

/// 默认数据库工厂实现
class DefaultDatabaseFactory implements IDatabaseFactory {
  static final DefaultDatabaseFactory _instance = DefaultDatabaseFactory._internal();
  factory DefaultDatabaseFactory() => _instance;
  DefaultDatabaseFactory._internal();

  final Map<String, Database> _databases = {};

  @override
  Future<Database> getDatabase(String dbName) async {
    if (_databases.containsKey(dbName)) {
      return _databases[dbName]!;
    }

    // 创建新的数据库连接
    final database = await _createDatabase(dbName);
    _databases[dbName] = database;
    return database;
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
    final dbPath = '$path/$dbName';
    if (await databaseExists(dbPath)) {
      await deleteDatabase(dbPath);
    }
  }

  /// 内部方法：创建数据库
  Future<Database> _createDatabase(String dbName) async {
    final path = await getDatabasesPath();
    final dbPath = '$path/$dbName';

    return await openDatabase(
      dbPath,
      version: 1,
      onCreate: _onCreate,
    );
  }

  /// 数据库创建回调
  Future<void> _onCreate(Database db, int version) async {
    // 创建默认表
    await db.execute('''
      CREATE TABLE IF NOT EXISTS app_settings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        key TEXT UNIQUE,
        value TEXT
      )
    ''');
  }
}