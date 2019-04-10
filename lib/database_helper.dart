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
    name TEXT, 
    pic TEXT, 
    unit TEXT, 
    unit1 TEXT , 
    unit2 TEXT NULL , 
    unit3 TEXT NULL , 
    amount INTEGER)
  ''';

  String sqlDropTableOrder = '''
  DROP TABLE orders
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

  Future dropTableOrder() async {
    var dbClient = await getDbOrder();
    // Create table
    await dbClient.rawQuery(sqlDropTableOrder);
    print('dropTableOrder');
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
      SELECT * FROM orders ORDER BY code ASC
    ''';
    return await dbClient.rawQuery(sql);
  }

  Future countOrder() async {
    var dbClient = await getDbOrder();
    var sql = '''
      SELECT COUNT(id) AS countOrderAll FROM orders
    ''';
    return await dbClient.rawQuery(sql);
  }

  Future countMember() async {
    var dbClient = await getDb();
    var sql = '''
      SELECT COUNT(id) AS countMemberAll FROM members
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

  Future removeOrder(int id) async {
    var dbClient = await getDbOrder();
    var sql = '''
      DELETE FROM orders WHERE id=?
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

  Future removeAllMember() async {
    var dbClient = await getDb();
    var sql = '''
      DELETE FROM members
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

  Future getOrderCheck(code, unit) async {
    var dbClient = await getDbOrder();
    var sql = '''
      SELECT * FROM orders WHERE code=? AND unit=?
    ''';
    return await dbClient.rawQuery(sql, [code, unit]);
  }

  Future getMemberCheck(code) async {
    var dbClient = await getDb();
    var sql = '''
      SELECT * FROM members WHERE code=? 
    ''';
    return await dbClient.rawQuery(sql, [code]);
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
    INSERT INTO orders(code, name, pic, unit, unit1, unit2, unit3, amount)
    VALUES(?, ?, ?, ?, ?, ?, ?, ?)
    ''';

    await dbClient.rawQuery(sql, [
      order['code'],
      order['name'],
      order['pic'],
      order['unit'],
      order['unit1'],
      order['unit2'],
      order['unit3'],
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

  Future updateOrder(Map order) async {
    var dbClient = await getDbOrder();

    String sql = '''
    UPDATE orders SET unit=?, amount=?
    WHERE id=?
    ''';

    await dbClient.rawQuery(sql, [
      order['unit'],
      order['amount'],
      order['id'],
    ]);

    print('Updated!');
  }
}