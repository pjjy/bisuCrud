import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class CheckData {
  static final CheckData _instance = CheckData._();
  Database? _database;

  CheckData._();

  factory CheckData() {
    return _instance;
  }

  Future<Database> get db async {
    if (_database != null) {
      return _database!;
    }

    _database = await init();

    return _database!;
  }

  Future<Database> init() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String dbPath = join(directory.path, 'check_data.db');
    var database = openDatabase(dbPath,
        version: 1,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade, onConfigure: (Database db) async {
      await db.execute('PRAGMA cache_size = 10097152;');
    });

    return database;
  }

  void _onCreate(Database db, int version) {
    db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT
        )''');

    print("Database was created!");
  }

  void _onUpgrade(Database db, int oldVersion, int newVersion) {
    // Run migration according database versions
  }

  Future<int> addUser(name) async {
    var client = await db;
    return client.insert('users', {'name': name});
  }

  Future<List> fetchUsers() async {
    var client = await db;
    return await client.rawQuery('SELECT * FROM users');
  }

  Future<int> updateUser(id, name) async {
    var client = await db;
    return client
        .rawUpdate('UPDATE users SET name = ? WHERE id = ?', [name, id]);
  }

  Future deleteUser(id) async {
    var client = await db;
    client.rawQuery('DELETE FROM users WHERE id = ?', [id]);
  }

  Future<int> addTrans(customerid, customerName, agentid, routeplaId, longitude,
      latitude, date) async {
    var client = await db;
    return client.insert('check_in_out_details', {
      'customer_id': customerid,
      'customer_name': customerName,
      'agent_id': agentid,
      'route_plan_id': routeplaId,
      'checkin_lat': latitude,
      'checkin_long': longitude,
      'checkin_date_time': date,
      'status': "Pending"
    });
  }

  Future<int> addAttachments(routeplaId, attachment) async {
    var client = await db;
    return client.insert(
        'attachments', {'route_plan_id': routeplaId, 'image': attachment});
  }

  Future<int> addRoutePlanTasks(routeplanId, taskId, amount) async {
    var client = await db;
    return client.insert('route_plan_tasks', {
      'route_id': routeplanId,
      'task_id': taskId,
      'remarks': "",
      'amount': amount
    });
  }

  Future<int> updateTrans(routeplaId, longitude, latitude, date, note) async {
    var client = await db;
    return client.rawUpdate(
        'UPDATE check_in_out_details SET checkout_long = ?, checkout_lat = ? , checkout_date_time = ?, status = ?, remarks = ? WHERE route_plan_id = ?',
        [longitude, latitude, date, "checked-out", note, routeplaId]);
  }

  Future routePlanTasks_1(routeplanId, taskId, taskName) async {
    var client = await db;
    return client.insert('route_plan_tasks_1',
        {'route_id': routeplanId, 'task_id': taskId, 'task_name': taskName});
  }

  Future<List> fetchTransactionHistory() async {
    var client = await db;
    return await client.query(
        'check_in_out_details WHERE checkout_date_time != "" ORDER BY id DESC');
  }

  Future<List> fetchrouteplantasks() async {
    var client = await db;
    return await client.query('route_plan_tasks  ORDER BY id DESC');
  }

  Future<List> loadRoutePLans(routePlanId) async {
    var client = await db;
    return await client.rawQuery(
        'SELECT * FROM route_plan_tasks_1 WHERE route_id = ? ', [routePlanId]);
  }

  Future<List> loadAttachments() async {
    var client = await db;
    return await client.rawQuery('SELECT * FROM attachments');
  }

  Future checkIFExist(routePlanId) async {
    var client = await db;
    //return client.query('tbl_oftransactions', where: 'status = ? and location = ?'  ,whereArgs: ['1',location] );
    var q = await client.rawQuery(
        'SELECT route_plan_id , status FROM check_in_out_details WHERE route_plan_id = ? AND status = ? ',
        [routePlanId, "checked-out"]);
    if (q.isNotEmpty) {
      return true;
    } else {
      return false;
    }
  }

  Future checkIFalreadyCheckin(routeId) async {
    var client = await db;

    var q = await client.rawQuery(
        'SELECT * FROM ifhascheckin WHERE route_id != ? AND checkinorout = ?',
        [routeId, 1]);
    print(q);
    if (q.isNotEmpty) {
      return true;
    } else {
      return false;
    }
  }

  Future addStatus() async {
    var client = await db;
    var q = await client.rawQuery('SELECT * FROM check_in_out_details');
    // print("paul");
    // print(q[0]["status"]);
    return q;
  }

  Future checkIfExistinroutePlanTasks_1(routePlanId) async {
    var client = await db;
    //return client.query('tbl_oftransactions', where: 'status = ? and location = ?'  ,whereArgs: ['1',location] );
    var q = await client.rawQuery(
        'SELECT DISTINCT  route_id FROM route_plan_tasks_1 WHERE route_id = ?',
        [routePlanId]);
    if (q.isNotEmpty) {
      return true;
    } else {
      return false;
    }
  }

  Future checkrouteplan(routeplanId) async {
    var client = await db;
    var q = await client.rawQuery(
        'SELECT route_plan_id FROM check_in_out_details WHERE route_plan_id = ?',
        [routeplanId]);
    if (q.isNotEmpty) {
      return true;
    } else {
      return false;
    }
  }

  Future emptyHistoryTbl(routeplanId) async {
    var client = await db;
    client.rawQuery('DELETE FROM check_in_out_details WHERE route_plan_id = ?',
        [routeplanId]);
  }

  Future emptyAttachment(routeplanId) async {
    var client = await db;
    client.rawQuery(
        'DELETE  FROM attachments WHERE route_plan_id = ?', [routeplanId]);
  }

  Future checkinorout(routeplanId) async {
    var client = await db;
    return client
        .insert('ifhascheckin', {'route_id': routeplanId, 'checkinorout': 1});
  }

  Future deleteifcheckin(routeplanId) async {
    var client = await db;
    client
        .rawQuery('DELETE FROM ifhascheckin WHERE route_id = ?', [routeplanId]);
  }
}
