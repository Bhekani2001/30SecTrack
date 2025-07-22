import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/location_model.dart';

class LocationRepository {
  static const String _tableName = 'locations';
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'locations.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_tableName(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            latitude REAL,
            longitude REAL,
            accuracy REAL,
            timestamp TEXT
          )
        ''');
      },
    );
  }

  Future<void> saveLocation(LocationModel location) async {
    final db = await database;
    await db.insert(
      _tableName,
      location.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<LocationModel>> getLocationHistory() async {
    final db = await database;
    final maps = await db.query(_tableName, orderBy: 'timestamp DESC');
    return maps.map((map) => LocationModel.fromMap(map)).toList();
  }

  Future<void> clearHistory() async {
    final db = await database;
    await db.delete(_tableName);
  }
}
