import 'dart:math';
import 'package:flutter/material.dart';
import 'package:mealfriend/db/database_helper.dart';
import 'package:mealfriend/models/meal_time_data.dart';
import 'package:mealfriend/screens/timer_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:fl_chart/fl_chart.dart';
// import 'package:intl/intl.dart';

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
    // final mealTimeDataList = await dbHelper.getMealTimeDataList();
    // setState(() {
    //   mealTimeDataList = list;
    // });

    // Get shared pref to check dummy data was already exist or not
    final prefs = await SharedPreferences.getInstance();
    final dummyDataCreated = prefs.getBool('dummyDataCreated') ?? false;

    // Create dummy data if it doesn't exist
    if (!dummyDataCreated) {
      final random = Random();
      List<MealTimeData> dummyDataList = List<MealTimeData>.generate(
        50,
        (index) => MealTimeData(
          createdTime: DateTime.now().subtract(Duration(days: index * 2)),
          mealTimeInSecond: (random.nextDouble() * 3 + 10)
              .round(), // 10 minutes increment for each dummy data
        ),
      );

      // insert dummy data into db
      for (var item in dummyDataList) {
        await dbHelper.insertMealTimeData(item);
      }

      // Set the flag to indicate that the dummy data has been created
      await prefs.setBool('dummyDataCreated', true);
    }

    // get data from db
    final mealTimeDataList = await dbHelper.getMealTimeDataList();

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
              averageMealTimeInSecond.toStringAsFixed(1);
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
        averageMealTimeInSecond.toStringAsFixed(1);

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
      body: ListView.separated(
        itemCount: itemsForDisplay.length,
        itemBuilder: (context, index) {
          var item = itemsForDisplay[index];
          if (item is Map) {
            return ListTile(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(item['month_year']),
                  Text(avgMonthlyMealTime[item['month_year']] ?? 'nan'),
                ],
              ),
            );
          } else {
            return ListTile(
              visualDensity: VisualDensity(horizontal: 0, vertical: -2),
              title: Row(
                children: [
                  Container(
                    width: 30,
                    padding: EdgeInsets.only(right: 5),
                    child: Text(
                      item.createdTime.day.toString(),
                      textAlign: TextAlign.right,
                    ),
                  ),
                  ClipRRect(
                      borderRadius: BorderRadius.circular(4.0),
                      child: Container(
                          height: 30,
                          width: (item.mealTimeInSecond) /
                              maxMealTimeInSecond * // Standardize the data by max
                              0.6 *
                              MediaQuery.of(context).size.width,
                          color: Colors.blue)),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(left: 8.0),
                      child: Text(item.mealTimeInSecond.toString()),
                    ),
                  ),
                ],
              ),
            );
          }
        },
        separatorBuilder: (context, index) => Container(), // Set height to 1
      ),
    );
  }
}

// class _BarChart extends StatelessWidget {
//   final List<MealTimeData> mealTimeDataList;

//   _BarChart({required this.mealTimeDataList});

//   @override
//   Widget build(BuildContext context) {
//     return BarChart(
//       BarChartData(
//         barTouchData: barTouchData,
//         titlesData: titlesData,
//         borderData: borderData,
//         barGroups: barGroups,
//         gridData: const FlGridData(show: false),
//         alignment: BarChartAlignment.spaceAround,
//         maxY: 20,
//       ),
//     );
//   }

//   BarTouchData get barTouchData => BarTouchData(
//         enabled: false,
//         touchTooltipData: BarTouchTooltipData(
//           tooltipBgColor: Colors.transparent,
//           tooltipPadding: EdgeInsets.zero,
//           tooltipMargin: 8,
//           getTooltipItem: (
//             BarChartGroupData group,
//             int groupIndex,
//             BarChartRodData rod,
//             int rodIndex,
//           ) {
//             return BarTooltipItem(
//               rod.toY.round().toString(),
//               const TextStyle(
//                 color: Colors.blue,
//                 fontWeight: FontWeight.bold,
//               ),
//             );
//           },
//         ),
//       );

//   Widget getTitles(double value, TitleMeta meta) {
//     final style = TextStyle(
//       color: Colors.blue,
//       fontWeight: FontWeight.bold,
//       fontSize: 14,
//     );
//     String text;
//     switch (value.toInt()) {
//       case 0:
//         text = 'Mn';
//         break;
//       case 1:
//         text = 'Te';
//         break;
//       case 2:
//         text = 'Wd';
//         break;
//       case 3:
//         text = 'Tu';
//         break;
//       case 4:
//         text = 'Fr';
//         break;
//       case 5:
//         text = 'St';
//         break;
//       case 6:
//         text = 'Sn';
//         break;
//       default:
//         text = '';
//         break;
//     }
//     return SideTitleWidget(
//       axisSide: meta.axisSide,
//       space: 4,
//       child: Text(text, style: style),
//     );
//   }

//   FlTitlesData get titlesData => FlTitlesData(
//         show: true,
//         bottomTitles: AxisTitles(
//           sideTitles: SideTitles(
//             showTitles: true,
//             reservedSize: 30,
//             getTitlesWidget: getTitles,
//           ),
//         ),
//         leftTitles: const AxisTitles(
//           sideTitles: SideTitles(showTitles: false),
//         ),
//         topTitles: const AxisTitles(
//           sideTitles: SideTitles(showTitles: false),
//         ),
//         rightTitles: const AxisTitles(
//           sideTitles: SideTitles(showTitles: false),
//         ),
//       );

//   FlBorderData get borderData => FlBorderData(
//         show: false,
//       );

//   LinearGradient get _barsGradient => LinearGradient(
//         colors: [
//           Colors.blueGrey,
//           Colors.blue,
//         ],
//         begin: Alignment.bottomCenter,
//         end: Alignment.topCenter,
//       );

//   List<BarChartGroupData> get barGroups {
//     return mealTimeDataList.asMap().entries.map((entry) {
//       final createdTime = entry.value.createdTime;
//       final mealTimeInSecond = entry.value.mealTimeInSecond;
//       int dayOfWeek = createdTime.weekday;
//       return BarChartGroupData(
//         x: dayOfWeek,
//         barRods: [
//           BarChartRodData(
//             toY: mealTimeInSecond.toDouble(),
//             gradient: _barsGradient,
//           )
//         ],
//         showingTooltipIndicators: [0],
//       );
//     }).toList();
//   }
// }
