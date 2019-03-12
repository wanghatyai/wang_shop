import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'dart:io' as io;
import 'package:synchronized/synchronized.dart';

class DatabaseHelper {
  static Database _db;

  DatabaseHelper.internal();

  final _lock = new Lock();

  String sqlCreate = '''
  create table if not exists members(
    id INTEGER PRIMARY KEY AUTOINCREMENT, 
    code TEXT, 
    name TEXT)
  ''';

  String sqlCreateOrder = '''
  create table if not exists orders(
    id INTEGER PRIMARY KEY AUTOINCREMENT, 
    code TEXT, 
    unit TEXT, 
    amount INTEGER)
  ''';

  Future<Database> getDb() async {
    if (_db == null) {
      io.Directory documentDirectory = await getApplicationDocumentsDirectory();

      String path = join(documentDirectory.path, 'members.db');

      print(path);

      await _lock.synchronized(() async {
        if (_db == null) {
          _db = await openDatabase(path, version: 1);
        }
      });
    }

    return _db;
  }

  Future<Database> getDbOrder() async {
    if (_db == null) {
      io.Directory documentDirectory = await getApplicationDocumentsDirectory();

      String path = join(documentDirectory.path, 'orders.db');

      print(path);

      await _lock.synchronized(() async {
        if (_db == null) {
          _db = await openDatabase(path, version: 1);
        }
      });
    }

    return _db;
  }

  Future initDatabase() async {
    var dbClient = await getDb();
    // Create table
    await dbClient.rawQuery(sqlCreate);
    print('Table is created');
  }

  Future initDatabaseOrder() async {
    var dbClient = await getDbOrder();
    // Create table
    await dbClient.rawQuery(sqlCreateOrder);
    print('Table Order is created');
  }

  Future getList() async {
    var dbClient = await getDb();
    var sql = '''
      SELECT * FROM members
    ''';
    return await dbClient.rawQuery(sql);
  }

  Future getOrder() async {
    var dbClient = await getDbOrder();
    var sql = '''
      SELECT * FROM orders
    ''';
    return await dbClient.rawQuery(sql);
  }

  Future remove(int id) async {
    var dbClient = await getDb();
    var sql = '''
      DELETE FROM members WHERE id=?
    ''';
    return await dbClient.rawQuery(sql, [id]);
  }

  Future removeAll() async {
    var dbClient = await getDbOrder();
    var sql = '''
      DELETE FROM orders
    ''';
    return await dbClient.rawQuery(sql);
  }

  Future getDetail(int id) async {
    var dbClient = await getDb();
    var sql = '''
      SELECT * FROM members WHERE id=?
    ''';
    return await dbClient.rawQuery(sql, [id]);
  }

  Future saveData(Map member) async {
    var dbClient = await getDb();

    String sql = '''
    INSERT INTO members(code, name)
    VALUES(?, ?)
    ''';

    await dbClient.rawQuery(sql, [
      member['code'],
      member['name'],
    ]);

    print('Saved!');
  }

  Future saveOrder(Map order) async {
    var dbClient = await getDbOrder();

    String sql = '''
    INSERT INTO orders(code, unit, amount)
    VALUES(?, ?, ?)
    ''';

    await dbClient.rawQuery(sql, [
      order['code'],
      order['unit'],
      order['amount'],
    ]);

    print('Saved Order!');
  }

  Future updateData(Map member) async {
    var dbClient = await getDb();

    String sql = '''
    UPDATE members SET code=?, name=?
    WHERE id=?
    ''';

    await dbClient.rawQuery(sql, [
      member['code'],
      member['name'],
      member['id'],
    ]);

    print('Updated!');
  }
}