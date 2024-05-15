import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static late Database _database;

  static Future<void> initDatabase(String dbName, List<String> tableSQLs) async {
    String path = await getDatabasesPath();
    print(path);
    _database = await openDatabase(
      join(path, dbName),
      onCreate: (db, version) async {
        Batch batch = db.batch();
        for (String sql in tableSQLs) {
          batch.execute(sql);
        }
        await batch.commit();
      },
      version: 1,
    );
  }

  // 删除数据库文件
  static Future<void> deleteDatabase(String dbName) async {
    String path = await getDatabasesPath();
    String dbPath = join(path, dbName);

    await deleteDatabase(dbPath);
  }

  // 查询
  static Future<List<Map<String, dynamic>>> getData(String tbl, List<List<dynamic>> where) async {
    final db = _database;

    // 构建 WHERE 子句
    String whereClause = '';
    List<dynamic> whereArgs = [];

    for (var item in where) {
      if (whereClause.isNotEmpty) {
        whereClause += ' AND ';
      }
      whereClause += '${item[0]} ${item[1]} ?';
      whereArgs.add(item[2]);
    }
    if (whereArgs.isNotEmpty) {
      return db.query(tbl, where: whereClause, whereArgs: whereArgs);
    } else {
      return db.query(tbl);
    }
  }

  // 查询
  static Future<Map<String, dynamic>?> getOne(String tbl, List<List<dynamic>> where) async {
    final db = _database;

    // 构建 WHERE 子句
    String whereClause = '';
    List<dynamic> whereArgs = [];

    for (var item in where) {
      if (whereClause.isNotEmpty) {
        whereClause += ' AND ';
      }
      whereClause += '${item[0]} ${item[1]} ?';
      whereArgs.add(item[2]);
    }
    // 直接赋值给结果变量
    List<Map<String, Object?>> result =
        whereArgs.isNotEmpty ? await db.query(tbl, where: whereClause, whereArgs: whereArgs) : await db.query(tbl);
    // 返回结果是否为空
    return result.isNotEmpty ? result.first : null;
  }

  // 新增
  static Future<void> insertData(String tbl, Map<String, dynamic> data) async {
    final db = _database;
    await db.insert(
      tbl,
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // 更新
  static Future<void> updateData(String tbl, Map<String, dynamic> data, List<List<dynamic>> where) async {
    final db = _database;

    // 构建 WHERE 子句
    String whereClause = '';
    List<dynamic> whereArgs = [];

    for (var item in where) {
      if (whereClause.isNotEmpty) {
        whereClause += ' AND ';
      }
      whereClause += '${item[0]} ${item[1]} ?';
      whereArgs.add(item[2]);
    }

    // 执行更新操作
    await db.update(
      tbl,
      data,
      where: whereClause,
      whereArgs: whereArgs,
    );
  }

  // 新增|更新
  static Future<void> upsertData(String tbl, Map<String, dynamic> data, List<List<dynamic>> where) async {
    final db = _database;

    // 构建 WHERE 子句和参数
    String whereClause = '';
    List<dynamic> whereArgs = [];

    for (var item in where) {
      if (whereClause.isNotEmpty) {
        whereClause += ' AND ';
      }
      whereClause += '${item[0]} ${item[1]} ?';
      whereArgs.add(item[2]);
    }

    try {
      // 使用事务保证操作的原子性
      await db.transaction((txn) async {
        // 查询数据库，检查是否存在符合条件的记录
        List<Map<String, dynamic>> existingRecords = await txn.query(
          tbl,
          where: whereClause,
          whereArgs: whereArgs,
        );

        // 如果存在符合条件的记录，则更新记录
        if (existingRecords.isNotEmpty) {
          await txn.update(
            tbl,
            data,
            where: whereClause,
            whereArgs: whereArgs,
          );
        }
        // 否则，新增记录
        else {
          await txn.insert(
            tbl,
            data,
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      });
    } catch (e) {
      // 处理异常情况
      print('Error in upsertData: $e');
      // 可以选择抛出异常或者进行其他处理
    }
  }

  // 删除
  static Future<void> deleteData(String tbl, List<List<dynamic>> where) async {
    final db = _database;

    // 构建 WHERE 子句
    String whereClause = '';
    List<dynamic> whereArgs = [];

    for (var item in where) {
      if (whereClause.isNotEmpty) {
        whereClause += ' AND ';
      }
      whereClause += '${item[0]} ${item[1]} ?';
      whereArgs.add(item[2]);
    }

    await db.delete(
      tbl,
      where: whereClause,
      whereArgs: whereArgs,
    );
  }
}
