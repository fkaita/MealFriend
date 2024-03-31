import 'package:flutter/material.dart';
import 'package:mealfriend/db/database_helper.dart';
import 'package:mealfriend/models/meal_time_data.dart';
import 'package:mealfriend/screens/timer_page.dart';

class RecordPage extends StatefulWidget {
  const RecordPage({super.key});

  @override
  State<StatefulWidget> createState() => RecordPageState();
}

class RecordPageState extends State<RecordPage> {
  Map<String, String> avgMonthlyMealTime = {};
  List<dynamic> itemsForDisplay = [];
  int maxMealTimeInSecond = 60;
  late DatabaseHelper dbHelper;

  @override
  void initState() {
    super.initState();
    dbHelper = DatabaseHelper();
    fetchMealTimeDataList();
  }

  void fetchMealTimeDataList() async {
    // initialize the variables
    avgMonthlyMealTime = {};
    itemsForDisplay = [];
    maxMealTimeInSecond = 60;

    // // Operations for dummy data
    // // Create dummy data
    // final random = Random();
    // List<MealTimeData> dummyDataList = List<MealTimeData>.generate(
    //   50,
    //   (index) => MealTimeData(
    //     createdTime: DateTime.now().subtract(Duration(days: index * 2)),
    //     mealTimeInSecond: (random.nextDouble() * 180 + 600)
    //         .round(), // 10 minutes increment for each dummy data
    //   ),
    // );
    // // insert dummy data into db
    // for (var item in dummyDataList) {
    //   await dbHelper.insertMealTimeData(item);
    // }

    // From here, normal operations without dummy data
    // get data from db
    final mealTimeDataList = await dbHelper.getMealTimeDataList();

    // When data exists
    if (mealTimeDataList.isNotEmpty) {
      // Finding the max mealTimeInSecond for given list
      maxMealTimeInSecond = mealTimeDataList
          .reduce((currentMax, next) =>
              next.mealTimeInSecond > currentMax.mealTimeInSecond
                  ? next
                  : currentMax)
          .mealTimeInSecond;

      // Get mean for each month
      String lastMonthYear = "";
      List<MealTimeData> itemsInLastMonth = [];
      // Iterate through the list to calculate the average mealTimeInSecond for each month
      for (var item in mealTimeDataList) {
        String monthYear = '${item.createdTime.month}-${item.createdTime.year}';
        if (monthYear != lastMonthYear) {
          itemsForDisplay.add({
            'month_year': monthYear,
          });

          if (lastMonthYear != "") {
            // Calculate the average mealTimeInSecond for the items in the last month
            double averageMealTimeInSecond = itemsInLastMonth.fold(
                    0, (sum, item) => sum + item.mealTimeInSecond) /
                itemsInLastMonth.length;
            avgMonthlyMealTime[lastMonthYear] =
                (averageMealTimeInSecond / 60).toStringAsFixed(1);
            itemsInLastMonth = [];
          }

          lastMonthYear = monthYear;
        }
        // add item for calculate average.
        itemsInLastMonth.add(item);

        // add item for display
        itemsForDisplay.add(item);
      }

      // Average for the last month
      double averageMealTimeInSecond =
          itemsInLastMonth.fold(0, (sum, item) => sum + item.mealTimeInSecond) /
              itemsInLastMonth.length;
      avgMonthlyMealTime[lastMonthYear] =
          (averageMealTimeInSecond / 60).toStringAsFixed(1);
    }

    // Set data for display
    setState(() {
      itemsForDisplay = itemsForDisplay;
      avgMonthlyMealTime = avgMonthlyMealTime;
      maxMealTimeInSecond = maxMealTimeInSecond;
    });
  }

  // Function to navigate to TimerPage
  void navigateToTimerPage() {
    // Remove dummy data
    setState(() {
      itemsForDisplay.clear();
      // when dummy data exist, delete all items here
      // dbHelper.deleteAllItems();
    });

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TimerPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Record Page'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: navigateToTimerPage,
        ),
      ),
      body: itemsForDisplay.isEmpty
          ? Center(
              child: Text('No record exists.'),
            )
          : ListView.separated(
              itemCount: itemsForDisplay.length,
              itemBuilder: (context, index) {
                var item = itemsForDisplay[index];
                if (item is Map) {
                  return ListTile(
                    // Display month and average meal time for the month
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(item['month_year']),
                        Text(avgMonthlyMealTime[item['month_year']] ?? 'nan'),
                      ],
                    ),
                  );
                } else {
                  // Display horizontal bar graph for each meal time
                  return ListTile(
                    visualDensity: VisualDensity(horizontal: 0, vertical: -2),
                    // ask user to delete data when long press
                    onLongPress: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Confirm Delete'),
                            content: Text(
                                'Are you sure you want to delete this item?'),
                            actions: <Widget>[
                              TextButton(
                                child: Text('Cancel'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                              TextButton(
                                child: Text('Delete'),
                                onPressed: () {
                                  // Code to delete the corresponding data
                                  dbHelper.deleteMealTimeData(item.id);
                                  // Fetch the data again
                                  fetchMealTimeDataList();
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                    title: Row(
                      children: [
                        // Display day of the month
                        Container(
                          width: 30,
                          padding: EdgeInsets.only(right: 5),
                          child: Text(
                            item.createdTime.day.toString(),
                            textAlign: TextAlign.right,
                          ),
                        ),
                        // Display horizontal bar graph
                        ClipRRect(
                            borderRadius: BorderRadius.circular(4.0),
                            child: Container(
                                height: 30,
                                width: (item.mealTimeInSecond) /
                                    maxMealTimeInSecond * // Standardize the data by max
                                    0.6 *
                                    MediaQuery.of(context).size.width,
                                color: Colors.blue)),
                        // Display meal time in minutes
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(left: 8.0),
                            child: Text((item.mealTimeInSecond / 60)
                                .toStringAsFixed(1)),
                          ),
                        ),
                      ],
                    ),
                  );
                }
              },
              separatorBuilder: (context, index) =>
                  Container(), // Set height to 1
            ),
    );
  }
}
