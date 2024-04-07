import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mealfriend/screens/record_page.dart';
import 'package:mealfriend/models/meal_time_data.dart';
import 'package:mealfriend/db/database_helper.dart';
import 'package:watch_connectivity/watch_connectivity.dart';
// TODO: Build connection between Android and watch

class TimerPage extends StatefulWidget {
  const TimerPage({super.key});

  @override
  _TimerPageState createState() => _TimerPageState();
}

enum TimerState { initial, started, paused }

class _TimerPageState extends State<TimerPage> {
  int seconds = 0;
  int _imageIndex = 0;
  int maxSeconds = 60 * 20; // 20 minutes by default
  TimerState timerState = TimerState.initial;
  Timer? _timer; // Timer for counting seconds
  Timer? _imageTimer; // Timer for animation
  late DatabaseHelper dbHelper;

  // Make list of svg images
  final List<String> _svgAssets = [
    'assets/images/eatingFace1.svg',
    'assets/images/eatingFace2.svg',
    'assets/images/eatingFace3.svg',
  ];

  // Set Connection with watch
  final _watch = WatchConnectivity();

  Future<void> sendMessage(String txt) async {
    var _reachable = await _watch.isReachable;
    if (_reachable) {
      print("Reachable!");
      await _watch.sendMessage({"data": txt});
    } else {
      print("Watch is not reachable");
    }
  }

  // Function to navigate to RecordPage
  void navigateToRecordPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RecordPage()),
    );
  }

  @override
  void initState() {
    super.initState();
    _watch.messageStream
        .listen((e) => setState(() => print('Received message: $e')));

    _watch.contextStream
        .listen((e) => setState(() => print('Received context: $e')));
  }

  void startTimer() {
    sendMessage("Hello World!");
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        seconds++;
      });
    });
    setState(() {
      timerState = TimerState.started;
    });
    startImageTimer();
  }

  void startImageTimer() {
    // For animation
    final random = Random();
    const meanSeconds = 1;
    const stdDevSeconds = 0.5;

    // Generate a random duration with normal distribution
    Duration randomDuration = Duration(
        milliseconds:
            ((random.nextDouble() * stdDevSeconds + meanSeconds) * 1000)
                .round());
    _imageTimer = Timer(randomDuration, () {
      if (seconds / maxSeconds < 1.0) {
        setState(() {
          _imageIndex = (_imageIndex + 1) % _svgAssets.length;
        });
      }
      startImageTimer(); // Start timer again for the next image change
    });
  }

  void pauseTimer() {
    _timer?.cancel();
    _imageTimer?.cancel();
    setState(() {
      timerState = TimerState.paused;
    });
  }

  void finishTimer() {
    // Stop timer
    _timer?.cancel();
    _imageTimer?.cancel();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Save Time'),
          content: Text('Do you want to save this time?'),
          actions: <Widget>[
            TextButton(
              child: Text('Discard'),
              onPressed: () {
                // Code to discard the timer
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Save'),
              onPressed: () {
                // Save time to db
                dbHelper = DatabaseHelper();
                final mealTimeData = MealTimeData(
                  createdTime: DateTime.now(),
                  mealTimeInSecond: seconds,
                );
                dbHelper.insertMealTimeData(mealTimeData);
                print(seconds.toString() + " second is saved");
                Navigator.of(context).pop();
                navigateToRecordPage();
              },
            ),
          ],
        );
      },
    ).then((_) {
      // Reset timer
      setState(() {
        seconds = 0;
        _imageIndex = 0;
        timerState = TimerState.initial;
      });
    });
  }

  Future<void> _showMyDialog() async {
    final result = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('Select time for a meal'),
          children: <Widget>[
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, "15");
              },
              child: const Text('15 minutes'),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, "20");
              },
              child: const Text('20 minutes'),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, "25");
              },
              child: const Text('25 minutes'),
            ),
          ],
        );
      },
    );
    // Change target time length
    if (result != null) {
      setState(() {
        maxSeconds = int.parse(result) * 60;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Timer Page'),
          automaticallyImplyLeading: false,
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.navigate_next),
              onPressed: navigateToRecordPage,
            ),
          ],
        ),
        body: SafeArea(
          child: Center(
            child: Column(
              children: [
                Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  IconButton(
                    icon: const Icon(Icons.av_timer_outlined),
                    iconSize: 24,
                    padding: const EdgeInsets.all(8.0),
                    onPressed: () {
                      _showMyDialog();
                    },
                  )
                ]),
                Expanded(
                  child: SvgPicture.asset(
                    _svgAssets[_imageIndex],
                    width: 200, // Adjust width and height as needed
                    height: 200,
                  ),
                ),
                LinearProgressIndicator(
                  value: seconds / maxSeconds,
                  minHeight: 12,
                ),
                const SizedBox(
                  height: 24,
                ),
                Text(
                  '$seconds',
                  style: const TextStyle(fontSize: 24),
                ),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                          onPressed: () {
                            if (timerState == TimerState.started) {
                              pauseTimer();
                            } else {
                              startTimer();
                            }
                          },
                          child: Text(timerState == TimerState.started
                              ? 'Pause'
                              : timerState == TimerState.paused
                                  ? 'Restart'
                                  : 'Start')),
                      if (timerState != TimerState.initial)
                        ElevatedButton(
                            onPressed: () {
                              finishTimer();
                            },
                            child: const Text('Finish'))
                    ]),
                const SizedBox(
                  height: 24,
                )
              ],
            ),
          ),
        ));
  }
}
