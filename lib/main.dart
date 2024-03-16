import 'dart:async';

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

void main() {
  runApp(MainApp());
}

class MainApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: TimerPage(),
    );
  }
}

class TimerPage extends StatefulWidget {
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

  // Make list of svg images
  final List<String> _svgAssets = [
    'assets/images/eatingFace1.svg',
    'assets/images/eatingFace2.svg',
    'assets/images/eatingFace3.svg',
  ];

  // @override
  // void initState() {
  //   super.initState();
  //   startImageTimer();
  //   startTimer();
  // }

  void startTimer() {
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
    _timer?.cancel();
    _imageTimer?.cancel();
    setState(() {
      seconds = 0;
      _imageIndex = 0;
      timerState = TimerState.initial;
      // TODO: Go to next stage here -> Record time
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
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
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
