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
  int _currentIndex = 0;
  final int maxSeconds = 600;
  TimerState timerState = TimerState.initial;
  Timer? _timer;
  Timer? _imageTimer;
  bool _isPaused = false;

  // Make list of svg images
  List<String> _svgAssets = [
    'assets/images/eatingFace1.svg',
    'assets/images/eatingFace2.svg',
    'assets/images/eatingFace3.svg',
  ];

  @override
  void initState() {
    super.initState();
    startImageTimer();
    startTimer();
  }

  void startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        seconds++;
      });
    });
    setState(() {
      timerState = TimerState.started;
    });
  }

  void startImageTimer() {
    // For animation
    final random = Random();
    final meanSeconds = 1;
    final stdDevSeconds = 0.5;

    // Generate a random duration with normal distribution
    Duration randomDuration = Duration(
        milliseconds:
            ((random.nextDouble() * stdDevSeconds + meanSeconds) * 1000)
                .round());
    _imageTimer = Timer(randomDuration, () {
      if (!_isPaused) {
        setState(() {
          _currentIndex = (_currentIndex + 1) % _svgAssets.length;
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
      _currentIndex = 0;
      timerState = TimerState.initial;
      // Go to next stage here
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Expanded(
              child: SvgPicture.asset(
                _svgAssets[_currentIndex],
                width: 300, // Adjust width and height as needed
                height: 300,
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
                      startImageTimer();
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
              height: 48,
            )
          ],
        ),
      ),
    );
  }
}
