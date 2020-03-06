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
    idUser TEXT,
    code TEXT, 
    name TEXT,
    credit TEXT NULL,
    route TEXT NULL)
  ''';

  String sqlCreateOrder = '''
  create table if not exists orders(
    id INTEGER PRIMARY KEY AUTOINCREMENT, 
    productID TEXT,
    code TEXT, 
    name TEXT, 
    pic TEXT, 
    unit TEXT, 
    unitStatus INTEGER, 
    unit1 TEXT, 
    unitQty1 INTEGER NULL,
    unit2 TEXT NULL, 
    unitQty2 INTEGER NULL,
    unit3 TEXT NULL, 
    unitQty3 INTEGER NULL,
    priceA FLOAT NULL, 
    priceB FLOAT NULL, 
    priceC FLOAT NULL, 
    amount INTEGER, 
    proStatus INTEGER,
    proLimit INTEGER)
  ''';

  String sqlCreateOrderFree = '''
  create table if not exists ordersfree(
    id INTEGER PRIMARY KEY AUTOINCREMENT, 
    productID TEXT,
    code TEXT, 
    name TEXT, 
    pic TEXT, 
    unitStatus INTEGER, 
    unit1 TEXT, 
    freePrice INTEGER, 
    freePriceSum INTEGER, 
    amount INTEGER)
  ''';

  String sqlCreateShipAndPay = '''
  create table if not exists shipandpay(
    id INTEGER PRIMARY KEY AUTOINCREMENT, 
    codeuser TEXT, 
    ship INTEGER,
    pay INTEGER)
  ''';

  String sqlCreateOrderTemps = '''
  create table if not exists orderTemps(
    id INTEGER PRIMARY KEY AUTOINCREMENT, 
    code TEXT, 
    status INTEGER,
    cusCode TEXT)
  ''';

  String sqlDropTableOrder = '''
  DROP TABLE orders
  ''';

  String sqlDropTableMembers = '''
  DROP TABLE members
  ''';

  String sqlDropTableOrderFree = '''
  DROP TABLE ordersfree
  ''';

  String sqlDropTableShipAndPay = '''
  DROP TABLE shipandpay
  ''';

  String sqlDropTableOrderTemps = '''
  DROP TABLE orderTemps
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

  Future<Database> getDbOrderFree() async {
    if (_db == null) {
      io.Directory documentDirectory = await getApplicationDocumentsDirectory();

      String path = join(documentDirectory.path, 'ordersfree.db');

      print(path);

      await _lock.synchronized(() async {
        if (_db == null) {
          _db = await openDatabase(path, version: 1);
        }
      });
    }

    return _db;
  }

  Future<Database> getDbShipAndPay() async {
    if (_db == null) {
      io.Directory documentDirectory = await getApplicationDocumentsDirectory();

      String path = join(documentDirectory.path, 'shipandpay.db');

      print(path);

      await _lock.synchronized(() async {
        if (_db == null) {
          _db = await openDatabase(path, version: 1);
        }
      });
    }

    return _db;
  }

  Future<Database> getDbOrderTemps() async {
    if (_db == null) {
      io.Directory documentDirectory = await getApplicationDocumentsDirectory();

      String path = join(documentDirectory.path, 'orderTemps.db');

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

  Future initDatabaseOrderFree() async {
    var dbClient = await getDbOrderFree();
    // Create table
    await dbClient.rawQuery(sqlCreateOrderFree);
    print('Table OrderFree is created');
  }

  Future initDatabaseShipAndPay() async {
    var dbClient = await getDbShipAndPay();
    // Create table
    await dbClient.rawQuery(sqlCreateShipAndPay);
    print('Table ShipAndPay is created');
  }

  Future initDatabaseOrderTemps() async {
    var dbClient = await getDbOrderTemps();
    // Create table
    await dbClient.rawQuery(sqlCreateOrderTemps);
    print('Table OrderTemps is created');
  }

  Future dropTableOrder() async {
    var dbClient = await getDbOrder();
    // Create table
    await dbClient.rawQuery(sqlDropTableOrder);
    print('dropTableOrder');
  }

  Future dropTableOrderFree() async {
    var dbClient = await getDbOrderFree();
    // Create table
    await dbClient.rawQuery(sqlDropTableOrderFree);
    print('dropTableOrderFree');
  }

  Future dropTableMembers() async {
    var dbClient = await getDb();
    // Create table
    await dbClient.rawQuery(sqlDropTableMembers);
    print('dropTableMembers');
  }

  Future dropTableShipAndPay() async {
    var dbClient = await getDbShipAndPay();
    // Create table
    await dbClient.rawQuery(sqlDropTableShipAndPay);
    print('dropTableShipAndPay');
  }

  Future dropTableOrderTemps() async {
    var dbClient = await getDbOrderTemps();
    // Create table
    await dbClient.rawQuery(sqlDropTableOrderTemps);
    print('dropTableOrderTemps');
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

  Future getOrderFree() async {
    var dbClient = await getDbOrderFree();
    var sql = '''
      SELECT * FROM ordersfree ORDER BY code ASC
    ''';
    return await dbClient.rawQuery(sql);
  }

  Future getSumOrderFree() async {
    var dbClient = await getDbOrderFree();
    var sql = '''
      SELECT SUM(freePriceSum) AS freePriceSumAll FROM ordersfree 
    ''';
    return await dbClient.rawQuery(sql);
  }

  Future getShipAndPay() async {
    var dbClient = await getDbShipAndPay();
    var sql = '''
      SELECT * FROM shipandpay
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

  Future removeOrderFree(int id) async {
    var dbClient = await getDbOrderFree();
    var sql = '''
      DELETE FROM ordersfree WHERE id=?
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

  Future removeAllOrderFree() async {
    var dbClient = await getDbOrderFree();
    var sql = '''
      DELETE FROM ordersfree
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

  Future removeAllOrderTemps() async {
    var dbClient = await getDbOrderTemps();
    var sql = '''
      DELETE FROM orderTemps
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

  Future getOrderFreeCheck(code) async {
    var dbClient = await getDbOrderFree();
    var sql = '''
      SELECT * FROM ordersfree WHERE code=?
    ''';
    return await dbClient.rawQuery(sql, [code]);
  }

  Future getMemberCheck(code) async {
    var dbClient = await getDb();
    var sql = '''
      SELECT * FROM members WHERE code=? 
    ''';
    return await dbClient.rawQuery(sql, [code]);
  }

  Future getOrderTempsCheck(code, status) async {
    var dbClient = await getDbOrderTemps();
    var sql = '''
      SELECT * FROM orderTemps WHERE code=? AND status=? 
    ''';
    return await dbClient.rawQuery(sql, [code, status]);
  }

  Future getOrderTempsCheckCode(code) async {
    var dbClient = await getDbOrderTemps();
    var sql = '''
      SELECT * FROM orderTemps WHERE code=? 
    ''';
    return await dbClient.rawQuery(sql, [code]);
  }

  Future getOrderTempsCheckCount() async {
    var dbClient = await getDbOrderTemps();
    var sql = '''
      SELECT COUNT(id) AS checkID FROM orderTemps 
    ''';
    return await dbClient.rawQuery(sql);
  }

  Future getMemberCheckCount() async {
    var dbClient = await getDb();
    var sql = '''
      SELECT COUNT(id) AS checkID FROM members 
    ''';
    return await dbClient.rawQuery(sql);
  }

  Future saveData(Map member) async {
    var dbClient = await getDb();

    String sql = '''
    INSERT INTO members(idUser, code, name, credit, route)
    VALUES(?, ?, ?, ?, ?)
    ''';

    await dbClient.rawQuery(sql, [
      member['idUser'],
      member['code'],
      member['name'],
      member['credit'],
      member['route'],
    ]);

    print('Saved!');
  }

  Future saveOrder(Map order) async {
    var dbClient = await getDbOrder();

    String sql = '''
    INSERT INTO orders(productID, code, name, pic, unit, unitStatus, unit1, unitQty1, unit2, unitQty2, unit3, unitQty3, priceA, priceB, priceC, amount, proStatus, proLimit)
    VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    ''';

    await dbClient.rawQuery(sql, [
      order['productID'],
      order['code'],
      order['name'],
      order['pic'],
      order['unit'],
      order['unitStatus'],
      order['unit1'],
      order['unitQty1'],
      order['unit2'],
      order['unitQty2'],
      order['unit3'],
      order['unitQty3'],
      order['priceA'],
      order['priceB'],
      order['priceC'],
      order['amount'],
      order['proStatus'],
      order['proLimit'],
    ]);

    print('Saved Order!');
  }

  Future saveOrderFree(Map order) async {
    var dbClient = await getDbOrderFree();

    String sql = '''
    INSERT INTO ordersfree(productID, code, name, pic, unitStatus, unit1, freePrice, freePriceSum, amount)
    VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?)
    ''';

    await dbClient.rawQuery(sql, [
      order['productID'],
      order['code'],
      order['name'],
      order['pic'],
      order['unitStatus'],
      order['unit1'],
      order['freePrice'],
      order['freePriceSum'],
      order['amount'],
    ]);

    print('Saved OrderFree!');
  }

  Future saveShipAndPay(Map statusShipAndPay) async {
    var dbClient = await getDbShipAndPay();

    String sql = '''
    INSERT INTO shipandpay(codeuser, ship, pay)
    VALUES(?, ?, ?)
    ''';

    await dbClient.rawQuery(sql, [
      statusShipAndPay['codeuser'],
      statusShipAndPay['ship'],
      statusShipAndPay['pay'],
    ]);

    print('Saved ShipAndPay!');
  }

  Future saveOrderTemps(Map statusOrderTemps) async {
    var dbClient = await getDbOrderTemps();

    String sql = '''
    INSERT INTO orderTemps(code, status, cusCode)
    VALUES(?, ?, ?)
    ''';

    await dbClient.rawQuery(sql, [
      statusOrderTemps['code'],
      statusOrderTemps['status'],
      statusOrderTemps['cusCode'],
    ]);

    print('Saved OrderTemps!');
  }

  Future updateData(Map member) async {
    var dbClient = await getDb();

    String sql = '''
    UPDATE members SET idUser=?, code=?, name=?
    WHERE id=?
    ''';

    await dbClient.rawQuery(sql, [
      member['idUser'],
      member['code'],
      member['name'],
      member['id'],
    ]);

    print('Updated!');
  }

  Future updateDataCreditAndRoute(Map member) async {
    var dbClient = await getDb();

    String sql = '''
    UPDATE members SET credit=?, route=? 
    WHERE idUser=?
    ''';

    await dbClient.rawQuery(sql, [
      member['credit'],
      member['route'],
      member['idUser'],
    ]);

    print('Updated! Credit');
  }


  Future updateOrderTemps(Map statusOrderTemps) async {
    var dbClient = await getDbOrderTemps();

    String sql = '''
    UPDATE orderTemps SET status=?
    WHERE code=?
    ''';

    await dbClient.rawQuery(sql, [
      statusOrderTemps['status'],
      statusOrderTemps['code'],
    ]);

    print('Updated! StatusOrderTemps');
  }

  Future updateOrder(Map order) async {
    var dbClient = await getDbOrder();

    String sql = '''
    UPDATE orders SET unit=?, unitStatus=?, amount=?
    WHERE id=?
    ''';

    await dbClient.rawQuery(sql, [
      order['unit'],
      order['unitStatus'],
      order['amount'],
      order['id'],
    ]);

    print('Updated!');
  }

  Future updateOrderFree(Map order) async {
    var dbClient = await getDbOrderFree();

    String sql = '''
    UPDATE ordersfree SET freePriceSum=?, amount=?
    WHERE id=?
    ''';

    await dbClient.rawQuery(sql, [
      order['freePriceSum'],
      order['amount'],
      order['id'],
    ]);

    print('Updated!');
  }

  Future updateShip(Map statusShip) async {
    var dbClient = await getDbShipAndPay();

    String sql = '''
    UPDATE shipandpay SET codeuser=?, ship=?
    WHERE id=?
    ''';

    await dbClient.rawQuery(sql, [
      statusShip['codeuser'],
      statusShip['ship'],
      statusShip['id'],
    ]);

    print('Updated!');
  }

  Future updatePay(Map statusPay) async {
    var dbClient = await getDbShipAndPay();

    String sql = '''
    UPDATE shipandpay SET codeuser=?, pay=?
    WHERE id=?
    ''';

    await dbClient.rawQuery(sql, [
      statusPay['codeuser'],
      statusPay['pay'],
      statusPay['id'],
    ]);

    print('Updated!');
  }

}