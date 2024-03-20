import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:mealfriend/db/DatabaseHelper.dart';
import 'package:mealfriend/model/meal_time_data.dart';

void main() {
  // Initialize FFI
  sqfliteFfiInit();

  // Use sqflite_ffi for tests
  databaseFactory = databaseFactoryFfi;

  group('DatabaseHelper Tests', () {
    late DatabaseHelper dbHelper;

    setUp(() {
      dbHelper = DatabaseHelper();
    });

    test('Test DatabaseHelper for single data', () async {
      // Test insertMealTimeData
      final mealTimeData = MealTimeData(
        id: 1,
        createdTime: DateTime.now(),
        mealTimeInSecond: 3600,
      );
      await dbHelper.insertMealTimeData(mealTimeData);

      // Test getMealTimeDataList
      final list = await dbHelper.getMealTimeDataList();
      expect(list.length, 1);
      expect(list[0].id, mealTimeData.id);
      expect(list[0].createdTime, mealTimeData.createdTime);
      expect(list[0].mealTimeInSecond, mealTimeData.mealTimeInSecond);

      // Test updateMealTimeData
      mealTimeData.mealTimeInSecond = 7200;
      await dbHelper.updateMealTimeData(mealTimeData);
      final updatedList = await dbHelper.getMealTimeDataList();
      expect(updatedList[0].mealTimeInSecond, 7200);

      // Test deleteMealTimeData
      await dbHelper.deleteMealTimeData(mealTimeData.id);
      final emptyList = await dbHelper.getMealTimeDataList();
      expect(emptyList.isEmpty, true);
    });

    test('Test DatabaseHelper for multiple inputs', () async {
      // Test insertMealTimeData with multiple entries
      final mealTimeData1 = MealTimeData(
        createdTime: DateTime.now(),
        mealTimeInSecond: 3600,
      );
      await dbHelper.insertMealTimeData(mealTimeData1);

      final mealTimeData2 = MealTimeData(
        createdTime: DateTime.now().add(Duration(hours: 1)),
        mealTimeInSecond: 7200,
      );
      await dbHelper.insertMealTimeData(mealTimeData2);

      // Test getMealTimeDataList
      final list = await dbHelper.getMealTimeDataList();
      expect(list.length, 2);

      // Check the properties of the first MealTimeData
      expect(list[0].createdTime, mealTimeData1.createdTime);
      expect(list[0].mealTimeInSecond, mealTimeData1.mealTimeInSecond);

      // Check the properties of the second MealTimeData
      expect(list[1].createdTime, mealTimeData2.createdTime);
      expect(list[1].mealTimeInSecond, mealTimeData2.mealTimeInSecond);
    });
  });

  // Delete the database after all tests have completed
  setUpAll(() async {
    // Delete the database after all tests
    await deleteDatabase(
        join(await getDatabasesPath(), '${MealTimeData.tableName}.db'));
  });
}
