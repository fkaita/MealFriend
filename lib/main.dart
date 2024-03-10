import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

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
  final int maxSeconds = 600;
  TimerState timerState = TimerState.initial;
  Timer? timer;

  void startTimer() {
    timer = Timer.periodic(Duration(seconds: 1), (_) {
      setState(() {
        seconds++;
      });
    });
    setState(() {
      timerState = TimerState.started;
    });
  }

  void pauseTimer() {
    timer?.cancel();
    setState(() {
      timerState = TimerState.paused;
    });
  }

  void finishTimer() {
    timer?.cancel();
    setState(() {
      seconds = 0;
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
            Expanded(child: Placeholder()),
            LinearProgressIndicator(
              value: seconds / maxSeconds,
              minHeight: 12,
            ),
            SizedBox(
              height: 24,
            ),
            Text(
              '$seconds',
              style: TextStyle(fontSize: 24),
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
                    child: Text('Finish'))
            ]),
            SizedBox(
              height: 48,
            )
          ],
        ),
      ),
    );
  }
}
