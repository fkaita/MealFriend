import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:mealfriend/models/meal_time_data.dart';

class DatabaseHelper {
  static DatabaseHelper? _databaseHelper;
  static Database? _database;

  DatabaseHelper._createInstance();

  factory DatabaseHelper() {
    if (_databaseHelper == null) {
      _databaseHelper = DatabaseHelper._createInstance();
    }
    return _databaseHelper!;
  }

  Future<Database> get database async {
    if (_database == null) {
      _database = await initializeDatabase();
    }
    return _database!;
  }

  Future<Database> initializeDatabase() async {
    String path =
        join(await getDatabasesPath(), '${MealTimeData.tableName}.db');
    return openDatabase(path, version: 1, onCreate: _createDb);
  }

  void _createDb(Database db, int newVersion) async {
    await db.execute('''
      CREATE TABLE ${MealTimeData.tableName} (
        ${MealTimeData.colId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${MealTimeData.colCreatedTime} TEXT NOT NULL,
        ${MealTimeData.colMealTimeInSecond} INTEGER NOT NULL
      )
    ''');
  }

  Future<int> insertMealTimeData(MealTimeData mealTimeData) async {
    Database db = await this.database;
    // Remove the id field from the map before inserting
    var map = mealTimeData.toMap();
    map.remove(MealTimeData.colId);
    return await db.insert(MealTimeData.tableName, mealTimeData.toMap());
  }

  Future<List<MealTimeData>> getMealTimeDataList() async {
    Database db = await this.database;
    List<Map<String, dynamic>> maps = await db.query(MealTimeData.tableName);
    return List.generate(maps.length, (i) {
      return MealTimeData(
        id: maps[i][MealTimeData.colId],
        createdTime: DateTime.parse(maps[i][MealTimeData.colCreatedTime]),
        mealTimeInSecond: maps[i][MealTimeData.colMealTimeInSecond],
      );
    });
  }

  Future<int> updateMealTimeData(MealTimeData mealTimeData) async {
    Database db = await this.database;
    return await db.update(MealTimeData.tableName, mealTimeData.toMap(),
        where: '${MealTimeData.colId} = ?', whereArgs: [mealTimeData.id]);
  }

  Future<int> deleteMealTimeData(int? id) async {
    Database db = await this.database;
    return await db.delete(MealTimeData.tableName,
        where: '${MealTimeData.colId} = ?', whereArgs: [id]);
  }

  Future<void> deleteDB() async {
    final db = await this.database;
    await db.close();

    String path =
        join(await getDatabasesPath(), '${MealTimeData.tableName}.db');

    await deleteDatabase(path);
  }
}
