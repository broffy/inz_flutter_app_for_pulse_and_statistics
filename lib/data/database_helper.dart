import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:flutter_myapp/models/user.dart';
import 'package:path/path.dart';
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter_myapp/models/oneShot.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = new DatabaseHelper.internal();
  factory DatabaseHelper() => _instance;

  static Database _db;

  Future<Database> get db async {
    if (_db != null) {
      return _db;
    }
    _db = await initDb();
    return _db;
  }

  DatabaseHelper.internal();

  initDb() async {
    Directory documentDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentDirectory.path, "flutter.db");

    // Only copy if the database doesn't exist
    //if (FileSystemEntity.typeSync(path) == FileSystemEntityType.notFound){
    // Load database from asset and copy
    ByteData data = await rootBundle.load(join('data', 'flutter.db'));
    List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

    // Save copied asset to documents
    await new File(path).writeAsBytes(bytes);
    //}

    var ourDb = await openDatabase(path);
    return ourDb;
  }
  Future<List<oneShot>> readRows() async {
    DatabaseHelper con = new DatabaseHelper();
    var db = await con.db;
    List<Map<String, dynamic>> maps = await db.rawQuery(
        '''SELECT * FROM oneShot''');
    return List.generate(maps.length, (i) {
      return oneShot(
          id: maps[i]['id'],
          username: maps[i]['username'],
          pulse: maps[i]['pulse'],
          spo2: maps[i]['spo2'],
          temp: maps[i]['temp'],
          pres: maps[i]['pres'],
          timestamp: maps[i]['timestamp']
      );
    });
  }
  Future<List<oneShot>> read_last100_records() async {
    DatabaseHelper con = new DatabaseHelper();
    var db = await con.db;
    List<Map<String, dynamic>> maps =
    await db.rawQuery('''SELECT *
FROM
(
    SELECT *
    FROM oneShot
    ORDER BY id DESC
    LIMIT 100
) t
ORDER BY t.id''');
    return List.generate(maps.length, (i) {
      return oneShot(
          id: maps[i]['id'],
          username: maps[i]['username'],
          pulse: maps[i]['pulse'],
          spo2: maps[i]['spo2'],
          temp: maps[i]['temp'],
          pres: maps[i]['pres'],
          timestamp: maps[i]['timestamp']);
    });
  }
  /*
   readMap() async {
    // Get a reference to the database.
    DatabaseHelper con = new DatabaseHelper();
    var db = await con.db;
    // Query the table for all The records.
    List<Map<String, dynamic>> maps = await db.rawQuery(
        '''SELECT * FROM oneShot''');
    //return await db.rawQuery('''SELECT * FROM $table WHERE $columnDate BETWEEN '$twoDaysAgo' AND '$today''');
    // Convert the List<Map<String, dynamic> into a List<Dog>.
    return maps;
  }
  */
}