class MealTimeData {
  static const String tableName = 'meal_time_data';
  static const String colId = '_id';
  static const String colCreatedTime = 'created_time';
  static const String colMealTimeInSecond = 'meal_time_in_second';

  int? id;
  DateTime createdTime;
  int mealTimeInSecond;

  MealTimeData(
      {this.id, required this.createdTime, required this.mealTimeInSecond});

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'created_time': createdTime.toString(),
      'meal_time_in_second': mealTimeInSecond
    };
  }
}
